import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tour_app/services/packages_service.dart';

class LiveTourController extends GetxController {
  LiveTourController({required this.packageId});

  final String packageId;

  final PackagesService _packagesService = Get.find<PackagesService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;
  final RxMap<String, dynamic> packageData = <String, dynamic>{}.obs;

  final MapController mapController = MapController();

  final RxList<Map<String, dynamic>> activities = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> bookings = <Map<String, dynamic>>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingsSub;

  final RxString activeActivityId = ''.obs;
  final RxSet<String> completedActivityIds = <String>{}.obs;
  final RxBool isTourEnded = false.obs;
  final Rxn<Timestamp> sessionStartedAt = Rxn<Timestamp>();

  @override
  void onInit() {
    super.onInit();
    _listenToBookings();
    load();
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  void _listenToBookings() {
    _bookingsSub?.cancel();
    _bookingsSub = _firestore
        .collectionGroup('upcomingBookings')
        .where('tourId', isEqualTo: packageId)
        .snapshots()
        .listen((snap) {
      final startedAt = sessionStartedAt.value;

      bookings.assignAll(
        snap.docs
            .where((d) {
              if (startedAt == null) return true;
              final data = d.data();
              final bookedAt = data['bookedAt'];
              if (bookedAt is Timestamp) {
                return bookedAt.compareTo(startedAt) >= 0;
              }
              return true;
            })
            .map((d) {
              final data = d.data();
              return {
                'id': d.id,
                ...data,
              };
            })
            .toList(),
      );
    });
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      final data = await _packagesService.getPackage(packageId);
      if (data == null) {
        packageData.clear();
        activities.clear();
        return;
      }

      packageData.assignAll(data);

      final raw = (data['activities'] as List<dynamic>?) ?? <dynamic>[];
      final mapped = <Map<String, dynamic>>[];
      for (var i = 0; i < raw.length; i++) {
        final a = Map<String, dynamic>.from(raw[i] as Map);
        final existingId = (a['activityId'] ?? '').toString().trim();
        if (existingId.isEmpty) {
          a['activityId'] = '${packageId}_activity_${i + 1}';
        }
        mapped.add(a);
      }
      activities.assignAll(mapped);

      final live = data['liveTourState'] as Map<String, dynamic>?;
      if (live != null) {
        activeActivityId.value = (live['activeActivityId'] ?? '').toString();
        final completedRaw = live['completedActivityIds'] as List<dynamic>?;
        if (completedRaw != null) {
          completedActivityIds.addAll(completedRaw.map((e) => e.toString()));
        }
        isTourEnded.value = (live['ended'] as bool?) ?? false;
        sessionStartedAt.value = live['sessionStartedAt'] as Timestamp?;
      }

      _moveToInitialCamera();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _bookingsSub?.cancel();
    super.onClose();
  }

  void _moveToInitialCamera() {
    final points = activities
        .map((a) {
          final lat = _toDouble(a['latitude']);
          final lng = _toDouble(a['longitude']);
          if (lat == null || lng == null) return null;
          return LatLng(lat, lng);
        })
        .whereType<LatLng>()
        .toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (points.isEmpty) {
        mapController.move(const LatLng(24.7136, 46.6753), 12);
        return;
      }

      if (points.length == 1) {
        mapController.move(points.first, 15);
        return;
      }

      final bounds = LatLngBounds.fromPoints(points);
      try {
        mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(42)),
        );
      } catch (_) {
        mapController.move(points.first, 13);
      }
    });
  }

  String activityName(Map<String, dynamic> a) =>
      (a['activityName'] ?? '').toString();

  String activityId(Map<String, dynamic> a) =>
      (a['activityId'] ?? '').toString();

  LatLng? activityLatLng(Map<String, dynamic> a) {
    final lat = _toDouble(a['latitude']);
    final lng = _toDouble(a['longitude']);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  String statusFor(Map<String, dynamic> a) {
    final id = activityId(a);
    if (isTourEnded.value) return 'Ended';
    if (completedActivityIds.contains(id)) return 'Completed';
    if (activeActivityId.value == id && id.isNotEmpty) return 'Active';
    return 'Not Started';
  }

  int get registeredCount => bookings.length;

  Future<void> startActivity(String id) async {
    if (isTourEnded.value) {
      Get.snackbar(
        'Tour ended',
        'You can\'t start activities after ending the tour',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (id.isEmpty) {
      Get.snackbar(
        'Invalid activity',
        'This activity has no id',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (completedActivityIds.contains(id)) {
      Get.snackbar(
        'Already completed',
        'This activity is already completed',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final previous = activeActivityId.value;
    activeActivityId.value = id;
    try {
      await _persistState();
      Get.snackbar(
        'Your tour is starting',
        'Activity started successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      activeActivityId.value = previous;
      Get.snackbar(
        'Failed to start',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> completeActiveActivity() async {
    if (isTourEnded.value) return;

    final id = activeActivityId.value;
    if (id.isEmpty) return;

    completedActivityIds.add(id);
    activeActivityId.value = '';
    try {
      await _persistState();
    } catch (e) {
      completedActivityIds.remove(id);
      activeActivityId.value = id;
      Get.snackbar(
        'Failed to complete',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> endTour() async {
    isTourEnded.value = true;
    activeActivityId.value = '';
    try {
      await _persistState();
    } catch (e) {
      isTourEnded.value = false;
      Get.snackbar(
        'Failed to end tour',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> restartTour() async {
    final previousEnded = isTourEnded.value;
    final previousActive = activeActivityId.value;
    final previousCompleted = completedActivityIds.toSet();
    final previousSessionStartedAt = sessionStartedAt.value;

    isTourEnded.value = false;
    activeActivityId.value = '';
    completedActivityIds.clear();
    sessionStartedAt.value = Timestamp.now();

    try {
      await _persistState();
      Get.snackbar(
        'Tour restarted',
        'The tour is live again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isTourEnded.value = previousEnded;
      activeActivityId.value = previousActive;
      completedActivityIds
        ..clear()
        ..addAll(previousCompleted);
      sessionStartedAt.value = previousSessionStartedAt;
      Get.snackbar(
        'Failed to restart tour',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _persistState() async {
    await _packagesService.updateLiveTourState(
      packageId: packageId,
      activeActivityId: activeActivityId.value,
      completedActivityIds: completedActivityIds.toList(),
      ended: isTourEnded.value,
      sessionStartedAt: sessionStartedAt.value,
    );
  }
}
