import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
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

                    /// COMPLETED TOURS
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Obx(() {
                        final tours = controller.tours;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// TITLE + COUNT
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Completed Tours ",
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "(${tours.length} Tours)",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12.h),

                            ///   EMPTY STATE
                            if (tours.isEmpty)
                              SizedBox(
                                height: 200.h,
                                child: Center(
                                  child: Text(
                                    "No completed tours yet",
                                    style: GoogleFonts.inter(fontSize: 14.sp),
                                  ),
                                ),
                              ),

                            /// LIST
                            ...tours.map((tour) => _buildGuideTourCard(tour)),

                            SizedBox(height: 24.h),
                          ],
                        );
                      }),
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

  Widget _buildGuideTourCard(Map<String, dynamic> tour) {
    final guideController = Get.find<GuideToursController>();

    final id = (tour['id'] ?? '').toString();
    final title = (tour['title'] ?? '').toString();
    final destination = (tour['destination'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        if (id.isEmpty) return;

        Get.dialog(_TourRatingsDialog(tourId: id, tourTitle: title));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 6.h),

            Text(
              destination,
              style: GoogleFonts.inter(
                color: const Color(0xFF666666),
                fontSize: 12.sp,
              ),
            ),

            SizedBox(height: 10.h),

            Obx(() {
              final avg = guideController.averageRatingByTourId[id] ?? 0.0;
              final count = guideController.ratingsCountByTourId[id] ?? 0;

              return Row(
                children: [
                  Icon(Icons.star, size: 18.sp, color: const Color(0xFFFFC107)),
                  SizedBox(width: 6.w),
                  Text(
                    count == 0
                        ? 'No ratings yet'
                        : '${avg.toStringAsFixed(1)} ($count)',
                  ),
                ],
              );
            }),

            SizedBox(height: 12.h),

            Row(
              children: [
                Icon(Icons.people, size: 18.sp),
                SizedBox(width: 6.w),
                Obx(() {
                  final count =
                      guideController.registeredCountByTourId[id] ?? 0;
                  return Text('$count registered');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TourRatingsDialog extends StatelessWidget {
  const _TourRatingsDialog({required this.tourId, required this.tourTitle});

  final String tourId;
  final String tourTitle;

  Widget _buildStars({required int rating}) {
    return Row(
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: const Color(0xFFFFC107),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideToursController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Ratings",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            Text(
              tourTitle,
              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
            ),

            SizedBox(height: 12.h),

            Obx(() {
              final ratings = controller.ratingsByTourId[tourId] ?? [];

              if (ratings.isEmpty) {
                return const Text('No ratings yet');
              }

              return Column(
                children: ratings.map((r) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            r['userName'] ?? '',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                          _buildStars(
                            rating: (r['rating'] as num?)?.toInt() ?? 0,
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        r['review'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[700],
                        ),
                      ),

                      const Divider(),
                    ],
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
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
