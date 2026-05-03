import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/user_service.dart';
import 'package:tour_app/view/main/tourist/profile/views/edit_profile_view.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class TouristProfileController extends GetxController {
  final RxString selectedTab = 'Completed Tours'.obs;
  final UserService _userService = Get.find<UserService>();
  final PackagesService _packagesService = Get.find<PackagesService>();

  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  final RxInt toursCompleted = 0.obs;
  final RxInt savedTours = 0.obs;
  final RxInt rewardPoints = 0.obs;
  final RxBool isSavingProfile = false.obs;

  final RxList<Map<String, dynamic>> completedTours =
      <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> savedToursList =
      <Map<String, dynamic>>[].obs;

  StreamSubscription<Map<String, dynamic>?>? _userDataSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _savedToursSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _completedToursSub;
  StreamSubscription<User?>? _authSub;

  @override
  void onInit() {
    super.onInit();

    listenToUserData();

    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      listenToUserData();
      listenToSavedTours();
      listenToCompletedTours();
    });

    listenToSavedTours();
    listenToCompletedTours();
  }

  @override
  void onClose() {
    _userDataSub?.cancel();
    _savedToursSub?.cancel();
    _completedToursSub?.cancel();
    _authSub?.cancel();
    super.onClose();
  }

  void listenToUserData() {
    _userDataSub?.cancel();
    _userDataSub = _userService.getCurrentUserDataStream().listen((data) {
      if (data != null) {
        userData.assignAll(data);
        rewardPoints.value = (data['totalPoints'] as num?)?.toInt() ?? 0;
      } else {
        userData.clear();
        rewardPoints.value = 0;
      }
    });
  }

  Future<void> loadUserData() async {
    final data = await _userService.getCurrentUserData();
    if (data != null) {
      userData.assignAll(data);
      rewardPoints.value = (data['totalPoints'] as num?)?.toInt() ?? 0;
    } else {
      userData.clear();
      rewardPoints.value = 0;
    }
  }

  void listenToSavedTours() {
    final userId = _userService.currentUserId;

    if (userId == null || userId.isEmpty) {
      _savedToursSub?.cancel();
      _savedToursSub = null;
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

  void listenToCompletedTours() {
    final userId = _userService.currentUserId;

    if (userId == null || userId.isEmpty) {
      _completedToursSub?.cancel();
      _completedToursSub = null;
      completedTours.clear();
      toursCompleted.value = 0;
      return;
    }

    _completedToursSub?.cancel();

    _completedToursSub = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('upcomingBookings')
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .listen((snapshot) async {
      final List<Map<String, dynamic>> loaded = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final tourId = (data['tourId'] ?? doc.id).toString();
        if (tourId.isEmpty) continue;

        final tourDoc = await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(tourId)
            .get();

        if (!tourDoc.exists) continue;
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

        final rating = double.tryParse('${tourData['rating'] ?? 0}') ?? 0.0;

        final completedAt = data['completedAt'] ?? data['updatedAt'];
        String completionDate = '';
        if (completedAt is Timestamp) {
          final dt = completedAt.toDate();
          completionDate = '${dt.month}/${dt.day}/${dt.year}';
        }

        final userRating = await _packagesService.getMyRatingFor(tourDoc.id);

        loaded.add({
          'id': tourDoc.id,
          'title': tourData['tourTitle'] ?? '',
          'guide': guideName,
          'rating': rating,
          'userRating': userRating,
          'completionDate': completionDate,
          'image': tourData['image'] ?? '',
        });
      }

      completedTours.assignAll(loaded);
      toursCompleted.value = loaded.length;
    });
  }

  Future<void> refreshCompletedTours() async {
    listenToCompletedTours();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void editProfile() {
    Get.to(() => const EditProfileView());
  }

  Future<void> saveProfile({
    required String fullName,
    required String email,
    required String phone,
    required String countryOfResidence,
    required String ageRange,
    required String travelBudget,
    required String travelPace,
    required List<String> interests,
  }) async {
    try {
      isSavingProfile.value = true;
      
      final oldEmail = (userData['email'] ?? '').toString().trim();
      final newEmail = email.trim();

      final emailChanged =
          oldEmail.isNotEmpty &&
          newEmail.isNotEmpty &&
          oldEmail.toLowerCase() != newEmail.toLowerCase();
      
      await _userService.updateCurrentUserProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        countryOfResidence: countryOfResidence,
        ageRange: ageRange,
        travelBudget: travelBudget,
        travelPace: travelPace,
        interests: interests,
      );

      await loadUserData();
      if (Get.isRegistered<TouristHomeController>()) {
  final homeController = Get.find<TouristHomeController>();
  await homeController.loadUserInterests();
  homeController.loadTours();
}

      Get.back();

      Get.snackbar(
        'Success',
        emailChanged
            ? 'Profile updated. Please verify your new email before signing in with it.'
            : 'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSavingProfile.value = false;
    }
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
    _completedToursSub?.cancel();
    super.onClose();
  }
}