import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/profile/controllers/profile_controller.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final dashboardController = Get.find<DashboardController>();
    dashboardController.currentBottomNavIndex.value = 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 100.w,
                                height: 100.h,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0E0E0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  size: 60.sp,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(
                                      () => Text(
                                        controller.profileData['name']
                                            as String,
                                        style: GoogleFonts.inter(
                                          color: Colors.black,
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Obx(
                                      () => Text(
                                        controller.profileData['location']
                                            as String,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF666666),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Obx(
                                      () => Row(
                                        children: [
                                          _buildStatBox(
                                            value:
                                                '${controller.profileData['toursCount']}',
                                            label: 'Tours',
                                            color: const Color(0xFFE8F5E9),
                                            textColor: const Color(0xFF4CAF50),
                                          ),
                                          SizedBox(width: 8.w),
                                          Obx(
                                            () => _buildStatBox(
                                              value:
                                                  controller
                                                          .profileData['yearsOfExperience']
                                                      as String? ??
                                                  '0',
                                              label: 'Years Exp.',
                                              color: const Color(0xFFFFF9C4),
                                              textColor: const Color(
                                                0xFFF57F17,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          _buildStatBox(
                                            value:
                                                '${controller.profileData['languagesCount']}',
                                            label: 'Languages',
                                            color: const Color(0xFFE3F2FD),
                                            textColor: const Color(0xFF2196F3),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              if (controller.profileData['isVerified'] as bool)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00A86B),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'Verified Guide',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              SizedBox(width: 12.w),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${controller.profileData['rating']}',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${controller.profileData['reviewsCount']} reviews',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF666666),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.messageGuide,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00A86B),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              child: Text(
                                'Message',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Obx(
                            () => Text(
                              controller.profileData['bio'] as String,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionTitle('Languages'),
                          SizedBox(height: 12.h),
                          Obx(
                            () => Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children:
                                  (controller.profileData['languages'] as List)
                                      .map(
                                        (lang) => _buildChip(
                                          lang.toString(),
                                          isSpecialization: false,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionTitle('Specializations'),
                          SizedBox(height: 12.h),
                          Obx(
                            () => Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children:
                                  (controller.profileData['specializations']
                                          as List)
                                      .map(
                                        (spec) => _buildChip(
                                          spec.toString(),
                                          isSpecialization: true,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _buildSectionTitle('Achievements'),
                          SizedBox(height: 12.h),
                          Obx(
                            () => Column(
                              children:
                                  (controller.profileData['achievements']
                                          as List)
                                      .map(
                                        (achievement) => _buildAchievementItem(
                                          achievement as Map<String, dynamic>,
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildTab(
                                label: 'Tours',
                                count: controller.tours.length,
                                isSelected:
                                    controller.selectedTab.value == 'Tours',
                                onTap: () => controller.changeTab('Tours'),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => _buildTab(
                                label: 'Reviews',
                                count:
                                    controller.profileData['reviewsCount']
                                        as int,
                                isSelected:
                                    controller.selectedTab.value == 'Reviews',
                                onTap: () => controller.changeTab('Reviews'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => controller.selectedTab.value == 'Tours'
                          ? Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Column(
                                children: [
                                  ...controller.tours.map(
                                    (tour) => _buildTourCard(tour),
                                  ),
                                  SizedBox(height: 24.h),
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: Container(
                                padding: EdgeInsets.all(40.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Center(
                                  child: Text(
                                    'No reviews yet',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF999999),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
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
            TourGuideBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        height: 96.w,
        width: 96.w,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (label.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChip(String text, {required bool isSpecialization}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isSpecialization ? const Color(0xFF00A86B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isSpecialization
            ? null
            : Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: isSpecialization ? Colors.white : Colors.black,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAchievementItem(Map<String, dynamic> achievement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAchievementIcon(achievement['icon'] as String),
              color: Colors.amber[700],
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              achievement['title'] as String,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAchievementIcon(String iconType) {
    switch (iconType) {
      case 'star':
        return Icons.star;
      case 'award':
        return Icons.emoji_events;
      case 'people':
        return Icons.people;
      default:
        return Icons.star;
    }
  }

  Widget _buildTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            '$label ($count)',
            style: GoogleFonts.inter(
              color: isSelected ? Colors.black : const Color(0xFF666666),
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTourCard(Map<String, dynamic> tour) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 200.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: tour['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      topRight: Radius.circular(12.r),
                    ),
                    child: Image.asset(
                      tour['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFE0E0E0),
                          child: Icon(
                            Icons.image,
                            size: 48.sp,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  )
                : Icon(Icons.image, size: 48.sp, color: Colors.grey),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tour['title'] as String,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${tour['rating']} (${tour['reviews']})',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time,
                      color: const Color(0xFF666666),
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      tour['duration'] as String,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF666666),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  tour['price'] as String,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00A86B),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
