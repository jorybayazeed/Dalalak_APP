import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PackagesService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<int?> getMyRatingFor(String packageId) async {
    final userId = currentUserId;
    if (userId == null || packageId.trim().isEmpty) return null;
    try {
      final snap = await _firestore
          .collection('tourPackages')
          .doc(packageId)
          .collection('ratings')
          .doc(userId)
          .get();
      if (!snap.exists) return null;
      final value = snap.data()?['rating'];
      if (value is num) return value.toInt().clamp(1, 5);
    } catch (_) {}
    return null;
  }

  Future<void> submitTourRating({
    required String packageId,
    required int rating,
    required String review,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final safeRating = rating.clamp(1, 5);
      final packageRef = _firestore.collection('tourPackages').doc(packageId);
      final ratingRef = packageRef.collection('ratings').doc(userId);

      final createdNewRating = await _firestore.runTransaction((tx) async {
        final already = await tx.get(ratingRef);
        if (already.exists) {
          return false;
        }

        final packageSnap = await tx.get(packageRef);
        if (!packageSnap.exists) {
          throw Exception('Tour package not found');
        }

        final data = packageSnap.data() as Map<String, dynamic>;
        final currentAvg = (data['rating'] as num?)?.toDouble() ?? 0.0;
        final currentReviews = (data['reviews'] as num?)?.toInt() ?? 0;

        final newReviews = currentReviews + 1;
        final newAvg =
            ((currentAvg * currentReviews) + safeRating) / newReviews;

        tx.set(ratingRef, {
          'userId': userId,
          'packageId': packageId,
          'rating': safeRating,
          'review': review,
          'createdAt': FieldValue.serverTimestamp(),
        });

        tx.update(packageRef, {
          'rating': double.parse(newAvg.toStringAsFixed(2)),
          'reviews': newReviews,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (createdNewRating) {
        try {
          await notifyGuideTourRated(
            packageId: packageId,
            rating: safeRating,
            review: review,
          );
        } catch (_) {}
      }
    } catch (e) {
      throw Exception('Failed to submit rating: ${e.toString()}');
    }
  }

  Future<void> notifyGuideTourRated({
    required String packageId,
    required int rating,
    required String review,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tourDoc =
          await _firestore.collection('tourPackages').doc(packageId).get();
      final tourData = tourDoc.data() ?? <String, dynamic>{};

      final guideId = (tourData['guideId'] ?? '').toString();
      if (guideId.isEmpty) return;

      final tourTitle =
          (tourData['tourTitle'] ?? tourData['title'] ?? 'Tour').toString();

      String touristName = '';
      try {
        final touristDoc = await _firestore.collection('users').doc(userId).get();
        touristName = (touristDoc.data()?['fullName'] ?? '').toString();
      } catch (_) {}

      await _firestore
          .collection('users')
          .doc(guideId)
          .collection('notifications')
          .doc('tour_rated_${packageId}_$userId')
          .set({
        'title': 'New Rating',
        'message': touristName.trim().isEmpty
            ? 'A tourist rated $tourTitle'
            : '$touristName rated $tourTitle',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'tour_rating',
        'tourId': packageId,
        'tourTitle': tourTitle,
        'rating': rating,
        'review': review,
        'touristId': userId,
        'touristName': touristName,
      });
    } catch (e) {
      throw Exception('Failed to notify guide tour rated: ${e.toString()}');
    }
  }

  Future<String> createPackage({
    required String tourTitle,
    required String destination,
    required String region,
    required String durationValue,
    required String durationUnit,
    required String price,
    required String maxGroupSize,
    required String tourDescription,
    String? activityType,
    String? availableDates,
    List<Map<String, dynamic>>? activities,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final packageData = {
        'tourTitle': tourTitle,
        'destination': destination,
        'region': region,
        'durationValue': durationValue,
        'durationUnit': durationUnit,
        'price': price,
        'maxGroupSize': maxGroupSize,
        'tourDescription': tourDescription,
        'activityType': activityType ?? '',
        'availableDates': availableDates ?? '',
        'activities': activities ?? [],
        'guideId': userId,
        'status': 'Published',
        'views': 0,
        'bookings': 0,
        'rating': 0,
        'reviews': 0,
        'image': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('tourPackages')
          .add(packageData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create package: ${e.toString()}');
    }
  }

  Future<void> updatePackage({
    required String packageId,
    required String tourTitle,
    required String destination,
    required String region,
    required String durationValue,
    required String durationUnit,
    required String price,
    required String maxGroupSize,
    required String tourDescription,
    String? activityType,
    String? availableDates,
    List<Map<String, dynamic>>? activities,
    bool? isCancelled,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final packageData = {
        'tourTitle': tourTitle,
        'destination': destination,
        'region': region,
        'durationValue': durationValue,
        'durationUnit': durationUnit,
        'price': price,
        'maxGroupSize': maxGroupSize,
        'tourDescription': tourDescription,
        'activityType': activityType ?? '',
        'availableDates': availableDates ?? '',
        'activities': activities ?? [],
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (isCancelled != null) {
        packageData['isCancelled'] = isCancelled;
      }

      await _firestore
          .collection('tourPackages')
          .doc(packageId)
          .update(packageData);
    } catch (e) {
      throw Exception('Failed to update package: ${e.toString()}');
    }
  }

  Future<void> deletePackage(String packageId) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection('tourPackages').doc(packageId).delete();
    } catch (e) {
      throw Exception('Failed to delete package: ${e.toString()}');
    }
  }

  Stream<List<Map<String, dynamic>>> getPackagesStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('tourPackages')
        .where('guideId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final packages = snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList();

          packages.sort((a, b) {
            final aCreated = a['createdAt'] as Timestamp?;
            final bCreated = b['createdAt'] as Timestamp?;
            if (aCreated == null && bCreated == null) return 0;
            if (aCreated == null) return 1;
            if (bCreated == null) return -1;
            return bCreated.compareTo(aCreated);
          });

          return packages;
        });
  }

  Future<Map<String, dynamic>?> getPackage(String packageId) async {
    try {
      final doc = await _firestore
          .collection('tourPackages')
          .doc(packageId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw Exception('Failed to get package: ${e.toString()}');
    }
  }

  Future<void> updateLiveTourState({
    required String packageId,
    required String activeActivityId,
    required List<String> completedActivityIds,
    required bool ended,
    String? sessionId,
    Timestamp? sessionStartedAt,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final liveTourState = <String, dynamic>{
        'guideId': userId,
        'activeActivityId': activeActivityId,
        'completedActivityIds': completedActivityIds,
        'ended': ended,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (sessionStartedAt != null) {
        liveTourState['sessionStartedAt'] = sessionStartedAt;
      }

      final safeSessionId = (sessionId ?? '').toString().trim();
      if (safeSessionId.isNotEmpty) {
        liveTourState['sessionId'] = safeSessionId;
      }

      await _firestore.collection('tourPackages').doc(packageId).update({
        'liveTourState': liveTourState,
      });
    } catch (e) {
      throw Exception('Failed to update live tour state: ${e.toString()}');
    }
  }

  Future<void> notifyTourEnded(String packageId, {String? sessionId}) async {
    try {
      final tourDoc =
          await _firestore.collection('tourPackages').doc(packageId).get();

      final tourTitle =
          (tourDoc.data()?['tourTitle'] ?? tourDoc.data()?['title'] ?? 'Your tour')
              .toString();

      final bookingsSnapshot = await _firestore
          .collectionGroup('upcomingBookings')
          .where('tourId', isEqualTo: packageId)
          .get();

      final filterSession = (sessionId ?? '').toString().trim();
      for (final doc in bookingsSnapshot.docs) {
        if (filterSession.isNotEmpty) {
          final data = doc.data();
          final bookingSession = (data['sessionId'] ?? '').toString().trim();
          if (bookingSession != filterSession) {
            continue;
          }
        }

        final userRef = doc.reference.parent.parent;
        if (userRef == null) continue;

        await userRef
            .collection('notifications')
            .doc(filterSession.isEmpty
                ? 'tour_ended_$packageId'
                : 'tour_ended_${packageId}_$filterSession')
            .set({
          'title': 'Tour Ended',
          'message': 'The tour has been ended by the guide',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'broadcast',
          'tourId': packageId,
          if (filterSession.isNotEmpty) 'sessionId': filterSession,
          'tourTitle': tourTitle,
          'tourName': tourTitle,
        });
      }
    } catch (e) {
      throw Exception('Failed to notify tour ended: ${e.toString()}');
    }
  }

  Future<void> cleanupEndedTourBookings(String packageId, {String? sessionId}) async {
    try {
      final bookingsSnapshot = await _firestore
          .collectionGroup('upcomingBookings')
          .where('tourId', isEqualTo: packageId)
          .get();

      final endedSessionId = (sessionId ?? '').toString().trim();

      final refs = bookingsSnapshot.docs
          .where((d) {
            final data = d.data();
            final status =
                (data['status'] ?? '').toString().trim().toLowerCase();
            return status != 'completed';
          })
          .map((d) => d.reference)
          .toList();

      const batchLimit = 400;
      for (var i = 0; i < refs.length; i += batchLimit) {
        final batch = _firestore.batch();
        final end =
            (i + batchLimit) > refs.length ? refs.length : (i + batchLimit);
        for (var j = i; j < end; j++) {
          batch.set(
            refs[j],
            {
              'status': 'Completed',
              'completedAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
              if (endedSessionId.isNotEmpty)
                'endedSessionId': endedSessionId,
            },
            SetOptions(merge: true),
          );
        }
        await batch.commit();
      }

      try {
        await _firestore.collection('tourPackages').doc(packageId).set(
          {
            'bookings': 0,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (_) {}
    } catch (e) {
      throw Exception('Failed to cleanup ended tour bookings: ${e.toString()}');
    }
  }

  Future<void> resetLiveTourState(String packageId) async {
    try {
      await _firestore.collection('tourPackages').doc(packageId).update({
        'liveTourState': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to reset live tour state: ${e.toString()}');
    }
  }

  Future<void> archiveEndedSession({
    required String packageId,
    required String guideId,
    required String? sessionId,
    required Timestamp? sessionStartedAt,
    required int registeredCount,
  }) async {
    try {
      if (guideId.trim().isEmpty || packageId.trim().isEmpty) {
        Get.log(
          'archiveEndedSession: skipped (guideId="$guideId", packageId="$packageId")',
        );
        return;
      }
      Get.log(
        'archiveEndedSession: writing for guide=$guideId package=$packageId session=$sessionId registered=$registeredCount',
      );

      String packageTitle = '';
      String packageImage = '';
      try {
        final pkgSnap =
            await _firestore.collection('tourPackages').doc(packageId).get();
        final pkgData = pkgSnap.data();
        if (pkgData != null) {
          packageTitle =
              (pkgData['tourTitle'] ?? pkgData['title'] ?? '').toString();
          packageImage = (pkgData['image'] ?? '').toString();
        }
      } catch (_) {}

      final cleanSessionId = (sessionId ?? '').toString().trim();

      final ref = await _firestore
          .collection('users')
          .doc(guideId)
          .collection('endedSessions')
          .add({
        'packageId': packageId,
        'packageTitle': packageTitle,
        'packageImage': packageImage,
        if (cleanSessionId.isNotEmpty) 'sessionId': cleanSessionId,
        if (sessionStartedAt != null) 'sessionStartedAt': sessionStartedAt,
        'endedAt': FieldValue.serverTimestamp(),
        'registeredCount': registeredCount,
      });
      Get.log('archiveEndedSession: OK ${ref.path}');
    } catch (e) {
      Get.log('archiveEndedSession: FAILED $e');
      throw Exception('Failed to archive ended session: ${e.toString()}');
    }
  }

  Future<int> backfillEndedSessionsForGuide(String guideId) async {
    if (guideId.trim().isEmpty) return 0;

    final endedSessionsRef = _firestore
        .collection('users')
        .doc(guideId)
        .collection('endedSessions');

    final existing = await endedSessionsRef.get();
    final existingKeys = <String>{};
    for (final doc in existing.docs) {
      final data = doc.data();
      final pkg = (data['packageId'] ?? '').toString();
      final sess = (data['sessionId'] ?? '').toString();
      existingKeys.add('$pkg|$sess');
    }

    final myPackages = await _firestore
        .collection('tourPackages')
        .where('guideId', isEqualTo: guideId)
        .get();

    final Map<String, Map<String, dynamic>> packageInfo = {};
    for (final doc in myPackages.docs) {
      final data = doc.data();
      packageInfo[doc.id] = {
        'title': (data['tourTitle'] ?? data['title'] ?? '').toString(),
        'image': (data['image'] ?? '').toString(),
      };
    }

    int created = 0;
    for (final pkgId in packageInfo.keys) {
      try {
        final completedBookings = await _firestore
            .collectionGroup('upcomingBookings')
            .where('tourId', isEqualTo: pkgId)
            .where('status', isEqualTo: 'Completed')
            .get();

        final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
            grouped = {};
        for (final b in completedBookings.docs) {
          final data = b.data();
          final endedSessionId = (data['endedSessionId'] ??
                  data['sessionId'] ??
                  '')
              .toString();
          grouped.putIfAbsent(endedSessionId, () => []).add(b);
        }

        for (final entry in grouped.entries) {
          final sess = entry.key;
          final docs = entry.value;
          final key = '$pkgId|$sess';
          if (existingKeys.contains(key)) continue;

          Timestamp? endedAt;
          for (final d in docs) {
            final ts = d.data()['completedAt'];
            if (ts is Timestamp) {
              if (endedAt == null ||
                  ts.microsecondsSinceEpoch >
                      endedAt.microsecondsSinceEpoch) {
                endedAt = ts;
              }
            }
          }

          await endedSessionsRef.add({
            'packageId': pkgId,
            'packageTitle': packageInfo[pkgId]?['title'] ?? '',
            'packageImage': packageInfo[pkgId]?['image'] ?? '',
            if (sess.isNotEmpty) 'sessionId': sess,
            'endedAt': endedAt ?? FieldValue.serverTimestamp(),
            'registeredCount': docs.length,
            'backfilled': true,
          });
          created++;
        }
      } catch (e) {
        Get.log('backfill: skipped $pkgId due to $e');
      }
    }

    Get.log('backfillEndedSessionsForGuide: created=$created');
    return created;
  }

  Stream<List<Map<String, dynamic>>> getAllPackagesStream() {
    return _firestore
        .collection('tourPackages')
        .where('status', isEqualTo: 'Published')
        .snapshots()
        .map((snapshot) {
          final packages = snapshot.docs.map((doc) {
            final data = doc.data();
            return {'id': doc.id, ...data};
          }).toList();

          packages.sort((a, b) {
            final aCreated = a['createdAt'] as Timestamp?;
            final bCreated = b['createdAt'] as Timestamp?;
            if (aCreated == null && bCreated == null) return 0;
            if (aCreated == null) return 1;
            if (bCreated == null) return -1;
            return bCreated.compareTo(aCreated);
          });

          return packages;
        });
  }

  Future<List<Map<String, dynamic>>> getAllPackages() async {
    try {
      final snapshot = await _firestore
          .collection('tourPackages')
          .where('status', isEqualTo: 'Published')
          .get();

      final packages = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      packages.sort((a, b) {
        final aCreated = a['createdAt'] as Timestamp?;
        final bCreated = b['createdAt'] as Timestamp?;
        if (aCreated == null && bCreated == null) return 0;
        if (aCreated == null) return 1;
        if (bCreated == null) return -1;
        return bCreated.compareTo(aCreated);
      });

      return packages;
    } catch (e) {
      Get.log('Error fetching all packages: $e');
      return [];
    }
  }

  Future<void> cancelTour(String packageId) async {
  try {
    await _firestore.collection('tourPackages').doc(packageId).update({
      'isCancelled': true,
      'cancelledAt': FieldValue.serverTimestamp(),
    });
    final tourDoc = await _firestore
    .collection('tourPackages')
    .doc(packageId)
    .get();

final tourTitle = tourDoc.data()?['tourTitle'] ?? 'Your tour';

    final bookingsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('upcomingBookings')
        .where('tourId', isEqualTo: packageId)
        .get();

    for (final doc in bookingsSnapshot.docs) {

      await doc.reference.update({
        'status': 'Cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      final userRef = doc.reference.parent.parent;

      await userRef!.collection('notifications').add({
        'title': 'Tour Cancelled',
        'message': '$tourTitle has been cancelled by the guide',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  } catch (e) {
    throw Exception('Failed to cancel tour: ${e.toString()}');
  }
}

  Future<void> notifyGuideQuizAnswered({
    required String packageId,
    required String activityId,
    required int pointsEarned,
    bool isCorrect = false,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tourDoc =
          await _firestore.collection('tourPackages').doc(packageId).get();
      final tourData = tourDoc.data() ?? <String, dynamic>{};

      final guideId = (tourData['guideId'] ?? '').toString();
      if (guideId.isEmpty) return;

      final tourTitle =
          (tourData['tourTitle'] ?? tourData['title'] ?? 'Tour').toString();

      String activityName = '';
      try {
        final acts = (tourData['activities'] as List<dynamic>?) ?? const [];
        for (final a in acts) {
          if (a is! Map) continue;
          final m = a.cast<String, dynamic>();
          final id = (m['activityId'] ?? '').toString();
          if (id == activityId) {
            activityName = (m['activityName'] ?? m['title'] ?? '').toString();
            break;
          }
        }
      } catch (_) {}

      String touristName = '';
      try {
        final touristDoc = await _firestore.collection('users').doc(userId).get();
        touristName = (touristDoc.data()?['fullName'] ?? '').toString();
      } catch (_) {}

      final safeTourist = touristName.trim().isEmpty ? 'A tourist' : touristName;
      final safeActivity = activityName.trim().isEmpty ? 'a quiz' : activityName;
      final message =
          '$safeTourist answered $safeActivity in $tourTitle (+$pointsEarned points)';

      await _firestore
          .collection('users')
          .doc(guideId)
          .collection('notifications')
          .doc('quiz_${packageId}_${activityId}_$userId')
          .set({
        'title': 'Quiz Answered',
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'quiz',
        'tourId': packageId,
        'tourTitle': tourTitle,
        'activityId': activityId,
        'activityName': activityName,
        'pointsEarned': pointsEarned,
        'isCorrect': isCorrect,
        'touristId': userId,
        'touristName': touristName,
      });
    } catch (e) {
      throw Exception('Failed to notify guide quiz answered: ${e.toString()}');
    }
  }

  Future<void> notifyGuideTourCompleted({
    required String packageId,
    required int pointsEarned,
    String? sessionId,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tourDoc =
          await _firestore.collection('tourPackages').doc(packageId).get();
      final tourData = tourDoc.data() ?? <String, dynamic>{};

      final guideId = (tourData['guideId'] ?? '').toString();
      if (guideId.isEmpty) return;

      final tourTitle =
          (tourData['tourTitle'] ?? tourData['title'] ?? 'Tour').toString();

      String touristName = '';
      try {
        final touristDoc = await _firestore.collection('users').doc(userId).get();
        touristName = (touristDoc.data()?['fullName'] ?? '').toString();
      } catch (_) {}

      final cleanSessionId = (sessionId ?? '').toString().trim();
      final docId = cleanSessionId.isEmpty
          ? 'tour_completed_${packageId}_$userId'
          : 'tour_completed_${packageId}_${userId}_$cleanSessionId';

      await _firestore
          .collection('users')
          .doc(guideId)
          .collection('notifications')
          .doc(docId)
          .set({
        'title': 'Tour Completed',
        'message': touristName.trim().isEmpty
            ? 'A tourist completed $tourTitle'
            : '$touristName completed $tourTitle',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'tour_completed',
        'tourId': packageId,
        'tourTitle': tourTitle,
        'pointsEarned': pointsEarned,
        'touristId': userId,
        'touristName': touristName,
        if (cleanSessionId.isNotEmpty) 'sessionId': cleanSessionId,
      });
    } catch (e) {
      throw Exception('Failed to notify guide tour completed: ${e.toString()}');
    }
  }
}
