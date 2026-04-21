import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/authentication/controllers/authentication_controller.dart';
import 'package:tour_app/view/authentication/views/create_account_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthenticationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          Icon(
                            Icons.language,
                            color: Colors.black,
                            size: 18.sp,
                          ),
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
              SizedBox(height: 40.h),
              Image.asset(
                'images/onboarding_logo.png',
                width: 100.w,
                height: 100.h,
              ),
              SizedBox(height: 24.h),
              Text(
                'Welcome Back',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Login to continue your journey',
                style: GoogleFonts.inter(
                  color: const Color(0xFF666666),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 40.h),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 24.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email Address',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      controller: controller.loginEmailController,
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
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Password',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => TextField(
                        controller: controller.loginPasswordController,
                        obscureText: !controller.isLoginPasswordVisible.value,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
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
                              controller.isLoginPasswordVisible.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF999999),
                              size: 20.sp,
                            ),
                            onPressed: controller.toggleLoginPasswordVisibility,
                          ),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
  onTap: () {
    controller.resetPassword(
      controller.loginEmailController.text,
    );
  },
  child: Text(
    'Forgot Password?',
    style: GoogleFonts.inter(
      color: const Color(0xFF00A86B),
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
    ),
  ),
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
                                : controller.login,
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
                                      'Login',
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
                    SizedBox(height: 24.h),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.inter(
                            color: const Color(0xFF666666),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(text: 'Don\'t have an account? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  Get.off(() => const CreateAccountView());
                                },
                                child: Text(
                                  'Sign up',
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
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
