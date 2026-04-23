import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/controllers/dashboard_controller.dart';

class TourGuideBottomNavigationBar extends StatelessWidget {
  const TourGuideBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

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
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                  controller: controller,
                ),
                _buildNavItem(
                  icon: Icons.inventory_2,
                  label: 'Packages',
                  index: 1,
                  controller: controller,
                ),
                _buildNavItem(
                    icon: Icons.campaign,
                   label: 'Broadcast',
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
    required DashboardController controller,
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
