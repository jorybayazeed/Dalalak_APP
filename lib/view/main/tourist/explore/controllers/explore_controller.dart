import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';

class ExploreController extends GetxController {

  final PackagesService _packagesService = Get.find();

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

  Stream<List<Map<String, dynamic>>>? packagesStream;

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
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}