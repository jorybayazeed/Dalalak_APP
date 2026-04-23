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
  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  void _listen() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _sub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          notifications.assignAll(
            snapshot.docs.map((doc) {
              return {'id': doc.id, ...doc.data()};
            }).toList(),
          );
        });
  }

  @override
  void onClose() {
    _sub?.cancel();
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
