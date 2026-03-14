import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tour_app/view/main/tour_guide/packages/controllers/create_package_controller.dart';

class CreatePackageView extends StatelessWidget {
  final String? packageId;

  const CreatePackageView({super.key, this.packageId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatePackageController(packageId: packageId));

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
                      Obx(
                        () => _buildDropdownField(
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
                        ),
                      ),
                      SizedBox(height: 20.h),
                       Obx(
                        () => _buildDropdownField(
                          label: 'Region *',
                          hintText: 'Select region',
                          value: controller.selectedRegion.value.isEmpty
                              ? null
                              : controller.selectedRegion.value,
                          items: controller.regions,
                          onChanged: (value) {
                            if (value != null) {
                              controller.setRegion(value);
                            }
                          },
                        ),
                      ),
                       SizedBox(height: 20.h),
                      Obx(
                        () => _buildDropdownField(
                          label: 'Activity Type *',
                          hintText: 'Select activity type',
                          value: controller.selectedActivityType.value.isEmpty
                              ? null
                              : controller.selectedActivityType.value,
                          items: controller.activityTypes,
                          onChanged: (value) {
                            if (value != null) {
                              controller.setActivityType(value);
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Text(
                            'Duration *',
                            style: GoogleFonts.inter(
                              color: Colors.black,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Obx(
                              () => TextField(
                                controller: TextEditingController(
                                  text: controller.durationValue.value,
                                ),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '3',
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
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                                onChanged: (value) =>
                                    controller.setDurationValue(value),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 3,
                            child: Obx(
                              () => Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: controller.durationUnit.value,
                                    isExpanded: true,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    items: controller.durationUnits
                                        .map(
                                          (unit) => DropdownMenuItem(
                                            value: unit,
                                            child: Text(
                                              unit,
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
                                        controller.setDurationUnit(value);
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
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Obx(
                        () => _buildTextField(
                          label: 'Price (SAR) *',
                          hintText: '500',
                          controller: TextEditingController(
                            text: controller.price.value,
                          ),
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: const Color(0xFF666666),
                            size: 20.sp,
                          ),
                          onChanged: (value) => controller.setPrice(value),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Obx(
                        () => _buildTextField(
                          label: 'Max Group Size *',
                          hintText: '15',
                          controller: TextEditingController(
                            text: controller.maxGroupSize.value,
                          ),
                          keyboardType: TextInputType.number,
                          prefixIcon: Icon(
                            Icons.people,
                            color: const Color(0xFF666666),
                            size: 20.sp,
                          ),
                          onChanged: (value) =>
                              controller.setMaxGroupSize(value),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Obx(
                        () => _buildTextField(
                          label: 'Available Dates',
                          hintText: 'Select dates',
                          controller: TextEditingController(
                            text: controller.selectedDates.value,
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: const Color(0xFF666666),
                            size: 20.sp,
                          ),
                          readOnly: true,
                          onTap: () {
                            controller.selectDates(context);
                          },
                          onChanged: (value) {
                            controller.setSelectedDates(value);
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Tour Description *',
                        style: GoogleFonts.inter(
                          color: Colors.black,
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
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            decoration: InputDecoration(
                              hintText:
                                  'Describe what makes your tour special...',
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
                              contentPadding: EdgeInsets.all(16.w),
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                            onChanged: (value) =>
                                controller.setTourDescription(value),
                          ),
                        ),
                      
                      SizedBox(height: 32.h),
                      // Tour Activities & Gamification Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Tour Activities & Gamification',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  GestureDetector(
                                    onTap: controller.addActivity,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00A86B),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20.sp,
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Add Activity',
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Add activities that will appear as pins on the interactive map with questions for tourists.',
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF666666),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          // Activities List
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
                      Obx(
                        () => Container(
                          width: double.infinity,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: controller.isLoading.value
                                ? const Color(0xFFCCCCCC)
                                : const Color(0xFF00A86B),
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: controller.isLoading.value
                                  ? null
                                  : controller.publishPackage,
                              borderRadius: BorderRadius.circular(30.r),
                              child: Center(
                                child: controller.isLoading.value
                                    ? SizedBox(
                                        width: 24.w,
                                        height: 24.h,
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        packageId == null
                                            ? 'Publish Tour Package'
                                            : 'Update Tour Package',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
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
          _buildTextField(
            label: 'Activity Name',
            hintText: 'e.g., Elephant Rock',
            controller: TextEditingController(text: activity.activityName),
            onChanged: (value) => controller.updateActivityName(index, value),
          ),
          SizedBox(height: 16.h),

          // Position Fields
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'X Position (%)',
                  hintText: '50',
                  controller: TextEditingController(text: activity.xPosition),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.updateActivityXPosition(index, value),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  label: 'Y Position (%)',
                  hintText: '50',
                  controller: TextEditingController(text: activity.yPosition),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.updateActivityYPosition(index, value),
                ),
              ),
            ],
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
          Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: TextEditingController(text: activity.question),
              maxLines: 3,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              decoration: InputDecoration(
                hintText: 'Enter the question tourists will answer...',
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
                contentPadding: EdgeInsets.all(16.w),
              ),
              style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.black),
              onChanged: (value) =>
                  controller.updateActivityQuestion(index, value),
            ),
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
              child: _buildTextField(
                label: questionType == 'True/False'
                    ? (optionIndex == 0 ? 'True' : 'False')
                    : 'Option ${optionIndex + 1}',
                hintText: questionType == 'True/False'
                    ? (optionIndex == 0 ? 'True' : 'False')
                    : 'Option ${optionIndex + 1}',
                controller: TextEditingController(
                  text: optionIndex <
                          currentActivity.answerOptions.length
                      ? currentActivity.answerOptions[optionIndex]
                      : '',
                ),
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
