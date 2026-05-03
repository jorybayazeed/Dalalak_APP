import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/profile_dropdown.dart';
import 'package:tour_app/view/main/tour_guide/profile/controllers/profile_controller.dart';
import 'package:tour_app/view/main/tour_guide/notifications/controllers/guide_notifications_controller.dart';
import 'package:tour_app/view/main/tour_guide/notifications/views/guide_notifications_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final profileController = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "images/onboarding_logo.png",
                    height: 36.w,
                    width: 36.w,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const NotificationsView());
                        },
                        child: Stack(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: Colors.black,
                                size: 22.sp,
                              ),
                            ),
                            Positioned(
                              right: 4.w,
                              top: 4.h,
                              child: Obx(() {
                                final count = Get.find<NotificationsController>()
                                    .unreadCount;
                                if (count <= 0) {
                                  return const SizedBox.shrink();
                                }
                                final label = count > 9 ? '9+' : '$count';
                                return Container(
                                  constraints: BoxConstraints(
                                    minWidth: 16.w,
                                    minHeight: 16.h,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.rectangle,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    label,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      const ProfileDropdown(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 16.h,
                          ),
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A86B),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80.w,
                                    height: 80.h,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00A86B),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      height: 36.w,
                                      width: 36.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Center(
                                          child: Text(
                                            'G',
                                            style: GoogleFonts.inter(
                                              color: Color(0xFF00A86B),
                                              fontSize: 36.sp,
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Obx(
                                          () => Text(
                                            profileController
                                                    .profileData['name'] ??
                                                'Tour Guide',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Obx(
                                          () => Text(
                                            profileController
                                                            .profileData['specializations'] !=
                                                        null &&
                                                    profileController
                                                        .profileData['specializations']
                                                        .isNotEmpty
                                                ? profileController
                                                      .profileData['specializations'][0]
                                                : (profileController
                                                          .profileData['specialization'] ??
                                                      'Tour Guide'),
                                            style: GoogleFonts.inter(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Wrap(
                                          spacing: 8.w,
                                          runSpacing: 8.h,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 12.sp,
                                                ),
                                                SizedBox(width: 4.w),
                                                Obx(
                                                  () => Text(
                                                    profileController
                                                        .averageRating
                                                        .value
                                                        .toStringAsFixed(1),
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Obx(
                                () => Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children:
                                      (profileController
                                                  .profileData['languages'] ??
                                              [])
                                          .map<Widget>(
                                            (language) => _buildLanguageChip(
                                              language.toString(),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 30.h,
                          right: 30.w,
                          child: Obx(() {
                            final isVerified =
                                profileController.profileData['isVerified'] ??
                                false;

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.check_circle
                                        : Icons.pending,
                                    color: Color(0xFF00A86B),
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    isVerified ? 'Verified' : 'Pending',
                                    style: GoogleFonts.inter(
                                      color: Color(0xFF00A86B),
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildMetricCard(
                                icon: Icons.inventory_2,
                                iconColor: Colors.blue,
                                value: '${controller.totalPackages.value}',
                                label: 'Total Packages',
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => _buildMetricCard(
                                icon: Icons.calendar_today,
                                iconColor: const Color(0xFF00A86B),
                                value: '${controller.activeTours.value}',
                                label: 'Active Tours',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildMetricCard(
                                icon: Icons.bar_chart,
                                iconColor: Colors.purple,
                                value: '${controller.totalBookings.value}',
                                label: 'Total Bookings',
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => _buildMetricCard(
                                icon: Icons.star,
                                iconColor: Colors.amber,
                                value: profileController.averageRating.value
                                    .toStringAsFixed(1),
                                label: 'Average Rating',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: _buildActionCard(
                        icon: Icons.tour,
                        iconColor: const Color(0xFF1565C0),
                        title: 'My Tours',
                        subtitle: 'Start and manage live tours',
                        onTap: controller.viewMyTours,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.add,
                              iconColor: const Color(0xFF00A86B),
                              title: 'Create Tour Package',
                              subtitle: 'Design a new tour experience',
                              onTap: controller.createTourPackage,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildActionCard(
                              icon: Icons.inventory_2,
                              iconColor: Colors.blue,
                              title: 'Manage Packages',
                              subtitle: 'Edit and organize your tours',
                              onTap: controller.managePackages,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: _buildActionCard(
                        icon: Icons.chat,
                        iconColor: Colors.purple,
                        title: 'Chat with Tourists',
                        subtitle: 'Message your customers',
                        onTap: controller.chatWithTourists,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TourGuideBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String language) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        language,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20.sp),
          SizedBox(height: 12.h),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF666666),
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF999999),
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF666666),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

