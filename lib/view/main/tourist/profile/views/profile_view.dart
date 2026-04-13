import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/profile/controllers/profile_controller.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';
import 'package:tour_app/view/main/tourist/explore/views/package_details_view.dart';

class TouristProfileView extends StatelessWidget {
  const TouristProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TouristProfileController());
    final homeController = Get.find<TouristHomeController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.currentBottomNavIndex.value = 3;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(18.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 40.sp,
                                color: const Color(0xFF00A86B),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.userData['fullName'] ?? '',
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  _buildUserDetailRow(
                                    icon: Icons.email,
                                    text: controller.userData['email'] ?? '',
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildUserDetailRow(
                                    icon: Icons.phone,
                                    text: controller.userData['phone'] ?? '',
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildUserDetailRow(
                                    icon: Icons.location_on,
                                    text: controller.userData['location'] ?? '',
                                  ),
                                  SizedBox(height: 8.h),
                                  _buildUserDetailRow(
                                    icon: Icons.calendar_today,
                                    text:
                                        'Member since ${controller.userData['memberSince'] ?? ''}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildStatCard(
                                icon: Icons.star_outline,
                                iconColor: const Color(0xFF00A86B),
                                value: controller.toursCompleted.value.toString(),
                                label: 'Tours Completed',
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => _buildStatCard(
                                icon: Icons.favorite_outline,
                                iconColor: const Color(0xFFFF9800),
                                value: controller.savedTours.value.toString(),
                                label: 'Saved Tours',
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => _buildStatCard(
                                icon: Icons.card_giftcard,
                                iconColor: const Color(0xFF2196F3),
                                value: controller.rewardPoints.value.toString(),
                                label: 'Reward Points',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => _buildTourTab(
                                icon: Icons.star,
                                label: 'Completed Tours',
                                isSelected:
                                    controller.selectedTab.value ==
                                    'Completed Tours',
                                onTap: () =>
                                    controller.changeTab('Completed Tours'),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Obx(
                              () => _buildTourTab(
                                icon: Icons.favorite,
                                label: 'Saved Tours',
                                isSelected:
                                    controller.selectedTab.value ==
                                    'Saved Tours',
                                onTap: () =>
                                    controller.changeTab('Saved Tours'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Obx(
                      () => controller.selectedTab.value == 'Completed Tours'
                          ? _buildCompletedToursList(controller)
                          : _buildSavedToursList(controller),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            const TouristBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF666666), size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFF666666),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 24.sp,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTourTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00A86B)
                  : const Color(0xFF999999),
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? const Color(0xFF00A86B)
                    : const Color(0xFF999999),
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedToursList(TouristProfileController controller) {
    final tours = controller.completedTours;

    if (tours.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(40.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'No completed tours yet',
              style: GoogleFonts.inter(
                color: const Color(0xFF999999),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [...tours.map((tour) => _buildCompletedTourCard(tour))],
      ),
    );
  }

  Widget _buildSavedToursList(TouristProfileController controller) {
    final tours = controller.savedToursList;

    if (tours.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Container(
          padding: EdgeInsets.all(40.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              'No saved tours yet',
              style: GoogleFonts.inter(
                color: const Color(0xFF999999),
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: [
          ...tours.map((tour) => _buildSavedTourCard(tour, controller)),
        ],
      ),
    );
  }

  Widget _buildCompletedTourCard(Map<String, dynamic> tour) {
    final rating = (tour['rating'] as num?)?.toDouble() ?? 0.0;

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
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180.h,
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
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Completed',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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
                Text(
                  'Guide: ${tour['guide'] as String}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating.toInt()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    Text(
                      (tour['completionDate'] ?? '').toString(),
                      style: GoogleFonts.inter(
                        color: const Color(0xFF999999),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedTourCard(
    Map<String, dynamic> tour,
    TouristProfileController controller,
  ) {
    final rating = tour['rating'] as double;

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
            height: 180.h,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: tour['image'] != null &&
                    (tour['image'] as String).isNotEmpty
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
                Text(
                  'Guide: ${tour['guide'] as String}',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < rating.toInt() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20.sp,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Get.to(
                          () => PackageDetailsView(
                            packageId: tour['id'],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF00A86B)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF00A86B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        controller.removeSavedTour(tour['id']);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18.sp,
                      ),
                      label: Text(
                        'Remove',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}