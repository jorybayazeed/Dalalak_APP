import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/gamification_service.dart';
import 'package:tour_app/services/packages_service.dart';

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

  final RxList<Map<String, dynamic>> applicableRewards =
      <Map<String, dynamic>>[].obs;
  final RxInt myLevel = 1.obs;
  final RxnString appliedRewardId = RxnString();
  final RxInt appliedDiscountPercent = 0.obs;

  final String packageId;

  PackageDetailsController({required this.packageId});

  @override
  void onInit() {
    super.onInit();
    loadPackage();
    loadRatings();
    loadRewards();
    _loadMyLevel();
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

  Future<void> _loadMyLevel() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        myLevel.value = 1;
        return;
      }
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        myLevel.value = 1;
        return;
      }
      final data = doc.data() ?? <String, dynamic>{};
      final lvl = (data['levelNumber'] as num?)?.toInt();
      if (lvl != null && lvl >= 1) {
        myLevel.value = lvl;
        return;
      }
      final pts = (data['totalPoints'] as num?)?.toInt() ?? 0;
      try {
        final svc = Get.find<GamificationService>();
        myLevel.value = svc.getLevelFromPoints(pts).level;
      } catch (_) {
        myLevel.value = 1;
      }
    } catch (_) {
      myLevel.value = 1;
    }
  }

  Future<void> loadRewards() async {
    try {
      applicableRewards.clear();

      final snap = await FirebaseFirestore.instance
          .collection('rewards')
          .where('applicableTours', arrayContains: packageId)
          .where('isActive', isEqualTo: true)
          .get();

      final now = DateTime.now();
      final List<Map<String, dynamic>> loaded = [];

      for (final doc in snap.docs) {
        final data = doc.data();
        final validUntil = data['validUntil'];
        if (validUntil is Timestamp) {
          if (validUntil.toDate().isBefore(now)) continue;
        }
        loaded.add({'id': doc.id, ...data});
      }

      loaded.sort((a, b) {
        final aDisc = (a['discountPercent'] as num?)?.toInt() ?? 0;
        final bDisc = (b['discountPercent'] as num?)?.toInt() ?? 0;
        return bDisc.compareTo(aDisc);
      });

      applicableRewards.assignAll(loaded);
    } catch (_) {
      // Ignore rewards loading errors.
    }
  }

  bool isRewardEligible(Map<String, dynamic> reward) {
    final required = (reward['requiredLevel'] as num?)?.toInt() ?? 1;
    return myLevel.value >= required;
  }

  void applyReward(Map<String, dynamic> reward) {
    final type = (reward['type'] ?? '').toString();
    if (type != 'tour_discount') return;
    if (!isRewardEligible(reward)) {
      Get.snackbar(
        'Locked',
        'Reach Level ${reward['requiredLevel']} to unlock this reward',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    appliedRewardId.value = (reward['id'] ?? '').toString();
    appliedDiscountPercent.value =
        (reward['discountPercent'] as num?)?.toInt() ?? 0;
  }

  void removeAppliedReward() {
    appliedRewardId.value = null;
    appliedDiscountPercent.value = 0;
  }

  double get _basePriceValue {
    final raw = packageData['price'];
    if (raw is num) return raw.toDouble();
    final cleaned =
        (raw ?? '').toString().replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get discountedPrice {
    final base = _basePriceValue;
    final pct = appliedDiscountPercent.value;
    if (pct <= 0) return base;
    return base * (1 - pct / 100);
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