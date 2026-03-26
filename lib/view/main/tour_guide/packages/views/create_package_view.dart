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

      /// 🟢 STEP 1 (General Info)
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

      /// 🟡 STEP 2 (Booking)

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
    ],
  );
}

else {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// 🔵 STEP 3 (Activities + Publish)

      SizedBox(height: 24.h),

      /// Activities Section (نفس كودك)
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tour Activities & Gamification',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: controller.addActivity,
                child: Text("Add Activity"),
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
          _buildInitialValueTextField(
            label: 'Activity Name',
            hintText: 'e.g., Elephant Rock',
            initialValue: activity.activityName,
            onChanged: (value) => controller.updateActivityName(index, value),
          ),_buildDropdownField(
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

          // Position Fields
          Row(
            children: [
              Expanded(
                child: _buildInitialValueTextField(
                  label: 'X Position (%)',
                  hintText: '50',
                  initialValue: activity.xPosition,
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                      controller.updateActivityXPosition(index, value),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildInitialValueTextField(
                  label: 'Y Position (%)',
                  hintText: '50',
                  initialValue: activity.yPosition,
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