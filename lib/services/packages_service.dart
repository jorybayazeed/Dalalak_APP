import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PackagesService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

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

      await _firestore.runTransaction((tx) async {
        final already = await tx.get(ratingRef);
        if (already.exists) {
          return;
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
      });
    } catch (e) {
      throw Exception('Failed to submit rating: ${e.toString()}');
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

      await _firestore.collection('tourPackages').doc(packageId).update({
        'liveTourState': liveTourState,
      });
    } catch (e) {
      throw Exception('Failed to update live tour state: ${e.toString()}');
    }
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
}
