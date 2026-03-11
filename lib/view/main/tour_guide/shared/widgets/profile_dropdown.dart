import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';
import 'package:tour_app/view/main/tour_guide/profile/controllers/profile_controller.dart';

class ProfileDropdown extends StatelessWidget {
  const ProfileDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    final dashboardController = Get.find<DashboardController>();

    return GestureDetector(
      onTap: () =>
          _showDropdown(context, profileController, dashboardController),
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: const BoxDecoration(
          color: Color(0xFF00A86B),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Obx(
            () => Text(
              dashboardController.userName.value.isNotEmpty
                  ? dashboardController.userName.value[0].toUpperCase()
                  : 'G',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDropdown(
    BuildContext context,
    ProfileController profileController,
    DashboardController dashboardController,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Colors.white,
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => Text(
                  dashboardController.userName.value,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Obx(
                () => Text(
                  dashboardController.userEmail.value.isNotEmpty
                      ? dashboardController.userEmail.value
                      : 'No email',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
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
    ).then((value) {
      if (value == 'logout') {
        profileController.logout();
      } else if (value == 'edit') {
        profileController.editProfile();
      }
    });
  }
}
