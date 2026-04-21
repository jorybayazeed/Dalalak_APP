import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:tour_app/view/authentication/controllers/authentication_controller.dart';
import 'package:tour_app/view/authentication/views/login_view.dart';

class CreateAccountView extends StatelessWidget {
  const CreateAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Back',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, color: Colors.black, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'AR',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 24.w),
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/onboarding_logo.png',
                        width: 100.w,
                        height: 100.h,
                      ),
                      SizedBox(height: 24.h),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Create Your Account',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF333333),
                            fontSize: 23.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Join the Daleelak community today',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF666666),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => GestureDetector(
                                  onTap: () => controller.toggleRole('Tourist'),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.selectedRole.value ==
                                                  'Tourist'
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Tourist',
                                        style: GoogleFonts.inter(
                                          color:
                                              controller.selectedRole.value ==
                                                      'Tourist'
                                                  ? const Color(0xFF333333)
                                                  : const Color(0xFF666666),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Obx(
                                () => GestureDetector(
                                  onTap: () =>
                                      controller.toggleRole('Tour Guide'),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    decoration: BoxDecoration(
                                      color:
                                          controller.selectedRole.value ==
                                                  'Tour Guide'
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Tour Guide',
                                        style: GoogleFonts.inter(
                                          color:
                                              controller.selectedRole.value ==
                                                      'Tour Guide'
                                                  ? const Color(0xFF333333)
                                                  : const Color(0xFF666666),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      TextField(
                        controller: controller.fullNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF999999),
                            fontSize: 16.sp,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => TextField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF999999),
                              fontSize: 16.sp,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            errorText: controller.emailError.value,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      IntlPhoneField(
                        initialCountryCode: 'SA',
                        onCountryChanged: (country) {
                          controller.countryCode.value = '+${country.dialCode}';
                        },
                        onChanged: (phone) {
                          controller.phoneNumber.value = phone.number;
                          controller.countryCode.value = phone.countryCode;
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: GoogleFonts.inter(
                            color: const Color(0xFF999999),
                            fontSize: 16.sp,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                        dropdownTextStyle: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                        invalidNumberMessage: 'Invalid phone number',
                        flagsButtonPadding: EdgeInsets.only(left: 16.w),
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.isPasswordVisible.value,
                          decoration: InputDecoration(
                            hintText: 'Create a password',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF999999),
                              fontSize: 16.sp,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF999999),
                                size: 20.sp,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            errorText: controller.passwordError.value,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                     Obx(
  () {
    if (controller.passwordStrengthLabel.value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: LinearProgressIndicator(
            value: controller.passwordStrength.value,
            minHeight: 8.h,
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(
              controller.passwordStrength.value <= 0.4
                  ? Colors.red
                  : controller.passwordStrength.value <= 0.8
                      ? Colors.orange
                      : const Color(0xFF00A86B),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Password strength: ${controller.passwordStrengthLabel.value}',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: controller.passwordStrength.value <= 0.4
                ? Colors.red
                : controller.passwordStrength.value <= 0.8
                    ? Colors.orange
                    : const Color(0xFF00A86B),
          ),
        ),
        SizedBox(height: 10.h),
        _PasswordRuleItem(
          label: 'At least 8 characters',
          isValid: controller.hasMinLength.value,
        ),
        _PasswordRuleItem(
          label: 'At least one uppercase letter',
          isValid: controller.hasUppercase.value,
        ),
        _PasswordRuleItem(
          label: 'At least one lowercase letter',
          isValid: controller.hasLowercase.value,
        ),
        _PasswordRuleItem(
          label: 'At least one number',
          isValid: controller.hasNumber.value,
        ),
        _PasswordRuleItem(
          label: 'At least one special character',
          isValid: controller.hasSpecialChar.value,
        ),
      ],
    );
  },
),
                      SizedBox(height: 16.h),
                      Obx(
                        () => TextField(
                          controller: controller.confirmPasswordController,
                          obscureText:
                              !controller.isConfirmPasswordVisible.value,
                          decoration: InputDecoration(
                            hintText: 'Confirm your password',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFF999999),
                              fontSize: 16.sp,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordVisible.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF999999),
                                size: 20.sp,
                              ),
                              onPressed:
                                  controller.toggleConfirmPasswordVisibility,
                            ),
                            errorText:
                                controller.confirmPasswordError.value,
                          ),
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Obx(
                        () => controller.selectedRole.value == 'Tourist'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 24.h),
                                  Text(
                                    'Help us personalize your experience',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Your Age',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: controller.age.value.isEmpty
                                            ? null
                                            : controller.age.value,
                                        hint: Text(
                                          'Select your age range',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF999999),
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        isExpanded: true,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        items: [
                                          '18-24',
                                          '25-34',
                                          '35-44',
                                          '45-54',
                                          '55-64',
                                          '65+',
                                        ]
                                            .map(
                                              (age) => DropdownMenuItem(
                                                value: age,
                                                child: Text(
                                                  age,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.sp,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.setAge(value);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                          size: 24.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Country of Residence',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  TextField(
                                    onChanged:
                                        controller.setCountryOfResidence,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your country',
                                      hintStyle: GoogleFonts.inter(
                                        color: const Color(0xFF999999),
                                        fontSize: 16.sp,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF5F5F5),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'What\'s your travel budget?',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: controller
                                                .travelBudget.value.isEmpty
                                            ? null
                                            : controller.travelBudget.value,
                                        hint: Text(
                                          'Select budget',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF999999),
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        isExpanded: true,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        items: [
                                          'Budget-friendly',
                                          'Mid-range',
                                          'Luxury',
                                        ]
                                            .map(
                                              (budget) => DropdownMenuItem(
                                                value: budget,
                                                child: Text(
                                                  budget,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.sp,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.setTravelBudget(value);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                          size: 24.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'What\'s your preferred travel pace?',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value:
                                            controller.travelPace.value.isEmpty
                                                ? null
                                                : controller.travelPace.value,
                                        hint: Text(
                                          'Select pace',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF999999),
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        isExpanded: true,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        items: [
                                          'Relaxed and slow-paced',
                                          'Action-packed and fast-paced',
                                          'A bit of both',
                                        ]
                                            .map(
                                              (pace) => DropdownMenuItem(
                                                value: pace,
                                                child: Text(
                                                  pace,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.sp,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.setTravelPace(value);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                          size: 24.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'What are your interests?',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Wrap(
                                    spacing: 12.w,
                                    runSpacing: 12.h,
                                    children: [
                                      'Adventure',
                                      'Cultural Heritage',
                                      'Nature & Wildlife',
                                      'Religious',
                                      'Beach',
                                      'Entertainment',
                                      'Historical',
                                      'Photography',
                                      'Food & Culinary',
                                      'Relaxation',
                                    ]
                                        .map(
                                          (interest) => Obx(
                                            () => GestureDetector(
                                              onTap: () => controller
                                                  .toggleInterest(interest),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 10.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: controller.interests
                                                          .contains(interest)
                                                      ? const Color(0xFF00A86B)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                  border: Border.all(
                                                    color: controller.interests
                                                            .contains(interest)
                                                        ? const Color(
                                                            0xFF00A86B)
                                                        : const Color(
                                                            0xFFE0E0E0),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  interest,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    color: controller.interests
                                                            .contains(interest)
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      Obx(
                        () => controller.selectedRole.value == 'Tour Guide'
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 24.h),
                                  Text(
                                    'Years of Experience',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: controller.yearsOfExperience
                                                .value.isEmpty
                                            ? null
                                            : controller
                                                .yearsOfExperience.value,
                                        hint: Text(
                                          'Select years',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF999999),
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        isExpanded: true,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        items: List.generate(
                                          21,
                                          (index) => DropdownMenuItem(
                                            value: index.toString(),
                                            child: Text(
                                              index.toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 16.sp,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.setYearsOfExperience(
                                              value,
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                          size: 24.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Specialization',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: controller
                                                .specialization.value.isEmpty
                                            ? null
                                            : controller.specialization.value,
                                        hint: Text(
                                          'Select type',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF999999),
                                            fontSize: 16.sp,
                                          ),
                                        ),
                                        isExpanded: true,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                        ),
                                        items: [
                                          'Historical Tours',
                                          'Adventure',
                                          'Cultural',
                                          'Nature & Wildlife',
                                        ]
                                            .map(
                                              (type) => DropdownMenuItem(
                                                value: type,
                                                child: Text(
                                                  type,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.sp,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            controller.setSpecialization(
                                              value,
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.black,
                                          size: 24.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Languages Spoken',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Wrap(
                                    spacing: 12.w,
                                    runSpacing: 12.h,
                                    children: [
                                      'Arabic',
                                      'English',
                                      'French',
                                      'Spanish',
                                    ]
                                        .map(
                                          (language) => Obx(
                                            () => GestureDetector(
                                              onTap: () => controller
                                                  .toggleLanguage(language),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 10.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: controller
                                                          .languagesSpoken
                                                          .contains(language)
                                                      ? const Color(0xFF00A86B)
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                  border: Border.all(
                                                    color: controller
                                                            .languagesSpoken
                                                            .contains(language)
                                                        ? const Color(
                                                            0xFF00A86B)
                                                        : const Color(
                                                            0xFFE0E0E0),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  language,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    color: controller
                                                            .languagesSpoken
                                                            .contains(language)
                                                        ? Colors.white
                                                        : Colors.black,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 24.h),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            color: const Color(0xFF666666),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(
                              text: 'By signing up, you agree to Daleelak\'s ',
                            ),
                            TextSpan(
                              text: 'Terms & Privacy Policy',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF333333),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Obx(
                        () => Container(
                          width: double.infinity,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: controller.isLoading.value
                                ? const Color(0xFFCCCCCC)
                                : const Color(0xFF00A86B),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.isLoading.value
                                  ? null
                                  : controller.createAccount,
                              borderRadius: BorderRadius.circular(30.r),
                              child: Center(
                                child: controller.isLoading.value
                                    ? SizedBox(
                                        width: 24.w,
                                        height: 24.h,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Create Account',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          Get.off(() => const LoginView());
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF00A86B),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordRuleItem extends StatelessWidget {
  final String label;
  final bool isValid;

  const _PasswordRuleItem({
    required this.label,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18.sp,
            color: isValid
                ? const Color(0xFF00A86B)
                : const Color(0xFF999999),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isValid
                    ? const Color(0xFF00A86B)
                    : const Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}