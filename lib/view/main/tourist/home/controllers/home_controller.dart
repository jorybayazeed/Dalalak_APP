import 'package:get/get.dart';
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
