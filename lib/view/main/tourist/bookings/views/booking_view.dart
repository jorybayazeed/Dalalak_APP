import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/services/gamification_service.dart';
import 'package:tour_app/services/guide_matching_service.dart';
import 'package:tour_app/services/weather_service.dart';
import 'package:tour_app/view/main/tourist/bookings/views/booking_success_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class BookingView extends StatefulWidget {
  final Map<String, dynamic> tour;

  const BookingView({super.key, required this.tour});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController guestsController = TextEditingController();
  final TextEditingController cardNameController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  int _guests = 1;
  SmartWeatherAssessment? _weatherAssessment;
  bool _isCheckingWeather = false;

  // Smart Guide Matching
  List<GuideMatch> _suggestedGuides = [];
  bool _isLoadingGuides = false;
  bool _guidesExpanded = false;

  double _parsePrice(dynamic v) {
    if (v is num) return v.toDouble();
    final raw = (v ?? '').toString().trim();
    if (raw.isEmpty) return 0.0;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get _basePrice => _parsePrice(widget.tour['price']);

  double get _unitPrice {
    final discounted = widget.tour['_discountedUnitPrice'];
    if (discounted is num) return discounted.toDouble();
    return _basePrice;
  }

  int get _appliedDiscountPercent {
    final v = widget.tour['_appliedDiscountPercent'];
    if (v is num) return v.toInt();
    return 0;
  }

  String? get _appliedRewardId {
    final v = widget.tour['_appliedRewardId'];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  double get _totalPrice {
    final guests = _guests < 1 ? 1 : _guests;
    return _unitPrice * guests;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        color: const Color(0xFF777777),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFF00A86B), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  void dispose() {
    guestsController.dispose();
    cardNameController.dispose();
    cardNumberController.dispose();
    expiryDateController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    guestsController.addListener(() {
      final guests = int.tryParse(guestsController.text.trim()) ?? 1;
      final next = guests < 1 ? 1 : guests;
      if (next != _guests) {
        setState(() {
          _guests = next;
        });
      }
    });
    _loadSmartWeather();
    _loadSmartGuides();
  }

  Future<void> _loadSmartGuides() async {
    final tour = widget.tour;
    final guideId = (tour['guideId'] ?? '').toString();
    final destination = (tour['destination'] ?? '').toString();
    final activityType = (tour['activityType'] ?? '').toString();
    final budget = _parsePrice(tour['price']);

    // استرداد لغات السائح من ملفه الشخصي
    List<String> touristLangs = [];
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();
      final d = userDoc.data() ?? {};
      final raw = d['languages'] ?? d['languagesSpoken'] ?? d['preferredLanguages'];
      if (raw is List) touristLangs = raw.map((e) => e.toString()).toList();
    } catch (_) {}

    setState(() => _isLoadingGuides = true);
    try {
      final service = Get.find<GuideMatchingService>();
      final results = await service.findBestGuides(
        GuideMatchRequest(
          tourId: (tour['id'] ?? '').toString(),
          destination: destination,
          activityType: activityType,
          budget: budget,
          tripType: '',
          preferredLanguages: touristLangs,
          guideId: guideId,
        ),
      );
      if (!mounted) return;
      setState(() => _suggestedGuides = results);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingGuides = false);
    }
  }

  Future<void> _loadSmartWeather() async {
    final destination = (widget.tour['destination'] ?? '').toString();
    if (destination.trim().isEmpty) return;

    final weatherService = Get.find<WeatherService>();
    final availableDates = (widget.tour['availableDates'] ?? '').toString();
    final startTime = (widget.tour['startTime'] ?? '').toString();
    final tripAt = weatherService.inferTourDateTime(
      availableDates: availableDates,
      startTime: startTime,
    );

    setState(() {
      _isCheckingWeather = true;
    });

    try {
      final result = await weatherService.evaluateSmartWeather(
        cityName: destination,
        tripDateTime: tripAt,
        isOutdoor: true,
      );
      if (!mounted) return;
      setState(() {
        _weatherAssessment = result;
      });
    } catch (_) {
      // Ignore weather load failure on booking screen.
    } finally {
      if (!mounted) return;
      setState(() {
        _isCheckingWeather = false;
      });
    }
  }

  Future<bool> _confirmWeatherRiskIfNeeded() async {
    final weather = _weatherAssessment;
    if (weather == null) return true;

    final level = weather.tripRecommendation.level;
    if (level == WeatherRiskLevel.normal || level == WeatherRiskLevel.caution) {
      return true;
    }

    final rec = weather.tripRecommendation;

    final shouldContinue = await Get.dialog<bool>(
      AlertDialog(
        title: Text(rec.title),
        content: Text(
          '${rec.message}\n\nDo you want to continue booking anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel booking'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return shouldContinue == true;
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    final canContinue = await _confirmWeatherRiskIfNeeded();
    if (!canContinue) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    final userId = user.uid;
    final tourId = (widget.tour['id'] ?? '').toString();

    var currentSessionId = '';

    if (tourId.isEmpty) {
      Get.snackbar('Error', 'Tour ID not found');
      return;
    }

    try {
      final upcomingRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('upcomingBookings');

      final docById = await upcomingRef.doc(tourId).get();
      if (docById.exists) {
        Get.snackbar(
          'Already booked',
          'You already booked this tour',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final docByField = await upcomingRef
          .where('tourId', isEqualTo: tourId)
          .limit(1)
          .get();
      if (docByField.docs.isNotEmpty) {
        Get.snackbar(
          'Already booked',
          'You already booked this tour',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final tourDoc = await FirebaseFirestore.instance
          .collection('tourPackages')
          .doc(tourId)
          .get();

      if (tourDoc.exists) {
        final tourData = tourDoc.data();
        final live = tourData?['liveTourState'] as Map<String, dynamic>?;
        currentSessionId = (live?['sessionId'] ?? '').toString().trim();

        final activities = (tourData?['activities'] as List<dynamic>?) ?? const [];
        final hasActivityLocation = activities.any((a) {
          if (a is! Map) return false;
          final m = a.cast<String, dynamic>();
          final lat = (m['latitude'] as num?)?.toDouble();
          final lng = (m['longitude'] as num?)?.toDouble();
          return lat != null &&
              lng != null &&
              lat.isFinite &&
              lng.isFinite;
        });

        bool hasTourLocation = false;
        final mapLocRaw = (tourData?['mapLocation'] ?? '').toString().trim();
        if (mapLocRaw.isNotEmpty) {
          final parts = mapLocRaw.split(',');
          if (parts.length == 2) {
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            hasTourLocation = lat != null &&
                lng != null &&
                lat.isFinite &&
                lng.isFinite;
          }
        }

        if (!hasActivityLocation && !hasTourLocation) {
          Get.snackbar(
            'Tour not available',
            'This tour is not available due to lack of location pointed',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        final rawEnded = live?['ended'];
        final ended = rawEnded is bool
            ? rawEnded
            : rawEnded is num
                ? rawEnded != 0
                : (rawEnded?.toString().trim().toLowerCase() == 'true' ||
                    rawEnded?.toString().trim() == '1');
        if (ended) {
          Get.snackbar(
            'Tour ended',
            'This tour has already ended and can\'t be booked',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
    } catch (e) {
      Get.log('Booking: failed to check tour state: $e');
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        Get.snackbar('Error', 'User data not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      final guests = int.tryParse(guestsController.text.trim()) ?? 1;
      final safeGuests = guests < 1 ? 1 : guests;
      final basePrice = _basePrice;
      final unitPrice = _unitPrice;
      final totalPrice = unitPrice * safeGuests;
      final discountPercent = _appliedDiscountPercent;
      final rewardId = _appliedRewardId;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('upcomingBookings')
          .doc(tourId)
          .set({
            'tourId': tourId,
            'tourTitle': widget.tour['tourTitle'],
            'destination': widget.tour['destination'],
            'price': unitPrice,
            'originalPrice': basePrice,
            'totalPrice': totalPrice,
            if (discountPercent > 0) 'discountPercent': discountPercent,
            if (rewardId != null) 'appliedRewardId': rewardId,
            'availableDates': widget.tour['availableDates'],
            'startTime': widget.tour['startTime'] ?? '',
            'durationValue': widget.tour['durationValue'],
            'durationUnit': widget.tour['durationUnit'],
            'guests': safeGuests,
            'cardHolderName': cardNameController.text.trim(),
            'fullName': userData['fullName'] ?? '',
            'email': userData['email'] ?? '',
            'phone': userData['phone'] ?? '',
            'bookedAt': Timestamp.now(),
            'status': 'Upcoming',
            if (currentSessionId.isNotEmpty) 'sessionId': currentSessionId,
          });

      if (rewardId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('rewards')
              .doc(rewardId)
              .update({
            'totalAppliedCount': FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {}
      }

      try {
        final tourDoc = await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(tourId)
            .get();
        final tourData = tourDoc.data();
        final guideId = (tourData?['guideId'] ?? '').toString();
        if (guideId.isNotEmpty) {
          final touristName = (userData['fullName'] ?? 'A tourist').toString();
          final tourTitle = (widget.tour['tourTitle'] ?? 'your tour').toString();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(guideId)
              .collection('notifications')
              .add({
            'type': 'booking',
            'title': 'New Booking',
            'message': '$touristName booked $tourTitle',
            'isRead': false,
            'createdAt': Timestamp.now(),
            'serverCreatedAt': FieldValue.serverTimestamp(),
            'tourId': tourId,
          });
        }
      } catch (_) {
        // Ignore notification errors.
      }

      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'bookingCount': FieldValue.increment(1),
        });
      } catch (_) {}

      var newBadges = <String>[];
      try {
        newBadges = await Get.find<GamificationService>().checkAndUnlockBadges();
      } catch (_) {}

      try {
        await FirebaseFirestore.instance
            .collection('tourPackages')
            .doc(tourId)
            .update({'bookings': FieldValue.increment(1)});
      } catch (_) {}

      final tourTitle = (widget.tour['tourTitle'] ?? '').toString();

      var bookingPointsEarned = 0;
      try {
        bookingPointsEarned = await Get.find<GamificationService>()
            .awardBookingPoints(
              packageId: tourId,
              sessionId: currentSessionId.isEmpty ? null : currentSessionId,
            );

        if (bookingPointsEarned > 0) {
          Get.snackbar(
            'Points Added',
            'You earned +$bookingPointsEarned points for booking $tourTitle',
            snackPosition: SnackPosition.BOTTOM,
          );
        }

        if (bookingPointsEarned > 0) {
          try {
            final notifId = 'booking_points_$tourId';
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('notifications')
                .doc(notifId)
                .set({
              'type': 'booking_points',
              'title': 'Points Added',
              'message': 'You earned +$bookingPointsEarned points for booking $tourTitle',
              'isRead': false,
              'createdAt': Timestamp.now(),
              'serverCreatedAt': FieldValue.serverTimestamp(),
              'tourId': tourId,
              'pointsEarned': bookingPointsEarned,
            }, SetOptions(merge: true));
          } catch (_) {
            // Ignore notification errors.
          }
        }

        await Get.find<GamificationService>().recomputeAndSyncTotalPoints(
          userId: userId,
          force: true,
        );
      } catch (e) {
        Get.log('Booking: failed to award points: $e');
      }

      await Get.dialog<void>(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Congratulations !!',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          content: Text(
            newBadges.contains('first_booking')
                ? 'You earned your first badge 🎉'
                : 'Your booking has been confirmed',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF00A86B),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (Get.isRegistered<TouristHomeController>()) {
        final home = Get.find<TouristHomeController>();
        await home.loadCurrentTours(showCompletionSnackbars: false);
        final activeTourId = home.activeTourId.value;
        if (activeTourId.isNotEmpty) {
          await home.loadTourActivities(
            activeTourId,
            showCompletionSnackbars: false,
          );
        }
      }

      Get.off(() => BookingSuccessView(tourTitle: tourTitle));
    } catch (e) {
      Get.log('Booking confirm error: $e');
      Get.snackbar('Error', 'Failed to confirm booking');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'Booking',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tour['tourTitle'] ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Destination: ${widget.tour['destination'] ?? ''}',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Duration: ${widget.tour['durationValue'] ?? ''} ${widget.tour['durationUnit'] ?? ''}',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                if (_appliedDiscountPercent > 0) ...[
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9C7),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Reward applied: -$_appliedDiscountPercent%',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB36B00),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Original: ${(_basePrice * (_guests < 1 ? 1 : _guests)).toStringAsFixed(0)} SAR',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
                Text(
                  'Price: ${_totalPrice.toStringAsFixed(0)} SAR',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00A86B),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Available Dates: ${widget.tour['availableDates'] ?? ''}',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                if ((widget.tour['startTime'] ?? '').toString().trim().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Start Time: ${widget.tour['startTime']}',
                    style: GoogleFonts.inter(fontSize: 14.sp),
                  ),
                ],
                SizedBox(height: 12.h),
                if (_isCheckingWeather)
                  const Center(child: CircularProgressIndicator())
                else if (_weatherAssessment != null)
                  _buildWeatherAlertCard(_weatherAssessment!),
                SizedBox(height: 16.h),

                // ─── Smart Guide Matching ───
                _buildGuideMatchingCard(),
                SizedBox(height: 24.h),

                Row(
                  children: [
                    const Icon(
                      Icons.event_available,
                      color: Color(0xFF00A86B),
                      size: 22,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Booking Information',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                TextFormField(
                  controller: guestsController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Number of Guests'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter number of guests';
                    }
                    final guests = int.tryParse(value.trim());
                    if (guests == null) return 'Numbers only';
                    if (guests < 1) return 'At least 1 guest';
                    if (guests > 20) return 'Maximum 20 guests';
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                Row(
                  children: [
                    const Icon(
                      Icons.credit_card,
                      color: Color(0xFF00A86B),
                      size: 22,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Payment Information',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                TextFormField(
                  controller: cardNameController,
                  decoration: _inputDecoration('Card Holder Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter card holder name';
                    }
                    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                      return 'Letters only';
                    }
                    if (value.trim().length < 2) {
                      return 'Name too short';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.h),

                TextFormField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Card Number'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter card number';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                      return 'Numbers only';
                    }
                    if (value.trim().length != 16) {
                      return 'Card must be 16 digits';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.h),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: expiryDateController,
                        decoration: _inputDecoration('Expiry Date (MM/YY)'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (!RegExp(
                            r'^(0[1-9]|1[0-2])\/[0-9]{2}$',
                          ).hasMatch(value.trim())) {
                            return 'Format MM/YY';
                          }
                          final parts = value.trim().split('/');
                          final month = int.parse(parts[0]);
                          final year = int.parse(parts[1]) + 2000;
                          final now = DateTime.now();
                          final expiry = DateTime(year, month + 1, 0);

                          if (expiry.isBefore(
                            DateTime(now.year, now.month, now.day),
                          )) {
                            return 'Card expired';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: cvvController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('CVV'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter CVV';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                            return 'Numbers only';
                          }
                          if (value.trim().length != 3) {
                            return 'CVV must be 3 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Confirm Booking',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideMatchingCard() {
    if (_isLoadingGuides) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12.w),
            Text(
              'Finding best guides for you…',
              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_suggestedGuides.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF00A86B).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _guidesExpanded = !_guidesExpanded),
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: const Color(0xFF00A86B),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Guide Suggestions',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'AI picked ${_suggestedGuides.length} guides that match your trip',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _guidesExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (_guidesExpanded) ...[
            const Divider(height: 1),
            ..._suggestedGuides.map((guide) => _buildGuideCard(guide)),
          ],
        ],
      ),
    );
  }

  Widget _buildGuideCard(GuideMatch guide) {
    final initial = guide.guideName.isNotEmpty
        ? guide.guideName[0].toUpperCase()
        : 'G';
    final matchPct = guide.matchScore.toInt();

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24.r,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(
                initial,
                style: GoogleFonts.inter(
                  color: const Color(0xFF00A86B),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          guide.guideName,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      // Match badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: matchPct >= 70
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '$matchPct% match',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: matchPct >= 70
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFF57F17),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Rating & experience
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 13.sp),
                      SizedBox(width: 3.w),
                      Text(
                        guide.rating > 0
                            ? guide.rating.toStringAsFixed(1)
                            : 'New',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                      ),
                      if (guide.reviews > 0) ...[
                        Text(
                          ' (${guide.reviews})',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      SizedBox(width: 10.w),
                      if (guide.yearsOfExperience > 0) ...[
                        Icon(
                          Icons.work_outline,
                          size: 12.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          '${guide.yearsOfExperience}y exp',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 6.h),
                  // Match reasons chips
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: guide.matchReasons
                        .take(3)
                        .map(
                          (reason) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              reason,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherAlertCard(SmartWeatherAssessment weather) {
    final rec = weather.tripRecommendation;
    final forecast = weather.tripForecast;

    Color color;
    switch (rec.level) {
      case WeatherRiskLevel.normal:
        color = const Color(0xFF2E7D32);
        break;
      case WeatherRiskLevel.caution:
        color = const Color(0xFFF9A825);
        break;
      case WeatherRiskLevel.warning:
        color = const Color(0xFFEF6C00);
        break;
      case WeatherRiskLevel.danger:
        color = const Color(0xFFC62828);
        break;
    }

    final activityType = (widget.tour['activityType'] ?? '').toString();
    final aiAlternative = WeatherRecommendation.suggestAiAlternative(
      level: rec.level,
      activityType: activityType,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rec.title,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 6.h),
          if (forecast != null)
            Text(
              'Forecast: ${forecast.temperatureC.toStringAsFixed(0)}°C • Rain ${forecast.precipitationProbability}% • Wind ${forecast.windSpeedKmH.toStringAsFixed(0)} km/h',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF444444),
              ),
            ),
          SizedBox(height: 6.h),
          Text(
            rec.message,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF444444),
            ),
          ),
          // اقتراح بديل ذكي من AI
          if (aiAlternative != null) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 14.sp, color: const Color(0xFF1565C0)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Alternative Suggestion',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1565C0),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          aiAlternative,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
