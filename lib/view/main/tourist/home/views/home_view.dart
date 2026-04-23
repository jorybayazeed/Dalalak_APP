import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tour_app/services/gamification_service.dart';
import 'package:tour_app/view/main/tourist/home/controllers/home_controller.dart';
import 'package:tour_app/view/main/tourist/home/controllers/tourist_notifications_controller.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/bottom_navigation_bar.dart';
import 'package:tour_app/view/main/tourist/shared/widgets/profile_dropdown.dart';
import 'package:tour_app/view/main/tourist/home/views/about_us_view.dart';
import 'package:tour_app/view/main/tourist/home/views/privacy_policy_view.dart';
import 'package:tour_app/view/main/tourist/home/views/support_view.dart';

import 'Tourist_notifications_view.dart';

class TouristHomeView extends StatelessWidget {
  const TouristHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TouristHomeController>()
        ? Get.find<TouristHomeController>()
        : Get.put(TouristHomeController());
    final notifController = Get.put(TouristNotificationsController());
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _RatePromptListener(controller: controller),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PopupMenuButton<String>(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    offset: Offset(0, 45.h),
                    onSelected: (value) {
                      if (value == 'about') {
                        Get.to(() => const AboutUsView());
                      } else if (value == 'privacy') {
                        Get.to(() => const PrivacyPolicyView());
                      } else if (value == 'support') {
                        Get.to(() => const SupportView());
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'about',
                        child: Row(
                          children: [
                            Icon(Icons.info_outline),
                            SizedBox(width: 8.w),
                            Text('About Us'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'privacy',
                        child: Row(
                          children: [
                            Icon(Icons.privacy_tip_outlined),
                            SizedBox(width: 8.w),
                            Text('Privacy Policy'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'support',
                        child: Row(
                          children: [
                            Icon(Icons.support_agent),
                            SizedBox(width: 8.w),
                            Text('Support'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.menu, color: const Color(0xFF4CAF50)),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(width: 12.w),
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                Get.to(() => const TouristNotificationsView()),
                            child: Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: Colors.black,
                                size: 22.sp,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 8.w,
                            top: 8.h,
                            child: Obx(() {
                              if (notifController.unreadCount == 0) {
                                return const SizedBox();
                              }

                              return Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      SizedBox(width: 12.w),
                      const TouristProfileDropdown(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              'Hi ${controller.userName.value.split(' ').first}, ready to explore?',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Discover amazing tours and experiences across Saudi Arabia',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF666666),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 18.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
                        ),
                        borderRadius: BorderRadius.circular(22.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 360.w,
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 60.w,
                                        height: 60.w,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.emoji_events,
                                          color: Colors.white,
                                          size: 32.sp,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            right: 110.w,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Your Total Points',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Obx(
                                                () => Text(
                                                  '${controller.totalPoints.value}',
                                                  style: GoogleFonts.inter(
                                                    color: Colors.white,
                                                    fontSize: 36.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8.h),
                                              Wrap(
                                                spacing: 12.w,
                                                runSpacing: 6.h,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                          vertical: 6.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20.r,
                                                          ),
                                                    ),
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                            maxWidth: 135.w,
                                                          ),
                                                      child: FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.star,
                                                              color:
                                                                  Colors.white,
                                                              size: 14.sp,
                                                            ),
                                                            SizedBox(
                                                              width: 6.w,
                                                            ),
                                                            Obx(
                                                              () => Text(
                                                                controller
                                                                    .level
                                                                    .value,
                                                                style: GoogleFonts.inter(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      10.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .workspace_premium,
                                                          color:
                                                              Colors.amber[300],
                                                          size: 16.sp,
                                                        ),
                                                        SizedBox(width: 4.w),
                                                        Obx(
                                                          () => Text(
                                                            '${controller.badgesCount.value}',
                                                            style:
                                                                GoogleFonts.inter(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 4.w),
                                                        Text(
                                                          'Badges',
                                                          style:
                                                              GoogleFonts.inter(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 44.h,
                                    child: GestureDetector(
                                      onTap: controller.viewRewards,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 10.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18.r,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.1,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 105.w,
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.center,
                                            child: Text(
                                              'View Rewards',
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFFFF9800),
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Current Tours',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Obx(() {
                            if (controller.currentTours.isEmpty) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Text(
                                  'No upcoming tours yet',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF6B6B6B),
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: controller.currentTours.map((tour) {
                                final tourId =
                                    (tour['tourId'] as String?) ?? '';
                                final title = (tour['title'] as String?) ?? '';
                                final date = (tour['date'] as String?) ?? '';
                                final guide = (tour['guide'] as String?) ?? '';
                                final totalActivities =
                                    (tour['totalActivities'] as int?) ?? 0;
                                final completedActivities =
                                    (tour['completedActivities'] as int?) ?? 0;
                                final pointsEarned =
                                    (tour['pointsEarned'] as int?) ?? 0;

                                final progress = totalActivities == 0
                                    ? 0.0
                                    : (completedActivities / totalActivities)
                                          .clamp(0.0, 1.0);

                                return Obx(() {
                                  final isExpanded = controller.expandedTourIds
                                      .contains(tourId);

                                  return Container(
                                    margin: EdgeInsets.only(bottom: 14.h),
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFFEFFAF2),
                                          Color(0xFFF7FDF8),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: GoogleFonts.inter(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 16,
                                              color: Color(0xFF6B6B6B),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              date,
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                color: const Color(0xFF6B6B6B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 14.w),
                                            const Icon(
                                              Icons.person_outline,
                                              size: 16,
                                              color: Color(0xFF6B6B6B),
                                            ),
                                            SizedBox(width: 6.w),
                                            Expanded(
                                              child: Text(
                                                'Guide: $guide',
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  color: const Color(
                                                    0xFF6B6B6B,
                                                  ),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Text(
                                              'Progress',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                color: const Color(0xFF6B6B6B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '$completedActivities/$totalActivities',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF00A86B),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 6.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00A86B),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                              child: Text(
                                                '$pointsEarned pts',
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8.r,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            minHeight: 8.h,
                                            backgroundColor: const Color(
                                              0xFFE2E8E4,
                                            ),
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  Color(0xFF00A86B),
                                                ),
                                          ),
                                        ),
                                        SizedBox(height: 14.h),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 44.h,
                                          child: OutlinedButton(
                                            onPressed: () => controller
                                                .toggleTourExpanded(tourId),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: Color(0xFF00A86B),
                                                width: 2,
                                              ),
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(22.r),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  isExpanded
                                                      ? 'Hide Activities'
                                                      : 'View Activities',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: const Color(
                                                      0xFF00A86B,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Icon(
                                                  isExpanded
                                                      ? Icons.keyboard_arrow_up
                                                      : Icons
                                                            .keyboard_arrow_down,
                                                  color: const Color(
                                                    0xFF00A86B,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isExpanded) ...[
                                          SizedBox(height: 16.h),
                                          Obx(() {
                                            final mapController = controller
                                                .mapControllerForTour(tourId);
                                            final tourMarkers =
                                                controller
                                                    .activityMapMarkersByTourId[tourId] ??
                                                const <Map<String, dynamic>>[];

                                            if (tourMarkers.isNotEmpty &&
                                                !controller.autoFittedTourIds
                                                    .contains(tourId)) {
                                              WidgetsBinding.instance
                                                  .addPostFrameCallback((_) {
                                                    if (controller
                                                        .autoFittedTourIds
                                                        .contains(tourId)) {
                                                      return;
                                                    }

                                                    final points = tourMarkers
                                                        .map(
                                                          (m) =>
                                                              m['position']
                                                                  as LatLng,
                                                        )
                                                        .toList();
                                                    final validPoints = points
                                                        .where(
                                                          (p) =>
                                                              p
                                                                  .latitude
                                                                  .isFinite &&
                                                              p
                                                                  .longitude
                                                                  .isFinite,
                                                        )
                                                        .toList();

                                                    if (validPoints.isEmpty) {
                                                      return;
                                                    }

                                                    final distinct = <String>{};
                                                    for (final p
                                                        in validPoints) {
                                                      distinct.add(
                                                        '${p.latitude.toStringAsFixed(6)},${p.longitude.toStringAsFixed(6)}',
                                                      );
                                                    }

                                                    if (distinct.length <= 1) {
                                                      mapController.move(
                                                        validPoints.first,
                                                        13,
                                                      );
                                                    } else {
                                                      final bounds =
                                                          LatLngBounds.fromPoints(
                                                            validPoints,
                                                          );
                                                      try {
                                                        mapController.fitCamera(
                                                          CameraFit.bounds(
                                                            bounds: bounds,
                                                            padding:
                                                                EdgeInsets.all(
                                                                  22.w,
                                                                ),
                                                          ),
                                                        );
                                                      } catch (_) {
                                                        mapController.move(
                                                          validPoints.first,
                                                          13,
                                                        );
                                                      }
                                                    }
                                                    controller.autoFittedTourIds
                                                        .add(tourId);
                                                  });
                                            }

                                            if (tourMarkers.isEmpty) {
                                              return Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(12.w),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        16.r,
                                                      ),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE0E0E0,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  'No map locations for these activities yet. The tour guide needs to pick locations (latitude/longitude) to show markers on the map.',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12.sp,
                                                    color: const Color(
                                                      0xFF6B6B6B,
                                                    ),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              );
                                            }

                                            return Container(
                                              width: double.infinity,
                                              height: 230.h,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16.r),
                                                child: FlutterMap(
                                                  mapController: mapController,
                                                  options: MapOptions(
                                                    initialCenter:
                                                        controller
                                                            .mapCenterByTourId[tourId] ??
                                                        controller
                                                            .mapCenter
                                                            .value,
                                                    initialZoom: 12,
                                                    interactionOptions:
                                                        const InteractionOptions(
                                                          flags: InteractiveFlag
                                                              .all,
                                                        ),
                                                    onTap: (_, point) {
                                                      mapController.move(
                                                        point,
                                                        13,
                                                      );
                                                    },
                                                  ),
                                                  children: [
                                                    TileLayer(
                                                      urlTemplate:
                                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                      userAgentPackageName:
                                                          'tour_app',
                                                    ),
                                                    MarkerLayer(
                                                      markers: tourMarkers
                                                          .map(
                                                            (m) => Marker(
                                                              point:
                                                                  (m['position']
                                                                      as LatLng),
                                                              width: 140.w,
                                                              height: 60.h,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  controller
                                                                          .activeTourId
                                                                          .value =
                                                                      tourId;
                                                                  final p =
                                                                      m['position']
                                                                          as LatLng;
                                                                  mapController
                                                                      .move(
                                                                        p,
                                                                        14,
                                                                      );

                                                                  final quizTitle =
                                                                      (m['title']
                                                                          as String?) ??
                                                                      '';
                                                                  final activityId =
                                                                      (m['activityId']
                                                                          as String?) ??
                                                                      '';
                                                                  final question =
                                                                      (m['question']
                                                                          as String?) ??
                                                                      '';
                                                                  final options =
                                                                      (m['options']
                                                                              as List?)
                                                                          ?.map(
                                                                            (
                                                                              e,
                                                                            ) =>
                                                                                e.toString(),
                                                                          )
                                                                          .toList() ??
                                                                      <
                                                                        String
                                                                      >[];

                                                                  if (activityId
                                                                          .isEmpty ||
                                                                      question
                                                                          .isEmpty ||
                                                                      options
                                                                          .isEmpty) {
                                                                    Get.snackbar(
                                                                      'No Quiz',
                                                                      'This activity has no quiz yet',
                                                                      snackPosition:
                                                                          SnackPosition
                                                                              .BOTTOM,
                                                                    );
                                                                    return;
                                                                  }

                                                                  final activities =
                                                                      controller
                                                                          .tourActivitiesByTourId[tourId] ??
                                                                      const <
                                                                        Map<
                                                                          String,
                                                                          dynamic
                                                                        >
                                                                      >[];
                                                                  final idx = activities.indexWhere(
                                                                    (a) =>
                                                                        (a['activityId'] ??
                                                                                '')
                                                                            .toString() ==
                                                                        activityId,
                                                                  );
                                                                  if (idx >=
                                                                      0) {
                                                                    controller
                                                                        .setSelectedActivityIndexForTour(
                                                                          tourId,
                                                                          idx,
                                                                        );
                                                                  }

                                                                  showDialog<
                                                                    void
                                                                  >(
                                                                    context:
                                                                        context,
                                                                    barrierDismissible:
                                                                        false,
                                                                    builder: (_) => _QuizDialog(
                                                                      packageId:
                                                                          tourId,
                                                                      activityId:
                                                                          activityId,
                                                                      photoChallengeEnabled:
                                                                          (m['photoChallengeEnabled']
                                                                              as bool?) ??
                                                                          false,
                                                                      photoChallengeText:
                                                                          (m['photoChallengeText']
                                                                              as String?) ??
                                                                          '',
                                                                      title:
                                                                          quizTitle,
                                                                      question:
                                                                          question,
                                                                      options:
                                                                          options,
                                                                      onSubmit:
                                                                          (
                                                                            selectedAnswer,
                                                                          ) async {
                                                                            final service =
                                                                                Get.find<
                                                                                  GamificationService
                                                                                >();
                                                                            final result = await service.submitQuizAnswer(
                                                                              packageId: tourId,
                                                                              activityId: activityId,
                                                                              answer: selectedAnswer,
                                                                            );

                                                                            await controller.loadCurrentTours();
                                                                            return result;
                                                                          },
                                                                    ),
                                                                  );
                                                                },
                                                                child: _MapMarker(
                                                                  label:
                                                                      (m['title']
                                                                          as String),
                                                                  isCompleted:
                                                                      (m['isCompleted']
                                                                          as bool?) ??
                                                                      false,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                          SizedBox(height: 16.h),
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(16.w),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF4F6F7),
                                              borderRadius:
                                                  BorderRadius.circular(16.r),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tour Activities',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(height: 6.h),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Complete each activity to earn points and unlock rewards!',
                                                        style:
                                                            GoogleFonts.inter(
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  const Color(
                                                                    0xFF6B6B6B,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    Text(
                                                      '$completedActivities/$totalActivities completed',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: const Color(
                                                          0xFF00A86B,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10.h),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                  child: LinearProgressIndicator(
                                                    value: totalActivities == 0
                                                        ? 0
                                                        : (completedActivities /
                                                                  totalActivities)
                                                              .clamp(0.0, 1.0),
                                                    minHeight: 8.h,
                                                    backgroundColor:
                                                        const Color(0xFFE2E8E4),
                                                    valueColor:
                                                        const AlwaysStoppedAnimation(
                                                          Color(0xFF00A86B),
                                                        ),
                                                  ),
                                                ),
                                                SizedBox(height: 16.h),
                                                Obx(() {
                                                  final mapController =
                                                      controller
                                                          .mapControllerForTour(
                                                            tourId,
                                                          );
                                                  final activities =
                                                      controller
                                                          .tourActivitiesByTourId[tourId] ??
                                                      const <
                                                        Map<String, dynamic>
                                                      >[];
                                                  if (activities.isEmpty) {
                                                    return const SizedBox();
                                                  }

                                                  final selectedIndex =
                                                      controller
                                                          .selectedActivityIndexByTourId[tourId] ??
                                                      controller
                                                          .selectedActivityIndex
                                                          .value;

                                                  return _TourActivitiesTimeline(
                                                    selectedIndex:
                                                        selectedIndex,
                                                    activities: activities,
                                                    onSelect: (index, a) {
                                                      controller
                                                          .setSelectedActivityIndexForTour(
                                                            tourId,
                                                            index,
                                                          );

                                                      final lat =
                                                          (a['latitude']
                                                                  as num?)
                                                              ?.toDouble();
                                                      final lng =
                                                          (a['longitude']
                                                                  as num?)
                                                              ?.toDouble();
                                                      if (lat != null &&
                                                          lng != null) {
                                                        mapController.move(
                                                          LatLng(lat, lng),
                                                          14,
                                                        );
                                                      }
                                                    },
                                                    onOpenQuiz: (a) {
                                                      controller
                                                              .activeTourId
                                                              .value =
                                                          tourId;
                                                      final activityId =
                                                          (a['activityId'] ??
                                                                  '')
                                                              .toString();
                                                      final activityTitle =
                                                          (a['title'] ?? '')
                                                              .toString();
                                                      final question =
                                                          (a['question'] ?? '')
                                                              .toString();
                                                      final options =
                                                          (a['options']
                                                                  as List?)
                                                              ?.map(
                                                                (e) => e
                                                                    .toString(),
                                                              )
                                                              .toList() ??
                                                          <String>[];

                                                      if (activityId.isEmpty ||
                                                          question
                                                              .trim()
                                                              .isEmpty ||
                                                          options.isEmpty) {
                                                        return;
                                                      }

                                                      showDialog<void>(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (_) => _QuizDialog(
                                                          packageId: tourId,
                                                          activityId:
                                                              activityId,
                                                          photoChallengeEnabled:
                                                              (a['photoChallengeEnabled']
                                                                  as bool?) ??
                                                              false,
                                                          photoChallengeText:
                                                              (a['photoChallengeText']
                                                                  as String?) ??
                                                              '',
                                                          title: activityTitle,
                                                          question: question,
                                                          options: options,
                                                          onSubmit: (selectedAnswer) async {
                                                            final service =
                                                                Get.find<
                                                                  GamificationService
                                                                >();
                                                            final result = await service
                                                                .submitQuizAnswer(
                                                                  packageId:
                                                                      tourId,
                                                                  activityId:
                                                                      activityId,
                                                                  answer:
                                                                      selectedAnswer,
                                                                );

                                                            await controller
                                                                .loadCurrentTours();
                                                            return result;
                                                          },
                                                        ),
                                                      );
                                                    },
                                                  );
                                                }),
                                                SizedBox(height: 16.h),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12.h,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16.r,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.06),
                                                        blurRadius: 16,
                                                        offset: const Offset(
                                                          0,
                                                          8,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '$completedActivities',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color:
                                                                    const Color(
                                                                      0xFF00A86B,
                                                                    ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4.h,
                                                            ),
                                                            Text(
                                                              'Completed',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 12.sp,
                                                                color:
                                                                    const Color(
                                                                      0xFF6B6B6B,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: 34.h,
                                                        color: const Color(
                                                          0xFFE0E0E0,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '${(totalActivities - completedActivities).clamp(0, totalActivities)}',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color:
                                                                    const Color(
                                                                      0xFFFF9800,
                                                                    ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4.h,
                                                            ),
                                                            Text(
                                                              'Remaining',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 12.sp,
                                                                color:
                                                                    const Color(
                                                                      0xFF6B6B6B,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 1,
                                                        height: 34.h,
                                                        color: const Color(
                                                          0xFFE0E0E0,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '$pointsEarned',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 18.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color:
                                                                    const Color(
                                                                      0xFF1976D2,
                                                                    ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 4.h,
                                                            ),
                                                            Text(
                                                              'Points Earned',
                                                              style: GoogleFonts.inter(
                                                                fontSize: 12.sp,
                                                                color:
                                                                    const Color(
                                                                      0xFF6B6B6B,
                                                                    ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 16.h),
                                                Obx(() {
                                                  final ended =
                                                      controller
                                                          .tourEndedByTourId[tourId] ??
                                                      false;
                                                  if (!ended) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Container(
                                                    width: double.infinity,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: 12.h,
                                                          horizontal: 14.w,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFFFE0E0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14.r,
                                                          ),
                                                      border: Border.all(
                                                        color: const Color(
                                                          0xFFD32F2F,
                                                        ),
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.stop_circle,
                                                          color: const Color(
                                                            0xFFD32F2F,
                                                          ),
                                                          size: 18.sp,
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Expanded(
                                                          child: Text(
                                                            'This tour has ended by the guide',
                                                            style: GoogleFonts.inter(
                                                              color:
                                                                  const Color(
                                                                    0xFFD32F2F,
                                                                  ),
                                                              fontSize: 12.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                                Obx(() {
                                                  final ended =
                                                      controller
                                                          .tourEndedByTourId[tourId] ??
                                                      false;
                                                  final rated =
                                                      controller
                                                          .ratedByTourId[tourId] ??
                                                      false;
                                                  if (!ended || rated) {
                                                    return const SizedBox.shrink();
                                                  }

                                                  return Column(
                                                    children: [
                                                      SizedBox(height: 12.h),
                                                      SizedBox(
                                                        width: double.infinity,
                                                        height: 46.h,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF00A86B,
                                                                ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    14.r,
                                                                  ),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            await Get.dialog<
                                                              void
                                                            >(
                                                              _RateTourDialog(
                                                                tourId: tourId,
                                                              ),
                                                              barrierDismissible:
                                                                  true,
                                                            );
                                                          },
                                                          child: Text(
                                                            'Rate Tour',
                                                            style:
                                                                GoogleFonts.inter(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14.sp,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }),
                                                SizedBox(height: 8.h),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                });
                              }).toList(),
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recommended For You',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Obx(() {
                            if (controller.recommendedTours.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              children: controller.recommendedTours.map((tour) {
                                return Container(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.explore,
                                        color: const Color(0xFF00A86B),
                                        size: 24.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tour['tourTitle'] ?? '',
                                              style: GoogleFonts.inter(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              tour['destination'] ?? '',
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                color: const Color(0xFF666666),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${tour['price']} SAR',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            );
                          }),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const TouristBottomNavigationBar(),
          ],
        ),
      ),
    );
  }
}

class _QuizWrongDialog extends StatelessWidget {
  const _QuizWrongDialog({required this.pointsEarned});

  final int pointsEarned;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incorrect answer',
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Better luck next time! You still earned +$pointsEarned points for participating—keep trying!',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoChallengeDialog extends StatefulWidget {
  const _PhotoChallengeDialog({
    required this.packageId,
    required this.activityId,
    required this.title,
    required this.challengeText,
  });

  final String packageId;
  final String activityId;
  final String title;
  final String challengeText;

  @override
  State<_PhotoChallengeDialog> createState() => _PhotoChallengeDialogState();
}

class _PhotoChallengeDialogState extends State<_PhotoChallengeDialog> {
  XFile? _photo;
  bool _isSubmitting = false;

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _photo = picked);
  }

  Future<void> _chooseSource() async {
    await Get.bottomSheet<void>(
      SafeArea(
        child: Container(
          color: Colors.white,
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () async {
                  Get.back();
                  await _pick(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () async {
                  Get.back();
                  await _pick(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _photo != null && !_isSubmitting;

    final homeController = Get.isRegistered<TouristHomeController>()
        ? Get.find<TouristHomeController>()
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 360.w,
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 18.sp,
                      color: const Color(0xFF00A86B),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
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
              SizedBox(height: 18.h),
              Text(
                widget.challengeText.trim().isEmpty
                    ? 'Take a photo for this challenge'
                    : widget.challengeText,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 14.h),
              InkWell(
                onTap: _isSubmitting ? null : _chooseSource,
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  width: double.infinity,
                  height: 170.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1.5,
                    ),
                  ),
                  child: _photo == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                size: 22.sp,
                                color: const Color(0xFF7A7A7A),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Take a photo',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Use your camera',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: Image.file(
                            File(_photo!.path),
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                                setState(() => _isSubmitting = true);
                                try {
                                  final service =
                                      Get.find<GamificationService>();
                                  final result = await service
                                      .submitPhotoChallenge(
                                        packageId: widget.packageId,
                                        activityId: widget.activityId,
                                        photo: _photo!,
                                      );

                                  if (!mounted) return;

                                  if (result.alreadyCompleted) {
                                    Get.snackbar(
                                      'Already Completed',
                                      'You already completed this challenge',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    Get.back<void>();
                                    return;
                                  }

                                  final earned = result.pointsEarned;
                                  Get.back<void>();

                                  if (homeController != null) {
                                    await homeController.loadCurrentTours();
                                    final activeTourId =
                                        homeController.activeTourId.value;
                                    if (activeTourId.isNotEmpty) {
                                      await homeController.loadTourActivities(
                                        activeTourId,
                                      );
                                    }
                                  }

                                  if (earned > 0) {
                                    Get.snackbar(
                                      'Challenge completed',
                                      'Points earned: $earned',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  Get.snackbar(
                                    'Error',
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7BC6A4),
                          disabledBackgroundColor: const Color(0xFFE6E6E6),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: const Color(0xFF9E9E9E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Submit Answer',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizSuccessDialog extends StatelessWidget {
  const _QuizSuccessDialog({required this.pointsEarned});

  final int pointsEarned;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nice! That\'s correct.',
                        style: GoogleFonts.inter(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '+$pointsEarned points | Ready for the next challenge?',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TourActivitiesTimeline extends StatelessWidget {
  const _TourActivitiesTimeline({
    required this.selectedIndex,
    required this.activities,
    required this.onSelect,
    required this.onOpenQuiz,
  });

  final int selectedIndex;
  final List<Map<String, dynamic>> activities;
  final void Function(int index, Map<String, dynamic> activity) onSelect;
  final void Function(Map<String, dynamic> activity) onOpenQuiz;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox();
    final clampedIndex = selectedIndex.clamp(0, activities.length - 1);

    return Column(
      children: [
        SizedBox(
          height: 54.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 20.w,
                right: 20.w,
                child: Container(height: 2.h, color: const Color(0xFFD6D6D6)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(activities.length, (i) {
                  final isActive = i == clampedIndex;
                  final isCompleted =
                      (activities[i]['isCompleted'] as bool?) ?? false;
                  return Container(
                    width: 46.w,
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFF00A86B)
                          : (isActive ? const Color(0xFFFFB74D) : Colors.white),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? const Color(0xFF00A86B)
                            : (isActive
                                  ? const Color(0xFFFFB74D)
                                  : const Color(0xFFD6D6D6)),
                        width: 3,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, size: 22.sp, color: Colors.white)
                        : (isActive
                              ? Icon(
                                  Icons.location_on,
                                  size: 22.sp,
                                  color: Colors.white,
                                )
                              : const SizedBox.shrink()),
                  );
                }),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 58.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            itemBuilder: (context, i) {
              final isActive = i == clampedIndex;
              final title = (activities[i]['title'] ?? '').toString();
              final canStartQuiz =
                  (activities[i]['activityId'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty &&
                  (activities[i]['question'] ?? '')
                      .toString()
                      .trim()
                      .isNotEmpty &&
                  ((activities[i]['options'] as List?)?.isNotEmpty ?? false);

              return SizedBox(
                width: 110.w,
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        onSelect(i, activities[i]);
                        if (canStartQuiz) {
                          onOpenQuiz(activities[i]);
                        } else {
                          Get.snackbar(
                            'No Quiz',
                            'This activity has no quiz yet',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFFB85B00)
                              : const Color(0xFF6B6B6B),
                        ),
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(height: 6.h),
                      InkWell(
                        onTap: canStartQuiz
                            ? () => onOpenQuiz(activities[i])
                            : null,
                        child: Text(
                          'Start Now',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: canStartQuiz
                                ? const Color(0xFFB85B00)
                                : const Color(0xFFBDBDBD),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            separatorBuilder: (context, _) => SizedBox(width: 4.w),
            itemCount: activities.length,
          ),
        ),
      ],
    );
  }
}

class _QuizDialog extends StatefulWidget {
  const _QuizDialog({
    required this.packageId,
    required this.activityId,
    required this.photoChallengeEnabled,
    required this.photoChallengeText,
    required this.title,
    required this.question,
    required this.options,
    required this.onSubmit,
  });

  final String packageId;
  final String activityId;
  final bool photoChallengeEnabled;
  final String photoChallengeText;
  final String title;
  final String question;
  final List<String> options;
  final Future<SubmitQuizAnswerResult> Function(String selectedAnswer) onSubmit;

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  int? _selectedIndex;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selectedIndex != null && !_isSubmitting;

    final homeController = Get.isRegistered<TouristHomeController>()
        ? Get.find<TouristHomeController>()
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 360.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      size: 18.sp,
                      color: const Color(0xFF00A86B),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
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
              SizedBox(height: 18.h),
              Text(
                widget.question,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: List.generate(widget.options.length, (i) {
                      final isSelected = _selectedIndex == i;
                      return InkWell(
                        onTap: _isSubmitting
                            ? null
                            : () => setState(() => _selectedIndex = i),
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 48.h),
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00A86B)
                                  : const Color(0xFFE6E6E6),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.options[i],
                            softWrap: true,
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          backgroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: canSubmit
                            ? () async {
                                setState(() => _isSubmitting = true);
                                try {
                                  final selectedAnswer =
                                      widget.options[_selectedIndex!];
                                  final result = await widget.onSubmit(
                                    selectedAnswer,
                                  );

                                  if (!context.mounted) return;

                                  if (result.alreadyAnswered) {
                                    Get.snackbar(
                                      'Already Answered',
                                      'You already answered this quiz',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );

                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                    return;
                                  }

                                  final userId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  final earned = result.pointsEarned;
                                  final isCorrect = result.isCorrect;

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .update({
                                        'quizCount': FieldValue.increment(1),
                                      });

                                  /// check badges
                                  final newBadges =
                                      await Get.find<GamificationService>()
                                          .checkAndUnlockBadges();

                                  if (homeController != null) {
                                    await homeController.loadCurrentTours(
                                      showCompletionSnackbars: false,
                                    );
                                    final activeTourId =
                                        homeController.activeTourId.value;
                                    if (activeTourId.isNotEmpty) {
                                      await homeController.loadTourActivities(
                                        activeTourId,
                                        showCompletionSnackbars: false,
                                      );
                                    }
                                  }

                                  Navigator.of(context).pop();

                                  if (isCorrect) {
                                    await Get.dialog(
                                      _QuizSuccessDialog(pointsEarned: earned),
                                    );
                                  } else {
                                    await Get.dialog(
                                      _QuizWrongDialog(pointsEarned: earned),
                                    );
                                  }

                                  if (newBadges.contains('quiz_starter')) {
                                    Get.snackbar(
                                      '🎉 New Badge!',
                                      'You unlocked Quiz Starter!',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                } catch (e) {
                                  if (!context.mounted) return;
                                  Get.snackbar(
                                    'Error',
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7BC6A4),
                          disabledBackgroundColor: const Color(0xFFE6E6E6),
                          foregroundColor: Colors.white,
                          disabledForegroundColor: const Color(0xFF9E9E9E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: 18.w,
                                height: 18.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Submit Answer',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatePromptListener extends StatelessWidget {
  const _RatePromptListener({required this.controller});

  final TouristHomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tourId = controller.ratePromptTourId.value;
      if (tourId == null || tourId.trim().isEmpty) {
        return const SizedBox.shrink();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final pending = controller.ratePromptTourId.value;
        if (pending == null || pending != tourId) return;
        controller.ratePromptTourId.value = null;

        await Future<void>.delayed(const Duration(seconds: 2));

        await Get.dialog<void>(
          _RateTourDialog(tourId: tourId),
          barrierDismissible: true,
        );
      });

      return const SizedBox.shrink();
    });
  }
}

class _RateTourDialog extends StatefulWidget {
  const _RateTourDialog({required this.tourId});

  final String tourId;

  @override
  State<_RateTourDialog> createState() => _RateTourDialogState();
}

class _RateTourDialogState extends State<_RateTourDialog> {
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
                            Get.snackbar(
                              'Thanks!',
                              'Rating submitted (+5 points)',
                              snackPosition: SnackPosition.BOTTOM,
                            );
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

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.label, required this.isCompleted});

  final String label;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final pinColor = isCompleted
        ? const Color(0xFF00A86B)
        : const Color(0xFFFFB74D);
    final chipColor = isCompleted
        ? const Color(0xFFE9F7F1)
        : const Color(0xFFFFF3E0);
    final chipTextColor = isCompleted
        ? const Color(0xFF0B6B48)
        : const Color(0xFF8D4B00);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34.w,
          height: 34.h,
          decoration: BoxDecoration(
            color: pinColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isCompleted ? Icons.check : Icons.place,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: chipTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
