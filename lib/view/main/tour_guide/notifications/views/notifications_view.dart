import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/notifications/controllers/notifications_controller.dart';
import 'package:tour_app/view/main/tour_guide/shared/widgets/bottom_navigation_bar.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _buildTab(
                        label: 'All',
                        count: controller.allNotifications.length,
                        isSelected: controller.selectedTab.value == 'All',
                        onTap: () => controller.changeTab('All'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTab(
                        label: 'Unread',
                        count: controller.unreadCount,
                        isSelected: controller.selectedTab.value == 'Unread',
                        onTap: () => controller.changeTab('Unread'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildTab(
                        label: 'Read',
                        count: controller.readCount,
                        isSelected: controller.selectedTab.value == 'Read',
                        onTap: () => controller.changeTab('Read'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(
                () => controller.filteredNotifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications',
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
                            ...controller.filteredNotifications.map(
                              (notification) => _buildNotificationCard(
                                notification: notification,
                                controller: controller,
                              ),
                            ),
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
              ),
            ),
            TourGuideBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            '$label ($count)',
            style: GoogleFonts.inter(
              color: isSelected ? Colors.black : const Color(0xFF666666),
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required Map<String, dynamic> notification,
    required NotificationsController controller,
  }) {
    final isRead = notification['isRead'] as bool;
    final iconColor = Color(notification['iconColor'] as int);
    final iconBgColor = Color(notification['iconBgColor'] as int);
    final iconType = notification['icon'] as String;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(_getIcon(iconType), color: iconColor, size: 24.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            notification['title'] as String,
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isRead) ...[
                            SizedBox(width: 6.w),
                            Container(
                              width: 6.w,
                              height: 6.h,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  notification['description'] as String,
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  notification['timestamp'] as String,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF999999),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            children: [
              if (!isRead)
                GestureDetector(
                  onTap: () =>
                      controller.markAsRead(notification['id'] as String),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      'Mark read',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF00A86B),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () =>
                    controller.deleteNotification(notification['id'] as String),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case 'calendar':
        return Icons.calendar_today;
      case 'verified':
        return Icons.verified;
      case 'message':
        return Icons.chat_bubble_outline;
      case 'update':
        return Icons.access_time;
      default:
        return Icons.notifications;
    }
  }
}
