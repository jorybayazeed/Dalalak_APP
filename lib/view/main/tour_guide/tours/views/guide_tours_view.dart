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
    
    final liveState = tour['liveTourState'];
    final isActive = liveState != null && liveState['ended'] == false;

    final id = (tour['id'] ?? '').toString();
    final title = (tour['title'] ?? '').toString();
    final destination = (tour['destination'] ?? '').toString();

    return Stack(
      children: [

        /// الكرت الأصلي (بدون أي تغيير)
        Container(
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

              /// Rating
              Obx(() {
  final avg = controller.averageRatingByTourId[id] ?? 0.0;
  final count = controller.ratingsCountByTourId[id] ?? 0;
  final displayAvg = avg.isNaN ? 0.0 : avg;

  return InkWell(
    onTap: count == 0
        ? null
        : () {
            Get.dialog(
              _TourRatingsDialog(tourId: id, tourTitle: title),
            );
          },
    child: Row(
      children: [
        Icon(Icons.star, size: 18.sp, color: const Color(0xFFFFC107)),
        SizedBox(width: 6.w),

        Text(
          displayAvg.toStringAsFixed(1),
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(width: 4.w),

        Text(
          '($count)',
          style: GoogleFonts.inter(
            color: Colors.grey,
            fontSize: 11.sp,
          ),
        ),
      ],
    ),
  );
}),
              SizedBox(height: 12.h),

              /// Count + Buttons
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.people, size: 18.sp, color: Colors.black),
                        SizedBox(width: 6.w),
                        Obx(() {
                          final count = controller.registeredCountByTourId[tour['id']] ?? 0;
                          print("UI ID: ${tour['id']}");
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

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: id.isEmpty
                                ? null
                                : () async {
                                    await controller.startTour(id); 
                                    Get.to(() => LiveTourView(packageId: id));
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00A86B),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Start',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        Expanded(
                          child: GestureDetector(
                            onTap: isActive
                                ? null
                                : () {
                                    Get.dialog(
                                      AlertDialog(
                                        title: const Text(
                                          'Cancel Tour',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to cancel this tour?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Get.back();
                                              controller.cancelTour(id);
                                            },
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.grey : Colors.red,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                'Cancel',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// 🔥 الإضافة الوحيدة (indicator)
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4),
              Text(
                isActive ? 'Active' : 'Not Active',
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
class _TourRatingsDialog extends StatelessWidget {
  const _TourRatingsDialog({
    required this.tourId,
    required this.tourTitle,
  });

  final String tourId;
  final String tourTitle;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuideToursController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final ratings = controller.ratingsByTourId[tourId] ?? [];

          if (ratings.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tourTitle, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('No ratings yet'),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tourTitle,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    final r = ratings[index];

                    return Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// 👤 اسم المستخدم
      Text(
        r['userName'] ?? 'User',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),

      const SizedBox(height: 6),

      /// ⭐ النجوم
      Row(
        children: List.generate(5, (i) {
          return Icon(
            i < (r['rating'] ?? 0)
                ? Icons.star
                : Icons.star_border,
            size: 16,
            color: const Color(0xFFFFC107),
          );
        }),
      ),

      /// 💬 التعليق (إذا موجود)
      if ((r['review'] ?? '').toString().isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(
          r['review'],
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ],
    ],
  ),
);
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}