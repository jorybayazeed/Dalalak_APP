import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/onboarding/views/onboarding_slides.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF0A4B52);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.62, 1.0],
                  colors: [
                    Color(0xFF63DCD0),
                    Color(0xFF8FE2C0),
                    Color(0xFFFF8623),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -30.h,
            left: -130.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200.r),
              child: Container(
                width: 330.w,
                height: 250.h,
                color: const Color(0xFF2FC6B2).withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            top: -20.h,
            right: -110.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(200.r),
              child: Container(
                width: 290.w,
                height: 230.h,
                color: const Color(0xFF7BE6D7).withOpacity(0.17),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 215.h,
            child: SizedBox(
              height: 130.h,
              child: CustomPaint(
                painter: _SkylinePainter(color: textColor.withOpacity(0.14)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _WaveClipperOne(),
              child: Container(
                height: 220.h,
                color: const Color(0xFFFFAE49).withOpacity(0.55),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipPath(
              clipper: _WaveClipperTwo(),
              child: Container(
                height: 180.h,
                color: const Color(0xFFFF982F).withOpacity(0.62),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.w),
              child: Column(
                children: [
                  SizedBox(height: 46.h),
                  Center(
                    child: Image.asset(
                      'images/new_logo.png',
                      width: 290.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Discover, Engage, and Experience\nSaudi Arabia with Daleelak',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: textColor,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 70.w,
                        height: 2.h,
                        color: textColor.withOpacity(0.45),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Icon(
                          Icons.diamond,
                          size: 12.sp,
                          color: textColor,
                        ),
                      ),
                      Container(
                        width: 70.w,
                        height: 2.h,
                        color: textColor.withOpacity(0.45),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 34.h),
                    child: Container(
                      width: 0.86.sw,
                      height: 68.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF13C9A2),
                        borderRadius: BorderRadius.circular(38.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.to(() => const OnboardingSlides());
                          },
                          borderRadius: BorderRadius.circular(38.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 30.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveClipperOne extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.18,
      size.width * 0.55,
      size.height * 0.36,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height * 0.5,
      size.width,
      size.height * 0.22,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _WaveClipperTwo extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.42);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.58,
      size.height * 0.44,
    );
    path.quadraticBezierTo(
      size.width * 0.84,
      size.height * 0.62,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SkylinePainter extends CustomPainter {
  const _SkylinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final baseY = size.height;

    final towers = <Rect>[
      Rect.fromLTWH(0, baseY - 44, size.width * 0.1, 44),
      Rect.fromLTWH(size.width * 0.12, baseY - 70, size.width * 0.08, 70),
      Rect.fromLTWH(size.width * 0.22, baseY - 55, size.width * 0.1, 55),
      Rect.fromLTWH(size.width * 0.36, baseY - 90, size.width * 0.12, 90),
      Rect.fromLTWH(size.width * 0.51, baseY - 62, size.width * 0.1, 62),
      Rect.fromLTWH(size.width * 0.66, baseY - 104, size.width * 0.1, 104),
      Rect.fromLTWH(size.width * 0.79, baseY - 74, size.width * 0.08, 74),
      Rect.fromLTWH(size.width * 0.89, baseY - 118, size.width * 0.11, 118),
    ];

    for (final tower in towers) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(tower, const Radius.circular(5)),
        paint,
      );
    }

    final dome = Path()
      ..moveTo(size.width * 0.58, baseY - 24)
      ..quadraticBezierTo(
        size.width * 0.63,
        baseY - 65,
        size.width * 0.68,
        baseY - 24,
      )
      ..close();
    canvas.drawPath(dome, paint);
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter oldDelegate) => false;
}
