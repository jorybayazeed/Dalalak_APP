import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:tour_app/services/weather_service.dart';
import 'package:tour_app/view/main/tour_guide/packages/controllers/create_package_controller.dart';

class CreatePackageView extends StatelessWidget {
  final String? packageId;

  const CreatePackageView({super.key, this.packageId});
  
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePackageController(packageId: packageId));
    final RxInt currentStep = 0.obs;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Back',
                          style: GoogleFonts.inter(
                            color: Colors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            _stepItem("Info", 0, currentStep.value),
            _stepItem("Booking", 1, currentStep.value),
            _stepItem("Activities", 2, currentStep.value),
            ],
             )
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 18.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packageId == null
                            ? 'Add a New Tour Package'
                            : 'Edit Tour Package',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Fill in the details and add interactive activities with gamification',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF666666),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    Obx(() {
                     if (currentStep.value == 0) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// STEP 1 (General Info)
      SizedBox(height: 24.h),

      Directionality(
        textDirection: TextDirection.ltr,
        child: _buildTextField(
          label: 'Tour Title *',
          hintText: 'e.g., Historical AlUla Adventure',
          controller: controller.tourTitleController,
          onChanged: (value) {
            controller.tourTitle.value = value;
          },
        ),
      ),

      SizedBox(height: 20.h),

      Obx(() => _buildDropdownField(
            label: 'Destination *',
            hintText: 'Select destination',
            value: controller.selectedDestination.value.isEmpty
                ? null
                : controller.selectedDestination.value,
            items: controller.destinations,
            onChanged: (value) {
              if (value != null) {
                controller.setDestination(value);
              }
            },
          )),

      SizedBox(height: 20.h),

      Text(
        'Tour Description *',
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),

      SizedBox(height: 8.h),

      Directionality(
        textDirection: TextDirection.ltr,
        child: TextField(
          controller: controller.tourDescriptionController,
          maxLines: 5,
          onChanged: (value) =>
              controller.setTourDescription(value),
        ),
      ),
    ],
  );
}

else if (currentStep.value == 1) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// STEP 2 (Booking)

      SizedBox(height: 24.h),

      Text('Duration *'),
      SizedBox(height: 8.h),

      Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.durationValueController,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  controller.setDurationValue(value),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(() => DropdownButton<String>(
                  value: controller.durationUnit.value,
                  items: controller.durationUnits
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      controller.setDurationUnit(v);
                    }
                  },
                )),
          ),
        ],
      ),

      SizedBox(height: 20.h),

      _buildTextField(
        label: 'Price (SAR) *',
        hintText: '500',
        controller: controller.priceController,
        onChanged: controller.setPrice,
      ),

      SizedBox(height: 20.h),

      _buildTextField(
        label: 'Max Group Size *',
        hintText: '15',
        controller: controller.maxGroupSizeController,
        onChanged: controller.setMaxGroupSize,
      ),

      SizedBox(height: 20.h),

      _buildTextField(
        label: 'Available Dates',
        hintText: 'Select dates',
        controller: controller.selectedDatesController,
        readOnly: true,
        onTap: () => controller.selectDates(context),
        onChanged: controller.setSelectedDates,
      ),

      SizedBox(height: 20.h),

      _buildTextField(
        label: 'Start Time *',
        hintText: 'Select start time',
        controller: controller.startTimeController,
        readOnly: true,
        onTap: () => controller.selectStartTime(context),
        onChanged: controller.setStartTime,
      ),

      SizedBox(height: 20.h),

      Obx(() {
        if (controller.isWeatherLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final weather = controller.weatherAssessment.value;
        if (weather == null) {
          return const SizedBox.shrink();
        }

        return _buildWeatherSuggestionCard(
          weather: weather,
          onUseEveningTime: controller.setSuggestedEveningTime,
          onAutoApplyBestDateTime: controller.autoApplyBestDateAndTime,
          onApplyAlternativeLocation: controller.applyAlternativeLocationOnMap,
        );
      }),
    ],
  );
}

else {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Activities + Publish

      SizedBox(height: 24.h),

      /// STEP 3 (Activities Section)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tour Activities & Gamification',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 16.w,
            runSpacing: 8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: controller.addActivity,
                child: Text(
                  'Add Activity',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF00A86B),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Obx(() {
            if (controller.activities.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: List.generate(
                controller.activities.length,
                (index) => _buildActivityCard(
                  context,
                  controller,
                  index,
                ),
              ),
            );
          }),
        ],
      ),

      SizedBox(height: 32.h),
    ],
  );
}
}),
SizedBox(height: 24.h),  
Obx(() => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
 children: [

  /// Back 
  if (currentStep.value > 0)
    ElevatedButton(
      onPressed: () {
        currentStep.value--;
      },
      child: Text("Back"),
    )
  else
    SizedBox(), 

  /// Next / Publish 
  ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: currentStep.value == 2
          ? const Color(0xFF00A86B)
          : null,
    ),
    onPressed: () {
      if (currentStep.value < 2) {
        currentStep.value++;
      } else {
        controller.publishPackage();
      }
    },
    child: Text(
      currentStep.value == 2 ? "Publish" : "Next",
    ),
  ),
], 
)),
                      
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF999999),
              fontSize: 16.sp,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: prefixIcon != null ? 12.w : 16.w,
              vertical: 16.h,
            ),
            prefixIcon: prefixIcon != null
                ? Padding(padding: EdgeInsets.all(12.w), child: prefixIcon)
                : null,
          ),
          style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.black),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInitialValueTextField({
    required String label,
    required String hintText,
    required String initialValue,
    TextInputType? keyboardType,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (label.isNotEmpty) SizedBox(height: 8.h),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF999999),
              fontSize: 16.sp,
            ),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
          style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.black),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildWeatherSuggestionCard({
    required SmartWeatherAssessment weather,
    required VoidCallback onUseEveningTime,
    required VoidCallback onAutoApplyBestDateTime,
    required VoidCallback onApplyAlternativeLocation,
  }) {
    final trip = weather.tripForecast;
    final recommendation = weather.tripRecommendation;
    final guide = weather.guideSuggestion;
    final alternative = weather.alternativeLocation;

    Color bg;
    Color border;
    IconData icon;

    switch (recommendation.level) {
      case WeatherRiskLevel.normal:
        bg = const Color(0xFFEAF7EE);
        border = const Color(0xFF9AD3AE);
        icon = Icons.check_circle_outline;
        break;
      case WeatherRiskLevel.caution:
        bg = const Color(0xFFFFF6E5);
        border = const Color(0xFFF5C77D);
        icon = Icons.tips_and_updates_outlined;
        break;
      case WeatherRiskLevel.warning:
        bg = const Color(0xFFFFF1E8);
        border = const Color(0xFFFFB27D);
        icon = Icons.warning_amber_rounded;
        break;
      case WeatherRiskLevel.danger:
        bg = const Color(0xFFFFECEC);
        border = const Color(0xFFE38D8D);
        icon = Icons.gpp_bad_outlined;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: border),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (trip != null)
            Text(
              'Forecast: ${trip.temperatureC.toStringAsFixed(0)}°C • Humidity ${trip.humidity}% • Rain ${trip.precipitationProbability}% • Wind ${trip.windSpeedKmH.toStringAsFixed(0)} km/h',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
          SizedBox(height: 8.h),
          Text(
            recommendation.message,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF4A4A4A),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.65),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: border.withOpacity(0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guide Suggestion State: ${guide.state}',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  guide.summary,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Suggested Start Time: ${guide.suggestedStartTime}',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3A3A3A),
                  ),
                ),
              ],
            ),
          ),
          if (guide.suggestedDates.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              'Best Dates For Activity Type',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: guide.suggestedDates.map((d) {
                final label =
                    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                return ActionChip(
                  label: Text(label),
                  onPressed: () {
                    final c = Get.find<CreatePackageController>();
                    c.applySuggestedDate(d);
                  },
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onAutoApplyBestDateTime,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto-Apply Best Date + Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A7C5B),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          if (alternative != null &&
              (recommendation.level == WeatherRiskLevel.warning ||
                  recommendation.level == WeatherRiskLevel.danger)) ...[
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFF1565C0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alternative Map Location: ${alternative.city}',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0D47A1),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    alternative.reason,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xFF444444),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  OutlinedButton.icon(
                    onPressed: onApplyAlternativeLocation,
                    icon: const Icon(Icons.place_outlined),
                    label: const Text('Use Alternative Location on Map'),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),
          ...recommendation.tips.map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Text(
                '• $tip',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ...guide.tips.map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Text(
                '• $tip',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (recommendation.suggestReschedule) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onUseEveningTime,
                icon: const Icon(Icons.schedule),
                label: const Text('Use suggested time: 6:00 PM'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hintText,
                style: GoogleFonts.inter(
                  color: const Color(0xFF999999),
                  fontSize: 16.sp,
                ),
              ),
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 24.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
  BuildContext context,
  CreatePackageController controller,
  int index,
) {
  return Obx(() {
    if (index >= controller.activities.length) {
      return const SizedBox.shrink();
    }
    final activity = controller.activities[index];
    final mapController = MapController();
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF00A86B).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A86B).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity ${index + 1}',
                style: GoogleFonts.inter(
                  color: const Color(0xFF00A86B),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => controller.removeActivity(index),
                child: Icon(Icons.delete, color: Colors.red, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Activity Name
          _buildInitialValueTextField(
            label: 'Activity Name',
            hintText: 'e.g., Elephant Rock',
            initialValue: activity.activityName,
            onChanged: (value) => controller.updateActivityName(index, value),
          ),
          SizedBox(height: 12.h),

          // Activity Place
          _buildInitialValueTextField(
            label: 'Activity Place',
            hintText: 'e.g., Al Shati, Jeddah 23613',
            initialValue: activity.activityPlace,
            onChanged: (value) => controller.updateActivityPlace(index, value),
          ),

          SizedBox(height: 12.h),

          _buildDropdownField(
            label: 'Activity Type',
            hintText: 'Select activity type',
            value: activity.activityType.isEmpty ? null : activity.activityType,
            items: controller.activityTypes,
            onChanged: (value) {
            if (value != null) {
            controller.updateActivityType(index, value);
    }
  },
),    
          // Position Fields

          SizedBox(height: 16.h),

          Obx(
            () {
              if (index >= controller.activities.length) {
                return const SizedBox.shrink();
              }

              final currentActivity = controller.activities[index];
              final isMapExpanded = controller.expandedActivityMapIds
                  .contains(currentActivity.id);

              LatLng? selectedPoint;
              if (currentActivity.latitude != null &&
                  currentActivity.longitude != null) {
                selectedPoint =
                    LatLng(currentActivity.latitude!, currentActivity.longitude!);
              }

              final preferredCenter = controller.getPreferredMapCenter(
                selectedPoint: selectedPoint,
              );
              final preferredZoom = controller.getPreferredMapZoom(
                selectedPoint: selectedPoint,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          controller.toggleActivityMap(currentActivity.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1976D2),
                        side: BorderSide(
                          color: const Color(0xFF1976D2).withOpacity(0.3),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined),
                      label: Text(
                        isMapExpanded ? 'Hide Map' : 'Pick Location on Map',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (isMapExpanded) ...[
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      height: 220.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 10.w,
                              right: 10.w,
                              top: 10.h,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: const Color(0xFF00A86B)
                                        .withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller:
                                            controller.activityPlaceSearchControllerFor(
                                          currentActivity.id,
                                          fallbackText: currentActivity.activityPlace,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Search place...',
                                        ),
                                        style: GoogleFonts.inter(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        textInputAction: TextInputAction.search,
                                        onChanged: (value) {
                                          controller.setActivityPlaceSearchDraft(
                                            activityId: currentActivity.id,
                                            value: value,
                                          );
                                        },
                                        onSubmitted: (value) async {
                                          controller.setActivityPlaceSearchDraft(
                                            activityId: currentActivity.id,
                                            value: value,
                                          );
                                          await controller
                                              .submitActivityPlaceSearch(index);
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await controller
                                            .submitActivityPlaceSearch(index);
                                      },
                                      icon: const Icon(Icons.search),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            FlutterMap(
                              key: ValueKey(
                                '${currentActivity.latitude}_${currentActivity.longitude}_${controller.selectedDestination.value}_${controller.selectedRegion.value}',
                              ),
                              mapController: mapController,
                              options: MapOptions(
                                initialCenter: preferredCenter,
                                initialZoom: preferredZoom,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.all,
                                ),
                                onPositionChanged: (pos, _) {
                                  controller.updateActivityDraftCenter(
                                    activityId: currentActivity.id,
                                    center: pos.center,
                                  );
                                },
                                onTap: (_, point) {
                                  controller.updateActivityLocation(index, point);
                                  mapController.move(point, 14);
                                },
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  userAgentPackageName: 'tour_app',
                                  tileProvider: NetworkTileProvider(
                                    headers: const {
                                      'Accept':
                                          'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                                    },
                                  ),
                                ),
                                if (selectedPoint != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: selectedPoint,
                                        width: 40.w,
                                        height: 40.h,
                                        child: Icon(
                                          Icons.place,
                                          color: Colors.red,
                                          size: 34.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),

                            // Crosshair for precise placement
                            IgnorePointer(
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  size: 26.sp,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ),

                            Positioned(
                              right: 10.w,
                              bottom: 10.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.setActivityMarkerToDraftCenter(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00A86B),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 10.h,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                child: Text(
                                  'Set Marker Here',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      selectedPoint == null
                          ? 'Tap on the map to set this activity location'
                          : 'Selected: ${selectedPoint.latitude.toStringAsFixed(5)}, ${selectedPoint.longitude.toStringAsFixed(5)}',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: const Color(0xFF666666),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          mapController.move(preferredCenter, preferredZoom);
                        });
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: 16.h),

          // Gamification Question
          Text(
            'Gamification Question',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          _buildInitialValueTextField(
            label: '',
            hintText: 'Enter the question tourists will answer...',
            initialValue: activity.question,
            maxLines: 3,
            onChanged: (value) => controller.updateActivityQuestion(index, value),
          ),
          SizedBox(height: 16.h),

          // Question Type Dropdown
          Text(
            'Question Type',
            style: GoogleFonts.inter(
              color: Colors.black,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: activity.questionType,
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                items: controller.questionTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.updateActivityQuestionType(index, value);
                  }
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                  size: 24.sp,
                ),
              ),
            ),
          ),

SizedBox(height: 16.h),

Obx(() {
  final currentActivity = controller.activities[index];
  final questionType = currentActivity.questionType;

  // ===== Short Answer =====
  if (questionType == 'Short Answer') {
    return _buildTextField(
      label: 'Correct Answer',
      hintText: 'Enter correct answer',
      controller: controller.correctAnswerControllers[index],
      onChanged: (value) =>
          controller.updateActivityCorrectAnswer(index, value),
    );
  }

  // ===== Multiple Choice & True/False =====
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Answer Options',
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: 8.h),

      ...List.generate(
        questionType == 'True/False' ? 2 : 4,
        (optionIndex) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<int>(
              value: optionIndex,
              groupValue: currentActivity.correctAnswer.isEmpty
                  ? null
                  : int.tryParse(currentActivity.correctAnswer),
              onChanged: (value) {
                if (value != null) {
                  controller.updateActivityCorrectAnswer(
                    index,
                    value.toString(),
                  );
                }
              },
              activeColor: const Color(0xFF00A86B),
            ),
            Expanded(
              child: _buildInitialValueTextField(
                label: questionType == 'True/False'
                    ? (optionIndex == 0 ? 'True' : 'False')
                    : 'Option ${optionIndex + 1}',
                hintText: questionType == 'True/False'
                    ? (optionIndex == 0 ? 'True' : 'False')
                    : 'Option ${optionIndex + 1}',
                initialValue: optionIndex < currentActivity.answerOptions.length
                    ? currentActivity.answerOptions[optionIndex]
                    : '',
                onChanged: (value) =>
                    controller.updateActivityAnswerOption(
                  index,
                  optionIndex,
                  value,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}),

          ],
        ),
      );
    });
  }
}
Widget _stepItem(String title, int step, int currentStep) {
  return Column(
    children: [
      CircleAvatar(
        radius: 10,
        backgroundColor:
            currentStep >= step ? const Color(0xFF00A86B) : Colors.grey,
      ),
      SizedBox(height: 4.h),
      Text(title, style: TextStyle(fontSize: 12.sp)),
    ],
  );
}