import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PackagesService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> createPackage({
    required String tourTitle,
    required String destination,
    required String durationValue,
    required String durationUnit,
    required String price,
    required String maxGroupSize,
    required String tourDescription,
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
        'durationValue': durationValue,
        'durationUnit': durationUnit,
        'price': price,
        'maxGroupSize': maxGroupSize,
        'tourDescription': tourDescription,
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
    required String durationValue,
    required String durationUnit,
    required String price,
    required String maxGroupSize,
    required String tourDescription,
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
        'durationValue': durationValue,
        'durationUnit': durationUnit,
        'price': price,
        'maxGroupSize': maxGroupSize,
        'tourDescription': tourDescription,
        'availableDates': availableDates ?? '',
        'activities': activities ?? [],
        'updatedAt': FieldValue.serverTimestamp(),
      };

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
}
