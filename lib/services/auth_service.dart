import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String userType,
    String? yearsOfExperience,
    String? specialization,
    List<String>? languagesSpoken,
    String? age,
    String? countryOfResidence,
    String? travelBudget,
    String? travelPace,
    List<String>? interests,
  }) async {
    try {
      if (userType == 'Tourist') {
        if (age == null ||
            countryOfResidence == null ||
            travelBudget == null ||
            travelPace == null ||
            interests == null ||
            interests.isEmpty) {
          return {'success': false, 'message': 'Please fill all the required fields'};
        }
      } else if (userType == 'Tour Guide') {
        if (yearsOfExperience == null ||
            specialization == null ||
            languagesSpoken == null ||
            languagesSpoken.isEmpty) {
          return {'success': false, 'message': 'Please fill all the required fields'};
        }
      }
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to create user'};
      }

      await user.updateDisplayName(fullName);

      final userData = {
        'uid': user.uid,
        'email': email,
        'fullName': fullName,
        'phone': phone,
        'userType': userType,
        'isProfileVerified': true,
        'totalPoints': 0,
        'level': 1,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add Tour Guide specific fields
      if (userType == 'Tour Guide') {
        userData['yearsOfExperience'] = yearsOfExperience!;
        userData['specialization'] = specialization!;
        userData['languagesSpoken'] = languagesSpoken!;
      }

      // Add Tourist specific fields
      if (userType == 'Tourist') {
        userData['age'] = age!;
        userData['countryOfResidence'] = countryOfResidence!;
        userData['travelBudget'] = travelBudget!;
        userData['travelPace'] = travelPace!;
        userData['interests'] = interests!;
      }

      await _firestore.collection('users').doc(user.uid).set(userData);

      return {
        'success': true,
        'message': 'Account created successfully',
        'userType': userType,
        'isVerified': true,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to sign in'};
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {'success': false, 'message': 'User data not found'};
      }

      final userData = userDoc.data()!;
      final userType = userData['userType'] as String? ?? 'Tourist';
      final isProfileVerified = userData['isProfileVerified'] as bool? ?? true;

      if (!userData.containsKey('totalPoints') || !userData.containsKey('level')) {
        await _firestore.collection('users').doc(user.uid).set(
          {
            if (!userData.containsKey('totalPoints')) 'totalPoints': 0,
            if (!userData.containsKey('level')) 'level': 1,
          },
          SetOptions(merge: true),
        );
      }

      if (userType == 'Tour Guide' && !isProfileVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message':
              'Your profile is pending verification. Please wait for admin approval.',
        };
      }

      return {
        'success': true,
        'message': 'Signed in successfully',
        'userType': userType,
        'isVerified': isProfileVerified,
      };
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is invalid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<Map<String, dynamic>> signUpWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
    required String fullName,
    required String email,
    required String userType,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to create user'};
      }

      await user.updateDisplayName(fullName);

      final userData = {
        'uid': user.uid,
        'phone': phoneNumber,
        'email': email,
        'fullName': fullName,
        'userType': userType,
        'isProfileVerified': true,
        'totalPoints': 0,
        'level': 1,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(user.uid).set(userData);

      return {
        'success': true,
        'message': 'Account created successfully',
        'userType': userType,
        'isVerified': true,
      };
    } catch (e) {
      return {'success': false, 'message': 'Invalid verification code'};
    }
  }

  Future<Map<String, dynamic>> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Failed to sign in'};
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await _auth.signOut();
        return {'success': false, 'message': 'User data not found'};
      }

      final userData = userDoc.data()!;
      final userType = userData['userType'] as String? ?? 'Tourist';
      final isProfileVerified = userData['isProfileVerified'] as bool? ?? true;

      if (!userData.containsKey('totalPoints') || !userData.containsKey('level')) {
        await _firestore.collection('users').doc(user.uid).set(
          {
            if (!userData.containsKey('totalPoints')) 'totalPoints': 0,
            if (!userData.containsKey('level')) 'level': 1,
          },
          SetOptions(merge: true),
        );
      }

      if (userType == 'Tour Guide' && !isProfileVerified) {
        await _auth.signOut();
        return {
          'success': false,
          'message':
              'Your profile is pending verification. Please wait for admin approval.',
        };
      }

      return {
        'success': true,
        'message': 'Signed in successfully',
        'userType': userType,
        'isVerified': isProfileVerified,
      };
    } catch (e) {
      return {'success': false, 'message': 'Invalid verification code'};
    }
  }
Future<void> sendPasswordReset(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
