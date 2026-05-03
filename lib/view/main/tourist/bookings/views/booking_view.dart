import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/services/gamification_service.dart';
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

  double _parsePrice(dynamic v) {
    if (v is num) return v.toDouble();
    final raw = (v ?? '').toString().trim();
    if (raw.isEmpty) return 0.0;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  double get _basePrice => _parsePrice(widget.tour['price']);

  double get _totalPrice {
    final guests = _guests < 1 ? 1 : _guests;
    return _basePrice * guests;
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
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

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
        final hasAnyLocation = activities.any((a) {
          if (a is! Map) return false;
          final m = a.cast<String, dynamic>();
          final lat = (m['latitude'] as num?)?.toDouble();
          final lng = (m['longitude'] as num?)?.toDouble();
          return lat != null &&
              lng != null &&
              lat.isFinite &&
              lng.isFinite;
        });
        if (!hasAnyLocation) {
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
      final totalPrice = basePrice * safeGuests;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('upcomingBookings')
          .doc(tourId)
          .set({
            'tourId': tourId,
            'tourTitle': widget.tour['tourTitle'],
            'destination': widget.tour['destination'],
            'price': basePrice,
            'totalPrice': totalPrice,
            'availableDates': widget.tour['availableDates'],
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
        backgroundColor: Colors.white,
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
}
