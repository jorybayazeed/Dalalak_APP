import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tour_app/view/main/tour_guide/tours/controllers/live_tour_controller.dart';

class LiveTourView extends StatelessWidget {
  const LiveTourView({super.key, required this.packageId});

  final String packageId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveTourController(packageId: packageId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.packageData.isEmpty) {
            return Center(
              child: Text(
                'Tour not found',
                style: GoogleFonts.inter(
                  color: const Color(0xFF999999),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          final tourTitle = (controller.packageData['tourTitle'] ?? '').toString();

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back<void>(),
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back, size: 20.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        tourTitle.isEmpty ? 'Live Tour' : tourTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Obx(() {
                      final count = controller.registeredCount;
                      return GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(18.r),
                                ),
                              ),
                              child: SafeArea(
                                top: false,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Registered Tourists',
                                            style: GoogleFonts.inter(
                                              color: Colors.black,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => Get.back<void>(),
                                          child: Container(
                                            width: 36.w,
                                            height: 36.h,
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
                                    Obx(() {
                                      if (controller.bookings.isEmpty) {
                                        return Expanded(
                                          child: Center(
                                            child: Text(
                                              'No bookings yet',
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF999999),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Expanded(
                                        child: ListView.separated(
                                          itemCount: controller.bookings.length,
                                          separatorBuilder: (_, __) => Divider(height: 18.h),
                                          itemBuilder: (context, index) {
                                            final b = controller.bookings[index];
                                            final name = (b['fullName'] ?? '').toString();
                                            final email = (b['email'] ?? '').toString();
                                            final phone = (b['phone'] ?? '').toString();
                                            final guests = (b['guests'] as num?)?.toInt() ?? 0;

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name.isEmpty ? 'Tourist ${index + 1}' : name,
                                                  style: GoogleFonts.inter(
                                                    color: Colors.black,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                if (email.isNotEmpty)
                                                  Text(
                                                    email,
                                                    style: GoogleFonts.inter(
                                                      color: const Color(0xFF666666),
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                if (phone.isNotEmpty)
                                                  Text(
                                                    phone,
                                                    style: GoogleFonts.inter(
                                                      color: const Color(0xFF666666),
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                SizedBox(height: 6.h),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10.w,
                                                    vertical: 6.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFE3F2FD),
                                                    borderRadius: BorderRadius.circular(12.r),
                                                  ),
                                                  child: Text(
                                                    'Guests: $guests',
                                                    style: GoogleFonts.inter(
                                                      color: const Color(0xFF1565C0),
                                                      fontSize: 11.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            isScrollControlled: true,
                          );
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6A1B9A),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );
                    }),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: controller.isTourEnded.value
                              ? const Color(0xFFFFE0E0)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          controller.isTourEnded.value ? 'Ended' : 'Live',
                          style: GoogleFonts.inter(
                            color: controller.isTourEnded.value
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF00A86B),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: SizedBox(
                    height: 240.h,
                    child: FlutterMap(
                      mapController: controller.mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(24.7136, 46.6753),
                        initialZoom: 10,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.example.tour_app',
                          tileProvider: NetworkTileProvider(
                            headers: {
                              'User-Agent': 'com.example.tour_app',
                            },
                          ),
                        ),
                        Obx(
                          () => MarkerLayer(
                            markers: controller.activities.map((a) {
                              final pos = controller.activityLatLng(a);
                              if (pos == null) return null;

                              final id = controller.activityId(a);
                              final status = controller.statusFor(a);
                              final isActive = status == 'Active';
                              final isCompleted = status == 'Completed';

                              Color color = const Color(0xFF9E9E9E);
                              if (isCompleted) color = const Color(0xFF00A86B);
                              if (isActive) color = const Color(0xFF1565C0);

                              return Marker(
                                width: 44.w,
                                height: 44.h,
                                point: pos,
                                child: GestureDetector(
                                  onTap: () {
                                    if (id.isEmpty) return;
                                    Get.snackbar(
                                      controller.activityName(a),
                                      status,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  },
                                  child: Icon(
                                    Icons.location_on,
                                    color: color,
                                    size: 34.sp,
                                  ),
                                ),
                              );
                            }).whereType<Marker>().toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 18.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Obx(() {
                    if (controller.activities.isEmpty) {
                      return Center(
                        child: Text(
                          'No activities',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF999999),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activities',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: ListView.separated(
                            itemCount: controller.activities.length,
                            separatorBuilder: (_, __) => Divider(height: 18.h),
                            itemBuilder: (context, index) {
                              final a = controller.activities[index];
                              final id = controller.activityId(a);
                              final name = controller.activityName(a);
                              final place = (a['activityPlace'] ?? '').toString();
                              final status = controller.statusFor(a);

                              final isActive = status == 'Active';
                              final isCompleted = status == 'Completed';

                              Color pillColor = const Color(0xFFE0E0E0);
                              Color pillText = const Color(0xFF666666);
                              if (isCompleted) {
                                pillColor = const Color(0xFFE8F5E9);
                                pillText = const Color(0xFF00A86B);
                              }
                              if (isActive) {
                                pillColor = const Color(0xFFE3F2FD);
                                pillText = const Color(0xFF1565C0);
                              }

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 10.w,
                                    height: 10.h,
                                    margin: EdgeInsets.only(top: 6.h),
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? const Color(0xFF00A86B)
                                          : (isActive
                                              ? const Color(0xFF1565C0)
                                              : const Color(0xFF9E9E9E)),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name.isEmpty ? 'Activity ${index + 1}' : name,
                                                style: GoogleFonts.inter(
                                                  color: Colors.black,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: pillColor,
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              child: Text(
                                                status,
                                                style: GoogleFonts.inter(
                                                  color: pillText,
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (place.isNotEmpty) ...[
                                          SizedBox(height: 4.h),
                                          Text(
                                            place,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF666666),
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                        SizedBox(height: 10.h),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: controller.isTourEnded.value || id.isEmpty
                                                    ? null
                                                    : () => controller.startActivity(id),
                                                child: Opacity(
                                                  opacity: controller.isTourEnded.value ? 0.5 : 1,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1565C0),
                                                      borderRadius: BorderRadius.circular(10.r),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Start Activity',
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 12.sp,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: controller.isTourEnded.value
                                                    ? null
                                                    : () => controller.completeActiveActivity(),
                                                child: Opacity(
                                                  opacity: controller.isTourEnded.value ? 0.5 : 1,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF00A86B),
                                                      borderRadius: BorderRadius.circular(10.r),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Complete Activity',
                                                        style: GoogleFonts.inter(
                                                          color: Colors.white,
                                                          fontSize: 12.sp,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: controller.isTourEnded.value
                              ? controller.restartTour
                              : controller.endTour,
                          child: Opacity(
                            opacity: 1,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                color: controller.isTourEnded.value
                                    ? const Color(0xFF1565C0)
                                    : const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Center(
                                child: Text(
                                  controller.isTourEnded.value
                                      ? 'Restart Tour'
                                      : 'End Tour',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              SizedBox(height: 18.h),
            ],
          );
        }),
      ),
    );
  }
}
