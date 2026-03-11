import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/view/main/tour_guide/packages/views/create_package_view.dart';

class PackagesController extends GetxController {
  final PackagesService _packagesService = Get.find<PackagesService>();

  final RxList<Map<String, dynamic>> packages = <Map<String, dynamic>>[].obs;

  int get totalPackages => packages.length;

  @override
  void onInit() {
    super.onInit();
    _loadPackages();
  }

  void _loadPackages() {
    _packagesService.getPackagesStream().listen((packagesList) {
      packages.value = packagesList.map((package) {
        return {
          'id': package['id'],
          'title': package['tourTitle'] ?? '',
          'location': package['destination'] ?? '',
          'price': '${package['price'] ?? ''} SAR',
          'duration':
              '${package['durationValue'] ?? ''} ${package['durationUnit'] ?? ''}',
          'maxParticipants': 'Max ${package['maxGroupSize'] ?? ''}',
          'views': package['views'] ?? 0,
          'bookings': package['bookings'] ?? 0,
          'status': package['status'] ?? 'Published',
          'image': 'images/tour_1.png',
        };
      }).toList();
    });
  }

  void addNewPackage() {
    Get.to(() => const CreatePackageView());
  }

  void editPackage(String packageId) {
    Get.to(() => CreatePackageView(packageId: packageId));
  }

  Future<void> deletePackage(String packageId) async {
    try {
      await _packagesService.deletePackage(packageId);
      Get.snackbar('Success', 'Package deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete package');
    }
  }
}
