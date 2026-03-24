import 'dart:async';
import 'package:get/get.dart';
import 'package:tour_app/services/auth_service.dart';
import 'package:tour_app/services/storage_service.dart';
import 'package:tour_app/view/authentication/views/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tour_app/services/user_service.dart';

class TouristProfileController extends GetxController {
  final RxString selectedTab = 'Completed Tours'.obs;
  final UserService _userService = Get.find<UserService>();

  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  final RxInt toursCompleted = 5.obs;
  final RxInt savedTours = 0.obs;
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

  final RxList<Map<String, dynamic>> savedToursList =
      <Map<String, dynamic>>[].obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _savedToursSub;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    listenToSavedTours();
  }

  Future<void> loadUserData() async {
    final data = await _userService.getCurrentUserData();
    if (data != null) {
      userData.assignAll(data);
    }
  }

  void listenToSavedTours() {
    final userId = _userService.currentUserId;

    if (userId == null || userId.isEmpty) {
      savedToursList.clear();
      savedTours.value = 0;
      return;
    }

    _savedToursSub?.cancel();

    _savedToursSub = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedTours')
        .snapshots()
        .listen((snapshot) async {
      final List<Map<String, dynamic>> loadedTours = [];

      for (final doc in snapshot.docs) {
        final tourId = doc.id;

        final tourDoc = await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(tourId)
            .get();

        if (tourDoc.exists) {
          final tourData = tourDoc.data() as Map<String, dynamic>;

          String guideName = '';

          final guideId = tourData['guideId'];
          if (guideId != null && guideId.toString().isNotEmpty) {
            final guideDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(guideId)
                .get();

            if (guideDoc.exists) {
              final guideData = guideDoc.data() as Map<String, dynamic>;
              guideName = guideData['fullName'] ?? '';
            }
          }

          loadedTours.add({
            'id': tourDoc.id,
            'title': tourData['tourTitle'] ?? '',
            'guide': guideName,
            'rating': double.tryParse('${tourData['rating'] ?? 0}') ?? 0.0,
            'image': tourData['image'] ?? '',
          });
        }
      }

      savedToursList.assignAll(loadedTours);
      savedTours.value = loadedTours.length;
    });
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void editProfile() {
    Get.snackbar(
      'Edit Profile',
      'Edit profile functionality not yet implemented.',
    );
  }
Future<void> removeSavedTour(String tourId) async {
  try {
    final userId = _userService.currentUserId;

    if (userId == null || userId.isEmpty) {
      Get.snackbar('Error', 'User not found');
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savedTours')
        .doc(tourId)
        .delete();

    Get.snackbar('Removed', 'Tour removed from saved tours');
  } catch (e) {
    Get.snackbar('Error', 'Failed to remove saved tour');
  }
}
  Future<void> logout() async {
    final authService = Get.find<AuthService>();
    await authService.signOut();
    await StorageService.clearAll();
    Get.offAll(() => const LoginView());
  }

  @override
  void onClose() {
    _savedToursSub?.cancel();
    super.onClose();
  }
}