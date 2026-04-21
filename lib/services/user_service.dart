import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // ===== Get User Data =====
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      return doc.data();
    } catch (_) {
      return null;
    }
  }

  // ===== Stream User Data (Live Update) =====
  Stream<Map<String, dynamic>?> getCurrentUserDataStream() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(null);

    return _firestore.collection('users').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot.data();
    });
  }

  // ===== Update Profile (FULL VERSION) =====
  Future<void> updateCurrentUserProfile({
    required String fullName,
    required String email,
    required String phone,
    required String countryOfResidence,
    required String ageRange,
    required String travelBudget,
    required String travelPace,
    required List<String> interests,
  }) async {
    final user = _auth.currentUser;
    final userId = currentUserId;

    if (user == null || userId == null) {
      throw Exception('User not found');
    }

    final cleanName = fullName.trim();
    final cleanEmail = email.trim();
    final cleanPhone = phone.trim();
    final cleanCountry = countryOfResidence.trim();

    if (cleanName.isEmpty) {
      throw Exception('Full name is required');
    }

    if (cleanEmail.isEmpty) {
      throw Exception('Email is required');
    }

    final currentEmail = (user.email ?? '').trim();

    try {
      // ===== Update Email (Secure Way) =====
      if (cleanEmail.toLowerCase() != currentEmail.toLowerCase()) {
        await user.verifyBeforeUpdateEmail(cleanEmail);
      }

      // ===== Update Firestore =====
      await _firestore.collection('users').doc(userId).set({
        'fullName': cleanName,
        'email': cleanEmail,
        'phone': cleanPhone,
        'countryOfResidence': cleanCountry,
        'ageRange': ageRange,
        'travelBudget': travelBudget,
        'travelPace': travelPace,
        'interests': interests,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('For security, please log in again before changing your email.');
      }
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already in use.');
      }
      if (e.code == 'invalid-email') {
        throw Exception('Please enter a valid email address.');
      }
      throw Exception(e.message ?? 'Failed to update profile.');
    } catch (_) {
      throw Exception('Failed to update profile.');
    }
  }
}