import 'package:get/get.dart';
import 'package:tour_app/services/auth_service.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/storage_service.dart';
import 'package:tour_app/services/user_service.dart';
import 'package:tour_app/view/authentication/views/login_view.dart';

class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final PackagesService _packagesService = Get.find<PackagesService>();

  final RxString selectedTab = 'Tours'.obs;

  final RxMap<String, dynamic> profileData = <String, dynamic>{
    'name': 'Guide',
    'location': '',
    'toursCount': 0,
    'experience': '0 Years Exp.',
    'languagesCount': 0,
    'rating': 0.0,
    'reviewsCount': 0,
    'isVerified': false,
    'bio': '',
    'languages': <String>[],
    'specializations': <String>[],
    'achievements': <Map<String, dynamic>>[],
  }.obs;

  final RxList<Map<String, dynamic>> tours = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
    _loadPackagesCount();
    _loadTours();
  }

  Future<void> _loadProfileData() async {
    final userData = await _userService.getCurrentUserData();
    if (userData != null) {
      profileData['name'] = userData['fullName'] as String? ?? 'Guide';
      profileData['location'] = userData['location'] as String? ?? '';
      profileData['isVerified'] =
          userData['isProfileVerified'] as bool? ?? false;
      profileData['bio'] = userData['bio'] as String? ?? '';

      // Load languagesSpoken from database
      profileData['languages'] =
          (userData['languagesSpoken'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];

      // Load specialization from database
      final specialization = userData['specialization'] as String?;
      profileData['specializations'] =
          specialization != null && specialization.isNotEmpty
          ? [specialization]
          : <String>[];

      // Load yearsOfExperience and format it
      final yearsOfExp = userData['yearsOfExperience'] as String? ?? '0';
      profileData['experience'] = '$yearsOfExp Years Exp.';
      profileData['yearsOfExperience'] = yearsOfExp;

      profileData['languagesCount'] = (profileData['languages'] as List).length;
      profileData['rating'] = (userData['rating'] as num?)?.toDouble() ?? 0.0;
      profileData['reviewsCount'] = userData['reviewsCount'] as int? ?? 0;
    }
  }

  void _loadPackagesCount() {
    _packagesService.getPackagesStream().listen((packages) {
      profileData['toursCount'] = packages.length;
    });
  }

  void _loadTours() {
    _packagesService.getPackagesStream().listen((packages) {
      tours.value = packages.map((package) {
        return {
          'id': package['id'],
          'title': package['tourTitle'] ?? '',
          'rating': 0.0,
          'reviews': 0,
          'duration':
              '${package['durationValue'] ?? ''} ${package['durationUnit'] ?? ''}',
          'price': '${package['price'] ?? ''} SAR',
          'image': 'images/tour_1.png',
        };
      }).toList();
    });
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void messageGuide() {
    // TODO: Navigate to chat/message page
  }

  Future<void> logout() async {
    final authService = Get.find<AuthService>();
    await authService.signOut();
    await StorageService.clearAll();
    Get.offAll(() => const LoginView());
  }

  void editProfile() {
    // TODO: Navigate to edit profile page
  }
}
