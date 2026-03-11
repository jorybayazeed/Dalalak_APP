import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;

  final RxString selectedRegion = 'All Regions'.obs;
  final RxString selectedDate = 'Any Date'.obs;
  final RxString selectedPriceRange = 'Any Price'.obs;
  final RxString selectedActivityType = 'All Activities'.obs;
  final RxBool isAIRecommendations = false.obs;
  final RxBool isNearMe = false.obs;
  final RxBool isFiltersVisible = false.obs;

  final RxList<Map<String, dynamic>> tours = [
    {
      'id': '1',
      'title': 'AlUla Heritage Tour',
      'location': 'AlUla',
      'duration': '6 hours',
      'rating': 4.9,
      'reviews': 127,
      'price': '450 SAR',
      'guide': 'Ahmed Al-Rashid',
      'image': 'images/tour_1.png',
      'isAIPick': true,
      'distance': '1km',
    },
    {
      'id': '2',
      'title': 'Riyadh City Explorer',
      'location': 'Riyadh',
      'duration': '4 hours',
      'rating': 4.8,
      'reviews': 95,
      'price': '350 SAR',
      'guide': 'Fatima Al-Otaibi',
      'image': 'images/tour_2.png',
      'isAIPick': true,
      'distance': '5km',
    },
    {
      'id': '3',
      'title': 'Jeddah Waterfront Experience',
      'location': 'Jeddah',
      'duration': '3 hours',
      'rating': 4.7,
      'reviews': 82,
      'price': '280 SAR',
      'guide': 'Mohammed Al-Zahrani',
      'image': 'images/tour_3.png',
      'isAIPick': false,
      'distance': '2km',
    },
    {
      'id': '4',
      'title': 'Edge of the World Adventure',
      'location': 'Riyadh Region',
      'duration': '8 hours',
      'rating': 5.0,
      'reviews': 156,
      'price': '520 SAR',
      'guide': 'Salem Al-Qahtani',
      'image': 'images/tour_4.png',
      'isAIPick': true,
      'distance': '8km',
    },
    {
      'id': '5',
      'title': 'Diriyah Heritage Walk',
      'location': 'Diriyah',
      'duration': '5 hours',
      'rating': 4.9,
      'reviews': 143,
      'price': '390 SAR',
      'guide': 'Nora Al-Saud',
      'image': 'images/tour_5.png',
      'isAIPick': false,
      'distance': '3km',
    },
  ].obs;

  List<Map<String, dynamic>> get filteredTours {
    return tours.where((tour) {
      if (isAIRecommendations.value && !(tour['isAIPick'] as bool)) {
        return false;
      }
      if (isNearMe.value && tour['distance'] == null) {
        return false;
      }
      if (searchText.value.isNotEmpty) {
        final query = searchText.value.toLowerCase();
        if (!(tour['title'] as String).toLowerCase().contains(query) &&
            !(tour['location'] as String).toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
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

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
