import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SubmitQuizAnswerResult {
  final int pointsEarned;
  final bool alreadyAnswered;

  const SubmitQuizAnswerResult({
    required this.pointsEarned,
    required this.alreadyAnswered,
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
        if (!userSnap.exists) {
          throw Exception('User data not found');
        }

        final userData = userSnap.data() as Map<String, dynamic>;
        final currentPoints = (userData['totalPoints'] as num?)?.toInt() ?? 0;
        final newTotalPoints = currentPoints + pointsToAward;
        final newLevel = (newTotalPoints ~/ 500) + 1;

        tx.update(userRef, {
          'totalPoints': newTotalPoints,
          'level': newLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        });

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
        return const SubmitQuizAnswerResult(pointsEarned: 0, alreadyAnswered: true);
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
      if (!userSnap.exists) {
        throw Exception('User data not found');
      }

      final userData = userSnap.data() as Map<String, dynamic>;
      final currentPoints = (userData['totalPoints'] as num?)?.toInt() ?? 0;

      int pointsEarned = 0;
      int newTotalPoints = currentPoints;
      if (isCorrect) {
        pointsEarned = 2;
        newTotalPoints = currentPoints + pointsEarned;
      }

      final newLevel = (newTotalPoints ~/ 500) + 1;

      if (isCorrect) {
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
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (isCorrect) {
        await _triggerBadgeCheck(tx: tx, userRef: userRef, totalPoints: newTotalPoints);
      }

      return SubmitQuizAnswerResult(pointsEarned: pointsEarned, alreadyAnswered: false);
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
