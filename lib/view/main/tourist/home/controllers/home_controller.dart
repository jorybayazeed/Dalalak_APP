import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tour_app/view/main/tourist/home/views/home_view.dart';
import 'package:tour_app/view/main/tourist/explore/views/explore_view.dart';
import 'package:tour_app/view/main/tourist/bookings/views/bookings_view.dart';
import 'package:tour_app/view/main/tourist/profile/views/profile_view.dart';
import 'package:tour_app/services/packages_service.dart';
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

  final Map<String, MapController> _mapControllersByTourId =
      <String, MapController>{};

  final RxSet<String> completedActivityIds = <String>{}.obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<User?>? _authSub;

  final PackagesService _packagesService = Get.find<PackagesService>();

  RxList<Map<String, dynamic>> recommendedTours = <Map<String, dynamic>>[].obs;
  RxList<String> userInterests = <String>[].obs;

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
    super.onClose();
  }

  Future<void> _onAuthChanged(User? user) async {
    _userDocSub?.cancel();
    _userDocSub = null;

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

    _bindUserGamification(uid: user.uid);
    await loadUserInterests();
    loadTours();
    await loadCurrentTours();
  }

  void _bindUserGamification({required String uid}) {

    _userDocSub?.cancel();
    _userDocSub = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      final data = snap.data();
      if (data == null) return;

      final points = (data['totalPoints'] as num?)?.toInt();
      totalPoints.value = points ?? 0;
      rewardsPoints.value = totalPoints.value;
      if (points == null) {
        _loadQuizAttemptsPointsFallback(uid);
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
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('quiz_attempts')
          .get();

      int sum = 0;
      for (final d in snap.docs) {
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

  void viewRewards() {}
  void viewMyRewards() {}
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

  Future<void> loadCurrentTours() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final bookingsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('upcomingBookings')
          .get();

      final List<Map<String, dynamic>> loaded = [];

      for (final doc in bookingsSnapshot.docs) {
        final data = doc.data();
        final tourId = (data['tourId'] ?? '').toString();
        if (tourId.isEmpty) continue;

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
        }

        int pointsEarned = 0;
        final Set<String> completedActivityIds = <String>{};

        final attemptsSnap = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('quiz_attempts')
            .where('packageId', isEqualTo: tourId)
            .get();

        for (final a in attemptsSnap.docs) {
          final attemptData = a.data();
          pointsEarned += (attemptData['pointsEarned'] as num?)?.toInt() ?? 0;
          final activityId = (attemptData['activityId'] ?? '').toString();
          if (activityId.isNotEmpty) {
            completedActivityIds.add(activityId);
          }
        }

        loaded.add({
          'tourId': tourId,
          'title': (data['tourTitle'] ?? '').toString(),
          'date': (data['availableDates'] ?? '').toString(),
          'guide': guideName,
          'totalActivities': totalActivities,
          'completedActivities': completedActivityIds.length,
          'pointsEarned': pointsEarned,
        });
      }

      currentTours.assignAll(loaded);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load current tours');
    }
  }

  Future<void> loadTourActivities(String tourId) async {
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

      final Set<String> completedIds = <String>{};
      final user = FirebaseAuth.instance.currentUser;
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
      for (final a in activities) {
        final m = (a as Map).cast<String, dynamic>();
        final activityId = (m['activityId'] ?? '').toString();
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
          'latitude': (m['latitude'] as num?)?.toDouble(),
          'longitude': (m['longitude'] as num?)?.toDouble(),
          'isCompleted': isCompleted,
          'photoChallengeEnabled': photoChallengeEnabled,
          'photoChallengeText': photoChallengeText,
        });

        final lat = (m['latitude'] as num?)?.toDouble();
        final lng = (m['longitude'] as num?)?.toDouble();
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
      selectedActivityIndexByTourId[tourId] = firstIncomplete;
      if (activeTourId.value == tourId) {
        selectedActivityIndex.value = firstIncomplete;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tour activities');
    }
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