import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SubmitQuizAnswerResult {
  final int pointsEarned;
  final bool alreadyAnswered;
  final bool isCorrect;

  const SubmitQuizAnswerResult({
    required this.pointsEarned,
    required this.alreadyAnswered,
    required this.isCorrect,
  });
}

class SubmitChallengeResult {
  final int pointsEarned;
  final bool alreadyCompleted;
  final String? photoUrl;

  const SubmitChallengeResult({
    required this.pointsEarned,
    required this.alreadyCompleted,
    required this.photoUrl,
  });
}

class GamificationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  String _normalizeAnswer(String v) => v.trim().toLowerCase();

  Future<int> _awardOnce({
    required String eventId,
    required int points,
    required Map<String, dynamic> eventData,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final userRef = _firestore.collection('users').doc(userId);
    final eventRef = userRef.collection('points_events').doc(eventId);

    return _firestore.runTransaction((tx) async {
      final eventSnap = await tx.get(eventRef);
      if (eventSnap.exists) {
        return 0;
      }

      final userSnap = await tx.get(userRef);
      final Map<String, dynamic> userData =
          (userSnap.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
      final currentPoints = (userData['totalPoints'] as num?)?.toInt() ?? 0;
      final newTotalPoints = currentPoints + points;
      final newLevel = (newTotalPoints ~/ 500) + 1;

      if (!userSnap.exists) {
        tx.set(
          userRef,
          {
            'totalPoints': newTotalPoints,
            'level': newLevel,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        tx.update(userRef, {
          'totalPoints': newTotalPoints,
          'level': newLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      tx.set(eventRef, {
        'userId': userId,
        'eventId': eventId,
        'pointsEarned': points,
        ...eventData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _triggerBadgeCheck(tx: tx, userRef: userRef, totalPoints: newTotalPoints);

      return points;
    });
  }

  Future<int> awardBookingPoints({required String packageId}) {
    return _awardOnce(
      eventId: 'booking_$packageId',
      points: 10,
      eventData: {
        'type': 'booking',
        'packageId': packageId,
      },
    );
  }

  Future<int> awardSaveTourPoints({required String packageId}) {
    return _awardOnce(
      eventId: 'save_$packageId',
      points: 2,
      eventData: {
        'type': 'save',
        'packageId': packageId,
      },
    );
  }

  Future<int> awardRatingPoints({required String packageId}) {
    return _awardOnce(
      eventId: 'rating_$packageId',
      points: 5,
      eventData: {
        'type': 'rating',
        'packageId': packageId,
      },
    );
  }

  Future<int> awardTourCompletionPoints({required String packageId}) async {
    final tourSnap = await _firestore.collection('tourPackages').doc(packageId).get();
    if (!tourSnap.exists) {
      return 0;
    }

    final data = tourSnap.data();
    final live = data?['liveTourState'] as Map<String, dynamic>?;
    final ended = (live?['ended'] as bool?) ?? false;
    if (!ended) {
      return 0;
    }

    return _awardOnce(
      eventId: 'tour_complete_$packageId',
      points: 20,
      eventData: {
        'type': 'tour_completion',
        'packageId': packageId,
      },
    );
  }

  Future<int> validateTourCompletionEventsAndRecompute({
    String? userId,
    bool force = false,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final userRef = _firestore.collection('users').doc(uid);

    if (!force) {
      final userSnap = await userRef.get();
      if (userSnap.exists) {
        final data = userSnap.data();
        if (data?['tourCompletionValidatedAt'] != null) {
          return (data?['totalPoints'] as num?)?.toInt() ?? 0;
        }
      }
    }

    final eventsSnap = await userRef
        .collection('points_events')
        .where('type', isEqualTo: 'tour_completion')
        .get();

    final quizSnap = await userRef.collection('quiz_attempts').get();
    final Map<String, Set<String>> completedActivitiesByPackage = {};
    for (final d in quizSnap.docs) {
      final data = d.data();
      final packageId = (data['packageId'] ?? '').toString();
      final activityId = (data['activityId'] ?? '').toString();
      if (packageId.isEmpty || activityId.isEmpty) continue;
      completedActivitiesByPackage
          .putIfAbsent(packageId, () => <String>{})
          .add(activityId);
    }

    final List<DocumentReference<Map<String, dynamic>>> toDelete = [];

    for (final evDoc in eventsSnap.docs) {
      final data = evDoc.data();
      final packageId = (data['packageId'] ?? '').toString();
      if (packageId.isEmpty) {
        toDelete.add(evDoc.reference);
        continue;
      }

      final tourSnap = await _firestore.collection('tourPackages').doc(packageId).get();
      if (!tourSnap.exists) {
        toDelete.add(evDoc.reference);
        continue;
      }

      final tourData = tourSnap.data() as Map<String, dynamic>;
      final live = tourData['liveTourState'] as Map<String, dynamic>?;
      final ended = (live?['ended'] as bool?) ?? false;
      final activities = (tourData['activities'] as List<dynamic>?) ?? const [];
      final totalActivities = activities.length;

      final completedIds = completedActivitiesByPackage[packageId] ?? <String>{};
      final completedAll = totalActivities > 0 && completedIds.length >= totalActivities;

      if (!ended || !completedAll) {
        toDelete.add(evDoc.reference);
      }
    }

    if (toDelete.isNotEmpty) {
      const batchLimit = 400;
      for (var i = 0; i < toDelete.length; i += batchLimit) {
        final batch = _firestore.batch();
        final end = (i + batchLimit) > toDelete.length ? toDelete.length : (i + batchLimit);
        for (var j = i; j < end; j++) {
          batch.delete(toDelete[j]);
        }
        await batch.commit();
      }
    }

    final total = await recomputeAndSyncTotalPoints(userId: uid, force: true);

    await userRef.set(
      {
        'tourCompletionValidatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return total;
  }

  Future<int> recomputeAndSyncTotalPoints({
    String? userId,
    bool force = false,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final userRef = _firestore.collection('users').doc(uid);

    if (!force) {
      final userSnap = await userRef.get();
      if (userSnap.exists) {
        final data = userSnap.data();
        if (data?['pointsReconciledAt'] != null) {
          return (data?['totalPoints'] as num?)?.toInt() ?? 0;
        }
      }
    }

    int sum = 0;

    final quizSnap = await userRef.collection('quiz_attempts').get();
    for (final d in quizSnap.docs) {
      sum += (d.data()['pointsEarned'] as num?)?.toInt() ?? 0;
    }

    final eventsSnap = await userRef.collection('points_events').get();
    for (final d in eventsSnap.docs) {
      sum += (d.data()['pointsEarned'] as num?)?.toInt() ?? 0;
    }

    final computedLevel = (sum ~/ 500) + 1;

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = (snap.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
      final current = (data['totalPoints'] as num?)?.toInt() ?? 0;
      final currentLevel = (data['level'] as num?)?.toInt();

      final payload = <String, dynamic>{
        'totalPoints': sum,
        'level': computedLevel,
        'updatedAt': FieldValue.serverTimestamp(),
        'pointsReconciledAt': FieldValue.serverTimestamp(),
      };

      if (!snap.exists) {
        tx.set(
          userRef,
          {
            ...payload,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        return;
      }

      if (current != sum || currentLevel != computedLevel) {
        tx.update(userRef, payload);
      } else {
        tx.update(userRef, {
          'pointsReconciledAt': FieldValue.serverTimestamp(),
        });
      }
    });

    return sum;
  }

  Future<int> cleanupChallengeAttempts({
    String? userId,
    bool force = false,
  }) async {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    final userRef = _firestore.collection('users').doc(uid);
    if (!force) {
      final userSnap = await userRef.get();
      if (userSnap.exists) {
        final data = userSnap.data();
        if (data?['challengeAttemptsCleanedAt'] != null) {
          return 0;
        }
      }
    }

    final attemptsRef = userRef.collection('challenge_attempts');
    final snap = await attemptsRef.get();

    final storagePaths = <String>[];
    final refsToDelete = <DocumentReference<Map<String, dynamic>>>[];
    for (final d in snap.docs) {
      refsToDelete.add(d.reference);
      final storagePath = (d.data()['storagePath'] ?? '').toString().trim();
      if (storagePath.isNotEmpty) {
        storagePaths.add(storagePath);
      }
    }

    var deletedCount = 0;
    const batchLimit = 400;
    for (var i = 0; i < refsToDelete.length; i += batchLimit) {
      final batch = _firestore.batch();
      final end = (i + batchLimit) > refsToDelete.length
          ? refsToDelete.length
          : (i + batchLimit);
      for (var j = i; j < end; j++) {
        batch.delete(refsToDelete[j]);
      }
      await batch.commit();
      deletedCount += (end - i);
    }

    for (final p in storagePaths) {
      try {
        await _storage.ref().child(p).delete();
      } catch (_) {
        // Ignore storage cleanup errors.
      }
    }

    await userRef.set(
      {
        'challengeAttemptsCleanedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return deletedCount;
  }

  Future<SubmitChallengeResult> submitPhotoChallenge({
    required String packageId,
    required String activityId,
    required XFile photo,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final locationId = '${packageId}_$activityId';

    final userRef = _firestore.collection('users').doc(userId);
    final attemptRef = userRef.collection('challenge_attempts').doc(locationId);

    final already = await attemptRef.get();
    if (already.exists) {
      return const SubmitChallengeResult(
        pointsEarned: 0,
        alreadyCompleted: true,
        photoUrl: null,
      );
    }

    final ext = (photo.name.split('.').lastOrNull ?? '').trim();
    final safeExt = ext.isEmpty ? 'jpg' : ext;
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.$safeExt';
    final storagePath =
        'users/$userId/challenges/$packageId/$activityId/$fileName';
    final ref = _storage.ref().child(storagePath);

    try {
      final bytes = await photo.readAsBytes();
      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/$safeExt'),
      );
      final url = await ref.getDownloadURL();

      final pointsToAward = 10;

      return _firestore.runTransaction((tx) async {
        final attemptSnap = await tx.get(attemptRef);
        if (attemptSnap.exists) {
          return const SubmitChallengeResult(
            pointsEarned: 0,
            alreadyCompleted: true,
            photoUrl: null,
          );
        }

        final userSnap = await tx.get(userRef);
        final userData =
            (userSnap.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
        final currentPoints = (userData['totalPoints'] as num?)?.toInt() ?? 0;
        final newTotalPoints = currentPoints + pointsToAward;
        final newLevel = (newTotalPoints ~/ 500) + 1;

        if (!userSnap.exists) {
          tx.set(
            userRef,
            {
              'totalPoints': newTotalPoints,
              'level': newLevel,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else {
          tx.update(userRef, {
            'totalPoints': newTotalPoints,
            'level': newLevel,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        tx.set(attemptRef, {
          'userId': userId,
          'packageId': packageId,
          'activityId': activityId,
          'locationId': locationId,
          'photoUrl': url,
          'storagePath': storagePath,
          'pointsEarned': pointsToAward,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _triggerBadgeCheck(
          tx: tx,
          userRef: userRef,
          totalPoints: newTotalPoints,
        );

        return SubmitChallengeResult(
          pointsEarned: pointsToAward,
          alreadyCompleted: false,
          photoUrl: url,
        );
      });
    } catch (e) {
      try {
        await ref.delete();
      } catch (_) {
        // ignore cleanup errors
      }
      rethrow;
    }
  }

  Future<SubmitQuizAnswerResult> submitQuizAnswer({
    required String packageId,
    required String activityId,
    required String answer,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final locationId = '${packageId}_$activityId';

    final userRef = _firestore.collection('users').doc(userId);
    final attemptRef = userRef.collection('quiz_attempts').doc(locationId);
    final packageRef = _firestore.collection('tourPackages').doc(packageId);

    return _firestore.runTransaction((tx) async {
      final attemptSnap = await tx.get(attemptRef);
      if (attemptSnap.exists) {
        return const SubmitQuizAnswerResult(
          pointsEarned: 0,
          alreadyAnswered: true,
          isCorrect: false,
        );
      }

      final packageSnap = await tx.get(packageRef);
      if (!packageSnap.exists) {
        throw Exception('Tour package not found');
      }

      final packageData = packageSnap.data() as Map<String, dynamic>;
      final activities = (packageData['activities'] as List<dynamic>?) ?? const [];

      Map<String, dynamic>? activity;
      for (final a in activities) {
        final m = (a as Map).cast<String, dynamic>();
        final id = (m['activityId'] as String?) ?? '';
        if (id == activityId) {
          activity = m;
          break;
        }
      }

      if (activity == null) {
        throw Exception('Activity not found');
      }

      final correctAnswerRaw = (activity['correctAnswer'] ?? '').toString();
      final options = (activity['answerOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[];

      String resolvedCorrectAnswer = correctAnswerRaw;
      final correctIndex = int.tryParse(correctAnswerRaw);
      if (correctIndex != null && correctIndex >= 0 && correctIndex < options.length) {
        resolvedCorrectAnswer = options[correctIndex];
      }

      final isCorrect = _normalizeAnswer(answer) ==
          _normalizeAnswer(resolvedCorrectAnswer);

      final userSnap = await tx.get(userRef);
      final userData =
          (userSnap.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
      final currentPoints = (userData['totalPoints'] as num?)?.toInt() ?? 0;

      const basePoints = 2;
      const correctBonusPoints = 8;
      final pointsEarned = isCorrect ? (basePoints + correctBonusPoints) : basePoints;
      final newTotalPoints = currentPoints + pointsEarned;

      final newLevel = (newTotalPoints ~/ 500) + 1;

      if (!userSnap.exists) {
        tx.set(
          userRef,
          {
            'totalPoints': newTotalPoints,
            'level': newLevel,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        tx.update(userRef, {
          'totalPoints': newTotalPoints,
          'level': newLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      tx.set(attemptRef, {
        'userId': userId,
        'packageId': packageId,
        'activityId': activityId,
        'locationId': locationId,
        'answer': answer,
        'correct': isCorrect,
        'correctAnswer': resolvedCorrectAnswer,
        'pointsEarned': pointsEarned,
        'basePoints': basePoints,
        'bonusPoints': isCorrect ? correctBonusPoints : 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _triggerBadgeCheck(tx: tx, userRef: userRef, totalPoints: newTotalPoints);

      return SubmitQuizAnswerResult(
        pointsEarned: pointsEarned,
        alreadyAnswered: false,
        isCorrect: isCorrect,
      );
    });
  }

  Future<void> _triggerBadgeCheck({
    required Transaction tx,
    required DocumentReference<Map<String, dynamic>> userRef,
    required int totalPoints,
  }) async {
    // Hook for future badge logic.
    // Intentionally no-op for now.
  }
}

extension _ListLastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
