import 'package:get/get.dart';
import 'package:tour_app/services/auth_service.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/services/storage_service.dart';
import 'package:tour_app/services/user_service.dart';
import 'package:tour_app/view/authentication/views/login_view.dart';
import 'package:tour_app/view/main/tour_guide/profile/views/edit_profile_view.dart';

class ProfileController extends GetxController {
  final UserService _userService = Get.find<UserService>();
  final PackagesService _packagesService = Get.find<PackagesService>();
  final RxString selectedTab = 'Tours'.obs;
  final RxDouble averageRating = 0.0.obs;
  final RxMap<String, dynamic> profileData = <String, dynamic>{
    'name': 'Guide',
    'email': '',
    'phone': '',
    'location': '',
    'toursCount': 0,
    'experience': '0 Years Exp.',
    'yearsOfExperience': '0',
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
    _listenToPackages();
  }

  
  Future<void> _loadProfileData() async {
    final userData = await _userService.getCurrentUserData();

    if (userData != null) {
     final languages =
    (userData['languages'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? <String>[];

    final specialization =
    (userData['specializations'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? <String>[];
      final yearsOfExp = (userData['yearsOfExperience'] ?? 0).toString();

      profileData.assignAll({
        'name': userData['fullName'] ?? 'Guide',
        'email': userData['email'] ?? '',
        'phone': userData['phone'] ?? '',
        'location': userData['location'] ?? '',
        'isVerified': userData['isProfileVerified'] ?? false,
        'bio': userData['bio'] ?? '',
        'languages': languages,
        'languagesCount': languages.length,
        'specializations': specialization,
        'experience': '$yearsOfExp Years Exp.',
        'yearsOfExperience': yearsOfExp,
        'rating': (userData['rating'] as num?)?.toDouble() ?? 0.0,
        'reviewsCount': userData['reviewsCount'] ?? 0,
      });
    }
  }

  
void _listenToPackages() {
  _packagesService.getPackagesStream().listen((packages) {

    final currentUserId = _userService.currentUserId;

    if (currentUserId == null) return;


    final myPackages = packages.where((p) {
      final isSameGuide = p['guideId'] == currentUserId;
      return isSameGuide;
    });


    double totalRating = 0;
    int count = 0;

    for (var p in myPackages) {
      final rating = (p['rating'] ?? 0).toDouble();

      if (rating > 0) {
        totalRating += rating;
        count++;
      }
    }

    averageRating.value = count == 0 ? 0 : totalRating / count;

    final filteredPackages = myPackages.where((p) {
      final live = p['liveTourState'];
      final isEnded = live != null && (live['ended'] == true);
      return isEnded;
    });

    tours.value = filteredPackages.map((package) {
      return {
        'id': package['id'],
        'title': package['tourTitle'] ?? '',
        'destination':
            (package['destination'] ??
             package['city'] ??
             package['location'] ?? '').toString(),
        'duration':
            '${package['durationValue'] ?? ''} ${package['durationUnit'] ?? ''}',
        'price': '${package['price'] ?? ''} SAR',
        'image': 'images/tour_1.png',
      };
    }).toList();

    profileData['toursCount'] = tours.length;
  });
}
  
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  Future<void> logout() async {
    final authService = Get.find<AuthService>();
    await authService.signOut();
    await StorageService.clearAll();
    Get.offAll(() => const LoginView());
  }

  void editProfile() {
    Get.to(() => const EditGuideProfileView());
  }
  final RxBool isSavingProfile = false.obs;

Future<void> saveProfile({
  required String fullName,
  required String email,
  required String phone,
  required String yearsOfExperience,
  required String specialization,
  required List<String> languages,
}) async {
  try {
    isSavingProfile.value = true;
   final oldEmail = (profileData['email'] ?? '').toString().trim();
    final newEmail = email.trim();

    final emailChanged =
        oldEmail.isNotEmpty &&
        newEmail.isNotEmpty &&
        oldEmail.toLowerCase() != newEmail.toLowerCase();

   await _userService.updateCurrentUserProfile(
  fullName: fullName,
  email: email,
  phone: phone,

  countryOfResidence: '',
  ageRange: '',
  travelBudget: '',
  travelPace: '',
  interests: [],

  yearsOfExperience: yearsOfExperience,
  specialization: specialization,
  languagesSpoken: languages,
);

await _loadProfileData();

profileData['specializations'] = [specialization];
profileData['languages'] = languages;
profileData['yearsOfExperience'] = yearsOfExperience;
profileData['experience'] = '$yearsOfExperience Years Exp.';
profileData['phone'] = phone;


profileData.refresh();

Get.back();

    Get.snackbar(
      'Success',
     emailChanged
      ? 'Profile updated. Please verify your new email before signing in with it.'
      : 'Profile updated successfully',
     snackPosition: SnackPosition.BOTTOM,
      
    );
  } catch (e) {
    Get.snackbar(
      'Error',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isSavingProfile.value = false;
  }
}
}
