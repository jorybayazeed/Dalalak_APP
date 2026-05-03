import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class TouristNotificationsController extends GetxController {
  final RxList<Map<String, dynamic>> notifications =
      <Map<String, dynamic>>[].obs;

  int get unreadCount =>
      notifications.where((n) => n['isRead'] == false).length;

  StreamSubscription? _sub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();

    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _bindToUser(user);
    });

    _bindToUser(FirebaseAuth.instance.currentUser);
  }

  void _bindToUser(User? user) {
    _sub?.cancel();
    notifications.clear();

    if (user == null) {
      return;
    }

    _purgeLegacyArabicNotifications(user.uid);

    final baseQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications');

    try {
      _sub = baseQuery
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        notifications.assignAll(
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
      });
    } catch (_) {
      _sub = baseQuery.snapshots().listen((snapshot) {
        final items = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList();

        items.sort((a, b) {
          final aTs = a['createdAt'];
          final bTs = b['createdAt'];
          final aTime = aTs is Timestamp ? aTs.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = bTs is Timestamp ? bTs.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });

        notifications.assignAll(items);
      });
    }
  }

  Future<void> _purgeLegacyArabicNotifications(String uid) async {
    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications');
      final snap = await ref
          .where('title', isEqualTo: 'انتهاء الجولة')
          .get();
      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.onClose();
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
  Future<void> deleteNotification(String id) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('notifications')
      .doc(id)
      .delete();
}
}
