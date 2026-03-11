import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class TouristBottomNavigationBar extends StatelessWidget {
  const TouristBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TouristHomeController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                  controller: controller,
                ),
                _buildNavItem(
                  icon: Icons.explore,
                  label: 'Explore',
                  index: 1,
                  controller: controller,
                ),
                _buildNavItem(
                  icon: Icons.calendar_today,
                  label: 'Bookings',
                  index: 2,
                  controller: controller,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  index: 3,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required TouristHomeController controller,
  }) {
    final isSelected = controller.currentBottomNavIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeBottomNavIndex(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF00A86B)
                : const Color(0xFF999999),
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              color: isSelected
                  ? const Color(0xFF00A86B)
                  : const Color(0xFF999999),
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
