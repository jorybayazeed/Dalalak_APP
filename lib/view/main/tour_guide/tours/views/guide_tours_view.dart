import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tour_guide/tours/controllers/guide_tours_controller.dart';
import 'package:tour_app/view/main/tour_guide/tours/views/live_tour_view.dart';

class GuideToursView extends StatelessWidget {
  const GuideToursView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GuideToursController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Tours',
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.tours.isEmpty) {
                  return Center(
                    child: Text(
                      'No tours yet',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF999999),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                  child: Column(
                    children: [
                      ...controller.tours.map((t) => _TourCard(tour: t)),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              }),
            ),
            const TourGuideBottomNavigationBar(),
          ],
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({required this.tour});

  final Map<String, dynamic> tour;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideToursController>();

    final id = (tour['id'] ?? '').toString();
    final title = (tour['title'] ?? '').toString();
    final destination = (tour['destination'] ?? '').toString();

    return Container(
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
              color: Colors.black,
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
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final avg = controller.averageRatingByTourId[id] ?? 0.0;
            final count = controller.ratingsCountByTourId[id] ?? 0;
            final displayAvg = avg.isNaN ? 0.0 : avg;
            final label = count == 0
                ? 'No ratings yet'
                : '${displayAvg.toStringAsFixed(1)} ($count)';

            return InkWell(
              onTap: count == 0
                  ? null
                  : () {
                      Get.dialog(
                        _TourRatingsDialog(tourId: id, tourTitle: title),
                        barrierDismissible: true,
                      );
                    },
              child: Row(
                children: [
                  Icon(Icons.star, size: 18.sp, color: const Color(0xFFFFC107)),
                  SizedBox(width: 6.w),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.people, size: 18.sp, color: Colors.black),
                    SizedBox(width: 6.w),
                    Obx(() {
                      final count = controller.registeredCountByTourId[id] ?? 0;
                      return Text(
                        '$count registered',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: id.isEmpty ? null : () => Get.to(() => LiveTourView(packageId: id)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A86B),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Start Tour',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TourRatingsDialog extends StatelessWidget {
  const _TourRatingsDialog({required this.tourId, required this.tourTitle});

  final String tourId;
  final String tourTitle;

  Widget _buildStars({required int rating}) {
    final safe = rating.clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < safe;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideToursController>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ratings',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back<void>(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tourTitle,
              style: GoogleFonts.inter(
                color: const Color(0xFF666666),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Obx(() {
                final ratings = controller.ratingsByTourId[tourId] ??
                    const <Map<String, dynamic>>[];
                if (ratings.isEmpty) {
                  return Center(
                    child: Text(
                      'No ratings yet',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF999999),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: ratings.length,
                  separatorBuilder: (_, __) => const Divider(height: 18),
                  itemBuilder: (context, index) {
                    final r = ratings[index];
                    final name = (r['userName'] ?? 'Tourist').toString();
                    final rating = (r['rating'] as num?)?.toInt() ?? 0;
                    final review = (r['review'] ?? '').toString();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _buildStars(rating: rating),
                          ],
                        ),
                        if (review.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            review,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF666666),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
