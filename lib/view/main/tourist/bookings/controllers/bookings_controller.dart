import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tour_app/view/main/tourist/explore/views/package_details_view.dart';

class BookingsController extends GetxController {
  final RxString selectedTab = 'Upcoming'.obs;
  final RxList<Map<String, dynamic>> allBookings = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  Future<void> loadBookings() async {
    try {
      isLoading.value = true;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('upcomingBookings')
          .get();

      final List<Map<String, dynamic>> loadedBookings = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        String guideName = '';

        final tourId = data['tourId'];
        if (tourId != null) {
          final tourDoc = await FirebaseFirestore.instance
              .collection('tourPackages')
              .doc(tourId)
              .get();

          if (tourDoc.exists) {
            final tourData = tourDoc.data() as Map<String, dynamic>;
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
          }
        }

        loadedBookings.add({
          'id': doc.id,
          'tourId': data['tourId'] ?? '',
          'title': data['tourTitle'] ?? '',
          'guide': guideName,
          'date': data['availableDates'] ?? '',
          'time':
              '${data['durationValue'] ?? ''} ${data['durationUnit'] ?? ''}',
          'location': data['destination'] ?? '',
          'price': '${data['price'] ?? ''} SAR',
          'status': data['status'] ?? 'Upcoming',
          'image': 'images/tour_1.png',
        });
      }

      allBookings.assignAll(loadedBookings);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookings');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredBookings {
    if (selectedTab.value == 'All') {
      return allBookings;
    }

    return allBookings
        .where((booking) => booking['status'] == selectedTab.value)
        .toList();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void messageGuide(String bookingId) {
    Get.snackbar(
      'Message Guide',
      'Messaging functionality not yet implemented.',
    );
  }

  void viewDetails(String bookingId) {
    final booking = allBookings.firstWhereOrNull((b) => b['id'] == bookingId);

    if (booking == null) {
      Get.snackbar('Error', 'Booking not found');
      return;
    }

    final tourId = booking['tourId'];
    if (tourId == null || tourId.toString().isEmpty) {
      Get.snackbar('Error', 'Tour ID not found');
      return;
    }

    Get.to(
  () => PackageDetailsView(
    packageId: tourId,
    showBookingButton: false,
  ),
);
  }
}
