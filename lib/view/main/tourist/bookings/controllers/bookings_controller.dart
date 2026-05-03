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
  StreamSubscription<User?>? _authSub;
  int _loadSeq = 0;

  @override
  void onInit() {
    super.onInit();

    _authSub?.cancel();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _bindForUser(user);
    });

    _bindForUser(FirebaseAuth.instance.currentUser);
  }

  void _bindForUser(User? user) {
    _bookingsSub?.cancel();
    _bookingsSub = null;

    allBookings.clear();
    selectedTab.value = 'Upcoming';

    if (user == null) {
      return;
    }

    _bookingsSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('upcomingBookings')
        .snapshots()
        .listen(
      (snap) {
        _loadBookingsFromSnapshot(snap);
      },
      onError: (e) {
        Get.log('BookingsController snapshots error: $e');
      },
    );

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
      var movedAnyToCompleted = false;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        String guideName = '';
        bool tourEnded = false;

        final bookingSessionId = (data['sessionId'] ?? '').toString().trim();

        final tourId = data['tourId'] ?? data['packageId'] ?? doc.id;
        if (tourId != null && tourId.toString().isNotEmpty) {
          final tourDoc = await FirebaseFirestore.instance
              .collection('tourPackages')
              .doc(tourId.toString())
              .get();

          if (tourDoc.exists) {
            final tourData = tourDoc.data() as Map<String, dynamic>;

            final live = tourData['liveTourState'] as Map<String, dynamic>?;
            final rawEnded = live?['ended'];
            final ended = rawEnded is bool
                ? rawEnded
                : rawEnded is num
                    ? rawEnded != 0
                    : (rawEnded?.toString().trim().toLowerCase() == 'true' ||
                        rawEnded?.toString().trim() == '1');
            final liveSessionId = (live?['sessionId'] ?? '').toString().trim();
            tourEnded = ended &&
                (bookingSessionId.isEmpty ||
                    liveSessionId.isEmpty ||
                    bookingSessionId == liveSessionId);

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
            movedAnyToCompleted = true;
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

      if (movedAnyToCompleted && selectedTab.value.trim() == 'Upcoming') {
        selectedTab.value = 'Completed';
      } else {
        final hasUpcoming = loadedBookings
            .any((b) => _normalizeStatus(b['status']) == 'Upcoming');
        final hasCompleted = loadedBookings
            .any((b) => _normalizeStatus(b['status']) == 'Completed');
        if (!hasUpcoming && hasCompleted && selectedTab.value.trim() == 'Upcoming') {
          selectedTab.value = 'Completed';
        }
      }
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
    _authSub?.cancel();
    _authSub = null;
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
