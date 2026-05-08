import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/services/weather_service.dart';
import 'package:tour_app/view/main/tourist/bookings/controllers/bookings_controller.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingsController());
    final homeController = Get.find<TouristHomeController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.currentBottomNavIndex.value = 2;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Text(
                'My Bookings',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _buildTab(
                        label: 'All',
                        isSelected: controller.selectedTab.value == 'All',
                        onTap: () => controller.changeTab('All'),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => _buildTab(
                        label: 'Upcoming',
                        isSelected: controller.selectedTab.value == 'Upcoming',
                        onTap: () => controller.changeTab('Upcoming'),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => _buildTab(
                        label: 'Completed',
                        isSelected: controller.selectedTab.value == 'Completed',
                        onTap: () => controller.changeTab('Completed'),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Obx(
                      () => _buildTab(
                        label: 'Cancelled',
                        isSelected: controller.selectedTab.value == 'Cancelled',
                        onTap: () => controller.changeTab('Cancelled'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final bookings = controller.filteredBookings;

                if (bookings.isEmpty) {
                  return Center(
                    child: Text(
                      'No bookings found',
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
                      ...bookings.map(
                        (booking) => _buildBookingCard(booking, controller),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              }),
            ),
            TouristBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.black : const Color(0xFF999999),
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
    BookingsController controller,
  ) {
    return GestureDetector(
      onTap: () {
        controller.viewDetails(booking['id']);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking['title'] ?? '',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 8.h,
              children: [
                _buildInfoItem(
                  Icons.location_on_outlined,
                  booking['location'] ?? '',
                ),
                _buildInfoItem(
                  Icons.calendar_today_outlined,
                  booking['date'] ?? '',
                ),
                _buildInfoItem(
                  Icons.access_time,
                  booking['time'] ?? '',
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Obx(() {
              final weather = controller.weatherByBookingId[booking['id']];
              if (weather == null ||
                  weather.tripRecommendation.level == WeatherRiskLevel.normal) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildWeatherAlert(weather),
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking['price'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00A86B),
                  ),
                ),
                SizedBox(
                  height: 36.h,
                  child: OutlinedButton(
                    onPressed: () {
                      controller.viewDetails(booking['id']);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00A86B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Details',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00A86B),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF777777)),
        SizedBox(width: 4.w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: const Color(0xFF777777),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAlert(SmartWeatherAssessment assessment) {
    final rec = assessment.tripRecommendation;
    final trip = assessment.tripForecast;
    final quickTips = _buildTripQuickTips(assessment);
    final color = switch (rec.level) {
      WeatherRiskLevel.normal => const Color(0xFF2E7D32),
      WeatherRiskLevel.caution => const Color(0xFFF9A825),
      WeatherRiskLevel.warning => const Color(0xFFEF6C00),
      WeatherRiskLevel.danger => const Color(0xFFC62828),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (trip != null) ...[
            SizedBox(height: 4.h),
            Text(
              'Forecast: ${trip.temperatureC.toStringAsFixed(0)}°C • Rain ${trip.precipitationProbability}% • Wind ${trip.windSpeedKmH.toStringAsFixed(0)} km/h',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            rec.message,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: const Color(0xFF4A4A4A),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (quickTips.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              'Quick tips:',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            ...quickTips.map(
              (tip) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  '• $tip',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<String> _buildTripQuickTips(SmartWeatherAssessment assessment) {
    final trip = assessment.tripForecast;
    final rec = assessment.tripRecommendation;
    final tips = <String>[];

    if (trip != null) {
      if (trip.temperatureC >= 38) {
        tips.add(
          'Very hot weather expected. Carry extra water and avoid midday sun.',
        );
      } else if (trip.temperatureC <= 8) {
        tips.add(
          'Cold weather expected. Wear warm layers and keep outdoor time short.',
        );
      }

      if (trip.precipitationProbability >= 55 || trip.weatherCode >= 61) {
        tips.add(
          'Rain is likely. Bring an umbrella and suitable shoes for wet roads.',
        );
      }

      if (trip.windSpeedKmH >= 35) {
        tips.add(
          'Strong wind expected. Avoid exposed open areas when possible.',
        );
      }
    }

    for (final tip in rec.tips) {
      if (tips.length >= 3) break;
      if (!tips.contains(tip)) {
        tips.add(tip);
      }
    }

    return tips.take(3).toList();
  }
}
