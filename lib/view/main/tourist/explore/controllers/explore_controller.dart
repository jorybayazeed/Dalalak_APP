import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/user_service.dart';

class ExploreController extends GetxController {

  final PackagesService _packagesService = Get.find();
  final UserService _userService = Get.find();

  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;

  final RxString selectedRegion = 'All Regions'.obs;
  final RxString selectedDate = 'Any Date'.obs;
  final RxString selectedPriceRange = 'Any Price'.obs;
  final RxString selectedActivityType = 'All Activities'.obs;

  final RxBool isAIRecommendations = false.obs;
  final RxBool isNearMe = false.obs;
  final RxBool isFiltersVisible = false.obs;

  final RxList<Map<String, dynamic>> tours = <Map<String, dynamic>>[].obs;

  Map<String, dynamic>? _touristProfile;

  Stream<List<Map<String, dynamic>>>? packagesStream;

  // Saudi Arabia cities covered by the app
  static const List<String> _saudiCities = [
    'Riyadh', 'Jeddah', 'AlUla', 'Abha', 'Taif',
    'Dammam', 'Makkah', 'Madinah', 'Diriyah',
  ];

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    packagesStream = _packagesService.getAllPackagesStream();

    packagesStream!.listen((data) {
      tours.assignAll(data);
    });

    _loadTouristProfile();
  }

  Future<void> _loadTouristProfile() async {
    _touristProfile = await _userService.getCurrentUserData();
  }

  void toggleFilters() {
    isFiltersVisible.value = !isFiltersVisible.value;
  }

  void toggleAIRecommendations() {
    isAIRecommendations.value = !isAIRecommendations.value;
  }

  void toggleNearMe() {
    isNearMe.value = !isNearMe.value;
  }

  void selectRegion(String region) {
    selectedRegion.value = region;
  }

  void selectDate(String date) {
    selectedDate.value = date;
  }

  void selectPriceRange(String priceRange) {
    selectedPriceRange.value = priceRange;
  }

  void selectActivityType(String activityType) {
    selectedActivityType.value = activityType;
  }

  void toggleFavorite(String tourId) {
    final index = tours.indexWhere((tour) => tour['id'] == tourId);
    if (index != -1) {
      tours[index]['isFavorite'] = !(tours[index]['isFavorite'] ?? false);
      tours.refresh();
    }
  }

  /// Returns the filtered (and optionally AI-sorted) list of tours based on
  /// all active filter settings.
  List<Map<String, dynamic>> get filteredTours {
    var result = tours.toList();

    // --- Region filter ---
    if (selectedRegion.value != 'All Regions') {
      result = result.where((tour) {
        final dest = (tour['destination'] as String? ?? '').toLowerCase();
        return dest == selectedRegion.value.toLowerCase();
      }).toList();
    }

    // --- Available Date filter ---
    if (selectedDate.value != 'Any Date') {
      result = result.where(_matchesDateFilter).toList();
    }

    // --- Price Range filter ---
    if (selectedPriceRange.value != 'Any Price') {
      result = result.where(_matchesPriceFilter).toList();
    }

    // --- Activity Type filter ---
    if (selectedActivityType.value != 'All Activities') {
      result = result.where((tour) {
        final actType = (tour['activityType'] as String? ?? '').toLowerCase();
        return actType == selectedActivityType.value.toLowerCase();
      }).toList();
    }

    // --- Search text filter ---
    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      result = result.where((tour) {
        final title = (tour['tourTitle'] as String? ?? '').toLowerCase();
        final dest = (tour['destination'] as String? ?? '').toLowerCase();
        return title.contains(query) || dest.contains(query);
      }).toList();
    }

    // --- Near Me filter (based on tourist's country of residence) ---
    if (isNearMe.value) {
      result = _applyNearMeFilter(result);
    }

    // --- AI Recommendations (sort by relevance to tourist profile) ---
    if (isAIRecommendations.value) {
      result = _applyAIRecommendations(result);
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool _matchesDateFilter(Map<String, dynamic> tour) {
    final availableDates = tour['availableDates'] as String?;
    if (availableDates == null || availableDates.isEmpty) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final parts = availableDates.split(' - ');
    if (parts.length != 2) return false;

    final start = _parseDate(parts[0]);
    final end = _parseDate(parts[1]);
    if (start == null || end == null) return false;

    switch (selectedDate.value) {
      case 'Today':
        // Package must be available today
        return !today.isBefore(start) && !today.isAfter(end);

      case 'This Week':
        // Package overlaps with the current calendar week (Mon–Sun)
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return start.isBefore(weekEnd.add(const Duration(days: 1))) &&
            end.isAfter(weekStart.subtract(const Duration(days: 1)));

      case 'This Month':
        // Package overlaps with the current month
        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 0);
        return start.isBefore(monthEnd.add(const Duration(days: 1))) &&
            end.isAfter(monthStart.subtract(const Duration(days: 1)));

      default:
        return true;
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.trim().split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  bool _matchesPriceFilter(Map<String, dynamic> tour) {
    final priceStr = tour['price'] as String?;
    if (priceStr == null || priceStr.isEmpty) return false;
    final price = double.tryParse(priceStr) ?? 0;

    switch (selectedPriceRange.value) {
      case 'Under 300 SAR':
        return price < 300;
      case '300 - 500 SAR':
        return price >= 300 && price <= 500;
      case 'Above 500 SAR':
        return price > 500;
      default:
        return true;
    }
  }

  /// Near Me: show packages whose destination is in Saudi Arabia when the
  /// tourist lives in Saudi Arabia; otherwise show packages for tourists
  /// visiting (i.e., return all since the app covers Saudi Arabia only).
  List<Map<String, dynamic>> _applyNearMeFilter(
      List<Map<String, dynamic>> list) {
    final country =
        (_touristProfile?['countryOfResidence'] as String? ?? '').toLowerCase();

    final isInSaudi = country.contains('saudi') ||
        country.contains('ksa') ||
        country.contains('المملكة');

    if (isInSaudi) {
      // Tourist resides in Saudi Arabia – all destinations are "near"
      return list;
    } else {
      // Tourist is from abroad – show packages whose destination is a
      // recognised Saudi city (they are visiting Saudi Arabia)
      return list.where((tour) {
        final dest = (tour['destination'] as String? ?? '');
        return _saudiCities.any(
          (city) => city.toLowerCase() == dest.toLowerCase(),
        );
      }).toList();
    }
  }

  /// AI Recommendations: score each package against the tourist's profile and
  /// return the list sorted by descending relevance score.
  ///
  /// Scoring dimensions:
  ///  +3  each interest that matches the package's activityType or description
  ///  +2  budget tier matches the package price range
  ///  +1  travelPace keyword found in description / title
  ///  +1  tripType keyword found in description / title
  List<Map<String, dynamic>> _applyAIRecommendations(
      List<Map<String, dynamic>> list) {
    if (_touristProfile == null) return list;

    final budget =
        (_touristProfile!['travelBudget'] as String? ?? '').toLowerCase();
    final interests = (_touristProfile!['interests'] as List<dynamic>?)
            ?.map((e) => e.toString().toLowerCase())
            .toList() ??
        [];
    final travelPace =
        (_touristProfile!['travelPace'] as String? ?? '').toLowerCase();
    final tripType =
        (_touristProfile!['tripType'] as String? ?? '').toLowerCase();

    double scorePackage(Map<String, dynamic> tour) {
      double score = 0;

      final actType =
          (tour['activityType'] as String? ?? '').toLowerCase();
      final desc =
          (tour['tourDescription'] as String? ?? '').toLowerCase();
      final title = (tour['tourTitle'] as String? ?? '').toLowerCase();
      final priceStr = tour['price'] as String? ?? '';
      final price = double.tryParse(priceStr) ?? 0;

      // Budget match
      if ((budget == 'budget' || budget == 'low') && price < 300) score += 2;
      if ((budget == 'moderate' || budget == 'medium') &&
          price >= 300 &&
          price <= 500) score += 2;
      if ((budget == 'luxury' || budget == 'high') && price > 500) score += 2;

      // Interest match against activityType, description, and title
      for (final interest in interests) {
        // Exact activity type match scores highest
        if (actType == interest) {
          score += 3;
        } else if (_containsWholeWord(actType, interest) ||
            _containsWholeWord(interest, actType)) {
          score += 2;
        } else if (desc.contains(interest) || title.contains(interest)) {
          score += 1;
        }
      }

      // Travel pace keyword match
      if (travelPace.isNotEmpty &&
          (desc.contains(travelPace) || title.contains(travelPace))) {
        score += 1;
      }

      // Trip type keyword match
      if (tripType.isNotEmpty &&
          (desc.contains(tripType) || title.contains(tripType))) {
        score += 1;
      }

      return score;
    }

    final scored = list
        .map((tour) => {'tour': tour, 'score': scorePackage(tour)})
        .toList();

    scored.sort(
        (a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scored
        .map((e) => e['tour'] as Map<String, dynamic>)
        .toList();
  }

  /// Returns true if [text] contains [word] as a whole word (space-delimited).
  bool _containsWholeWord(String text, String word) {
    if (word.isEmpty) return false;
    final words = text.split(RegExp(r'\s+'));
    return words.any((w) => w == word);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}