import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tour_app/view/main/tourist/explore/views/package_details_view.dart';

class BookingsController extends GetxController {
  final RxString selectedTab = 'Upcoming'.obs;
  final RxList<Map<String, dynamic>> allBookings = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingsSub;
  int _loadSeq = 0;

  @override
  void onInit() {
    super.onInit();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _bookingsSub?.cancel();
      _bookingsSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('upcomingBookings')
          .snapshots()
          .listen((snap) {
        _loadBookingsFromSnapshot(snap);
      }, onError: (e) {
        Get.log('BookingsController snapshots error: $e');
      });
    }

    loadBookings();
  }

  String _normalizeStatus(dynamic raw) {
    final s = (raw ?? 'Upcoming').toString().trim();
    final lower = s.toLowerCase();
    if (lower == 'completed') return 'Completed';
    if (lower == 'cancelled' || lower == 'canceled') return 'Cancelled';
    if (lower == 'upcoming') return 'Upcoming';
    return s;
  }

  Future<void> _loadBookingsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final seq = ++_loadSeq;
    try {
      isLoading.value = true;

      final List<Map<String, dynamic>> loadedBookings = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        String guideName = '';
        bool tourEnded = false;

        final tourId = data['tourId'] ?? data['packageId'] ?? doc.id;
        if (tourId != null && tourId.toString().isNotEmpty) {
          final tourDoc = await FirebaseFirestore.instance
              .collection('tourPackages')
              .doc(tourId.toString())
              .get();

          if (tourDoc.exists) {
            final tourData = tourDoc.data() as Map<String, dynamic>;

            final live = tourData['liveTourState'] as Map<String, dynamic>?;
            tourEnded = (live?['ended'] as bool?) ?? false;

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

        final currentStatus = _normalizeStatus(data['status']);
        if (tourEnded && currentStatus != 'Completed') {
          try {
            await doc.reference.set(
              {
                'status': 'Completed',
                'completedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true),
            );
          } catch (_) {
            // Ignore reconciliation errors.
          }
        }

        final effectiveStatus = tourEnded ? 'Completed' : currentStatus;

        loadedBookings.add({
          'id': doc.id,
          'tourId': (data['tourId'] ?? data['packageId'] ?? doc.id).toString(),
          'title': data['tourTitle'] ?? '',
          'guide': guideName,
          'date': data['availableDates'] ?? '',
          'time': '${data['durationValue'] ?? ''} ${data['durationUnit'] ?? ''}',
          'location': data['destination'] ?? '',
          'price': '${data['price'] ?? ''} SAR',
          'status': effectiveStatus,
          'image': 'images/tour_1.png',
        });
      }

      if (seq != _loadSeq) return;
      allBookings.assignAll(loadedBookings);
    } catch (e) {
      Get.log('BookingsController snapshot processing error: $e');
    } finally {
      if (seq == _loadSeq) {
        isLoading.value = false;
      }
    }
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

      await _loadBookingsFromSnapshot(snapshot);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bookings');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _bookingsSub?.cancel();
    _bookingsSub = null;
    super.onClose();
  }

  List<Map<String, dynamic>> get filteredBookings {
    if (selectedTab.value == 'All') {
      return allBookings;
    }

    return allBookings
        .where(
          (booking) =>
              _normalizeStatus(booking['status']) == selectedTab.value.trim(),
        )
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
