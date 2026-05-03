import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PackageDetailsController extends GetxController {
  final PackagesService _packagesService = Get.find<PackagesService>();

  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> packageData = <String, dynamic>{}.obs;
  final RxString guideName = ''.obs;
  final RxString guideImage = ''.obs;
  final RxString guidePhone = ''.obs;
  final RxString guideYearsOfExperience = ''.obs;
  final RxString guideSpecialization = ''.obs;
  final RxList<String> guideLanguages = <String>[].obs;
  final RxDouble guideRating = 0.0.obs;
  final RxInt guideTotalReviews = 0.obs;
  final RxBool isRatingsLoading = false.obs;
  final RxList<Map<String, dynamic>> ratings = <Map<String, dynamic>>[].obs;

  final String packageId;

  PackageDetailsController({required this.packageId});

  @override
  void onInit() {
    super.onInit();
    loadPackage();
    loadRatings();
  }

  Future<void> loadRatings() async {
    try {
      isRatingsLoading.value = true;
      ratings.clear();

      final ratingsSnap = await FirebaseFirestore.instance
          .collection('tourPackages')
          .doc(packageId)
          .collection('ratings')
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> loaded = [];

      for (final doc in ratingsSnap.docs) {
        final data = doc.data();
        final userId = (data['userId'] ?? doc.id).toString();
        String userName = 'Tourist';
        String userImage = '';

        if (userId.isNotEmpty) {
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();
            if (userDoc.exists) {
              final u = userDoc.data();
              userName = (u?['fullName'] ?? u?['name'] ?? 'Tourist').toString();
              userImage = (u?['image'] ?? '').toString();
            }
          } catch (_) {
            // Ignore user lookup errors.
          }
        }

        loaded.add({
          'userId': userId,
          'userName': userName,
          'userImage': userImage,
          'rating': (data['rating'] as num?)?.toInt() ?? 0,
          'review': (data['review'] ?? '').toString(),
          'createdAt': data['createdAt'],
        });
      }

      ratings.assignAll(loaded);
    } catch (_) {
      // Ignore ratings loading errors.
    } finally {
      isRatingsLoading.value = false;
    }
  }

  Future<void> loadPackage() async {
    try {
      isLoading.value = true;

      final data = await _packagesService.getPackage(packageId);

      if (data != null) {
        packageData.assignAll(data);

        final guideId = (data['guideId'] ?? '').toString();

        if (guideId.isNotEmpty) {
          final guideDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(guideId)
              .get();

          if (guideDoc.exists) {
            final guideData = guideDoc.data() as Map<String, dynamic>;

            guideName.value = (guideData['fullName'] ?? '').toString();
            guideImage.value = (guideData['image'] ?? '').toString();
            guidePhone.value = (guideData['phone'] ?? '').toString();
            guideYearsOfExperience.value =
                (guideData['yearsOfExperience'] ?? '').toString();

            final specs = guideData['specializations'];
            if (specs is List && specs.isNotEmpty) {
              guideSpecialization.value = (specs.first ?? '').toString();
            } else {
              guideSpecialization.value =
                  (guideData['specialization'] ?? '').toString();
            }

            final langs = guideData['languages'];
            if (langs is List) {
              guideLanguages.assignAll(
                langs.map((e) => e.toString()).toList(),
              );
            } else {
              guideLanguages.clear();
            }

          }

          try {
            final pkgsSnap = await FirebaseFirestore.instance
                .collection('tourPackages')
                .where('guideId', isEqualTo: guideId)
                .get();
            double weightedSum = 0;
            int totalReviews = 0;
            for (final p in pkgsSnap.docs) {
              final pd = p.data();
              final r = (pd['rating'] as num?)?.toDouble() ?? 0.0;
              final n = (pd['reviews'] as num?)?.toInt() ?? 0;
              if (n > 0 && r > 0) {
                weightedSum += r * n;
                totalReviews += n;
              }
            }
            guideRating.value =
                totalReviews == 0 ? 0.0 : weightedSum / totalReviews;
            guideTotalReviews.value = totalReviews;
          } catch (_) {
            guideRating.value = 0.0;
            guideTotalReviews.value = 0;
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load package details');
    } finally {
      isLoading.value = false;
    }
  }

  String get title => packageData['tourTitle'] ?? '';
  String get destination => packageData['destination'] ?? '';
  String get price => '${packageData['price'] ?? ''} SAR';
  String get duration =>
      '${packageData['durationValue'] ?? ''} ${packageData['durationUnit'] ?? ''}';
  String get maxGroupSize => 'Max ${packageData['maxGroupSize'] ?? ''}';
  String get description => packageData['tourDescription'] ?? '';
  String get activityType => packageData['activityType'] ?? '';
  String get availableDates => packageData['availableDates'] ?? '';
  String get status => packageData['status'] ?? 'Published';
  int get views => packageData['views'] ?? 0;
  int get bookings => packageData['bookings'] ?? 0;
  String get image => packageData['image'] ?? '';

  List<Map<String, dynamic>> get activities {
    final raw = packageData['activities'] as List<dynamic>? ?? [];
    return raw.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}