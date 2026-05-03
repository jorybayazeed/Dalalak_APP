import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';

class RateTourDialog extends StatefulWidget {
  const RateTourDialog({super.key, required this.tourId});

  final String tourId;

  @override
  State<RateTourDialog> createState() => _RateTourDialogState();
}

class _RateTourDialogState extends State<RateTourDialog> {
  int _rating = 5;
  bool _isSubmitting = false;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_isSubmitting;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 380.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rate this tour',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      size: 18.sp,
                      color: const Color(0xFF7A7A7A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Row(
                children: List.generate(5, (i) {
                  final selected = i < _rating;
                  return InkWell(
                    onTap: _isSubmitting
                        ? null
                        : () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Icon(
                        selected ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 26.sp,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 14.h),
              TextField(
                controller: _reviewController,
                enabled: !_isSubmitting,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a short review (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0xFF00A86B)),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A86B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: canSubmit
                      ? () async {
                          setState(() => _isSubmitting = true);
                          try {
                            final controller =
                                Get.find<TouristHomeController>();
                            await controller.submitTourRating(
                              tourId: widget.tourId,
                              rating: _rating,
                              review: _reviewController.text.trim(),
                            );

                            if (!mounted) return;
                            Navigator.of(context).pop();
                          } catch (e) {
                            if (!mounted) return;
                            setState(() => _isSubmitting = false);
                            Get.snackbar(
                              'Error',
                              e.toString(),
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      : null,
                  child: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
