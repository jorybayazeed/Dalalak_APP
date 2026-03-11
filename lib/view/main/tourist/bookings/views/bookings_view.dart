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
    // final homeController = Get.find<TouristHomeController>();
    final homeController = Get.put(TouristHomeController());
    if (homeController.currentBottomNavIndex.value != 2) {
      homeController.currentBottomNavIndex.value = 2;
    }

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
                final bookings = controller.filteredBookings;
                return bookings.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings found',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF999999),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Column(
                          children: [
                            ...bookings.map(
                              (booking) =>
                                  _buildBookingCard(booking, controller),
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
    final status = booking['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 180.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: booking['image'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        ),
                        child: Image.asset(
                          booking['image'] as String,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE0E0E0),
                              child: Icon(
                                Icons.image,
                                size: 48.sp,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      )
                    : Icon(Icons.image, size: 48.sp, color: Colors.grey),
              ),
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking['title'] as String,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildDetailRow(
                  icon: Icons.person,
                  text: booking['guide'] as String,
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  text: booking['date'] as String,
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  icon: Icons.access_time,
                  text: booking['time'] as String,
                ),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  icon: Icons.location_on,
                  text: booking['location'] as String,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking ID: ${booking['id'] as String}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF666666),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      booking['price'] as String,
                      style: GoogleFonts.inter(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            controller.messageGuide(booking['id'] as String),
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(
                              color: const Color(0xFF00A86B),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.message,
                                color: const Color(0xFF00A86B),
                                size: 18.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Message',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF00A86B),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
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
                        onTap: () =>
                            controller.viewDetails(booking['id'] as String),
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A86B),
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          child: Center(
                            child: Text(
                              'View Details',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00A86B), size: 16.sp),
        SizedBox(width: 8.w),
        Text(
          text,
          style: GoogleFonts.inter(
            color: const Color(0xFF666666),
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Upcoming':
        return const Color(0xFF00A86B);
      case 'Completed':
        return const Color(0xFF4CAF50);
      case 'Cancelled':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF999999);
    }
  }
}
