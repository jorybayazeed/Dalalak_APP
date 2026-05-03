import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tour_app/view/main/tour_guide/completed_tours/controllers/guide_completed_tours_controller.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tour_guide/profile/controllers/profile_controller.dart';
import 'package:tour_app/view/main/tour_guide/tours/controllers/guide_tours_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    Get.put(GuideToursController());

    final dashboardController = Get.find<DashboardController>();
    dashboardController.currentBottomNavIndex.value = 3;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      bottomNavigationBar: const TourGuideBottomNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// HEADER
                    Obx(
                      () => Container(
                        margin: EdgeInsets.all(18.w),
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  child: Text(
                                    controller.profileData['name']?[0] ?? 'G',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF00A86B),
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 14.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.profileData['name'] ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),

                                      SizedBox(height: 8.h),

                                      _row(
                                        Icons.email_outlined,
                                        controller.profileData['email'] ?? '',
                                      ),
                                      _row(
                                        Icons.call_outlined,
                                        '+966 ${controller.profileData['phone'] ?? ''}',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 12.h),

                            SizedBox(
                              width: double.infinity,
                              height: 45.h,
                              child: ElevatedButton(
                                onPressed: controller.editProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A86B),
                                ),
                                child: const Text("Edit Profile"),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 20.h),
                      child: Obx(() {
                        final data = controller.profileData;

                        return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// TITLE
                              Text(
                                'Guide Information',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              SizedBox(height: 14.h),

                              /// EXPERIENCE
                              _simpleRow(
                                title: 'Experience',
                                value:
                                    '${data['yearsOfExperience'] ?? 0} Years',
                              ),

                              SizedBox(height: 10.h),

                              /// SPECIALIZATION
                              _simpleRow(
                                title: 'Specialization',
                                value:
                                    (data['specializations'] != null &&
                                        data['specializations'].isNotEmpty)
                                    ? data['specializations'][0]
                                    : 'Not specified',
                              ),

                              SizedBox(height: 10.h),

                              /// LANGUAGES
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Languages',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),

                                  Wrap(
                                    spacing: 6.w,
                                    children: (data['languages'] ?? [])
                                        .map<Widget>(
                                          (lang) => Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 4.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF00A86B,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(10.r),
                                            ),
                                            child: Text(
                                              lang.toString(),
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF00A86B),
                                                fontSize: 11.sp,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    /// COMPLETED TOURS (from endedSessions)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Builder(
                        builder: (_) {
                          final completedCtrl =
                              Get.put(GuideCompletedToursController());
                          return Obx(() {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Completed Tours',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                _buildCompletedToursSummary(
                                  completedCtrl.totalCompleted,
                                ),
                                SizedBox(height: 12.h),
                                if (completedCtrl.sessions.isEmpty)
                                  _buildCompletedToursEmpty(completedCtrl)
                                else
                                  ...completedCtrl.sessions.map(
                                    (s) => _buildCompletedSessionCard(
                                      s,
                                      completedCtrl,
                                    ),
                                  ),
                                SizedBox(height: 24.h),
                              ],
                            );
                          });
                        },
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

  Widget _row(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey),
        SizedBox(width: 6.w),
        Text(text),
      ],
    );
  }

  Widget _buildCompletedToursSummary(int total) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF00A86B),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Completed Tours',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '$total',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedToursEmpty(GuideCompletedToursController controller) {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 36.sp,
            color: const Color(0xFFBDBDBD),
          ),
          SizedBox(height: 10.h),
          Text(
            'No completed tours yet',
            style: GoogleFonts.inter(
              color: const Color(0xFF999999),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'If you ended tours before this update, tap below to restore them.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: const Color(0xFF999999),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Obx(() {
            final busy = controller.isBackfilling.value;
            return SizedBox(
              height: 40.h,
              child: ElevatedButton.icon(
                onPressed: busy
                    ? null
                    : () async {
                        final created = await controller.restoreHistory();
                        Get.snackbar(
                          'Restore History',
                          created > 0
                              ? 'Restored $created past tour${created == 1 ? '' : 's'}.'
                              : 'No past tours found to restore.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                icon: busy
                    ? SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.history, size: 16.sp, color: Colors.white),
                label: Text(
                  busy ? 'Restoring...' : 'Restore History',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A86B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompletedSessionCard(
    Map<String, dynamic> s,
    GuideCompletedToursController controller,
  ) {
    final title = (s['packageTitle'] ?? '').toString().isEmpty
        ? 'Untitled tour'
        : s['packageTitle'].toString();
    final endedRelative = controller.formatRelative(s['endedAt']);
    final registered = (s['registeredCount'] as int?) ?? 0;
    final rating = (s['rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = (s['reviews'] as int?) ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (endedRelative.isNotEmpty)
                Text(
                  endedRelative,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF999999),
                    fontSize: 11.sp,
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildCompletedStat(
                icon: Icons.people_outline,
                label: '$registered registered',
                color: const Color(0xFF1565C0),
              ),
              SizedBox(width: 12.w),
              _buildCompletedStat(
                icon: Icons.star,
                label: rating > 0
                    ? '${rating.toStringAsFixed(1)} ($reviews)'
                    : 'No ratings',
                color: rating > 0 ? Colors.amber : const Color(0xFF999999),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedStat({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          label,
          style: GoogleFonts.inter(
            color: const Color(0xFF333333),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

}

Widget _simpleRow({required String title, required String value}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.inter(fontSize: 11.sp, color: Colors.grey),
      ),
      SizedBox(height: 4.h),
      Text(
        value,
        style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
