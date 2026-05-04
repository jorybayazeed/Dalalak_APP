import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';
import 'package:tour_app/view/main/tourist/home/controllers/weather_controller.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/profile_dropdown.dart';

class TouristHomeView extends StatelessWidget {
  const TouristHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TouristHomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(6.w),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.emoji_events,
                                size: 12.sp,
                                color: const Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.explore,
                                size: 12.sp,
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.park,
                                size: 12.sp,
                                color: const Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.extension,
                                size: 12.sp,
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        height: 40.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.language,
                              color: Colors.black,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'AR',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Stack(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_outlined,
                              color: Colors.black,
                              size: 22.sp,
                            ),
                          ),
                          Positioned(
                            right: 8.w,
                            top: 8.h,
                            child: Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      const TouristProfileDropdown(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi User, ready to explore?',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Discover amazing tours and experiences across Saudi Arabia',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF666666),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                   
                    SizedBox(height: 20.h),
                    _WeatherCard(),
                    SizedBox(height: 20.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 32.sp,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Total Points',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Obx(
                                  () => Text(
                                    '${controller.totalPoints}',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 36.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 6.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 14.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          Obx(
                                            () => Text(
                                              controller.level.value,
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.workspace_premium,
                                          color: Colors.amber[300],
                                          size: 16.sp,
                                        ),
                                        SizedBox(width: 4.w),
                                        Obx(
                                          () => Text(
                                            '${controller.badgesCount}',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'Badges',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.viewRewards,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'View Rewards',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFFF9800),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AlUla Heritage Tour - Dec 25, 2024',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Complete activities to earn points!',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF666666),
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Obx(
                                () => Text(
                                  '${controller.completedActivities}/${controller.totalActivities} completed',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF00A86B),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            width: double.infinity,
                            height: 200.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.map,
                                        size: 48.sp,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Map View',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF666666),
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 40.h,
                                  left: 60.w,
                                  child: _buildMapMarker(
                                    'Elephant Rock',
                                    Icons.place,
                                    Colors.orange,
                                  ),
                                ),
                                Positioned(
                                  bottom: 60.h,
                                  left: 100.w,
                                  child: _buildMapMarker(
                                    'Hegra Archaeological Site',
                                    Icons.place,
                                    Colors.orange,
                                  ),
                                ),
                                Positioned(
                                  top: 50.h,
                                  right: 80.w,
                                  child: _buildMapMarker(
                                    'Old Town',
                                    Icons.place,
                                    Colors.orange,
                                  ),
                                ),
                                Positioned(
                                  top: 20.h,
                                  left: 40.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      '15',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                     SizedBox(height: 24.h),

Padding(
  padding: EdgeInsets.symmetric(horizontal: 18.w),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        'Recommended For You',
        style: GoogleFonts.inter(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),

      SizedBox(height: 12.h),

      Obx(() {

        if (controller.recommendedTours.isEmpty) {
          return const SizedBox();
        }

        return Column(
          children: controller.recommendedTours.map((tour) {

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [

                  Icon(
                    Icons.explore,
                    color: const Color(0xFF00A86B),
                    size: 24.sp,
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          tour['tourTitle'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          tour['destination'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '${tour['price']} SAR',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                ],
              ),
            );

          }).toList(),
        );

      })

    ],
  ),
),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: controller.viewMyRewards,
                                  child: Container(
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9C4),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFFFF9800),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: const Color(0xFFFF9800),
                                          size: 32.sp,
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'My Rewards',
                                          style: GoogleFonts.inter(
                                            color: Colors.black,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Obx(
                                          () => Text(
                                            '${controller.rewardsPoints} points',
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF666666),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: GestureDetector(
                                  onTap: controller.openSettings,
                                  child: Container(
                                    padding: EdgeInsets.all(20.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: const Color(0xFF2196F3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.settings,
                                          color: const Color(0xFF2196F3),
                                          size: 32.sp,
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'Settings',
                                          style: GoogleFonts.inter(
                                            color: Colors.black,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Manage profile',
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF666666),
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            TouristBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMarker(String label, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Weather card ─────────────────────────────────────────────────────────────

class _WeatherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final WeatherController controller = Get.find<WeatherController>();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return SizedBox(
            height: 80.h,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (controller.hasError.value || controller.weather.value == null) {
          return SizedBox(
            height: 80.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, color: Colors.white70, size: 28.sp),
                  SizedBox(height: 8.h),
                  Text(
                    'Weather unavailable',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: controller.fetchWeather,
                    child: Text(
                      'Tap to retry',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12.sp,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final w = controller.weather.value!;
        return Row(
          children: [
            // Temperature + icon
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${w.temperature.round()}°',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 48.sp,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 6.h),
                        child: Text(
                          'C',
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    w.conditionLabel,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 14.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        w.city,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Right side: icon + details + city picker
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  w.conditionIcon,
                  style: TextStyle(fontSize: 40.sp),
                ),
                SizedBox(height: 8.h),
                _weatherDetail(
                  Icons.air,
                  '${w.windSpeed.round()} km/h',
                ),
                SizedBox(height: 4.h),
                _weatherDetail(
                  Icons.water_drop,
                  '${w.humidity.round()}%',
                ),
                SizedBox(height: 8.h),
                // City picker
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedCity.value,
                      dropdownColor: const Color(0xFF1976D2),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      iconEnabledColor: Colors.white,
                      iconSize: 14.sp,
                      isDense: true,
                      items: WeatherController.cities
                          .map(
                            (city) => DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            ),
                          )
                          .toList(),
                      onChanged: (city) {
                        if (city != null) {
                          controller.fetchWeather(city: city);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _weatherDetail(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14.sp),
        SizedBox(width: 4.w),
        Text(
          value,
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}