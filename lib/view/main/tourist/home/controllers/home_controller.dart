import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tour_app/services/gamification_service.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/views/dashboard_view.dart';
import 'package:tour_app/view/main/tourist/bookings/views/bookings_view.dart';
import 'package:tour_app/view/main/tourist/explore/views/explore_view.dart';
import 'package:tour_app/view/main/tourist/home/views/home_view.dart';
import 'package:tour_app/view/main/tourist/profile/views/profile_view.dart';
import 'package:tour_app/view/main/tourist/rewards/views/rewards_view.dart';

class TouristHomeController extends GetxController {
  final PackagesService _packagesService = Get.find<PackagesService>();
  final GamificationService _gamificationService =
      Get.find<GamificationService>();

  final currentBottomNavIndex = 0.obs;

  final userName = 'User'.obs;

  final totalPoints = 0.obs;

  final level = 'Starter'.obs;
  final levelName = 'Starter'.obs;
  final levelDescription = 'Beginning the journey'.obs;
  final levelNumber = 1.obs;
  final nextLevelName = ''.obs;
  final remainingPointsToNextLevel = 0.obs;
  final levelProgress = 0.0.obs;

  final badgesCount = 0.obs;
  final completedActivities = 0.obs;
  final totalActivities = 0.obs;
  final rewardsPoints = 0.obs;

  final currentTours = <Map<String, dynamic>>[].obs;
  final recommendedTours = <Map<String, dynamic>>[].obs;
  final userInterests = <String>[].obs;

  final mapCenter = const LatLng(24.7136, 46.6753).obs;
  final activityMapMarkers = <Map<String, dynamic>>[].obs;
  final tourActivities = <Map<String, dynamic>>[].obs;

  final expandedTourIds = <String>{}.obs;
  final autoFittedTourIds = <String>{}.obs;

  final activeTourId = ''.obs;
  final selectedActivityIndex = 0.obs;
  final ratePromptTourId = RxnString();

  final mapCenterByTourId = <String, LatLng>{}.obs;
  final activityMapMarkersByTourId = <String, List<Map<String, dynamic>>>{}.obs;
  final tourActivitiesByTourId = <String, List<Map<String, dynamic>>>{}.obs;
  final selectedActivityIndexByTourId = <String, int>{}.obs;
  final completedActivityIdsByTourId = <String, List<String>>{}.obs;
  final tourEndedByTourId = <String, bool>{}.obs;
  final ratedByTourId = <String, bool>{}.obs;

  final completedActivityIds = <String>{}.obs;

  final Map<String, MapController> _mapControllersByTourId = {};

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userDocSub;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingsSub;

  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
      _tourEndedSubs = {};

  bool _bootstrappedUserDoc = false;
  bool _recomputedMissingPoints = false;
  bool _recomputedPointsOnLogin = false;
  bool _shownPointsRecomputeError = false;
  bool _shownUserDocWriteError = false;

  int _currentToursLoadSeq = 0;

  final Map<String, bool> _lastEndedByTourId = {};
  final Set<String> _tourEndedNotified = {};
  final Set<String> _bookingCompletedByTourId = {};

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() async {
    await _gamificationService.refreshBadgesForCurrentUser();
  });

    loadUserName();

    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) async {
      await _onAuthChanged(user);
    });

    _onAuthChanged(FirebaseAuth.instance.currentUser);
  }

  @override
  void onClose() {
    _userDocSub?.cancel();
    _authSub?.cancel();
    _bookingsSub?.cancel();

    for (final sub in _tourEndedSubs.values) {
      sub.cancel();
    }

    super.onClose();
  }

  Future<void> _onAuthChanged(User? user) async {
    _userDocSub?.cancel();
    _bookingsSub?.cancel();

    for (final sub in _tourEndedSubs.values) {
      sub.cancel();
    }
    _tourEndedSubs.clear();
    _lastEndedByTourId.clear();
    _tourEndedNotified.clear();

    totalPoints.value = 0;
    rewardsPoints.value = 0;
    _applyLevelSummary(0);
    //badgesCount.value = 0;
    currentTours.clear();
    recommendedTours.clear();
    userInterests.clear();
    userName.value = 'User';

    if (user == null) return;

    _bootstrappedUserDoc = false;
    _recomputedMissingPoints = false;
    _recomputedPointsOnLogin = false;

    await loadUserName();

    _bindUserGamification(uid: user.uid);

    _bookingsSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('upcomingBookings')
        .snapshots()
        .listen((_) {
      loadCurrentTours(showCompletionSnackbars: false);
    });

    try {
      await _gamificationService.recomputeAndSyncTotalPoints(userId: user.uid);
    } catch (_) {}

    try {
      await _gamificationService.cleanupChallengeAttempts(userId: user.uid);
    } catch (_) {}

    try {
      await _gamificationService.validateTourCompletionEventsAndRecompute(
        userId: user.uid,
      );
    } catch (_) {}

    await loadUserInterests();
    loadTours();
    await loadCurrentTours();
  }

  void _applyLevelSummary(int points) {
    final summary = _gamificationService.getLevelSummary(points);

    level.value = (summary['levelName'] ?? 'Starter').toString();
    levelName.value = (summary['levelName'] ?? 'Starter').toString();
    levelDescription.value =
        (summary['levelDescription'] ?? 'Beginning the journey').toString();
    levelNumber.value = (summary['levelNumber'] as int?) ?? 1;
    nextLevelName.value = (summary['nextLevelName'] ?? '').toString();
    remainingPointsToNextLevel.value =
        (summary['remainingPoints'] as int?) ?? 0;
    levelProgress.value = (summary['progress'] as num?)?.toDouble() ?? 0.0;
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
          final summary = _gamificationService.getLevelSummary(0);

          await FirebaseFirestore.instance.collection('users').doc(uid).set(
            {
              'totalPoints': 0,
              'level': summary['levelName'],
              'levelNumber': summary['levelNumber'],
              'levelDescription': summary['levelDescription'],
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } catch (_) {
          if (!_shownUserDocWriteError) {
            _shownUserDocWriteError = true;
            Get.snackbar(
              'Error',
              'Failed to create user profile in Firestore',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
        return;
      }

      if (data == null) return;

      final fullName = (data['fullName'] ?? '').toString().trim();
      if (fullName.isNotEmpty) {
        userName.value = fullName.split(' ').first;
      }

      final points = (data['totalPoints'] as num?)?.toInt() ?? 0;
      totalPoints.value = points;
      rewardsPoints.value = points;
      _applyLevelSummary(points);

      final badges = data['badges'];
      if (badges is List) {
        badgesCount.value = badges.length;
      } else {
        badgesCount.value = (data['badgesCount'] as num?)?.toInt() ?? 0;
      }

      if (!_recomputedPointsOnLogin) {
        _recomputedPointsOnLogin = true;
        try {
          await _gamificationService.recomputeAndSyncTotalPoints(
            userId: uid,
            force: true,
          );
        } catch (_) {}
      }

      if ((data['totalPoints'] == null) && !_recomputedMissingPoints) {
        _recomputedMissingPoints = true;
        try {
          await _gamificationService.recomputeAndSyncTotalPoints(
            userId: uid,
            force: true,
          );
        } catch (_) {
          if (!_shownPointsRecomputeError) {
            _shownPointsRecomputeError = true;
            Get.snackbar(
              'Error',
              'Failed to compute points',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      }
    });
  }

  Future<void> loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        userName.value = 'User';
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        userName.value = 'User';
        return;
      }

      final data = doc.data() as Map<String, dynamic>;
      final fullName = (data['fullName'] ?? '').toString().trim();

      userName.value = fullName.isEmpty ? 'User' : fullName.split(' ').first;
    } catch (_) {
      userName.value = 'User';
    }
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
      userInterests.value = List<String>.from(data?['interests'] ?? []);
    } else {
      userInterests.clear();
    }
  }

  void loadTours() {
    _packagesService.getAllPackagesStream().listen((tours) {
      calculateRecommendations(tours);
    });
  }

  String _normalizeText(String text) {
    return text.trim().toLowerCase();
  }

  double _readPriceValue(Map<String, dynamic> tour) {
    final price = tour['price'];
    if (price is num) return price.toDouble();
    if (price is String) {
      return double.tryParse(price.trim()) ?? 0;
    }
    return 0;
  }

  List<String> _extractTourKeywords(Map<String, dynamic> tour) {
    final keywords = <String>[];

    void addValue(dynamic value) {
      if (value == null) return;
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        keywords.add(_normalizeText(text).replaceAll('&', 'and'));
      }
    }

    addValue(tour['tourTitle']);
    addValue(tour['destination']);
    addValue(tour['category']);
    addValue(tour['type']);
    addValue(tour['description']);

    final tags = tour['tags'];
    if (tags is List) {
      for (final tag in tags) {
        addValue(tag);
      }
    }

    final activities = tour['activities'];
    if (activities is List) {
      for (final activity in activities) {
        if (activity is Map) {
          addValue(activity['activityType']);
          addValue(activity['activityName']);
          addValue(activity['title']);
          addValue(activity['description']);
        }
      }
    }

    return keywords;
  }

  bool _matchesInterestKeyword(String interest, String keyword) {
    if (keyword.contains(interest) || interest.contains(keyword)) {
      return true;
    }

    final groups = [
      {
        'cultural heritage',
        'culture',
        'heritage',
        'historical',
        'history',
      },
      {
        'nature and wildlife',
        'nature and wildlife'.replaceAll('&', 'and'),
        'nature',
        'wildlife',
        'outdoor',
      },
      {
        'food and culinary',
        'food',
        'culinary',
        'restaurant',
        'dining',
      },
      {
        'relaxation',
        'relax',
        'spa',
        'calm',
      },
      {
        'photography',
        'photo',
        'pictures',
        'scenic',
      },
      {
        'entertainment',
        'fun',
        'festival',
        'events',
      },
      {
        'beach',
        'sea',
        'coast',
        'island',
      },
      {
        'religious',
        'spiritual',
        'mosque',
        'islamic',
      },
      {
        'adventure',
        'hiking',
        'camping',
        'safari',
        'climbing',
      },
    ];

    for (final group in groups) {
      if (group.contains(interest) && group.contains(keyword)) {
        return true;
      }
    }

    return false;
  }

  int _calculateInterestScore(
    Map<String, dynamic> tour,
    List<String> normalizedInterests,
  ) {
    int score = 0;
    final keywords = _extractTourKeywords(tour);

    for (final interest in normalizedInterests) {
      if (interest.isEmpty) continue;

      bool matched = false;
      for (final keyword in keywords) {
        if (_matchesInterestKeyword(interest, keyword)) {
          matched = true;
          break;
        }
      }

      if (matched) {
        score += 4;
      }
    }

    return score;
  }

  int _calculateBudgetScore(Map<String, dynamic> tour, String normalizedBudget) {
    if (normalizedBudget.isEmpty) return 0;

    final price = _readPriceValue(tour);

    if (normalizedBudget == 'budget-friendly' ||
        normalizedBudget == 'budget friendly') {
      if (price > 0 && price <= 150) return 3;
      if (price > 150 && price <= 250) return 1;
      return 0;
    }

    if (normalizedBudget == 'mid-range' || normalizedBudget == 'mid range') {
      if (price > 150 && price <= 400) return 3;
      if (price > 0 && price <= 500) return 1;
      return 0;
    }

    if (normalizedBudget == 'luxury') {
      if (price >= 400) return 3;
      if (price >= 300) return 1;
      return 0;
    }

    return 0;
  }

  int _calculatePaceScore(Map<String, dynamic> tour, String normalizedPace) {
    if (normalizedPace.isEmpty) return 0;

    final keywords = _extractTourKeywords(tour);

    final relaxedKeywords = {
      'relax',
      'slow',
      'calm',
      'spa',
      'beach',
      'nature',
    };

    final fastKeywords = {
      'adventure',
      'action',
      'fast',
      'hiking',
      'safari',
      'climbing',
    };

    if (normalizedPace == 'relaxed and slow-paced' ||
        normalizedPace == 'relax and slow-paced') {
      for (final keyword in keywords) {
        if (relaxedKeywords.contains(keyword)) return 2;
      }
    }

    if (normalizedPace == 'action-packed and fast-paced' ||
        normalizedPace == 'action packed and fast paced') {
      for (final keyword in keywords) {
        if (fastKeywords.contains(keyword)) return 2;
      }
    }

    if (normalizedPace == 'a bit of both') {
      return 1;
    }

    return 0;
  }

  void calculateRecommendations(List<Map<String, dynamic>> tours) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      recommendedTours.value = tours.take(3).toList();
      return;
    }

    FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
      final data = doc.data() ?? <String, dynamic>{};

      final normalizedInterests = List<String>.from(data['interests'] ?? [])
          .map((e) => _normalizeText(e).replaceAll('&', 'and'))
          .where((e) => e.isNotEmpty)
          .toList();

      final normalizedBudget =
          _normalizeText((data['travelBudget'] ?? '').toString());
      final normalizedPace =
          _normalizeText((data['travelPace'] ?? '').toString());

      final List<Map<String, dynamic>> scoredTours = [];

      for (final originalTour in tours) {
        final tour = Map<String, dynamic>.from(originalTour);

        final interestScore =
            _calculateInterestScore(tour, normalizedInterests);
        final budgetScore = _calculateBudgetScore(tour, normalizedBudget);
        final paceScore = _calculatePaceScore(tour, normalizedPace);

        final totalScore = interestScore + budgetScore + paceScore;

        final title = (tour['tourTitle'] ?? '').toString().trim();
        final destination = (tour['destination'] ?? '').toString().trim();
        final price = _readPriceValue(tour);

        if (title.isEmpty || title.length < 4) {
          continue;
        }

        if (destination.isEmpty) {
          continue;
        }

        if (price <= 0) {
          continue;
        }

        tour['score'] = totalScore;
        scoredTours.add(tour);
      }

      scoredTours.sort((a, b) {
        final scoreCompare = (b['score'] ?? 0).compareTo(a['score'] ?? 0);
        if (scoreCompare != 0) return scoreCompare;

        final priceA = _readPriceValue(a);
        final priceB = _readPriceValue(b);
        return priceA.compareTo(priceB);
      });

      final matchedTours =
          scoredTours.where((tour) => (tour['score'] ?? 0) > 0).toList();

      if (matchedTours.isNotEmpty) {
        recommendedTours.value = matchedTours.take(3).toList();
      } else {
        recommendedTours.value = scoredTours.take(3).toList();
      }
    });
  }

  void changeBottomNavIndex(int index) {
    if (currentBottomNavIndex.value == index) return;

    currentBottomNavIndex.value = index;

    switch (index) {
      case 0:
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
    Get.to(() => TouristRewardsView());
  }

  Future<void> loadCurrentTours({
    bool showCompletionSnackbars = true,
  }) async {
    final seq = ++_currentToursLoadSeq;

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

        final tourId = (data['tourId'] ?? doc.id).toString();
        final title = (data['tourTitle'] ?? '').toString();
        final date = (data['availableDates'] ?? '').toString();

        final tourDoc = await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(tourId)
            .get();

        if (!tourDoc.exists) continue;

        final tourData = tourDoc.data() as Map<String, dynamic>;
        final activities = (tourData['activities'] as List<dynamic>?) ?? [];

        final live = tourData['liveTourState'] as Map<String, dynamic>?;
        final ended = (live?['ended'] as bool?) ?? false;
        tourEndedByTourId[tourId] = ended;

        String guideName = '';
        final guideId = (tourData['guideId'] ?? '').toString();
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

        int pointsEarned = 0;
        final Set<String> completedIds = <String>{};

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
          if (activityId.isNotEmpty) completedIds.add(activityId);
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
        } catch (_) {}

        loaded.add({
          'tourId': tourId,
          'title': title,
          'date': date,
          'guide': guideName,
          'totalActivities': activities.length,
          'completedActivities': completedIds.length,
          'pointsEarned': pointsEarned,
          'ended': ended,
          'rated': ratedByTourId[tourId] ?? false,
        });
      }

      if (seq != _currentToursLoadSeq) return;
      currentTours.assignAll(loaded);

      final totalCompleted = loaded.fold<int>(
        0,
        (sum, item) => sum + ((item['completedActivities'] as int?) ?? 0),
      );

      final totalAll = loaded.fold<int>(
        0,
        (sum, item) => sum + ((item['totalActivities'] as int?) ?? 0),
      );

      completedActivities.value = totalCompleted;
      totalActivities.value = totalAll;

      _syncTourEndedListeners(
        loaded
            .map((t) => (t['tourId'] ?? '').toString())
            .where((id) => id.isNotEmpty)
            .toSet(),
      );
    } catch (_) {
      Get.snackbar('Error', 'Failed to load current tours');
    }
  }

  void _syncTourEndedListeners(Set<String> tourIds) {
    final toRemove = _tourEndedSubs.keys
        .where((id) => !tourIds.contains(id))
        .toList();

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

        await _maybeAwardTourCompletionAndNotify(tourId);
      });

      _tourEndedSubs[tourId] = sub;
    }
  }

  Future<void> _maybeAwardTourCompletionAndNotify(String tourId) async {
    try {
      final earned =
          await _gamificationService.awardTourCompletionPoints(packageId: tourId);

      if (earned > 0) {
        Get.snackbar(
          'Reward',
          'Thank you for completing the tour you earned +$earned',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {}
  }

  Future<void> loadTourActivities(
    String tourId, {
    bool showCompletionSnackbars = true,
  }) async {
    try {
      activeTourId.value = tourId;

      final tourDoc = await FirebaseFirestore.instance
          .collection('tourPackages')
          .doc(tourId)
          .get();

      if (!tourDoc.exists) return;

      final tourData = tourDoc.data() as Map<String, dynamic>;
      final activities = (tourData['activities'] as List<dynamic>?) ?? [];

      final user = FirebaseAuth.instance.currentUser;
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

      final List<Map<String, dynamic>> markers = [];
      final List<Map<String, dynamic>> loadedActivities = [];

      var activityIndex = 0;
      for (final a in activities) {
        activityIndex++;
        final m = (a as Map).cast<String, dynamic>();

        var activityId = (m['activityId'] ?? '').toString().trim();
        if (activityId.isEmpty) {
          activityId = '${tourId}activity$activityIndex';
        }

        final lat = _toDouble(m['latitude']);
        final lng = _toDouble(m['longitude']);
        final isCompleted = completedIds.contains(activityId);

        loadedActivities.add({
          'activityId': activityId,
          'title': (m['activityName'] ?? '').toString(),
          'question': (m['question'] ?? '').toString(),
          'options': (m['answerOptions'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              <String>[],
          'latitude': lat,
          'longitude': lng,
          'isCompleted': isCompleted,
          'photoChallengeEnabled': (m['photoChallengeEnabled'] as bool?) ?? false,
          'photoChallengeText': (m['photoChallengeText'] ?? '').toString(),
        });

        if (lat != null && lng != null) {
          markers.add({
            'activityId': activityId,
            'title': (m['activityName'] ?? '').toString(),
            'position': LatLng(lat, lng),
            'question': (m['question'] ?? '').toString(),
            'options': (m['answerOptions'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                <String>[],
            'isCompleted': isCompleted,
            'photoChallengeEnabled':
                (m['photoChallengeEnabled'] as bool?) ?? false,
            'photoChallengeText': (m['photoChallengeText'] ?? '').toString(),
          });
        }
      }

      if (markers.isNotEmpty) {
        final center = markers.first['position'] as LatLng;
        mapCenterByTourId[tourId] = center;
        mapCenter.value = center;
      }

      tourActivitiesByTourId[tourId] = loadedActivities;
      activityMapMarkersByTourId[tourId] = markers;
      completedActivityIdsByTourId[tourId] = completedIds.toList();

      if (activeTourId.value == tourId) {
        tourActivities.assignAll(loadedActivities);
        activityMapMarkers.assignAll(markers);
        completedActivityIds
          ..clear()
          ..addAll(completedIds);
      }

      int firstIncomplete = 0;
      for (var i = 0; i < loadedActivities.length; i++) {
        if ((loadedActivities[i]['isCompleted'] as bool?) != true) {
          firstIncomplete = i;
          break;
        }
      }

      selectedActivityIndexByTourId[tourId] = firstIncomplete;
      if (activeTourId.value == tourId) {
        selectedActivityIndex.value = firstIncomplete;
      }
    } catch (_) {
      Get.snackbar('Error', 'Failed to load tour activities');
    }
  }

  MapController mapControllerForTour(String tourId) {
    final existing = _mapControllersByTourId[tourId];
    if (existing != null) return existing;

    final created = MapController();
    _mapControllersByTourId[tourId] = created;
    return created;
  }

  void setSelectedActivityIndexForTour(String tourId, int index) {
    if (index < 0) return;
    selectedActivityIndexByTourId[tourId] = index;
    if (activeTourId.value == tourId) {
      selectedActivityIndex.value = index;
    }
  }

  void setSelectedActivityIndex(int index) {
    if (index < 0) return;
    selectedActivityIndex.value = index;
  }

  void toggleTourExpanded(String tourId) {
    if (expandedTourIds.contains(tourId)) {
      expandedTourIds.remove(tourId);
      autoFittedTourIds.remove(tourId);
    } else {
      expandedTourIds.add(tourId);
      activeTourId.value = tourId;
      loadTourActivities(tourId);
    }
  }

  Future<void> submitTourRating({
    required String tourId,
    required int rating,
    required String review,
  }) async {
    await _packagesService.submitTourRating(
      packageId: tourId,
      rating: rating,
      review: review,
    );

    ratedByTourId[tourId] = true;

    try {
      await _gamificationService.awardRatingPoints(packageId: tourId);
    } catch (_) {}

    await loadCurrentTours();
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }
}