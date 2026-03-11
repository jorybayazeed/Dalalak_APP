import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final RxString selectedTab = 'All'.obs;

  final RxList<Map<String, dynamic>> allNotifications = [
    {
      'id': '1',
      'type': 'booking',
      'title': 'Booking Confirmed',
      'description': 'Your AlUla Heritage Tour is confirmed for Dec 25, 2024',
      'timestamp': '2 hours ago',
      'isRead': false,
      'icon': 'calendar',
      'iconColor': 0xFF4CAF50,
      'iconBgColor': 0xFFE8F5E9,
    },
    {
      'id': '2',
      'type': 'verification',
      'title': 'Verification Approved',
      'description':
          'Congratulations! Your tour guide profile has been verified',
      'timestamp': '1 day ago',
      'isRead': false,
      'icon': 'verified',
      'iconColor': 0xFFFF9800,
      'iconBgColor': 0xFFFFF3E0,
    },
    {
      'id': '3',
      'type': 'message',
      'title': 'New Message',
      'description': 'Ahmed Al-Rashid sent you a message about your booking',
      'timestamp': '2 days ago',
      'isRead': true,
      'icon': 'message',
      'iconColor': 0xFF2196F3,
      'iconBgColor': 0xFFE3F2FD,
    },
    {
      'id': '4',
      'type': 'package',
      'title': 'Tour Package Update',
      'description':
          'Your tour "Desert Safari Adventure" has been published successfully',
      'timestamp': '3 days ago',
      'isRead': true,
      'icon': 'update',
      'iconColor': 0xFF9C27B0,
      'iconBgColor': 0xFFF3E5F5,
    },
  ].obs;

  List<Map<String, dynamic>> get filteredNotifications {
    switch (selectedTab.value) {
      case 'Unread':
        return allNotifications.where((n) => !n['isRead']).toList();
      case 'Read':
        return allNotifications.where((n) => n['isRead']).toList();
      default:
        return allNotifications;
    }
  }

  int get unreadCount => allNotifications.where((n) => !n['isRead']).length;
  int get readCount => allNotifications.where((n) => n['isRead']).length;

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void markAsRead(String notificationId) {
    final index = allNotifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      allNotifications[index]['isRead'] = true;
      allNotifications.refresh();
    }
  }

  void deleteNotification(String notificationId) {
    allNotifications.removeWhere((n) => n['id'] == notificationId);
  }
}
