import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';

class GuideCompletedToursController extends GetxController {
  final RxList<Map<String, dynamic>> sessions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isBackfilling = false.obs;
  final PackagesService _packagesService = Get.find<PackagesService>();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sessionsSub;
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
    _sessionsSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  void _bind(User? user) {
    _sessionsSub?.cancel();
    sessions.clear();
    if (user == null) return;

    isLoading.value = true;

    final query = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('endedSessions');

    _sessionsSub = query.snapshots().listen(
      (snap) async {
        final List<Map<String, dynamic>> loaded = [];

        for (final doc in snap.docs) {
          final data = doc.data();
          final packageId = (data['packageId'] ?? '').toString();

          double rating = 0.0;
          int reviews = 0;
          String packageTitle = (data['packageTitle'] ?? '').toString();
          String packageImage = (data['packageImage'] ?? '').toString();

          if (packageId.isNotEmpty) {
            try {
              final pkgSnap = await FirebaseFirestore.instance
                  .collection('tourPackages')
                  .doc(packageId)
                  .get();
              if (pkgSnap.exists) {
                final pkgData = pkgSnap.data();
                if (pkgData != null) {
                  rating = (pkgData['rating'] as num?)?.toDouble() ?? 0.0;
                  reviews = (pkgData['reviews'] as num?)?.toInt() ?? 0;
                  if (packageTitle.isEmpty) {
                    packageTitle =
                        (pkgData['tourTitle'] ?? pkgData['title'] ?? '')
                            .toString();
                  }
                  if (packageImage.isEmpty) {
                    packageImage = (pkgData['image'] ?? '').toString();
                  }
                }
              }
            } catch (_) {}
          }

          loaded.add({
            'id': doc.id,
            'packageId': packageId,
            'packageTitle': packageTitle,
            'packageImage': packageImage,
            'sessionId': (data['sessionId'] ?? '').toString(),
            'sessionStartedAt': data['sessionStartedAt'],
            'endedAt': data['endedAt'],
            'registeredCount': (data['registeredCount'] as num?)?.toInt() ?? 0,
            'rating': rating,
            'reviews': reviews,
          });
        }

        loaded.sort((a, b) {
          final aTs = a['endedAt'];
          final bTs = b['endedAt'];
          final aMicros = aTs is Timestamp ? aTs.microsecondsSinceEpoch : 0;
          final bMicros = bTs is Timestamp ? bTs.microsecondsSinceEpoch : 0;
          return bMicros.compareTo(aMicros);
        });

        sessions.assignAll(loaded);
        isLoading.value = false;
      },
      onError: (_) {
        isLoading.value = false;
      },
    );
  }

  int get totalCompleted => sessions.length;

  Future<int> restoreHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0;
    isBackfilling.value = true;
    try {
      final created =
          await _packagesService.backfillEndedSessionsForGuide(user.uid);
      return created;
    } finally {
      isBackfilling.value = false;
    }
  }

  String formatRelative(dynamic ts) {
    if (ts is! Timestamp) return '';
    final dt = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    if (diff.inDays < 30) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
