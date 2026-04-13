import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/user_service.dart';
import 'package:tour_app/view/main/tour_guide/packages/views/packages_view.dart';
import 'package:tour_app/view/main/tour_guide/packages/views/create_package_view.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/views/dashboard_view.dart';
import 'package:tour_app/view/main/tour_guide/profile/views/profile_view.dart';
import 'package:tour_app/view/main/tour_guide/chat/views/chat_view.dart';
import 'package:tour_app/view/main/tour_guide/tours/views/guide_tours_view.dart';

class DashboardController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final PackagesService _packagesService = Get.find<PackagesService>();

  final RxInt currentBottomNavIndex = 0.obs;

  final RxInt totalPackages = 0.obs;
  final RxInt activeTours = 0.obs;
  final RxInt totalBookings = 0.obs;
  final RxDouble averageRating = 4.8.obs;

  final RxString userName = 'Guide'.obs;
  final RxString userEmail = ''.obs;
  final RxList<String> languagesSpoken = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadPackagesCount();
  }

  Future<void> _loadUserData() async {
    final userData = await _userService.getCurrentUserData();
    if (userData != null) {
      userName.value = userData['fullName'] as String? ?? 'Guide';
      userEmail.value = userData['email'] as String? ?? '';
      languagesSpoken.value =
          (userData['languagesSpoken'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
    }
  }

  void _loadPackagesCount() {
    _packagesService.getPackagesStream().listen((packages) {
      totalPackages.value = packages.length;
    });
  }

  void changeBottomNavIndex(int index) {
    if (currentBottomNavIndex.value == index) return;

    currentBottomNavIndex.value = index;

    switch (index) {
      case 0:
        Get.to(() => const DashboardView());
        break;
      case 1:
        Get.to(() => const PackagesView());
        break;
      case 2:
        Get.to(() => const ChatView());
        break;
      case 3:
        Get.to(() => const ProfileView());
        break;
    }
  }

  void viewVerification() {
    // TODO: Navigate to verification page
  }

  void createTourPackage() {
    Get.to(() => const CreatePackageView());
  }

  void managePackages() {
    currentBottomNavIndex.value = 1;
    Get.to(() => const PackagesView());
  }

  void chatWithTourists() {
    currentBottomNavIndex.value = 2;
    Get.to(() => const ChatView());
  }

  void viewMyTours() {
    Get.to(() => const GuideToursView());
  }
}
