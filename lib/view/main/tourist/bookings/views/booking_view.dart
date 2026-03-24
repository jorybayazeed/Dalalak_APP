import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_app/view/main/tourist/bookings/views/booking_success_view.dart';

class BookingView extends StatefulWidget {
  final Map<String, dynamic> tour;

  const BookingView({
    super.key,
    required this.tour,
  });

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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(
        fontSize: 13.sp,
        color: const Color(0xFF777777),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 10.h,
      ),
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

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final userId = user.uid;
      final tourId = widget.tour['id'];

      if (tourId == null || tourId.toString().isEmpty) {
        Get.snackbar('Error', 'Tour ID not found');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        Get.snackbar('Error', 'User data not found');
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('upcomingBookings')
          .doc(tourId)
          .set({
        'tourId': tourId,
        'tourTitle': widget.tour['tourTitle'],
        'destination': widget.tour['destination'],
        'price': widget.tour['price'],
        'availableDates': widget.tour['availableDates'],
        'durationValue': widget.tour['durationValue'],
        'durationUnit': widget.tour['durationUnit'],
        'guests': int.parse(guestsController.text.trim()),
        'cardHolderName': cardNameController.text.trim(),
        'fullName': userData['fullName'] ?? '',
        'email': userData['email'] ?? '',
        'phone': userData['phone'] ?? '',
        'bookedAt': Timestamp.now(),
        'status': 'Upcoming',
      });

      Get.off(
        () => BookingSuccessView(
          tourTitle: widget.tour['tourTitle'] ?? '',
        ),
      );
    } catch (e) {
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
                  'Price: ${widget.tour['price'] ?? ''} SAR',
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
                          if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$')
                              .hasMatch(value.trim())) {
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