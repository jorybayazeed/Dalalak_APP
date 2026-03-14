import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_app/models/user_model.dart';
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

  final RxList<Map<String, dynamic>> allTours = <Map<String, dynamic>>[].obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  Stream<List<Map<String, dynamic>>>? packagesStream;

  @override
  void onInit() {
    super.onInit();

    searchController.addListener(() {
      searchText.value = searchController.text;
    });

    packagesStream = _packagesService.getAllPackagesStream();

    packagesStream!.listen((data) {
      allTours.assignAll(data);
    });

    _userService.getCurrentUserDataStream().listen((userData) {
      if (userData != null) {
        currentUser.value = UserModel.fromFirestore(userData as dynamic);
      }
    });
  }

  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) return null;
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return null;
      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> get filteredTours {
    List<Map<String, dynamic>> filteredTours = allTours.toList();

    // Search
    if (searchText.value.isNotEmpty) {
      filteredTours = filteredTours.where((tour) {
        final query = searchText.value.toLowerCase();
        return (tour['tourTitle'] as String).toLowerCase().contains(query) ||
            (tour['destination'] as String).toLowerCase().contains(query);
      }).toList();
    }

    // Region
    if (selectedRegion.value != 'All Regions') {
      filteredTours = filteredTours.where((tour) {
        return tour['destination'] == selectedRegion.value;
      }).toList();
    }

    // Date
    if (selectedDate.value != 'Any Date') {
      final now = DateTime.now();
      if (selectedDate.value == 'Today') {
        filteredTours = filteredTours.where((tour) {
          if (tour['availableDates'] == null || tour['availableDates'].isEmpty) {
            return false;
          }
          final tourDate = _parseDate(tour['availableDates'].split(' - ')[0]);
          if (tourDate == null) return false;
          return tourDate.year == now.year &&
              tourDate.month == now.month &&
              tourDate.day == now.day;
        }).toList();
      } else if (selectedDate.value == 'This Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        filteredTours = filteredTours.where((tour) {
          if (tour['availableDates'] == null || tour['availableDates'].isEmpty) {
            return false;
          }
          final tourDate = _parseDate(tour['availableDates'].split(' - ')[0]);
          if (tourDate == null) return false;
          return tourDate.isAfter(startOfWeek) && tourDate.isBefore(endOfWeek);
        }).toList();
      } else if (selectedDate.value == 'This Month') {
        filteredTours = filteredTours.where((tour) {
          if (tour['availableDates'] == null || tour['availableDates'].isEmpty) {
            return false;
          }
          final tourDate = _parseDate(tour['availableDates'].split(' - ')[0]);
          if (tourDate == null) return false;
          return tourDate.year == now.year && tourDate.month == now.month;
        }).toList();
      }
    }

    // Price Range
    if (selectedPriceRange.value != 'Any Price') {
      if (selectedPriceRange.value == 'Under 300 SAR') {
        filteredTours = filteredTours.where((tour) {
          if (tour['price'] == null) return false;
          return double.parse(tour['price']) < 300;
        }).toList();
      } else if (selectedPriceRange.value == '300 - 500 SAR') {
        filteredTours = filteredTours.where((tour) {
          if (tour['price'] == null) return false;
          final price = double.parse(tour['price']);
          return price >= 300 && price <= 500;
        }).toList();
      } else if (selectedPriceRange.value == 'Above 500 SAR') {
        filteredTours = filteredTours.where((tour) {
          if (tour['price'] == null) return false;
          return double.parse(tour['price']) > 500;
        }).toList();
      }
    }

    // Activity Type
    if (selectedActivityType.value != 'All Activities') {
      filteredTours = filteredTours.where((tour) {
        return tour['activityType'] == selectedActivityType.value;
      }).toList();
    }

    // AI Recommendations
    if (isAIRecommendations.value) {
      final user = currentUser.value;
      if (user != null) {
        filteredTours = filteredTours.where((tour) {
          return _calculateScore(tour, user) > 0;
        }).toList();
        filteredTours.sort((a, b) {
          return _calculateScore(b, user).compareTo(_calculateScore(a, user));
        });
      }
    }

    // Near Me
    if (isNearMe.value) {
      final user = currentUser.value;
      if (user != null) {
        final userCountry = user.countryOfResidence ?? '';
        if (userCountry.toLowerCase() == 'saudi arabia') {
          final userCity = user.city ?? '';
          if (userCity.isNotEmpty) {
            filteredTours = filteredTours.where((tour) {
              return tour['destination'] == userCity;
            }).toList();
          }
        } else {
          final knownCities = ['Riyadh', 'Jeddah', 'Dammam', 'AlUla', 'Abha', 'Taif', 'Makkah', 'Madinah'];
          filteredTours = filteredTours.where((tour) {
            return knownCities.contains(tour['destination']);
          }).toList();
        }
      }
    }

    return filteredTours;
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

  double _calculateScore(Map<String, dynamic> tour, UserModel user) {
    double score = 0;
    if (tour['price'] != null) {
      final price = double.parse(tour['price']);
      final budget = user.travelBudget ?? '';
      if (budget == 'Low' && price < 300) {
        score += 1;
      } else if (budget == 'Medium' && price >= 300 && price <= 500) {
        score += 1;
      } else if (budget == 'High' && price > 500) {
        score += 1;
      }
    }
    if (tour['activityType'] != null) {
      final activityType = tour['activityType'] as String;
      final interests = user.interests ?? [];
      if (interests.contains(activityType)) {
        score += 1;
      }
    }
    if (tour['destination'] != null) {
      final destination = tour['destination'] as String;
      final userInterests = user.interests ?? [];
      if (userInterests.contains(destination)) {
        score += 1;
      }
    }
    return score;
  }

  void toggleFavorite(String tourId) {
    final index = allTours.indexWhere((tour) => tour['id'] == tourId);
    if (index != -1) {
      allTours[index]['isFavorite'] = !(allTours[index]['isFavorite'] ?? false);
      allTours.refresh();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
