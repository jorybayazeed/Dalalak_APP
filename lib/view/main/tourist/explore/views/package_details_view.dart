import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/explore/controllers/package_details_controller.dart';
import 'package:tour_app/view/main/tourist/bookings/views/booking_view.dart';


class PackageDetailsView extends StatelessWidget {
  final String packageId;
  final bool showBookingButton;

  const PackageDetailsView({
    super.key,
    required this.packageId,
    this.showBookingButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      PackageDetailsController(packageId: packageId),
      tag: packageId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.packageData.isEmpty) {
            return const Center(
              child: Text('Package not found'),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 250.h,
                  color: const Color(0xFFE0E0E0),
                  child: controller.image.isNotEmpty
                      ? Image.asset(
                          controller.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, size: 60);
                          },
                        )
                      : const Icon(Icons.image, size: 60),
                ),

                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Row(
                          children: const [
                            Icon(Icons.arrow_back),
                            SizedBox(width: 8),
                            Text('Back'),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        controller.title,
                        style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          SizedBox(width: 6.w),
                          Text(
                            controller.destination,
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey),
                          SizedBox(width: 6.w),
                          Text(
                            controller.duration,
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.grey),
                          SizedBox(width: 6.w),
                          Text(
                            controller.maxGroupSize,
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        controller.price,
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF00A86B),
                        ),
                      ),

                      SizedBox(height: 20.h),
                       Text(
  'Tour Guide',
  style: GoogleFonts.inter(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  ),
),

SizedBox(height: 12.h),

Container(
  width: double.infinity,
  padding: EdgeInsets.all(12.w),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(color: Colors.grey.shade300),
  ),
  child: Row(
    children: [
      CircleAvatar(
        radius: 28.r,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: controller.guideImage.value.isNotEmpty
            ? NetworkImage(controller.guideImage.value)
            : null,
        child: controller.guideImage.value.isEmpty
            ? Icon(Icons.person, size: 28.sp, color: Colors.white)
            : null,
      ),
      SizedBox(width: 12.w),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.guideName.value,
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Tour Guide',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ],
  ),
),

SizedBox(height: 20.h),
                      Text(
                        'Description',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        controller.description,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 20.h),

                      if (controller.activityType.isNotEmpty) ...[
                        Text(
                          'Activity Type',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.activityType,
                          style: GoogleFonts.inter(fontSize: 14.sp),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      if (controller.availableDates.isNotEmpty) ...[
                        Text(
                          'Available Dates',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.availableDates,
                          style: GoogleFonts.inter(fontSize: 14.sp),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      if (controller.activities.isNotEmpty) ...[
                        Text(
                          'Activities',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...controller.activities.map((activity) {
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity['activityName'] ?? '',
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                              ],
                            ),
                          );
                        }).toList(),
                      ],

                      SizedBox(height: 20.h),

                      Text(
                        'Reviews',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      if (controller.isRatingsLoading.value)
                        const Center(child: CircularProgressIndicator())
                      else if (controller.ratings.isEmpty)
                        Text(
                          'No reviews yet',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        )
                      else
                        ...controller.ratings.map((r) {
                          final userName = (r['userName'] ?? 'Tourist').toString();
                          final userImage = (r['userImage'] ?? '').toString();
                          final rating = (r['rating'] as int?) ?? 0;
                          final review = (r['review'] ?? '').toString();

                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18.r,
                                      backgroundColor: Colors.grey.shade300,
                                      backgroundImage: userImage.isNotEmpty
                                          ? NetworkImage(userImage)
                                          : null,
                                      child: userImage.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              size: 18.sp,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        userName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (i) {
                                        final filled = i < rating;
                                        return Icon(
                                          filled ? Icons.star : Icons.star_border,
                                          size: 16.sp,
                                          color: const Color(0xFFFFC107),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                if (review.trim().isNotEmpty) ...[
                                  SizedBox(height: 10.h),
                                  Text(
                                    review,
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),

                      SizedBox(height: 24.h),

                     if (showBookingButton)
  SizedBox(
    width: double.infinity,
    height: 50.h,
    child: ElevatedButton(
      onPressed: () {
        Get.to(
          () => BookingView(
            tour: controller.packageData,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00A86B),
      ),
      child: Text(
        'Book Now',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}