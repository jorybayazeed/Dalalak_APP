import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/bookings/controllers/bookings_controller.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class BookingsView extends StatelessWidget {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BookingsController());
    final homeController = Get.put(TouristHomeController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeController.currentBottomNavIndex.value = 2;
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
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
}
