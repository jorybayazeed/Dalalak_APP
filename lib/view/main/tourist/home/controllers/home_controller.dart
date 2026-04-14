import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tour_app/view/main/tourist/home/views/home_view.dart';
import 'package:tour_app/view/main/tourist/explore/views/explore_view.dart';
import 'package:tour_app/view/main/tourist/bookings/views/bookings_view.dart';
import 'package:tour_app/view/main/tourist/profile/views/profile_view.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/gamification_service.dart';
import 'package:tour_app/view/main/tourist/rewards/views/rewards_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter_map/flutter_map.dart';

class TouristHomeController extends GetxController {
  final RxInt currentBottomNavIndex = 0.obs;

  final RxInt totalPoints = 0.obs;
  final RxString level = 'Level 1 Explorer'.obs;
  final RxInt badgesCount = 0.obs;
  final RxInt completedActivities = 0.obs;
  final RxInt totalActivities = 3.obs;
  final RxInt rewardsPoints = 0.obs;

  final RxBool isInteractiveMapVisible = true.obs;

  final RxSet<String> expandedTourIds = <String>{}.obs;

  final RxSet<String> autoFittedTourIds = <String>{}.obs;

  final RxList<Map<String, dynamic>> currentTours = <Map<String, dynamic>>[].obs;

  final RxString activeTourId = ''.obs;
  final Rx<LatLng> mapCenter = const LatLng(26.6082, 37.9232).obs;
  final RxList<Map<String, dynamic>> activityMapMarkers =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> tourActivities =
      <Map<String, dynamic>>[].obs;

  final RxInt selectedActivityIndex = 0.obs;

  final RxMap<String, LatLng> mapCenterByTourId = <String, LatLng>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> activityMapMarkersByTourId =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxMap<String, List<Map<String, dynamic>>> tourActivitiesByTourId =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxMap<String, int> selectedActivityIndexByTourId = <String, int>{}.obs;
  final RxMap<String, List<String>> completedActivityIdsByTourId =
      <String, List<String>>{}.obs;

  final RxMap<String, bool> tourEndedByTourId = <String, bool>{}.obs;
  final RxMap<String, bool> ratedByTourId = <String, bool>{}.obs;

  final RxnString ratePromptTourId = RxnString();

  final Map<String, MapController> _mapControllersByTourId =
      <String, MapController>{};

  final RxSet<String> completedActivityIds = <String>{}.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingsSub;

  bool _bootstrappedUserDoc = false;
  bool _recomputedMissingPoints = false;
  bool _recomputedPointsOnLogin = false;
  bool _shownPointsRecomputeError = false;
  bool _shownUserDocWriteError = false;

  int _currentToursLoadSeq = 0;

  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
      _tourEndedSubs = <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};
  final Map<String, bool> _lastEndedByTourId = <String, bool>{};
  final Set<String> _tourEndedNotified = <String>{};

  final Set<String> _bookingCompletedByTourId = <String>{};

  final PackagesService _packagesService = Get.find<PackagesService>();

  RxList<Map<String, dynamic>> recommendedTours = <Map<String, dynamic>>[].obs;
  RxList<String> userInterests = <String>[].obs;

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  Future<bool> _tryCreateTourCompletionNotification({
    required String userId,
    required String tourId,
  }) async {
    try {
      final ref = _tourCompletionNotificationRef(userId: userId, tourId: tourId);

      return FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (snap.exists) return false;
        tx.set(ref, {
          'tourId': tourId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        return true;
      });
    } catch (e) {
      Get.log('HomeController: failed to create completion notification flag: $e');
      return false;
    }
  }

  DocumentReference<Map<String, dynamic>> _tourCompletionNotificationRef({
    required String userId,
    required String tourId,
  }) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tour_completion_notifications')
        .doc(tourId);
  }

  Future<String> _resolveTourIdFromBookingDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    final existing = (data['tourId'] ?? data['packageId'] ?? '').toString().trim();
    if (existing.isNotEmpty) return existing;

    final title = (data['tourTitle'] ?? '').toString().trim();
    final destination = (data['destination'] ?? '').toString().trim();
    if (title.isEmpty) return '';

    try {
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection('tourPackages')
          .where('tourTitle', isEqualTo: title);

      if (destination.isNotEmpty) {
        q = q.where('destination', isEqualTo: destination);
      }

      final snap = await q.limit(1).get();
      if (snap.docs.isEmpty) return '';

      final resolvedId = snap.docs.first.id;
      await doc.reference.set(
        {
          'tourId': resolvedId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      return resolvedId;
    } catch (e) {
      Get.log('HomeController: failed to resolve tourId for booking ${doc.id}: $e');
      return '';
    }
  }

  Future<void> _markBookingCompleted(String tourId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (tourId.isEmpty) return;

    if (_bookingCompletedByTourId.contains(tourId)) return;

    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('upcomingBookings');

    final snap = await col.where('tourId', isEqualTo: tourId).get();
    if (snap.docs.isEmpty) {
      try {
        final direct = await col.doc(tourId).get();
        if (!direct.exists) return;

        final data = direct.data();
        final status = (data?['status'] ?? '').toString();
        if (status != 'Completed') {
          await direct.reference.set(
            {
              'status': 'Completed',
              'completedAt': FieldValue.serverTimestamp(),
              'tourId': tourId,
            },
            SetOptions(merge: true),
          );
          _bookingCompletedByTourId.add(tourId);
        }
      } catch (_) {
        // Ignore fallback errors.
      }
      return;
    }

    var didUpdateAny = false;
    for (final d in snap.docs) {
      final data = d.data();
      final status = (data['status'] ?? '').toString();
      if (status == 'Completed') {
        continue;
      }

      await d.reference.set(
        {
          'status': 'Completed',
          'completedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      didUpdateAny = true;
    }

    if (didUpdateAny) {
      _bookingCompletedByTourId.add(tourId);
    }
  }

  @override
  void onInit() async {
    super.onInit();

    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      await _onAuthChanged(user);
    });

    await _onAuthChanged(FirebaseAuth.instance.currentUser);
  }

  MapController mapControllerForTour(String tourId) {
    final existing = _mapControllersByTourId[tourId];
    if (existing != null) return existing;
    final created = MapController();
    _mapControllersByTourId[tourId] = created;
    return created;
  }

  void setSelectedActivityIndex(int index) {
    if (index < 0) return;
    if (selectedActivityIndex.value == index) return;
    selectedActivityIndex.value = index;
  }

  void setSelectedActivityIndexForTour(String tourId, int index) {
    if (index < 0) return;
    selectedActivityIndexByTourId[tourId] = index;
    if (activeTourId.value == tourId) {
      selectedActivityIndex.value = index;
    }
  }

  @override
  void onClose() {
    _userDocSub?.cancel();
    _userDocSub = null;
    _authSub?.cancel();
    _authSub = null;
    _bookingsSub?.cancel();
    _bookingsSub = null;

    for (final sub in _tourEndedSubs.values) {
      sub.cancel();
    }
    _tourEndedSubs.clear();
    _lastEndedByTourId.clear();
    _tourEndedNotified.clear();

    super.onClose();
  }

  Future<void> _onAuthChanged(User? user) async {
    _userDocSub?.cancel();
    _userDocSub = null;
    _bookingsSub?.cancel();
    _bookingsSub = null;

    for (final sub in _tourEndedSubs.values) {
      sub.cancel();
    }
    _tourEndedSubs.clear();
    _lastEndedByTourId.clear();
    _tourEndedNotified.clear();

    _mapControllersByTourId.clear();
    autoFittedTourIds.clear();

    totalPoints.value = 0;
    rewardsPoints.value = 0;
    level.value = 'Level 1 Explorer';
    badgesCount.value = 0;
    completedActivities.value = 0;
    totalActivities.value = 3;

    currentTours.clear();
    expandedTourIds.clear();
    activeTourId.value = '';
    activityMapMarkers.clear();
    tourActivities.clear();
    completedActivityIds.clear();
    selectedActivityIndex.value = 0;
    userInterests.clear();

    if (user == null) {
      return;
    }

    Get.log('HomeController auth uid: ${user.uid}');

    _bootstrappedUserDoc = false;
    _recomputedMissingPoints = false;
    _recomputedPointsOnLogin = false;

    _bindUserGamification(uid: user.uid);

    _bookingsSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('upcomingBookings')
        .snapshots()
        .listen((_) {
      loadCurrentTours(showCompletionSnackbars: false);
    }, onError: (e) {
      Get.log('HomeController upcomingBookings snapshots error: $e');
    });

    try {
      await Get.find<GamificationService>().recomputeAndSyncTotalPoints(
        userId: user.uid,
      );
    } catch (_) {
      // Ignore reconciliation errors.
    }

    try {
      await Get.find<GamificationService>().cleanupChallengeAttempts(
        userId: user.uid,
      );
    } catch (_) {
      // Ignore cleanup errors.
    }

    try {
      await Get.find<GamificationService>().validateTourCompletionEventsAndRecompute(
        userId: user.uid,
      );
    } catch (_) {
      // Ignore migration errors.
    }

    await loadUserInterests();
    loadTours();
    await loadCurrentTours();
  }

  void _syncTourEndedListeners(Set<String> tourIds) {
    final toRemove = _tourEndedSubs.keys.where((id) => !tourIds.contains(id)).toList();
    for (final id in toRemove) {
      _tourEndedSubs.remove(id)?.cancel();
      _lastEndedByTourId.remove(id);
      _tourEndedNotified.remove(id);
      _bookingCompletedByTourId.remove(id);
    }

    for (final tourId in tourIds) {
      if (_tourEndedSubs.containsKey(tourId)) continue;

      final sub = FirebaseFirestore.instance
          .collection('tourPackages')
          .doc(tourId)
          .snapshots()
          .listen((snap) async {
        if (!snap.exists) return;
        final data = snap.data();
        if (data == null) return;

        final live = data['liveTourState'] as Map<String, dynamic>?;
        final ended = (live?['ended'] as bool?) ?? false;
        final previous = _lastEndedByTourId[tourId] ?? false;
        _lastEndedByTourId[tourId] = ended;

        if (!ended || previous == ended) return;
        if (_tourEndedNotified.contains(tourId)) return;

        _tourEndedNotified.add(tourId);

        try {
          await _markBookingCompleted(tourId);
        } catch (_) {
          // Ignore booking update errors.
        }

        await _maybeAwardTourCompletionAndNotify(tourId);
      });

      _tourEndedSubs[tourId] = sub;
    }
  }

  Future<void> _maybeAwardTourCompletionAndNotify(String tourId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (tourId.trim().isEmpty) return;

    final acquired = await _tryCreateTourCompletionNotification(
      userId: user.uid,
      tourId: tourId,
    );
    if (!acquired) return;

    final tourDoc = await FirebaseFirestore.instance
        .collection('tourPackages')
        .doc(tourId)
        .get();
    if (!tourDoc.exists) return;

    final tourData = tourDoc.data();
    if (tourData == null) return;

    final live = tourData['liveTourState'] as Map<String, dynamic>?;
    final ended = (live?['ended'] as bool?) ?? false;
    if (!ended) {
      try {
        await _tourCompletionNotificationRef(userId: user.uid, tourId: tourId)
            .delete();
      } catch (_) {
        // Ignore flag cleanup errors.
      }
      return;
    }

    try {
      final earned = await Get.find<GamificationService>().awardTourCompletionPoints(
        packageId: tourId,
      );

      if (earned > 0) {
        Get.snackbar(
          'Reward',
          'Thank you for completing the tour you earned + $earned',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      try {
        final ratedDoc = await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(tourId)
            .collection('ratings')
            .doc(user.uid)
            .get();
        final alreadyRated = ratedDoc.exists || (ratedByTourId[tourId] ?? false);
        if (!alreadyRated && ratePromptTourId.value != tourId) {
          ratePromptTourId.value = tourId;
        }
      } catch (_) {
        if (!(ratedByTourId[tourId] ?? false) && ratePromptTourId.value != tourId) {
          ratePromptTourId.value = tourId;
        }
      }
    } catch (_) {
      try {
        await _tourCompletionNotificationRef(userId: user.uid, tourId: tourId).delete();
      } catch (_) {
        // Ignore flag cleanup errors.
      }
      // Ignore points errors.
    }
  }

  void _bindUserGamification({required String uid}) {

    _userDocSub?.cancel();
    _userDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) async {
      final data = snap.data();

      if (!snap.exists) {
        if (_bootstrappedUserDoc) return;
        _bootstrappedUserDoc = true;
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(
            {
              'totalPoints': 0,
              'level': 1,
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } catch (e, st) {
          Get.log('HomeController: failed to bootstrap user doc: $e\n$st');
          if (!_shownUserDocWriteError) {
            _shownUserDocWriteError = true;
            Get.snackbar(
              'Error',
              'Failed to create user profile in Firestore (check rules/connection)',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
        return;
      }

      if (data == null) return;

      final points = (data['totalPoints'] as num?)?.toInt();
      totalPoints.value = points ?? 0;
      rewardsPoints.value = totalPoints.value;

      if (!_recomputedPointsOnLogin) {
        _recomputedPointsOnLogin = true;
        try {
          await Get.find<GamificationService>().recomputeAndSyncTotalPoints(
            userId: uid,
            force: true,
          );
        } catch (e, st) {
          Get.log('HomeController: recompute points (login) failed: $e\n$st');
        }
      }

      if (points == null && !_recomputedMissingPoints) {
        _recomputedMissingPoints = true;
        try {
          await Get.find<GamificationService>().recomputeAndSyncTotalPoints(
            userId: uid,
            force: true,
          );
        } catch (e, st) {
          Get.log('HomeController: recompute points failed: $e\n$st');
          if (!_shownPointsRecomputeError) {
            _shownPointsRecomputeError = true;
            Get.snackbar(
              'Error',
              'Failed to compute points (check Firestore rules/connection)',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          _loadQuizAttemptsPointsFallback(uid);
        }
      }

      final rawLevel = data['level'];
      if (rawLevel is num) {
        level.value = 'Level ${rawLevel.toInt()} Explorer';
      } else if (rawLevel is String && rawLevel.trim().isNotEmpty) {
        level.value = rawLevel;
      }

      final badges = data['badges'];
      if (badges is List) {
        badgesCount.value = badges.length;
      } else {
        final bc = (data['badgesCount'] as num?)?.toInt();
        if (bc != null) {
          badgesCount.value = bc;
        }
      }
    });
  }

  Future<void> _loadQuizAttemptsPointsFallback(String uid) async {
    try {
      int sum = 0;

      final quizSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_attempts')
          .get();

      for (final d in quizSnap.docs) {
        sum += (d.data()['pointsEarned'] as num?)?.toInt() ?? 0;
      }

      final eventsSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('points_events')
          .get();

      for (final d in eventsSnap.docs) {
        sum += (d.data()['pointsEarned'] as num?)?.toInt() ?? 0;
      }

      if (sum > totalPoints.value) {
        totalPoints.value = sum;
        rewardsPoints.value = sum;
      }
    } catch (_) {
      // Ignore fallback errors.
    }
  }

  void changeBottomNavIndex(int index) {
    if (currentBottomNavIndex.value == index) return;

    currentBottomNavIndex.value = index;

    switch (index) {
      case 0:
        loadCurrentTours();
        Get.off(() => const TouristHomeView());
        break;
      case 1:
        Get.off(() => const ExploreView());
        break;
      case 2:
        Get.off(() => const BookingsView());
        break;
      case 3:
        Get.off(() => const TouristProfileView());
        break;
    }
  }

  void viewRewards() {
    Get.to(() => const TouristRewardsView());
  }

  void viewMyRewards() {
    Get.to(() => const TouristRewardsView());
  }
  void openSettings() {}

  void toggleInteractiveMap() {
    isInteractiveMapVisible.value = !isInteractiveMapVisible.value;
  }

  void toggleTourExpanded(String tourId) {
    if (expandedTourIds.contains(tourId)) {
      expandedTourIds.remove(tourId);
      autoFittedTourIds.remove(tourId);
    } else {
      expandedTourIds.add(tourId);
      activeTourId.value = tourId;
      isInteractiveMapVisible.value = true;
      loadTourActivities(tourId);
    }
  }

  Future<void> loadCurrentTours({bool showCompletionSnackbars = true}) async {
    final seq = ++_currentToursLoadSeq;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bookingsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('upcomingBookings')
          .get();

      Get.log(
        'HomeController loadCurrentTours: bookings=${bookingsSnapshot.docs.length}',
      );

      final List<Map<String, dynamic>> loaded = [];

      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data();
        final resolved = await _resolveTourIdFromBookingDoc(doc);
        final tourId = (resolved.isNotEmpty ? resolved : doc.id).toString();
        if (tourId.isEmpty) continue;

        try {
          final ratedDoc = await FirebaseFirestore.instance
              .collection('tourPackages')
              .doc(tourId)
              .collection('ratings')
              .doc(user.uid)
              .get();
          ratedByTourId[tourId] = ratedDoc.exists;
        } catch (_) {
          ratedByTourId[tourId] = false;
        }

        String guideName = '';
        int totalActivities = 0;

        Map<String, dynamic>? tourData;

        final tourDoc = await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(tourId)
            .get();

        if (tourDoc.exists) {
          tourData = tourDoc.data() as Map<String, dynamic>;
        } else {
          final legacyDoc = await FirebaseFirestore.instance
              .collection('packages')
              .doc(tourId)
              .get();
          if (legacyDoc.exists) {
            tourData = legacyDoc.data() as Map<String, dynamic>;
          }
        }

        if (tourData != null) {
          final guideId = (tourData['guideId'] ?? tourData['creatorId'] ?? '')
              .toString();
          final activities = (tourData['activities'] as List<dynamic>?) ?? [];
          totalActivities = activities.length;

          final live = tourData['liveTourState'] as Map<String, dynamic>?;
          final ended = (live?['ended'] as bool?) ?? false;
          tourEndedByTourId[tourId] = ended;

          if (ended) {
            try {
              await _markBookingCompleted(tourId);
            } catch (_) {
              // Ignore booking update errors.
            }

            try {
              await _maybeAwardTourCompletionAndNotify(tourId);
            } catch (_) {
              // Ignore completion notification errors.
            }

            // Do not show ended tours in the Upcoming/Current list.
            continue;
          }

          if (guideId.isNotEmpty) {
            final guideDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(guideId)
                .get();

            if (guideDoc.exists) {
              final guideData = guideDoc.data() as Map<String, dynamic>;
              guideName = (guideData['fullName'] ?? '').toString();
            }
          }
        } else {
          tourEndedByTourId[tourId] = false;
        }

        int pointsEarned = 0;
        final Set<String> completedActivityIds = <String>{};

        final quizAttemptsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_attempts')
            .where('packageId', isEqualTo: tourId)
            .get();

        for (final a in quizAttemptsSnap.docs) {
          final attemptData = a.data();
          pointsEarned += (attemptData['pointsEarned'] as num?)?.toInt() ?? 0;
          final activityId = (attemptData['activityId'] ?? '').toString();
          if (activityId.isNotEmpty) {
            completedActivityIds.add(activityId);
          }
        }

        try {
          final eventsSnap = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('points_events')
              .where('packageId', isEqualTo: tourId)
              .get();

          for (final evDoc in eventsSnap.docs) {
            final ev = evDoc.data();
            pointsEarned += (ev['pointsEarned'] as num?)?.toInt() ?? 0;
          }
        } catch (_) {
          // Ignore points events errors.
        }

        loaded.add({
          'tourId': tourId,
          'title': (data['tourTitle'] ?? '').toString(),
          'date': (data['availableDates'] ?? '').toString(),
          'guide': guideName,
          'totalActivities': totalActivities,
          'completedActivities': completedActivityIds.length,
          'pointsEarned': pointsEarned,
          'ended': tourEndedByTourId[tourId] ?? false,
          'rated': ratedByTourId[tourId] ?? false,
        });
      }

      if (seq != _currentToursLoadSeq) return;
      currentTours.assignAll(loaded);

      Get.log(
        'HomeController loadCurrentTours: loadedCurrentTours=${loaded.length}',
      );

      if (seq == _currentToursLoadSeq) {
        _syncTourEndedListeners(
          loaded
              .map((t) => (t['tourId'] ?? '').toString())
              .where((id) => id.isNotEmpty)
              .toSet(),
        );
      }
    } catch (e, st) {
      Get.log('HomeController loadCurrentTours error: $e\n$st');
      Get.snackbar('Error', 'Failed to load current tours');
    }
  }

  Future<void> loadTourActivities(
    String tourId, {
    bool showCompletionSnackbars = true,
  }) async {
    try {
      activeTourId.value = tourId;

      Map<String, dynamic>? tourData;

      final tourDoc = await FirebaseFirestore.instance
          .collection('tourPackages')
          .doc(tourId)
          .get();

      if (tourDoc.exists) {
        tourData = tourDoc.data() as Map<String, dynamic>;
      } else {
        final legacyDoc = await FirebaseFirestore.instance
            .collection('packages')
            .doc(tourId)
            .get();

        if (legacyDoc.exists) {
          tourData = legacyDoc.data() as Map<String, dynamic>;
        }
      }

      if (tourData == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final ratedDoc = await FirebaseFirestore.instance
              .collection('tourPackages')
              .doc(tourId)
              .collection('ratings')
              .doc(user.uid)
              .get();
          ratedByTourId[tourId] = ratedDoc.exists;
        } catch (_) {
          ratedByTourId[tourId] = false;
        }
      }

      final live = tourData['liveTourState'] as Map<String, dynamic>?;
      final ended = (live?['ended'] as bool?) ?? false;
      tourEndedByTourId[tourId] = ended;

      final Set<String> completedIds = <String>{};
      if (user != null) {
        final attemptsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_attempts')
            .where('packageId', isEqualTo: tourId)
            .get();

        for (final a in attemptsSnap.docs) {
          final attemptData = a.data();
          final activityId = (attemptData['activityId'] ?? '').toString();
          if (activityId.isNotEmpty) {
            completedIds.add(activityId);
          }
        }
      }

      final activities = (tourData['activities'] as List<dynamic>?) ?? [];

      final List<Map<String, dynamic>> markers = [];
      final List<Map<String, dynamic>> loadedActivities = [];
      var activityIndex = 0;
      for (final a in activities) {
        activityIndex++;
        final m = (a as Map).cast<String, dynamic>();
        var activityId = (m['activityId'] ?? '').toString().trim();
        if (activityId.isEmpty) {
          activityId = '${tourId}_activity_$activityIndex';
        }
        final title = (m['activityName'] ?? '').toString();
        final question = (m['question'] ?? '').toString();
        final photoChallengeEnabled =
            (m['photoChallengeEnabled'] as bool?) ?? false;
        final photoChallengeText =
            (m['photoChallengeText'] ?? '').toString();
        final options = (m['answerOptions'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[];

        final isCompleted = completedIds.contains(activityId);

        loadedActivities.add({
          'activityId': activityId,
          'title': title,
          'question': question,
          'options': options,
          'latitude': _toDouble(m['latitude']),
          'longitude': _toDouble(m['longitude']),
          'isCompleted': isCompleted,
          'photoChallengeEnabled': photoChallengeEnabled,
          'photoChallengeText': photoChallengeText,
        });

        final lat = _toDouble(m['latitude']);
        final lng = _toDouble(m['longitude']);
        if (lat == null || lng == null) continue;

        markers.add({
          'activityId': activityId,
          'title': title,
          'position': LatLng(lat, lng),
          'question': question,
          'options': options,
          'isCompleted': isCompleted,
          'photoChallengeEnabled': photoChallengeEnabled,
          'photoChallengeText': photoChallengeText,
        });
      }

      if (markers.isNotEmpty) {
        final center = markers.first['position'] as LatLng;
        mapCenterByTourId[tourId] = center;
        mapCenter.value = center;
      }

      tourActivitiesByTourId[tourId] = loadedActivities;
      activityMapMarkersByTourId[tourId] = markers;
      completedActivityIdsByTourId[tourId] = completedIds.toList(growable: false);

      if (activeTourId.value == tourId) {
        tourActivities.assignAll(loadedActivities);
        activityMapMarkers.assignAll(markers);
        completedActivityIds
          ..clear()
          ..addAll(completedIds);
      }

      int firstIncomplete = 0;
      for (var i = 0; i < loadedActivities.length; i++) {
        final isCompleted = (loadedActivities[i]['isCompleted'] as bool?) ?? false;
        if (!isCompleted) {
          firstIncomplete = i;
          break;
        }
      }

      if (ended && loadedActivities.isNotEmpty && completedIds.length >= loadedActivities.length) {
        try {
          final earned = await Get.find<GamificationService>().awardTourCompletionPoints(
            packageId: tourId,
          );
          if (showCompletionSnackbars && earned > 0) {
            Get.snackbar(
              'Reward',
              'Thank you for completing this tour your reward +$earned',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } catch (_) {
          // Ignore points errors.
        }
      }

      selectedActivityIndexByTourId[tourId] = firstIncomplete;
      if (activeTourId.value == tourId) {
        selectedActivityIndex.value = firstIncomplete;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tour activities');
    }
  }

  Future<void> submitTourRating({
    required String tourId,
    required int rating,
    required String review,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _packagesService.submitTourRating(
      packageId: tourId,
      rating: rating,
      review: review,
    );

    ratedByTourId[tourId] = true;

    try {
      await Get.find<GamificationService>().awardRatingPoints(
        packageId: tourId,
      );
    } catch (_) {
      // Ignore points errors.
    }

    await loadCurrentTours();
  }

  void loadTours() {
    _packagesService.getAllPackagesStream().listen((tours) {
      calculateRecommendations(tours);
    });
  }

  Future<void> loadUserInterests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      userInterests.value =
          List<String>.from(data?['interests'] ?? []);
    }
  }

 void calculateRecommendations(List<Map<String, dynamic>> tours) {

  List<Map<String, dynamic>> scoredTours = [];

  for (var tour in tours) {

    int score = 0;

    List activities = tour['activities'] ?? [];

    for (var activity in activities) {

      String type = activity['activityType'] ?? '';

      if (userInterests.contains(type)) {
        score++;
      }

    }

    tour['score'] = score;
    scoredTours.add(tour);
  }

  scoredTours.sort((a, b) => b['score'].compareTo(a['score']));

  recommendedTours.value = scoredTours.take(3).toList();
}
}