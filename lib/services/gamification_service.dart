import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class LevelConfig {
  final int level;
  final String name;
  final String description;
  final int minPoints;

  const LevelConfig({
    required this.level,
    required this.name,
    required this.description,
    required this.minPoints,
  });
}

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

  static const List<LevelConfig> levels = [
    LevelConfig(
      level: 1,
      name: 'Starter',
      description: 'Beginning the journey',
      minPoints: 0,
    ),
    LevelConfig(
      level: 2,
      name: 'Explorer',
      description: 'Discovering new places',
      minPoints: 100,
    ),
    LevelConfig(
      level: 3,
      name: 'Traveler',
      description: 'Gaining travel experience',
      minPoints: 250,
    ),
    LevelConfig(
      level: 4,
      name: 'Adventurer',
      description: 'Exploring deeper experiences',
      minPoints: 450,
    ),
    LevelConfig(
      level: 5,
      name: 'Guide',
      description: 'Knows the paths well',
      minPoints: 700,
    ),
    LevelConfig(
      level: 6,
      name: 'Expert',
      description: 'Highly experienced traveler',
      minPoints: 1000,
    ),
    LevelConfig(
      level: 7,
      name: 'Master',
      description: 'Top level of achievement',
      minPoints: 1400,
    ),
  ];

  String? get currentUserId => _auth.currentUser?.uid;

  String _normalizeAnswer(String v) => v.trim().toLowerCase();

  LevelConfig getLevelFromPoints(int points) {
    LevelConfig current = levels.first;

    for (final level in levels) {
      if (points >= level.minPoints) {
        current = level;
      } else {
        break;
      }
    }

    return current;
  }

  LevelConfig? getNextLevelFromPoints(int points) {
    for (final level in levels) {
      if (points < level.minPoints) {
        return level;
      }
    }
    return null;
  }

  int getRemainingPointsToNextLevel(int points) {
    final next = getNextLevelFromPoints(points);
    if (next == null) return 0;
    return next.minPoints - points;
  }

  double getLevelProgress(int points) {
    final current = getLevelFromPoints(points);
    final next = getNextLevelFromPoints(points);

    if (next == null) return 1.0;

    final span = next.minPoints - current.minPoints;
    if (span <= 0) return 1.0;

    return ((points - current.minPoints) / span).clamp(0.0, 1.0);
  }

  Map<String, dynamic> getLevelSummary(int points) {
    final current = getLevelFromPoints(points);
    final next = getNextLevelFromPoints(points);

    return {
      'levelNumber': current.level,
      'levelName': current.name,
      'levelDescription': current.description,
      'currentMinPoints': current.minPoints,
      'nextLevelName': next?.name,
      'nextLevelPoints': next?.minPoints,
      'remainingPoints': getRemainingPointsToNextLevel(points),
      'progress': getLevelProgress(points),
      'isMaxLevel': next == null,
    };
  }

  Future<int> _awardOnce({
    required String eventId,
    required int points,
    required Map<String, dynamic> eventData,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
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

      final levelData = getLevelFromPoints(newTotalPoints);

      if (!userSnap.exists) {
        tx.set(
          userRef,
          {
            'totalPoints': newTotalPoints,
            'level': levelData.name,
            'levelNumber': levelData.level,
            'levelDescription': levelData.description,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        tx.update(userRef, {
          'totalPoints': newTotalPoints,
          'level': levelData.name,
          'levelNumber': levelData.level,
          'levelDescription': levelData.description,
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

        //await _triggerBadgeCheck(
       // tx: tx,
        //userRef: userRef,
       // totalPoints: newTotalPoints,
     // );

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
    final tourSnap =
        await _firestore.collection('tourPackages').doc(packageId).get();
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

      final tourSnap =
          await _firestore.collection('tourPackages').doc(packageId).get();
      if (!tourSnap.exists) {
        toDelete.add(evDoc.reference);
        continue;
      }

      final tourData = tourSnap.data() as Map<String, dynamic>;
      final live = tourData['liveTourState'] as Map<String, dynamic>?;
      final ended = (live?['ended'] as bool?) ?? false;
      final activities =
          (tourData['activities'] as List<dynamic>?) ?? const [];
      final totalActivities = activities.length;

      final completedIds = completedActivitiesByPackage[packageId] ?? <String>{};
      final completedAll =
          totalActivities > 0 && completedIds.length >= totalActivities;

      if (!ended || !completedAll) {
        toDelete.add(evDoc.reference);
      }
    }

    if (toDelete.isNotEmpty) {
      const batchLimit = 400;
      for (var i = 0; i < toDelete.length; i += batchLimit) {
        final batch = _firestore.batch();
        final end =
            (i + batchLimit) > toDelete.length ? toDelete.length : (i + batchLimit);
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

    final levelData = getLevelFromPoints(sum);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(userRef);
      final data = (snap.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
      final current = (data['totalPoints'] as num?)?.toInt() ?? 0;
      final currentLevel = (data['level'] ?? '').toString();

      final payload = <String, dynamic>{
        'totalPoints': sum,
        'level': levelData.name,
        'levelNumber': levelData.level,
        'levelDescription': levelData.description,
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

      if (current != sum || currentLevel != levelData.name) {
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
      } catch (_) {}
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
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$safeExt';
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

      const pointsToAward = 10;

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

        final levelData = getLevelFromPoints(newTotalPoints);

        if (!userSnap.exists) {
          tx.set(
            userRef,
            {
              'totalPoints': newTotalPoints,
              'level': levelData.name,
              'levelNumber': levelData.level,
              'levelDescription': levelData.description,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else {
          tx.update(userRef, {
            'totalPoints': newTotalPoints,
            'level': levelData.name,
            'levelNumber': levelData.level,
            'levelDescription': levelData.description,
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

        //await _triggerBadgeCheck(
         // tx: tx,
        //  userRef: userRef,
         // totalPoints: newTotalPoints,
        //);

        return SubmitChallengeResult(
          pointsEarned: pointsToAward,
          alreadyCompleted: false,
          photoUrl: url,
        );
      });
    } catch (e) {
      try {
        await ref.delete();
      } catch (_) {}
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
      final activities =
          (packageData['activities'] as List<dynamic>?) ?? const [];

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
      if (correctIndex != null &&
          correctIndex >= 0 &&
          correctIndex < options.length) {
        resolvedCorrectAnswer = options[correctIndex];
      }

      final isCorrect =
          _normalizeAnswer(answer) == _normalizeAnswer(resolvedCorrectAnswer);

      final userSnap = await tx.get(userRef);
      final userData =
          (userSnap.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
      final currentPoints = (userData['totalPoints'] as num?)?.toInt() ?? 0;

      const basePoints = 2;
      const correctBonusPoints = 8;
      final pointsEarned =
          isCorrect ? (basePoints + correctBonusPoints) : basePoints;
      final newTotalPoints = currentPoints + pointsEarned;

      final levelData = getLevelFromPoints(newTotalPoints);

      if (!userSnap.exists) {
        tx.set(
          userRef,
          {
            'totalPoints': newTotalPoints,
            'level': levelData.name,
            'levelNumber': levelData.level,
            'levelDescription': levelData.description,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        tx.update(userRef, {
          'totalPoints': newTotalPoints,
          'level': levelData.name,
          'levelNumber': levelData.level,
          'levelDescription': levelData.description,
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

      //await _triggerBadgeCheck(
       // tx: tx,
       // userRef: userRef,
      //  totalPoints: newTotalPoints,
     // );

      return SubmitQuizAnswerResult(
        pointsEarned: pointsEarned,
        alreadyAnswered: false,
        isCorrect: isCorrect,
      );
    });
  }

 //Future<void> _triggerBadgeCheck({
 // required Transaction tx,
 // required DocumentReference<Map<String, dynamic>> userRef,
 // required int totalPoints,
//}) async {
//  final updatedBadges = <String>{};

 // if (totalPoints >= 100) {
  //  updatedBadges.add('points_100');
  //}

  //if (totalPoints >= 250) {
   // updatedBadges.add('points_250');
  //}

 // if (totalPoints >= 500) {
  //  updatedBadges.add('points_500');
  //}

  //final badgesList = updatedBadges.toList();

 // tx.set(
   // userRef,
    //{
      //'badges': badgesList,
      //'badgesCount': badgesList.length,
     // 'updatedAt': FieldValue.serverTimestamp(),
   // },
   // SetOptions(merge: true),
 // ); 
//}

Future<List<String>> checkAndUnlockBadges() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final doc = await ref.get();
  final data = doc.data() ?? {};
  final quizCount = (data['quizCount'] ?? 0) + 1;
  final completedTours = data['completedTours'] ?? 0;


  List badges = data['badges'] ?? [];

  int bookings = data['bookingCount'] ?? 0;
  int reviews = data['reviewsCount'] ?? 0;
  int quiz = data['quizCount'] ?? 0;
  int completed = data['completedTours'] ?? 0;

 List<String> newBadges = [];

if (quizCount >= 3 && !badges.contains('quiz_starter')) {
  newBadges.add('quiz_starter');
}

if (completedTours >= 5 && !badges.contains('explorer')) {
  newBadges.add('explorer');
}

if (bookings >= 1 && !badges.contains('first_booking')) {
  newBadges.add('first_booking');
}

if (reviews >= 3 && !badges.contains('reviewer')) {
  newBadges.add('reviewer');
}

if (newBadges.isNotEmpty) {
  await ref.update({
    'badges': FieldValue.arrayUnion(newBadges),
  });
}
  

  return newBadges;
}
}
extension _ListLastOrNull<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
