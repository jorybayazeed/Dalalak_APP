import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GuideRewardsController extends GetxController {
  final RxList<Map<String, dynamic>> rewards = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> myTours = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _rewardsSub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();
    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _bind(user);
    });
    _bind(FirebaseAuth.instance.currentUser);
  }

  @override
  void onClose() {
    _rewardsSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  void _bind(User? user) {
    _rewardsSub?.cancel();
    rewards.clear();
    myTours.clear();
    if (user == null) return;

    isLoading.value = true;

    _rewardsSub = FirebaseFirestore.instance
        .collection('rewards')
        .where('creatorId', isEqualTo: user.uid)
        .snapshots()
        .listen(
      (snap) {
        final loaded = snap.docs.map((doc) {
          final data = doc.data();
          return {'id': doc.id, ...data};
        }).toList();
        loaded.sort((a, b) {
          final aTs = a['createdAt'];
          final bTs = b['createdAt'];
          final aMs = aTs is Timestamp ? aTs.microsecondsSinceEpoch : 0;
          final bMs = bTs is Timestamp ? bTs.microsecondsSinceEpoch : 0;
          return bMs.compareTo(aMs);
        });
        rewards.assignAll(loaded);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
      },
    );

    _loadMyTours(user.uid);
  }

  Future<void> _loadMyTours(String guideId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('tourPackages')
          .where('guideId', isEqualTo: guideId)
          .get();
      myTours.assignAll(
        snap.docs
            .map((d) => {
                  'id': d.id,
                  'title': (d.data()['tourTitle'] ?? '').toString(),
                })
            .where((t) => (t['title'] as String).isNotEmpty)
            .toList(),
      );
    } catch (_) {}
  }

  Future<void> createReward({
    required String type,
    required String title,
    required String description,
    required int discountPercent,
    required int requiredLevel,
    required List<String> applicableTours,
    String? partnerName,
    String? partnerCategory,
    String? partnerLocation,
    String? redemptionCode,
    DateTime? validUntil,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Not authenticated');
    }
    if (title.trim().isEmpty) {
      throw Exception('Title is required');
    }
    if (discountPercent < 1 || discountPercent > 100) {
      throw Exception('Discount must be between 1 and 100');
    }
    if (applicableTours.isEmpty) {
      throw Exception('Select at least one tour');
    }
    if (type == 'partner_coupon') {
      if ((partnerName ?? '').trim().isEmpty) {
        throw Exception('Partner name is required for coupons');
      }
      if ((redemptionCode ?? '').trim().isEmpty) {
        throw Exception('Redemption code is required for coupons');
      }
    }

    isSaving.value = true;
    try {
      await FirebaseFirestore.instance.collection('rewards').add({
        'type': type,
        'createdBy': 'guide',
        'creatorId': user.uid,
        'title': title.trim(),
        'description': description.trim(),
        'discountPercent': discountPercent,
        'requiredLevel': requiredLevel,
        'applicableTours': applicableTours,
        if (type == 'partner_coupon') ...{
          'partnerName': (partnerName ?? '').trim(),
          'partnerCategory': (partnerCategory ?? '').trim(),
          'partnerLocation': (partnerLocation ?? '').trim(),
          'redemptionCode': (redemptionCode ?? '').trim(),
        },
        'isActive': true,
        if (validUntil != null) 'validUntil': Timestamp.fromDate(validUntil),
        'totalAppliedCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setActive(String rewardId, bool active) async {
    await FirebaseFirestore.instance
        .collection('rewards')
        .doc(rewardId)
        .update({
      'isActive': active,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteReward(String rewardId) async {
    await FirebaseFirestore.instance
        .collection('rewards')
        .doc(rewardId)
        .delete();
  }
}
