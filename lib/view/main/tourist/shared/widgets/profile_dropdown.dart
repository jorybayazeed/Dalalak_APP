import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/services/auth_service.dart';
import 'package:tour_app/services/storage_service.dart';
import 'package:tour_app/view/authentication/views/login_view.dart';
import 'package:tour_app/view/main/tourist/profile/controllers/profile_controller.dart';

class TouristProfileDropdown extends StatelessWidget {
  const TouristProfileDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TouristProfileController>()
        ? Get.find<TouristProfileController>()
        : Get.put(TouristProfileController(), permanent: false);

    return GestureDetector(
      onTap: () => _showDropdown(context, controller),
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: const BoxDecoration(
          color: Color(0xFF00A86B),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Obx(() {
            final fullName =
                (controller.userData['fullName'] ?? '').toString().trim();

            final firstLetter =
                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

            return Text(
              firstLetter,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showDropdown(
    BuildContext context,
    TouristProfileController controller,
  ) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx + size.width - 200.w,
        offset.dy + size.height + 8.h,
        offset.dx + size.width,
        offset.dy + size.height + 8.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: Colors.white,
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Obx(() {
            final fullName =
                (controller.userData['fullName'] ?? 'Tourist').toString().trim();

            final email =
                (controller.userData['email'] ?? 'tourist@example.com')
                    .toString()
                    .trim();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fullName.isEmpty ? 'Tourist' : fullName,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  email.isEmpty ? 'tourist@example.com' : email,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          }),
        ),
        PopupMenuDivider(height: 1.h),
        PopupMenuItem<String>(
          value: 'edit',
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(Icons.edit, color: Colors.black, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                'Edit Profile',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(Icons.arrow_forward, color: Colors.red, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) async {
      if (value == 'logout') {
        await _logoutDirectly();
      } else if (value == 'edit') {
        controller.editProfile();
      }
    });
  }

  Future<void> _logoutDirectly() async {
    try {
      final authService = Get.find<AuthService>();
      await authService.signOut();
      await StorageService.clearAll();
      Get.offAll(() => const LoginView());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}