import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tour_app/view/main/tourist/explore/controllers/package_details_controller.dart';
import 'package:tour_app/view/main/tourist/bookings/views/booking_view.dart';
import 'package:url_launcher/url_launcher.dart';


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

GestureDetector(
  onTap: () {
    Get.dialog(
      _GuideProfileDialog(controller: controller),
    );
  },
  child: Container(
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
        Expanded(
          child: Column(
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
        ),
        Icon(Icons.chevron_right, color: Colors.grey, size: 22.sp),
      ],
    ),
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
class _GuideProfileDialog extends StatelessWidget {
  const _GuideProfileDialog({required this.controller});

  final PackageDetailsController controller;

  String _sanitizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';

    final onlyDigits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyDigits.isEmpty) return '';

    if (onlyDigits.startsWith('966')) {
      return onlyDigits;
    }

    if (onlyDigits.startsWith('0')) {
      final withoutZero = onlyDigits.substring(1);
      if (withoutZero.isNotEmpty) {
        return '966$withoutZero';
      }
    }

    if (onlyDigits.startsWith('5') && onlyDigits.length == 9) {
      return '966$onlyDigits';
    }

    return onlyDigits;
  }

  Future<void> _openWhatsApp(String phone) async {
    final sanitized = _sanitizePhone(phone);
    if (sanitized.isEmpty) {
      Get.snackbar('Error', 'Phone number not available');
      return;
    }

    final text = Uri.encodeComponent('Hello, I found you on Dalalak');
    final appUri = Uri.parse('whatsapp://send?phone=$sanitized&text=$text');
    final webUri = Uri.parse('https://wa.me/$sanitized?text=$text');

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      Get.snackbar('Error', 'Unable to open WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Obx(() {
          final name = controller.guideName.value;
          final image = controller.guideImage.value;
          final phone = controller.guidePhone.value;
          final years = controller.guideYearsOfExperience.value;
          final spec = controller.guideSpecialization.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tour Guide',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back<void>(),
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 18.sp),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A86B),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.white,
                      backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                      child: image.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'G',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF00A86B),
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Tour Guide' : name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          if (spec.trim().isNotEmpty)
                            Text(
                              spec,
                              style: GoogleFonts.inter(
                                color: Colors.white.withAlpha(230),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(Icons.badge, color: Colors.white, size: 14.sp),
                              SizedBox(width: 6.w),
                              Text(
                                years.trim().isEmpty ? '0 Years Exp.' : '$years Years Exp.',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18.sp),
                  SizedBox(width: 6.w),
                  if (controller.guideTotalReviews.value == 0)
                    Text(
                      'New Guide — No ratings yet',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF999999),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      '${controller.guideRating.value.toStringAsFixed(1)}  '
                      '(${controller.guideTotalReviews.value} '
                      '${controller.guideTotalReviews.value == 1 ? 'review' : 'reviews'})',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF333333),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              if (controller.guideLanguages.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(
                  'Languages',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF666666),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: controller.guideLanguages
                      .map(
                        (lang) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A86B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            lang,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF00A86B),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone, size: 16.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              phone.isEmpty ? 'Not available' : phone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: phone.isEmpty ? null : () => _openWhatsApp(phone),
                    child: Opacity(
                      opacity: phone.isEmpty ? 0.5 : 1,
                      child: Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Icon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}