import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';

class GuideToursController extends GetxController {
  final PackagesService _packagesService = Get.find<PackagesService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Map<String, dynamic>> tours = <Map<String, dynamic>>[].obs;

  final RxMap<String, int> registeredCountByTourId = <String, int>{}.obs;

  final RxMap<String, double> averageRatingByTourId = <String, double>{}.obs;
  final RxMap<String, int> ratingsCountByTourId = <String, int>{}.obs;

  final RxMap<String, List<Map<String, dynamic>>> ratingsByTourId =
      <String, List<Map<String, dynamic>>>{}.obs;

  final Map<String, Timestamp?> _sessionStartedAtByTourId =
      <String, Timestamp?>{};
  final Map<String, QuerySnapshot<Map<String, dynamic>>> _lastBookingSnapshots =
      <String, QuerySnapshot<Map<String, dynamic>>>{};

  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _bookingCountSubs = {};

  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _ratingsSubs = {};

  final Map<String, String> _userNameCache = <String, String>{};

  dynamic _deepCopy(dynamic value) {
    if (value is Map) {
      final copied = <String, dynamic>{};
      value.forEach((k, v) {
        copied[k.toString()] = _deepCopy(v);
      });
      return copied;
    }
    if (value is List) {
      return value.map(_deepCopy).toList();
    }
    return value;
  }

  @override
  void onInit() {
    super.onInit();
    _packagesService.getPackagesStream().listen((packagesList) {
      final next = packagesList
          .where((p) => p['isCancelled'] != true) // 🔥 هذا السطر الجديد
          .map((p) {
            final safe = Map<String, dynamic>.from(_deepCopy(p) as Map);
            final id = (p['id'] ?? '').toString();
            if (id.isNotEmpty) {
              final live = safe['liveTourState'];
              Timestamp? startedAt;
              if (live is Map<String, dynamic>) {
                final raw = live['sessionStartedAt'];
                if (raw is Timestamp) {
                  startedAt = raw;
                }
              }

              final previous = _sessionStartedAtByTourId[id];
              _sessionStartedAtByTourId[id] = startedAt;

              _ensureBookingCountListener(id);
              _ensureRatingsListener(id);

              if (previous != startedAt) {
                _recomputeRegisteredCount(tourId: id);
              }
            }
            return {
              'id': id,
              'title': (safe['tourTitle'] ?? '').toString(),
              'destination': (safe['destination'] ?? '').toString(),
              'availableDates': (safe['availableDates'] ?? '').toString(),
              'activities': safe['activities'],
              'liveTourState': safe['liveTourState'],
            };
          })
          .toList();

      tours.assignAll(next);

      final activeIds = next.map((e) => (e['id'] ?? '').toString()).toSet();
      final toRemove = _bookingCountSubs.keys
          .where((id) => !activeIds.contains(id))
          .toList();
      for (final id in toRemove) {
        _bookingCountSubs.remove(id)?.cancel();
        registeredCountByTourId.remove(id);
        _sessionStartedAtByTourId.remove(id);
        _lastBookingSnapshots.remove(id);
      }

      final ratingToRemove = _ratingsSubs.keys
          .where((id) => !activeIds.contains(id))
          .toList();
      for (final id in ratingToRemove) {
        _ratingsSubs.remove(id)?.cancel();
        averageRatingByTourId.remove(id);
        ratingsCountByTourId.remove(id);
        ratingsByTourId.remove(id);
      }
    });
  }

  Future<void> _refreshRatingsList({
    required String tourId,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  }) async {
    if (docs.isEmpty) {
      ratingsByTourId[tourId] = <Map<String, dynamic>>[];
      return;
    }

    final List<Map<String, dynamic>> loaded = [];

    for (final d in docs) {
      final data = d.data();
      final userId = (data['userId'] ?? d.id).toString();
      var userName = 'Tourist';

      if (userId.isNotEmpty) {
        final cached = _userNameCache[userId];
        if (cached != null && cached.trim().isNotEmpty) {
          userName = cached;
        } else {
          try {
            final userDoc = await _firestore
                .collection('users')
                .doc(userId)
                .get();
            if (userDoc.exists) {
              final u = userDoc.data();
              final resolved = (u?['fullName'] ?? u?['name'] ?? '').toString();
              if (resolved.trim().isNotEmpty) {
                userName = resolved;
                _userNameCache[userId] = resolved;
              }
            }
          } catch (_) {
            // Ignore user lookup errors.
          }
        }
      }

      loaded.add({
        'userId': userId,
        'userName': userName,
        'rating': (data['rating'] as num?)?.toInt() ?? 0,
        'review': (data['review'] ?? '').toString(),
        'createdAt': data['createdAt'],
      });
    }

    loaded.sort((a, b) {
      final aTs = a['createdAt'];
      final bTs = b['createdAt'];
      if (aTs is Timestamp && bTs is Timestamp) {
        return bTs.compareTo(aTs);
      }
      return 0;
    });

    ratingsByTourId[tourId] = loaded;
  }

  void _ensureRatingsListener(String tourId) {
    if (_ratingsSubs.containsKey(tourId)) return;

    final sub = _firestore
        .collection('tourPackages')
        .doc(tourId)
        .collection('ratings')
        .snapshots()
        .listen(
          (snap) {
            final docs = snap.docs;
            if (docs.isEmpty) {
              averageRatingByTourId[tourId] = 0.0;
              ratingsCountByTourId[tourId] = 0;
              ratingsByTourId[tourId] = <Map<String, dynamic>>[];
              return;
            }

            var sum = 0.0;
            for (final d in docs) {
              final data = d.data();
              final r = (data['rating'] as num?)?.toDouble() ?? 0.0;
              sum += r;
            }
            averageRatingByTourId[tourId] = sum / docs.length;
            ratingsCountByTourId[tourId] = docs.length;

            _refreshRatingsList(tourId: tourId, docs: docs);
          },
          onError: (_) {
            averageRatingByTourId[tourId] = 0.0;
            ratingsCountByTourId[tourId] = 0;
            ratingsByTourId[tourId] = <Map<String, dynamic>>[];
          },
        );

    _ratingsSubs[tourId] = sub;
  }

  void _recomputeRegisteredCount({required String tourId}) {
    final snap = _lastBookingSnapshots[tourId];
    if (snap == null) return;

    final startedAt = _sessionStartedAtByTourId[tourId];
    final docs = snap.docs;

    var count = 0;
    for (final d in docs) {
      final data = d.data();
      final status =
          (data['status'] ?? '').toString().trim().toLowerCase();
      if (status == 'completed') continue;
      if (startedAt == null) {
        count++;
        continue;
      }
      final bookedAt = data['bookedAt'];
      if (bookedAt is Timestamp) {
        if (bookedAt.compareTo(startedAt) >= 0) {
          count++;
        }
      } else {
        count++;
      }
    }

    registeredCountByTourId[tourId] = count;
  }

  void _ensureBookingCountListener(String tourId) {
    if (_bookingCountSubs.containsKey(tourId)) return;

    final sub = _firestore
        .collectionGroup('upcomingBookings')
        .where('tourId', isEqualTo: tourId)
        .snapshots()
        .listen(
          (snap) {
            _lastBookingSnapshots[tourId] = snap;
            _recomputeRegisteredCount(tourId: tourId);
          },
          onError: (e) {
            registeredCountByTourId[tourId] = 0;
            // The thrown exception usually contains a direct Firebase Console link
            // to create the required index.
            // ignore: avoid_print
            print(e);
            Get.snackbar(
              'Bookings index required',
              'Open Debug Console to copy the index creation link from this error.',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );

    _bookingCountSubs[tourId] = sub;
  }

  @override
  void onClose() {
    for (final sub in _bookingCountSubs.values) {
      sub.cancel();
    }
    _bookingCountSubs.clear();

    for (final sub in _ratingsSubs.values) {
      sub.cancel();
    }
    _ratingsSubs.clear();

    ratingsByTourId.clear();

    super.onClose();
  }
  Future<void> cancelTour(String id) async {
  try {
    
    await _packagesService.cancelTour(id);

   final tourDoc = await _firestore
    .collection('tourPackages')
    .doc(id)
    .get();

final tourTitle = tourDoc.data()?['tourTitle'] ?? 'Your tour';

    final bookingsSnapshot = await _firestore
        .collectionGroup('upcomingBookings')
        .where('tourId', isEqualTo: id)
        .get();

    // send notification
    for (var doc in bookingsSnapshot.docs) {
      final data = doc.data();

      final touristId = data['userId']; 

      if (touristId != null && touristId.toString().isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(touristId)
            .collection('notifications')
            .add({
          'title': 'Tour Cancelled',
          'message': '$tourTitle has been cancelled by the guide.',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    Get.snackbar('Success', 'Tour cancelled successfully');
  } catch (e) {
    Get.snackbar('Error', e.toString());
  }
}

Future<void> startTour(String id) async {
  await FirebaseFirestore.instance
      .collection('tourPackages') 
      .doc(id)
      .update({
    'liveTourState': {
      'activeActivityId': '',
      'completedActivityIds': [],
      'ended': false,
      'sessionStartedAt': Timestamp.now(),
    }
  });
}
}
