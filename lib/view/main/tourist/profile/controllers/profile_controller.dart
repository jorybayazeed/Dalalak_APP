import 'package:get/get.dart';
import 'package:tour_app/services/auth_service.dart';
import 'package:tour_app/services/storage_service.dart';
import 'package:tour_app/view/authentication/views/login_view.dart';

class TouristProfileController extends GetxController {
  final RxString selectedTab = 'Completed Tours'.obs;

  final Map<String, dynamic> userData = {
    'name': 'User',
    'email': 'john.smith@email.com',
    'phone': '+966 50 123 4567',
    'location': 'Riyadh, Saudi Arabia',
    'memberSince': 'November 2024',
  };

  final RxInt toursCompleted = 5.obs;
  final RxInt savedTours = 12.obs;
  final RxInt rewardPoints = 350.obs;

  final RxList<Map<String, dynamic>> completedTours = [
    {
      'id': '1',
      'title': 'AlUla Heritage Tour',
      'guide': 'Ahmed Al-Rashid',
      'rating': 5.0,
      'completionDate': 'Oct 15, 2024',
      'image': 'images/tour_1.png',
    },
    {
      'id': '2',
      'title': 'Riyadh City Explorer',
      'guide': 'Fatima Al-Otaibi',
      'rating': 3.0,
      'completionDate': 'Sep 20, 2024',
      'image': 'images/tour_2.png',
    },
  ].obs;

  final RxList<Map<String, dynamic>> savedToursList = [
    {
      'id': '3',
      'title': 'Jeddah Waterfront Experience',
      'guide': 'Mohammed Al-Zahrani',
      'rating': 4.7,
      'image': 'images/tour_3.png',
    },
    {
      'id': '4',
      'title': 'Edge of the World Adventure',
      'guide': 'Salem Al-Qahtani',
      'rating': 5.0,
      'image': 'images/tour_4.png',
    },
  ].obs;

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void editProfile() {
    // TODO: Navigate to edit profile page
    Get.snackbar(
      'Edit Profile',
      'Edit profile functionality not yet implemented.',
    );
  }

  Future<void> logout() async {
    final authService = Get.find<AuthService>();
    await authService.signOut();
    await StorageService.clearAll();
    Get.offAll(() => const LoginView());
  }
}
