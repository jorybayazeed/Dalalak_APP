import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final RxString selectedTab = 'All'.obs;

  final RxList<Map<String, dynamic>> allNotifications = <Map<String, dynamic>>[].obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((u) {
        if (u != null) {
          _listen();
        }
      });
    } else {
      _listen();
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  void _listen() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _sub?.cancel();
    final baseQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications');

    _sub = baseQuery
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final loaded = snapshot.docs.map((doc) {
          final data = doc.data();
          final mapped = _decorate(doc.id, data);
          return mapped;
        }).toList();

        allNotifications.assignAll(loaded);
      },
      onError: (e) async {
        Get.log('Guide notifications: orderBy(createdAt) failed: $e');

        _sub?.cancel();
        _sub = baseQuery.snapshots().listen(
          (snapshot) {
            final loaded = snapshot.docs.map((doc) {
              final data = doc.data();
              final mapped = _decorate(doc.id, data);
              return mapped;
            }).toList();

            loaded.sort((a, b) {
              final aTs = a['createdAt'];
              final bTs = b['createdAt'];
              final aMicros = aTs is Timestamp ? aTs.microsecondsSinceEpoch : 0;
              final bMicros = bTs is Timestamp ? bTs.microsecondsSinceEpoch : 0;
              return bMicros.compareTo(aMicros);
            });

            allNotifications.assignAll(loaded);
          },
          onError: (e2) {
            Get.log('Guide notifications: fallback snapshots failed: $e2');
          },
        );
      },
    );
  }

  Map<String, dynamic> _decorate(
    String id,
    Map<String, dynamic> data,
  ) {
    final type = (data['type'] ?? '').toString().trim().toLowerCase();
    final isRead = (data['isRead'] as bool?) ?? false;

    final title = (data['title'] ?? '').toString();
    final description =
        (data['message'] ?? data['description'] ?? '').toString();

    final createdAt = data['createdAt'];
    String timestamp = '';
    if (createdAt is Timestamp) {
      timestamp = _formatRelative(createdAt.toDate());
    }

    int iconColor = 0xFF00A86B;
    int iconBgColor = 0xFFE8F5E9;
    String icon = 'calendar';

    if (type.contains('cancel')) {
      icon = 'update';
      iconColor = 0xFFD32F2F;
      iconBgColor = 0xFFFFEBEE;
    } else if (type.contains('message') || type.contains('chat')) {
      icon = 'message';
      iconColor = 0xFF1565C0;
      iconBgColor = 0xFFE3F2FD;
    } else if (type.contains('verification')) {
      icon = 'verified';
      iconColor = 0xFFFF9800;
      iconBgColor = 0xFFFFF3E0;
    } else if (type.contains('booking')) {
      icon = 'calendar';
      iconColor = 0xFF4CAF50;
      iconBgColor = 0xFFE8F5E9;
    }

    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': timestamp,
      'isRead': isRead,
      'icon': icon,
      'iconColor': iconColor,
      'iconBgColor': iconBgColor,
      'createdAt': createdAt,
    };
  }

  String _formatRelative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  void deleteNotification(String notificationId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }
}
