import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/user_service.dart';
import 'package:tour_app/services/recommendation_service.dart';
import 'package:tour_app/view/main/tourist/home/views/home_view.dart';
import 'package:tour_app/view/main/tourist/explore/views/explore_view.dart';
import 'package:tour_app/view/main/tourist/bookings/views/bookings_view.dart';
import 'package:tour_app/view/main/tourist/profile/views/profile_view.dart';

class TouristHomeController extends GetxController {
  final RxInt currentBottomNavIndex = 0.obs;

  final RxInt totalPoints = 500.obs;
  final RxString level = 'Level 2 Explorer'.obs;
  final RxInt badgesCount = 3.obs;
  final RxInt completedActivities = 0.obs;
  final RxInt totalActivities = 3.obs;
  final RxInt rewardsPoints = 350.obs;

  final PackagesService _packagesService = Get.find<PackagesService>();
  final UserService _userService = Get.find<UserService>();

  final RxList<Map<String, dynamic>> aiRecommendedPackages =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingRecommendations = false.obs;
  Map<String, dynamic>? _touristProfile;

  @override
  void onInit() {
    super.onInit();
    _loadAIRecommendedPackages();
  }

  Future<void> _loadAIRecommendedPackages() async {
    try {
      isLoadingRecommendations.value = true;

      // Load tourist profile
      _touristProfile = await _userService.getCurrentUserData();

      if (_touristProfile == null) {
        isLoadingRecommendations.value = false;
        return;
      }

      // Get all packages
      final allPackages = await _packagesService.getAllPackages();

      // Score and sort packages using AI recommendation
      final scoredPackages = allPackages.map((package) {
        final score = RecommendationService.scorePackageForTourist(
          package: package,
          touristProfile: _touristProfile!,
          selectedInterest: '',
        );
        return {...package, 'recommendationScore': score};
      }).toList();

      // Sort by score (highest first) and take top 3
      scoredPackages.sort((a, b) =>
          (b['recommendationScore'] as num).compareTo(a['recommendationScore'] as num));

      aiRecommendedPackages.assignAll(scoredPackages.take(3).toList());

      isLoadingRecommendations.value = false;
    } catch (e) {
      isLoadingRecommendations.value = false;
      print('Error loading AI recommendations: $e');
    }
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
    // TODO: Navigate to rewards page
  }

  void viewMyRewards() {
    // TODO: Navigate to my rewards page
  }

  void openSettings() {
    // TODO: Navigate to settings page
  }
}
