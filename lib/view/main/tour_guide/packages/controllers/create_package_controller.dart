import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/views/dashboard_view.dart';

class TourActivity {
  String id;
  String activityName;
  String xPosition;
  String yPosition;
  String question;
  String questionType;
  List<String> answerOptions;
  String correctAnswer;
  

  
 

  TourActivity({
    required this.id,
    this.activityName = '',
    this.xPosition = '50',
    this.yPosition = '50',
    this.question = '',
    this.questionType = 'Multiple Choice',
    this.answerOptions = const ['', '', '', ''],
    this.correctAnswer = '',
    
  });

  Map<String, dynamic> toMap() {
    return {
      'activityName': activityName,
      'xPosition': xPosition,
      'yPosition': yPosition,
      'question': question,
      'questionType': questionType,
      'answerOptions': answerOptions,
      'correctAnswer': correctAnswer,
      
    };
  }

  factory TourActivity.fromMap(String id, Map<String, dynamic> map) {
    return TourActivity(
      id: id,
      activityName: map['activityName'] as String? ?? '',
      xPosition: map['xPosition'] as String? ?? '50',
      yPosition: map['yPosition'] as String? ?? '50',
      question: map['question'] as String? ?? '',
      questionType: map['questionType'] as String? ?? 'Multiple Choice',
      answerOptions:
          (map['answerOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['', '', '', ''],
      correctAnswer: map['correctAnswer'] ?? '',
      
    );
  }
}

class CreatePackageController extends GetxController {
  final PackagesService _packagesService = Get.find<PackagesService>();

  final RxString tourTitle = ''.obs;
  final RxString selectedDestination = ''.obs;
  final RxString selectedRegion = ''.obs;
  final RxString selectedActivityType = ''.obs;
  final RxString durationValue = '3'.obs;
  final RxString durationUnit = 'Hours'.obs;
  final RxString price = '500'.obs;
  final RxString maxGroupSize = '15'.obs;
  final RxString selectedDates = ''.obs;
  final RxString tourDescription = ''.obs;

  final RxList<TourActivity> activities = <TourActivity>[].obs;
  final List<TextEditingController> correctAnswerControllers = [];
  final RxBool isLoading = false.obs;
  final String? packageId;
  final TextEditingController tourTitleController = TextEditingController();
  final TextEditingController tourDescriptionController = TextEditingController();

  CreatePackageController({this.packageId});

  @override
  void onInit() {
    super.onInit();
    if (packageId != null) {
      _loadPackageData();
    }
  }

   Future<void> _loadPackageData() async {
    if (packageId == null) return;

    try {
      final packageData = await _packagesService.getPackage(packageId!);
      if (packageData != null) {
        tourTitle.value = packageData['tourTitle'] as String? ?? '';
        selectedDestination.value = packageData['destination'] as String? ?? '';
        selectedRegion.value = packageData['region'] as String? ?? '';
        selectedActivityType.value = packageData['activityType'] as String? ?? '';
        durationValue.value = packageData['durationValue'] as String? ?? '3';
        durationUnit.value = packageData['durationUnit'] as String? ?? 'Hours';
        price.value = packageData['price'] as String? ?? '500';
        maxGroupSize.value = packageData['maxGroupSize'] as String? ?? '15';
        selectedDates.value = packageData['availableDates'] as String? ?? '';
        tourDescription.value = packageData['tourDescription'] as String? ?? '';

        if (packageData['activities'] != null) {
          final activitiesList = packageData['activities'] as List<dynamic>?;

          if (activitiesList != null) {
            activities.value =
                activitiesList.asMap().entries.map((entry) {
              final index = entry.key;
              final activityData =
                  entry.value as Map<String, dynamic>;
              return TourActivity.fromMap(
                  'activity_$index', activityData);
            }).toList();

          
            correctAnswerControllers.clear();
            for (var activity in activities) {
              correctAnswerControllers.add(
                TextEditingController(
                    text: activity.correctAnswer),
              );
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load package data');
    }
  }

  final List<String> destinations = [
    'Riyadh',
    'Jeddah',
    'AlUla',
    'Dammam',
    'Abha',
    'Taif',
    'Makkah',
    'Madinah',
  ];

    final List<String> regions = [
    'Riyadh',
    'Jeddah',
    'AlUla',
    'Dammam',
    'Abha',
    'Taif',
    'Makkah',
    'Madinah',
  ];

  final List<String> activityTypes = [
    'Adventure',
    'Cultural Heritage',
    'Nature & Wildlife',
    'Religious',
    'Beach',
    'Entertainment',
    'Historical',
    'Photography',
    'Food & Culinary',
    'Relaxation',
  ];

  final List<String> durationUnits = ['Hours', 'Days'];
  final List<String> questionTypes = [
    'Multiple Choice',
    'True/False',
    'Short Answer',
  ];

  void setDestination(String destination) {
    selectedDestination.value = destination;
  }
  void setRegion(String region) {
    selectedRegion.value = region;
  }

  void setActivityType(String value) {
    selectedActivityType.value = value;
  }

  void setDurationValue(String value) {
    durationValue.value = value;
  }

  void setDurationUnit(String unit) {
    durationUnit.value = unit;
  }

  void setPrice(String value) {
    price.value = value;
  }

  void setMaxGroupSize(String value) {
    maxGroupSize.value = value;
  }

  void setSelectedDates(String dates) {
    selectedDates.value = dates;
  }

  Future<void> selectDates(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _parseDateRange(selectedDates.value),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A86B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final startDate = picked.start;
      final endDate = picked.end;
      final formattedDates =
          '${_formatDate(startDate)} - ${_formatDate(endDate)}';
      selectedDates.value = formattedDates;
    }
  }

  DateTimeRange? _parseDateRange(String dateString) {
    if (dateString.isEmpty) return null;
    try {
      final parts = dateString.split(' - ');
      if (parts.length == 2) {
        final start = _parseDate(parts[0]);
        final end = _parseDate(parts[1]);
        if (start != null && end != null) {
          return DateTimeRange(start: start, end: end);
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  DateTime? _parseDate(String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void setTourDescription(String description) {
    tourDescription.value = description;
  }

  void addActivity() {
    activities.add(TourActivity(id: 'activity_${activities.length}'));
    correctAnswerControllers.add(TextEditingController());
  }

  void removeActivity(int index) {
    if (index >= 0 && index < activities.length) {
      activities.removeAt(index);
      correctAnswerControllers.removeAt(index);
      // Reassign IDs
      for (int i = 0; i < activities.length; i++) {
        activities[i].id = 'activity_$i';
      }
    }
  }

  void updateActivityName(int index, String value) {
    if (index >= 0 && index < activities.length) {
      activities[index].activityName = value;
    }
  }

  void updateActivityXPosition(int index, String value) {
    if (index >= 0 && index < activities.length) {
      activities[index].xPosition = value;
    }
  }

  void updateActivityYPosition(int index, String value) {
    if (index >= 0 && index < activities.length) {
      activities[index].yPosition = value;
    }
  }

  void updateActivityQuestion(int index, String value) {
    if (index >= 0 && index < activities.length) {
      activities[index].question = value;
      
    }
  }
  void updateActivityCorrectAnswer(int index, String value) {
  if (index >= 0 && index < activities.length) {
    final current = activities[index];
    final updatedActivity = TourActivity(
      id: current.id,
      activityName: current.activityName,
      xPosition: current.xPosition,
      yPosition: current.yPosition,
      question: current.question,
      questionType: current.questionType,
      answerOptions: List<String>.from(current.answerOptions),
      correctAnswer: value,
    );
    activities[index] = updatedActivity;

  }
}

  void updateActivityQuestionType(int index, String value) {
    if (index >= 0 && index < activities.length) {
      correctAnswerControllers[index].text = value;
      // Create a new activity with updated question type to trigger reactivity
      final currentActivity = activities[index];
      final updatedActivity = TourActivity(
        id: currentActivity.id,
        activityName: currentActivity.activityName,
        xPosition: currentActivity.xPosition,
        yPosition: currentActivity.yPosition,
        question: currentActivity.question,
        questionType: value,
        answerOptions: List<String>.from(currentActivity.answerOptions),
        correctAnswer: value,
       
      );

      // Update answer options based on question type
      if (value == 'True/False') {
        // Set default True/False options
        updatedActivity.answerOptions = ['True', 'False'];
      } else if (value == 'Short Answer') {
        // Clear options for short answer
        updatedActivity.answerOptions = ['', '', '', ''];
      } else if (value == 'Multiple Choice') {
        // Ensure 4 options for multiple choice
        if (updatedActivity.answerOptions.length < 4) {
          while (updatedActivity.answerOptions.length < 4) {
            updatedActivity.answerOptions.add('');
          }
        }
      }

      // Replace the activity in the list to trigger reactivity
      activities[index] = updatedActivity;

      correctAnswerControllers[index].text = value;
    }
  }

  void updateActivityAnswerOption(
    int activityIndex,
    int optionIndex,
    String value,
  ) {
    if (activityIndex >= 0 && activityIndex < activities.length) {
      final activity = activities[activityIndex];
      final maxOptions = activity.questionType == 'True/False' ? 2 : 4;

      if (optionIndex >= 0 && optionIndex < maxOptions) {
        final options = List<String>.from(activity.answerOptions);
        // Ensure the list has enough elements
        while (options.length < maxOptions) {
          options.add('');
        }
        options[optionIndex] = value;
        activity.answerOptions = options;
      }
    }
  }

  Future<void> publishPackage() async {
    if (tourTitle.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter tour title');
      return;
    }

    if (selectedDestination.value.isEmpty) {
      Get.snackbar('Error', 'Please select destination');
      return;
    }
     if (selectedRegion.value.isEmpty) {
      Get.snackbar('Error', 'Please select region');
      return;
    }

    if (price.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter price');
      return;
    }

    if (maxGroupSize.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter max group size');
      return;
    }

    if (tourDescription.value.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter tour description');
      return;
    }

    isLoading.value = true;

    try {
      final activitiesData = activities
          .map((activity) => activity.toMap())
          .toList();

      if (packageId != null) {
        await _packagesService.updatePackage(
          packageId: packageId!,
          tourTitle: tourTitle.value.trim(),
          destination: selectedDestination.value,
          region: selectedRegion.value,
          activityType: selectedActivityType.value,
          durationValue: durationValue.value,
          durationUnit: durationUnit.value,
          price: price.value.trim(),
          maxGroupSize: maxGroupSize.value.trim(),
          tourDescription: tourDescription.value.trim(),
          availableDates: selectedDates.value.isNotEmpty
              ? selectedDates.value
              : null,
          activities: activitiesData,
        );
        isLoading.value = false;
        Get.snackbar(
          'Success', 
          'Tour package updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00A86B),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAll(() => const DashboardView());
      } else {
        await _packagesService.createPackage(
          tourTitle: tourTitle.value.trim(),
          destination: selectedDestination.value,
           region: selectedRegion.value,
           activityType: selectedActivityType.value,
          durationValue: durationValue.value,
          durationUnit: durationUnit.value,
          price: price.value.trim(),
          maxGroupSize: maxGroupSize.value.trim(),
          tourDescription: tourDescription.value.trim(),
          availableDates: selectedDates.value.isNotEmpty
              ? selectedDates.value
              : null,
          activities: activitiesData,
        );
        isLoading.value = false;
        Get.snackbar(
          'Success',
          'Tour package created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF00A86B),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.offAll(() => const DashboardView());
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
