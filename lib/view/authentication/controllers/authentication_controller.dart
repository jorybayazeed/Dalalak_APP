import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/auth_service.dart';
import 'package:tour_app/services/storage_service.dart';
import 'package:tour_app/services/user_service.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/views/dashboard_view.dart';
import 'package:tour_app/view/main/tour_guide/profile/controllers/profile_controller.dart';
import 'package:tour_app/view/main/tourist/home/views/home_view.dart';
import 'package:tour_app/view/main/tourist/profile/controllers/profile_controller.dart';

class AuthenticationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxString countryCode = '+966'.obs;
  final RxString phoneNumber = ''.obs;
  final RxString fullPhoneNumber = ''.obs;

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final RxString selectedRole = 'Tourist'.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoginPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  final RxnString emailError = RxnString(null);
  final RxnString passwordError = RxnString(null);
  final RxnString confirmPasswordError = RxnString(null);

  final RxBool hasMinLength = false.obs;
  final RxBool hasUppercase = false.obs;
  final RxBool hasLowercase = false.obs;
  final RxBool hasNumber = false.obs;
  final RxBool hasSpecialChar = false.obs;
  final RxDouble passwordStrength = 0.0.obs;
  final RxString passwordStrengthLabel = ''.obs;

  final RxString yearsOfExperience = ''.obs;
  final RxString specialization = ''.obs;
  final RxList<String> languagesSpoken = <String>[].obs;

  final RxString age = ''.obs;
  final RxString countryOfResidence = ''.obs;
  final RxString travelBudget = ''.obs;
  final RxString travelPace = ''.obs;
  final RxList<String> interests = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateEmail() {
    final email = emailController.text;
    if (email.isEmpty) {
      emailError.value = null;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email address';
    } else {
      emailError.value = null;
    }
  }

  void _validatePassword() {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      passwordError.value = null;
      hasMinLength.value = false;
      hasUppercase.value = false;
      hasLowercase.value = false;
      hasNumber.value = false;
      hasSpecialChar.value = false;
      passwordStrength.value = 0.0;
      passwordStrengthLabel.value = '';
      _validateConfirmPassword();
      return;
    }

    hasMinLength.value = password.length >= 8;
    hasUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    hasLowercase.value = RegExp(r'[a-z]').hasMatch(password);
    hasNumber.value = RegExp(r'[0-9]').hasMatch(password);
    hasSpecialChar.value =
        RegExp(r'[!@#$%^&*(),.?":{}|<>_\-]').hasMatch(password);

    int passedRules = 0;
    if (hasMinLength.value) passedRules++;
    if (hasUppercase.value) passedRules++;
    if (hasLowercase.value) passedRules++;
    if (hasNumber.value) passedRules++;
    if (hasSpecialChar.value) passedRules++;

    passwordStrength.value = passedRules / 5;

    if (passedRules <= 2) {
      passwordStrengthLabel.value = 'Weak';
    } else if (passedRules <= 4) {
      passwordStrengthLabel.value = 'Medium';
    } else {
      passwordStrengthLabel.value = 'Strong';
    }

    if (!hasMinLength.value) {
      passwordError.value = 'Password must be at least 8 characters';
    } else if (!hasUppercase.value) {
      passwordError.value = 'Must contain at least one uppercase letter';
    } else if (!hasLowercase.value) {
      passwordError.value = 'Must contain at least one lowercase letter';
    } else if (!hasNumber.value) {
      passwordError.value = 'Must contain at least one number';
    } else if (!hasSpecialChar.value) {
      passwordError.value = 'Must contain at least one special character';
    } else {
      passwordError.value = null;
    }

    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = null;
    } else if (password != confirmPassword) {
      confirmPasswordError.value = 'Passwords do not match';
    } else {
      confirmPasswordError.value = null;
    }
  }

  void toggleRole(String role) {
    selectedRole.value = role;
    if (role == 'Tourist') {
      yearsOfExperience.value = '';
      specialization.value = '';
      languagesSpoken.clear();
    } else {
      age.value = '';
      countryOfResidence.value = '';
      travelBudget.value = '';
      travelPace.value = '';
      interests.clear();
    }
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void toggleLoginPasswordVisibility() {
    isLoginPasswordVisible.value = !isLoginPasswordVisible.value;
  }

  void setYearsOfExperience(String value) {
    yearsOfExperience.value = value;
  }

  void setSpecialization(String value) {
    specialization.value = value;
  }

  void toggleLanguage(String language) {
    if (languagesSpoken.contains(language)) {
      languagesSpoken.remove(language);
    } else {
      languagesSpoken.add(language);
    }
  }

  void setAge(String value) {
    age.value = value;
  }

  void setCountryOfResidence(String value) {
    countryOfResidence.value = value;
  }

  void setTravelBudget(String value) {
    travelBudget.value = value;
  }

  void setTravelPace(String value) {
    travelPace.value = value;
  }

  void toggleInterest(String interest) {
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
  }

  bool _isFormValid() {
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your full name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return false;
    }

    if (emailError.value != null) {
      Get.snackbar('Error', emailError.value!);
      return false;
    }

    if (phoneNumber.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number');
      return false;
    }

    final cleanedPhone = phoneNumber.value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedPhone.length < 9 || cleanedPhone.length > 15) {
      Get.snackbar('Error', 'Please enter a valid phone number');
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter a password');
      return false;
    }

    if (passwordError.value != null) {
      Get.snackbar('Error', passwordError.value!);
      return false;
    }

    if (confirmPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please confirm your password');
      return false;
    }

    if (confirmPasswordError.value != null) {
      Get.snackbar('Error', confirmPasswordError.value!);
      return false;
    }

    if (selectedRole.value == 'Tour Guide') {
      if (yearsOfExperience.value.isEmpty) {
        Get.snackbar('Error', 'Please select years of experience');
        return false;
      }
      if (specialization.value.isEmpty) {
        Get.snackbar('Error', 'Please select specialization');
        return false;
      }
      if (languagesSpoken.isEmpty) {
        Get.snackbar('Error', 'Please select at least one language');
        return false;
      }
    }

    if (selectedRole.value == 'Tourist') {
      if (age.value.isEmpty) {
        Get.snackbar('Error', 'Please select your age range');
        return false;
      }
      if (countryOfResidence.value.isEmpty) {
        Get.snackbar('Error', 'Please enter your country of residence');
        return false;
      }
      if (travelBudget.value.isEmpty) {
        Get.snackbar('Error', 'Please select your travel budget');
        return false;
      }
      if (travelPace.value.isEmpty) {
        Get.snackbar('Error', 'Please select your preferred travel pace');
        return false;
      }
      if (interests.isEmpty) {
        Get.snackbar('Error', 'Please select at least one interest');
        return false;
      }
    }

    return true;
  }

  Future<void> createAccount() async {
    if (!_isFormValid()) {
      return;
    }

    final cleanedPhone = phoneNumber.value.replaceAll(RegExp(r'[^0-9]'), '');
    fullPhoneNumber.value = '${countryCode.value}$cleanedPhone';

    isLoading.value = true;

    try {
      final result = await _authService.signUpWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phone: fullPhoneNumber.value,
        userType: selectedRole.value,
        yearsOfExperience:
            selectedRole.value == 'Tour Guide' ? yearsOfExperience.value : null,
        specialization:
            selectedRole.value == 'Tour Guide' ? specialization.value : null,
        languagesSpoken:
            selectedRole.value == 'Tour Guide'
                ? languagesSpoken.toList()
                : null,
        age: selectedRole.value == 'Tourist' ? age.value : null,
        countryOfResidence:
            selectedRole.value == 'Tourist' ? countryOfResidence.value : null,
        travelBudget:
            selectedRole.value == 'Tourist' ? travelBudget.value : null,
        travelPace: selectedRole.value == 'Tourist' ? travelPace.value : null,
        interests:
            selectedRole.value == 'Tourist' ? interests.toList() : null,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        Get.snackbar('Success', result['message'] as String);

        if (result['isVerified'] == true) {
          await StorageService.setSignedIn(true);
          await StorageService.setUserType(result['userType'] as String);
          await StorageService.setUserId(_authService.currentUser?.uid);

          _navigateToHome(result['userType'] as String);
        } else {
          Get.back();
          Get.snackbar(
            'Account Created',
            'Your account is pending verification. You will be notified once approved.',
            duration: const Duration(seconds: 4),
          );
        }

        _clearControllers();
      } else {
        Get.snackbar('Error', result['message'] as String);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  Future<void> login() async {
    if (loginEmailController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email');
      return;
    }

    if (!GetUtils.isEmail(loginEmailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    if (loginPasswordController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter your password');
      return;
    }

    isLoading.value = true;

    try {
      await FirebaseAuth.instance.signOut();

      Get.delete<TouristProfileController>();
      Get.delete<ProfileController>();
      Get.delete<UserService>();
      
      final result = await _authService.signInWithEmail(
        email: loginEmailController.text.trim(),
        password: loginPasswordController.text,
      );

      isLoading.value = false;

      if (result['success'] == true) {
        await StorageService.setSignedIn(true);
        await StorageService.setUserType(result['userType'] as String);
        await StorageService.setUserId(_authService.currentUser?.uid);

        _navigateToHome(result['userType'] as String);
        _clearLoginControllers();
      } else {
        String message = 'Login failed';
        final error = (result['message'] as String).toLowerCase();

        if (error.contains('user-not-found')) {
          message = 'No account found with this email';
        } else if (error.contains('wrong-password')) {
          message = 'Incorrect password';
        } else if (error.contains('invalid-email')) {
          message = 'Invalid email format';
        } else if (error.contains('too-many-requests')) {
          message = 'Too many attempts. Try again later';
        } else {
          message = 'Email or password is incorrect';
        }

        Get.snackbar('Login Failed', message);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred');
    }
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your email first');
      return;
    }

    if (!GetUtils.isEmail(email.trim())) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }

    try {
      await _authService.sendPasswordReset(email.trim());

      Get.snackbar(
        'Success',
        'Password reset email sent',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send reset email',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _navigateToHome(String userType) {
    if (userType == 'Tour Guide') {
      Get.offAll(() => const DashboardView());
    } else {
      Get.offAll(() => const TouristHomeView());
    }
  }

  void _clearControllers() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    countryCode.value = '+966';
    phoneNumber.value = '';
    fullPhoneNumber.value = '';
    yearsOfExperience.value = '';
    specialization.value = '';
    languagesSpoken.clear();
    age.value = '';
    countryOfResidence.value = '';
    travelBudget.value = '';
    travelPace.value = '';
    interests.clear();
    hasMinLength.value = false;
    hasUppercase.value = false;
    hasLowercase.value = false;
    hasNumber.value = false;
    hasSpecialChar.value = false;
    passwordStrength.value = 0.0;
    passwordStrengthLabel.value = '';
  }

  void _clearLoginControllers() {
    loginEmailController.clear();
    loginPasswordController.clear();
  }

  @override
  void onClose() {
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    confirmPasswordController.removeListener(_validateConfirmPassword);
    super.onClose();
  }
}
