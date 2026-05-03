import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/gamification_service.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreController extends GetxController {
  final PackagesService _packagesService = Get.find();
  final UserService _userService = Get.find();

  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;

  final RxString selectedRegion = 'All Regions'.obs;
  final RxString selectedDate = 'Any Date'.obs;
  final RxString selectedPriceRange = 'Any Price'.obs;
  final RxString selectedActivityType = 'All Activities'.obs;

  final RxBool isFiltersVisible = false.obs;

  final RxList<Map<String, dynamic>> tours = <Map<String, dynamic>>[].obs;

  Stream<List<Map<String, dynamic>>>? packagesStream;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    packagesStream = _packagesService.getAllPackagesStream();

    packagesStream!.listen((data) async {
      await _loadToursWithFavorites(data);
    });
  }

  Future<void> _loadToursWithFavorites(List<Map<String, dynamic>> data) async {
     final filteredData = data
      .where((tour) => tour['isCancelled'] != true)
      .toList();
    final user = await _userService.getCurrentUserData();
    final userId = user?['uid'];

    if (userId == null || userId.toString().isEmpty) {
      tours.assignAll(
         filteredData.map((tour) {
          final updatedTour = Map<String, dynamic>.from(tour);
          updatedTour['isFavorite'] = false;
          return updatedTour;
        }).toList(),
      );
      return;
    }

    final savedSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedTours')
        .get();

    final savedIds = savedSnapshot.docs.map((doc) => doc.id).toSet();

    final bookedSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('upcomingBookings')
        .get();

    final bookedTourIds = bookedSnapshot.docs
        .map((d) => (d.data()['tourId'] ?? d.id).toString())
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    final visibleTours =
        filteredData.where((t) => !bookedTourIds.contains((t['id'] ?? '').toString())).toList();

    final updatedTours = visibleTours.map((tour) {
      final updatedTour = Map<String, dynamic>.from(tour);
      updatedTour['isFavorite'] = savedIds.contains(tour['id']);
      return updatedTour;
    }).toList();

    tours.assignAll(updatedTours);
  }

  void toggleFilters() {
    isFiltersVisible.value = !isFiltersVisible.value;
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

  Future<void> toggleFavorite(String tourId) async {
    final userData = await _userService.getCurrentUserData();
    final userId = userData?['uid'];

    if (userId == null || userId.toString().isEmpty) {
      Get.snackbar('Error', 'User not found');
      return;
    }

    final savedTourRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedTours')
        .doc(tourId);

    final savedTourDoc = await savedTourRef.get();

    if (savedTourDoc.exists) {
      await savedTourRef.delete();
    } else {
      await savedTourRef.set({
        'tourId': tourId,
        'savedAt': FieldValue.serverTimestamp(),
      });

      try {
        await Get.find<GamificationService>().awardSaveTourPoints(
          packageId: tourId,
        );
      } catch (_) {
        // Ignore points errors.
      }
    }

    final index = tours.indexWhere((tour) => tour['id'] == tourId);
    if (index != -1) {
      tours[index]['isFavorite'] = !(tours[index]['isFavorite'] ?? false);
      tours.refresh();
    }
  }

  List<Map<String, dynamic>> get filteredTours {
    var result = tours.toList();

    if (selectedRegion.value != 'All Regions') {
      result = result.where((tour) {
        final dest = (tour['destination'] as String? ?? '').toLowerCase();
        return dest == selectedRegion.value.toLowerCase();
      }).toList();
    }

    if (selectedDate.value != 'Any Date') {
      result = result.where(_matchesDateFilter).toList();
    }

    if (selectedPriceRange.value != 'Any Price') {
      result = result.where(_matchesPriceFilter).toList();
    }

    if (selectedActivityType.value != 'All Activities') {
      result = result.where((tour) {
        final actType = (tour['activityType'] as String? ?? '').toLowerCase();
        return actType == selectedActivityType.value.toLowerCase();
      }).toList();
    }

    if (searchText.value.isNotEmpty) {
      final query = searchText.value.toLowerCase();
      result = result.where((tour) {
        final title = (tour['tourTitle'] as String? ?? '').toLowerCase();
        final dest = (tour['destination'] as String? ?? '').toLowerCase();
        return title.contains(query) || dest.contains(query);
      }).toList();
    }

    return result;
  }

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
        return !today.isBefore(start) && !today.isAfter(end);

      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return start.isBefore(weekEnd.add(const Duration(days: 1))) &&
            end.isAfter(weekStart.subtract(const Duration(days: 1)));

      case 'This Month':
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



  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}