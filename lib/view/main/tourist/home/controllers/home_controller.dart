import 'package:get/get.dart';
import 'package:tour_app/view/main/tourist/home/views/home_view.dart';
import 'package:tour_app/view/main/tourist/explore/views/explore_view.dart';
import 'package:tour_app/view/main/tourist/bookings/views/bookings_view.dart';
import 'package:tour_app/view/main/tourist/profile/views/profile_view.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TouristHomeController extends GetxController {

  final RxInt currentBottomNavIndex = 0.obs;

  final RxInt totalPoints = 500.obs;
  final RxString level = 'Level 2 Explorer'.obs;
  final RxInt badgesCount = 3.obs;
  final RxInt completedActivities = 0.obs;
  final RxInt totalActivities = 3.obs;
  final RxInt rewardsPoints = 350.obs;

  final PackagesService _packagesService = Get.find<PackagesService>();

  RxList<Map<String, dynamic>> recommendedTours = <Map<String, dynamic>>[].obs;
  RxList<String> userInterests = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    loadUserInterests();
    loadTours();
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

  void viewRewards() {}

  void viewMyRewards() {}

  void openSettings() {}

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

      userInterests.value = List<String>.from(data?['interests'] ?? []);
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