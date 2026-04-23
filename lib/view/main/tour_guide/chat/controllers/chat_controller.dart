import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BroadcastController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final RxList<Map<String, dynamic>> tours = <Map<String, dynamic>>[].obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  final RxList<Map<String, dynamic>> broadcasts = <Map<String, dynamic>>[].obs;

  /// select broadcasts for the current guide
  void listenBroadcasts() {
    _db
        .collection('broadcasts')
        .where('guideId', isEqualTo: currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          broadcasts.assignAll(
            snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id; 
              return data;
            }).toList(),
          );
        });
  }

  /// Send broadcast to all users who booked the tour
  Future<void> sendBroadcast(String tourId) async {
    final title = titleController.text.trim();
    final message = messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      Get.snackbar('Error', 'Please enter title and message');
      return;
    }

    /// select users who booked this tour
    final bookingsSnap = await _db
        .collectionGroup('upcomingBookings')
        .where('tourId', isEqualTo: tourId)
        .get();

    if (bookingsSnap.docs.isEmpty) {
      Get.snackbar('Info', 'No users found');
      return;
    }
    final selectedTour = tours.firstWhere((t) => t['id'] == tourId);

    ///  save broadcast
    await _db.collection('broadcasts').add({
      'tourId': tourId,
      'guideId': currentUserId,
      'tourName': selectedTour['name'],
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
      'recipientsCount': bookingsSnap.docs.length,
    });


for (final doc in bookingsSnap.docs) {
  final userId = doc.reference.parent.parent!.id;

  await _db
      .collection('users')
      .doc(userId)
      .collection('notifications')
      .add({
    'title': title,
    'message': message,
    'type': 'broadcast',
    'tourId': tourId,
    'tourName': selectedTour['name'], 
    'createdAt': FieldValue.serverTimestamp(),
    'isRead': false,
  });
}

    Get.snackbar('Success', 'Message sent');

    titleController.clear();
    messageController.clear();
  }

  @override
  void onInit() {
    super.onInit();
    listenBroadcasts();
    loadTours(); 
  }

  @override
  void onClose() {
    titleController.dispose();
    messageController.dispose();
    super.onClose();
  }

  Future<void> loadTours() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final snap = await _db
        .collection('tourPackages')
        .where('guideId', isEqualTo: userId)
        .get();

    tours.assignAll(
      snap.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['tourTitle'] ?? 'No name', 
        };
      }).toList(),
    );
  }
}
