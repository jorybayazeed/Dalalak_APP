import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_app/view/main/tourist/home/controllers/tourist_notifications_controller.dart';

class TouristNotificationsView extends StatelessWidget {
  const TouristNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TouristNotificationsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.markAllAsRead();
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final n = controller.notifications[index];
            final id = n['id'];
            final isUnread = n['isRead'] == false;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isUnread
                      ? Border.all(
                          color: const Color(0xFF00A86B).withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Color(0xFF00A86B),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 🔹 Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title + badge
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n['title'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                onPressed: () {
                                  controller.deleteNotification(id);
                                },
                              ),
                              if (isUnread)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          if (n['type'] == 'broadcast' &&
                              (n['tourName'] ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                n['tourName'],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          Text(
                            n['message'] ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(n['createdAt']),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              if (!isUnread)
                                const Icon(
                                  Icons.done,
                                  size: 16,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // 🔹 Empty UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No notifications yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            'You’ll see updates about your tours here',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // 🔹 Time formatting
  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      final date = timestamp.toDate();
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} h ago';
      return '${diff.inDays} d ago';
    } catch (e) {
      return '';
    }
  }
}
