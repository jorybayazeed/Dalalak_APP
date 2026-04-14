import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tour_app/services/packages_service.dart';
import 'package:tour_app/view/main/tour_guide/dashboard/views/dashboard_view.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

class TourActivity {
  String id;
  String activityName;
  String activityPlace;
  String activityType;
  double? latitude;
  double? longitude;
  String question;
  String questionType;
  List<String> answerOptions;
  String correctAnswer;
  bool photoChallengeEnabled;
  String photoChallengeText;
  

  
 

  TourActivity({
    required this.id,
    this.activityName = '',
    this.activityPlace = '',
    this.activityType = '',
    this.latitude,
    this.longitude,
    this.question = '',
    this.questionType = 'Multiple Choice',
    this.answerOptions = const ['', '', '', ''],
    this.correctAnswer = '',
    this.photoChallengeEnabled = false,
    this.photoChallengeText = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'activityId': id,
      'activityName': activityName,
      'activityPlace': activityPlace,
      'activityType': activityType,
      'latitude': latitude,
      'longitude': longitude,
      'question': question,
      'questionType': questionType,
      'answerOptions': answerOptions,
      'correctAnswer': correctAnswer,
      'photoChallengeEnabled': photoChallengeEnabled,
      'photoChallengeText': photoChallengeText,
    };
  }

  factory TourActivity.fromMap(String id, Map<String, dynamic> map) {
    final activityId = map['activityId'] as String?;
    return TourActivity(
      id: (activityId != null && activityId.isNotEmpty) ? activityId : id,
      activityName: map['activityName'] as String? ?? '',
      activityPlace: map['activityPlace'] as String? ?? '',
      activityType: map['activityType'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      question: map['question'] as String? ?? '',
      questionType: map['questionType'] as String? ?? 'Multiple Choice',
      answerOptions:
          (map['answerOptions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['', '', '', ''],
      correctAnswer: map['correctAnswer'] ?? '',
      photoChallengeEnabled:
          (map['photoChallengeEnabled'] as bool?) ?? false,
      photoChallengeText: map['photoChallengeText'] as String? ?? '',
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

  final RxMap<String, LatLng> activityDraftCenters = <String, LatLng>{}.obs;
  final RxMap<String, String> activityPlaceSearchDraft = <String, String>{}.obs;
  final Map<String, TextEditingController> _activityPlaceSearchControllers =
      <String, TextEditingController>{};

  final Map<String, Timer> _activityGeocodeDebounce = <String, Timer>{};
  final Map<String, String> _lastGeocodeQuery = <String, String>{};
  final Map<String, String> _lastGeocodeDialogQuery = <String, String>{};
  final Map<String, DateTime> _lastGeocodeDialogShownAt = <String, DateTime>{};

  double _degToRad(double d) => d * (3.141592653589793 / 180.0);

  String _simplifyGeocodeQuery(
    String raw, {
    int maxTokens = 7,
  }) {
    final postcodeMatch = RegExp(r'\b\d{5}\b').firstMatch(raw);
    final postcode = postcodeMatch?.group(0);

    final cleaned = raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleaned.isEmpty) return '';

    const stop = <String>{
      'the',
      'a',
      'an',
      'and',
      'or',
      'of',
      'to',
      'in',
      'at',
      'on',
      'for',
      'with',
      'from',
      'near',
      'around',
      'by',
    };

    final tokens = cleaned
        .split(' ')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty && !stop.contains(t))
        .toList();

    if (tokens.isEmpty) return cleaned;

    final simplified = tokens.take(maxTokens).join(' ');
    if (postcode == null || postcode.isEmpty) return simplified;
    if (simplified.contains(postcode)) return simplified;
    return '$simplified $postcode';
  }

  double _distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _degToRad(b.latitude - a.latitude);
    final dLon = _degToRad(b.longitude - a.longitude);
    final lat1 = _degToRad(a.latitude);
    final lat2 = _degToRad(b.latitude);

    final h =
        (sin(dLat / 2) * sin(dLat / 2)) +
            (sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2));
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return r * c;
  }

  final RxSet<String> expandedActivityMapIds = <String>{}.obs;
  final LatLng defaultMapCenter = const LatLng(24.7136, 46.6753);

  static const Map<String, LatLng> _destinationCenters = {
    'Riyadh': LatLng(24.7136, 46.6753),
    'Jeddah': LatLng(21.4858, 39.1925),
    'AlUla': LatLng(26.6082, 37.9232),
    'Dammam': LatLng(26.4207, 50.0888),
    'Abha': LatLng(18.2164, 42.5053),
    'Taif': LatLng(21.2703, 40.4158),
    'Makkah': LatLng(21.3891, 39.8579),
    'Madinah': LatLng(24.5247, 39.5692),
  };

  LatLng _centerForArea(String area) {
    final trimmed = area.trim();
    if (trimmed.isEmpty) return defaultMapCenter;
    return _destinationCenters[trimmed] ?? defaultMapCenter;
  }

  LatLng getPreferredMapCenter({LatLng? selectedPoint}) {
    if (selectedPoint != null) return selectedPoint;
    if (selectedRegion.value.trim().isNotEmpty) {
      return _centerForArea(selectedRegion.value);
    }
    if (selectedDestination.value.trim().isNotEmpty) {
      return _centerForArea(selectedDestination.value);
    }
    return defaultMapCenter;
  }

  double getPreferredMapZoom({LatLng? selectedPoint}) {
    if (selectedPoint != null) return 13;
    if (selectedRegion.value.trim().isNotEmpty ||
        selectedDestination.value.trim().isNotEmpty) {
      return 10;
    }
    return 5;
  }
  final TextEditingController tourTitleController = TextEditingController();
  final TextEditingController tourDescriptionController = TextEditingController();
  final TextEditingController durationValueController = TextEditingController(text: '3');
  final TextEditingController priceController = TextEditingController(text: '500');
  final TextEditingController maxGroupSizeController = TextEditingController(text: '15');
  final TextEditingController selectedDatesController = TextEditingController();

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
        final priceValue = packageData['price'] as String? ?? '500';
        final maxGroupSizeValue = packageData['maxGroupSize'] as String? ?? '15';
        
        tourTitle.value = packageData['tourTitle'] as String? ?? '';
        tourTitleController.text = tourTitle.value;
        selectedDestination.value = packageData['destination'] as String? ?? '';
        selectedRegion.value = packageData['region'] as String? ?? selectedDestination.value;
        selectedActivityType.value = packageData['activityType'] as String? ?? '';
        durationValue.value = packageData['durationValue'] as String? ?? '3';
        durationValueController.text = durationValue.value;
        durationUnit.value = packageData['durationUnit'] as String? ?? 'Hours';
        price.value = priceValue;
        priceController.text = priceValue;
        maxGroupSize.value = maxGroupSizeValue;
        maxGroupSizeController.text = maxGroupSizeValue;
        selectedDates.value = packageData['availableDates'] as String? ?? '';
        selectedDatesController.text = selectedDates.value;
        tourDescription.value = packageData['tourDescription'] as String? ?? '';
        tourDescriptionController.text = tourDescription.value;

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
    // Keep region aligned with destination when no dedicated region selector exists.
    selectedRegion.value = destination;
  }

  void setActivityType(String activityType) {
    selectedActivityType.value = activityType;
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
    selectedDatesController.text = dates;
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
      selectedDatesController.text = formattedDates;
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
    final activityId = DateTime.now().microsecondsSinceEpoch.toString();
    final preferred = getPreferredMapCenter();
    activities.add(
      TourActivity(
        id: activityId,
        latitude: preferred.latitude,
        longitude: preferred.longitude,
      ),
    );
    correctAnswerControllers.add(TextEditingController());
  }

  void toggleActivityMap(String activityId) {
    if (expandedActivityMapIds.contains(activityId)) {
      expandedActivityMapIds.remove(activityId);
    } else {
      expandedActivityMapIds.add(activityId);

      final index = activities.indexWhere((a) => a.id == activityId);
      if (index != -1) {
        final a = activities[index];
        if (a.latitude == null || a.longitude == null) {
          updateActivityLocation(index, getPreferredMapCenter());
        }
      }
    }
  }

  void updateActivityLocation(int index, LatLng position) {
    if (index < 0 || index >= activities.length) return;
    final current = activities[index];
    final updated = TourActivity(
      id: current.id,
      activityName: current.activityName,
      activityPlace: current.activityPlace,
      activityType: current.activityType,
      latitude: position.latitude,
      longitude: position.longitude,
      question: current.question,
      questionType: current.questionType,
      answerOptions: List<String>.from(current.answerOptions),
      correctAnswer: current.correctAnswer,
      photoChallengeEnabled: current.photoChallengeEnabled,
      photoChallengeText: current.photoChallengeText,
    );
    activities[index] = updated;
  }

  void updateActivityDraftCenter({
    required String activityId,
    required LatLng center,
  }) {
    activityDraftCenters[activityId] = center;
  }

  void setActivityMarkerToDraftCenter(int index) {
    if (index < 0 || index >= activities.length) return;
    final activityId = activities[index].id;
    final center = activityDraftCenters[activityId];
    if (center == null) return;
    updateActivityLocation(index, center);
  }

  void removeActivity(int index) {
    if (index >= 0 && index < activities.length) {
      activities.removeAt(index);
      correctAnswerControllers.removeAt(index);
    }
  }

  void updateActivityName(int index, String value) {
    if (index >= 0 && index < activities.length) {
      final current = activities[index];
      final updated = TourActivity(
        id: current.id,
        activityName: value,
        activityPlace: current.activityPlace,
        activityType: current.activityType,
        latitude: current.latitude,
        longitude: current.longitude,
        question: current.question,
        questionType: current.questionType,
        answerOptions: List<String>.from(current.answerOptions),
        correctAnswer: current.correctAnswer,
        photoChallengeEnabled: current.photoChallengeEnabled,
        photoChallengeText: current.photoChallengeText,
      );
      activities[index] = updated;
    }
  }

  void updateActivityPlace(int index, String value) {
    if (index < 0 || index >= activities.length) return;
    final current = activities[index];
    final updated = TourActivity(
      id: current.id,
      activityName: current.activityName,
      activityPlace: value,
      activityType: current.activityType,
      latitude: current.latitude,
      longitude: current.longitude,
      question: current.question,
      questionType: current.questionType,
      answerOptions: List<String>.from(current.answerOptions),
      correctAnswer: current.correctAnswer,
      photoChallengeEnabled: current.photoChallengeEnabled,
      photoChallengeText: current.photoChallengeText,
    );
    activities[index] = updated;

    activityPlaceSearchDraft[current.id] = value;

    final c = _activityPlaceSearchControllers[current.id];
    if (c != null && c.text != value) {
      c.value = c.value.copyWith(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
        composing: TextRange.empty,
      );
    }

    _debouncedGeocodeActivityName(index: index);
  }

  void updateActivityPhotoChallengeEnabled(int index, bool enabled) {
    if (index < 0 || index >= activities.length) return;
    final current = activities[index];
    final updated = TourActivity(
      id: current.id,
      activityName: current.activityName,
      activityPlace: current.activityPlace,
      activityType: current.activityType,
      latitude: current.latitude,
      longitude: current.longitude,
      question: current.question,
      questionType: current.questionType,
      answerOptions: List<String>.from(current.answerOptions),
      correctAnswer: current.correctAnswer,
      photoChallengeEnabled: enabled,
      photoChallengeText: enabled ? current.photoChallengeText : '',
    );
    activities[index] = updated;
  }

  void updateActivityPhotoChallengeText(int index, String text) {
    if (index < 0 || index >= activities.length) return;
    final current = activities[index];
    final updated = TourActivity(
      id: current.id,
      activityName: current.activityName,
      activityPlace: current.activityPlace,
      activityType: current.activityType,
      latitude: current.latitude,
      longitude: current.longitude,
      question: current.question,
      questionType: current.questionType,
      answerOptions: List<String>.from(current.answerOptions),
      correctAnswer: current.correctAnswer,
      photoChallengeEnabled: current.photoChallengeEnabled,
      photoChallengeText: text,
    );
    activities[index] = updated;
  }

  void removePhotoChallengesFromAllActivities() {
    if (activities.isEmpty) return;

    final updated = activities
        .map(
          (a) => TourActivity(
            id: a.id,
            activityName: a.activityName,
            activityPlace: a.activityPlace,
            activityType: a.activityType,
            latitude: a.latitude,
            longitude: a.longitude,
            question: a.question,
            questionType: a.questionType,
            answerOptions: List<String>.from(a.answerOptions),
            correctAnswer: a.correctAnswer,
            photoChallengeEnabled: false,
            photoChallengeText: '',
          ),
        )
        .toList(growable: false);

    activities.assignAll(updated);
  }

  void setActivityPlaceSearchDraft({
    required String activityId,
    required String value,
  }) {
    activityPlaceSearchDraft[activityId] = value;
  }

  TextEditingController activityPlaceSearchControllerFor(
    String activityId, {
    required String fallbackText,
  }) {
    final existing = _activityPlaceSearchControllers[activityId];
    if (existing != null) return existing;

    final initialText =
        activityPlaceSearchDraft[activityId] ?? fallbackText;
    final controller = TextEditingController(text: initialText);
    _activityPlaceSearchControllers[activityId] = controller;
    return controller;
  }

  Future<void> submitActivityPlaceSearch(int index) async {
    if (index < 0 || index >= activities.length) return;
    final activity = activities[index];
    final draft = (activityPlaceSearchDraft[activity.id] ?? '').trim();
    if (draft.isEmpty) {
      Get.snackbar('Missing place', 'Please enter a place');
      return;
    }

    updateActivityPlace(index, draft);
    await geocodeActivityPlaceNow(index);
  }

  Future<void> geocodeActivityPlaceNow(int index) async {
    if (index < 0 || index >= activities.length) return;

    final activityId = activities[index].id;
    _activityGeocodeDebounce[activityId]?.cancel();

    final place = activities[index].activityPlace.trim();
    if (place.length < 3) {
      Get.snackbar('Missing place', 'Please enter Activity Place');
      return;
    }

    _lastGeocodeQuery[activityId] = place;
    await _geocodeAndSetActivityLocation(index: index, query: place);
  }

  void _debouncedGeocodeActivityName({
    required int index,
  }) {
    if (index < 0 || index >= activities.length) return;
    final activityId = activities[index].id;

    _activityGeocodeDebounce[activityId]?.cancel();

    final place = activities[index].activityPlace.trim();
    if (place.length < 3) return;

    if (_lastGeocodeQuery[activityId] == place) return;
    _lastGeocodeQuery[activityId] = place;

    _activityGeocodeDebounce[activityId] = Timer(const Duration(milliseconds: 1200), () {
      _geocodeAndSetActivityLocation(index: index, query: place);
    });
  }

  Future<void> _geocodeAndSetActivityLocation({
    required int index,
    required String query,
  }) async {
    if (index < 0 || index >= activities.length) return;

    final activityId = activities[index].id;
    final placeAtRequestTime = activities[index].activityPlace.trim();

    try {
      if (placeAtRequestTime.isEmpty || placeAtRequestTime != query) {
        return;
      }

      final destination = selectedDestination.value.trim();
      final region = selectedRegion.value.trim();

      final qLower = query.toLowerCase();
      final regionLower = region.toLowerCase();
      final destinationLower = destination.toLowerCase();
      final shouldAddRegion = region.isNotEmpty && !qLower.contains(regionLower);
      final shouldAddDestination =
          destination.isNotEmpty && !qLower.contains(destinationLower);

      final simplified = _simplifyGeocodeQuery(query);
      final postcode = RegExp(r'\b\d{5}\b')
          .firstMatch(query)
          ?.group(0)
          ?.trim();
      final q = [
        if (simplified.isNotEmpty) simplified else query,
        if (shouldAddRegion) region,
        if (shouldAddDestination) destination,
      ].where((e) => e.trim().isNotEmpty).join(' ');

      LatLng? biasCenter;
      if (region.isNotEmpty) {
        biasCenter = _destinationCenters[region];
      }
      biasCenter ??= _destinationCenters[destination];

      final params = <String, String>{
        'format': 'jsonv2',
        'limit': '10',
        'q': q,
        'countrycodes': 'sa',
        'addressdetails': '1',
        'extratags': '1',
      };

      if (biasCenter != null) {
        const delta = 0.7;
        final left = (biasCenter.longitude - delta).toStringAsFixed(6);
        final right = (biasCenter.longitude + delta).toStringAsFixed(6);
        final top = (biasCenter.latitude + delta).toStringAsFixed(6);
        final bottom = (biasCenter.latitude - delta).toStringAsFixed(6);
        params['viewbox'] = '$left,$top,$right,$bottom';
        params['bounded'] = '1';
      }

      final uri = Uri.https('nominatim.openstreetmap.org', '/search', params);

      Future<List<dynamic>> fetch(Uri u) async {
        final client = HttpClient();
        try {
          final request = await client.getUrl(u);
          request.headers.set('User-Agent', 'DalalakApp/1.0 (contact: support@dalalak.app)');
          request.headers.set('Accept', 'application/json');
          request.headers.set('Accept-Language', 'en');
          final res = await request.close();
          if (res.statusCode < 200 || res.statusCode >= 300) {
            return const <dynamic>[];
          }
          final body = await res.transform(utf8.decoder).join();
          final decoded = jsonDecode(body);
          return decoded is List ? decoded : const <dynamic>[];
        } catch (_) {
          return const <dynamic>[];
        } finally {
          client.close(force: true);
        }
      }

      var decoded = await fetch(uri);
      if (decoded.isEmpty) {
        final relaxedParams = Map<String, String>.from(params);
        relaxedParams.remove('viewbox');
        relaxedParams.remove('bounded');
        final relaxedUri =
            Uri.https('nominatim.openstreetmap.org', '/search', relaxedParams);
        decoded = await fetch(relaxedUri);
      }
      if (decoded.isEmpty) {
        final fallbackParams = <String, String>{
          'format': 'jsonv2',
          'limit': '20',
          'q': q,
        };
        final fallbackUri =
            Uri.https('nominatim.openstreetmap.org', '/search', fallbackParams);
        decoded = await fetch(fallbackUri);
      }
      if (decoded.isEmpty) {
        if (index < 0 || index >= activities.length) return;
        if (activities[index].id != activityId) return;
        if (activities[index].activityPlace.trim() != placeAtRequestTime) return;

        if (query.trim().length >= 3) {
          Get.snackbar('Not found', 'No results for "$query"');
        }
        return;
      }

      final List<Map<String, dynamic>> scored = <Map<String, dynamic>>[];

      final queryTokens = (simplified.isNotEmpty ? simplified : query)
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(growable: false);

      for (final item in decoded) {
        if (item is! Map) continue;
        final m = item.cast<String, dynamic>();

        final lat = double.tryParse((m['lat'] ?? '').toString());
        final lon = double.tryParse((m['lon'] ?? '').toString());
        if (lat == null || lon == null) continue;

        final importance = (m['importance'] as num?)?.toDouble() ?? 0.0;
        double score = importance * 1000;

        if (biasCenter != null) {
          final dist = _distanceKm(biasCenter, LatLng(lat, lon));
          score -= dist;
        }

        final displayName = (m['display_name'] ?? '').toString().toLowerCase();

        int tokenMatches = 0;
        for (final t in queryTokens) {
          if (displayName.contains(t)) tokenMatches++;
        }
        score += tokenMatches * 120;

        if (postcode != null && postcode.isNotEmpty) {
          final address = m['address'];
          if (address is Map) {
            final candidatePostcode = (address['postcode'] ?? '').toString();
            if (candidatePostcode == postcode) {
              score += 500;
            } else if (candidatePostcode.replaceAll(' ', '') ==
                postcode.replaceAll(' ', '')) {
              score += 350;
            }
          }
        }

        if (destination.isNotEmpty && displayName.contains(destination.toLowerCase())) {
          score += 50;
        }
        if (region.isNotEmpty && displayName.contains(region.toLowerCase())) {
          score += 50;
        }

        final candidate = <String, dynamic>{
          ...m,
          '_score': score,
          '_lat': lat,
          '_lon': lon,
        };
        scored.add(candidate);
      }

      if (scored.isEmpty) return;
      scored.sort((a, b) =>
          ((b['_score'] as num?)?.toDouble() ?? 0)
              .compareTo(((a['_score'] as num?)?.toDouble() ?? 0)));

      if (index < 0 || index >= activities.length) return;
      if (activities[index].id != activityId) return;
      if (activities[index].activityPlace.trim() != placeAtRequestTime) return;

      final top = scored.take(5).toList(growable: false);

      if (top.length == 1) {
        final only = top.first;
        final onlyLat = (only['_lat'] as num?)?.toDouble();
        final onlyLon = (only['_lon'] as num?)?.toDouble();
        if (onlyLat == null || onlyLon == null) return;
        updateActivityLocation(index, LatLng(onlyLat, onlyLon));
        return;
      }

      final now = DateTime.now();
      final lastQuery = _lastGeocodeDialogQuery[activityId];
      final lastShownAt = _lastGeocodeDialogShownAt[activityId];
      final recentlyShownSameQuery =
          lastQuery == query && lastShownAt != null && now.difference(lastShownAt).inSeconds < 5;
      if (recentlyShownSameQuery) {
        return;
      }
      _lastGeocodeDialogQuery[activityId] = query;
      _lastGeocodeDialogShownAt[activityId] = now;

      await _showGeocodeResultsDialog(
        activityId: activityId,
        activityIndex: index,
        query: query,
        candidates: top,
        nameAtRequestTime: placeAtRequestTime,
      );
    } catch (_) {
      return;
    }
  }

  Future<void> _showGeocodeResultsDialog({
    required String activityId,
    required int activityIndex,
    required String query,
    required List<Map<String, dynamic>> candidates,
    required String nameAtRequestTime,
  }) async {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    await Get.dialog(
      SimpleDialog(
        title: Text('Select location for "$query"'),
        children: [
          ...candidates.map((c) {
            final display = (c['display_name'] ?? '').toString();
            final lat = (c['_lat'] as num?)?.toDouble();
            final lon = (c['_lon'] as num?)?.toDouble();
            if (lat == null || lon == null) {
              return const SizedBox.shrink();
            }

            return SimpleDialogOption(
              onPressed: () {
                if (activityIndex < 0 || activityIndex >= activities.length) {
                  Get.back();
                  return;
                }
                if (activities[activityIndex].id != activityId) {
                  Get.back();
                  return;
                }
                if (activities[activityIndex].activityName.trim() !=
                    nameAtRequestTime) {
                  Get.back();
                  return;
                }

                updateActivityLocation(activityIndex, LatLng(lat, lon));
                Get.back();
              },
              child: Text(display),
            );
          }),
          SimpleDialogOption(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  void updateActivityType(int index, String value) {
    if (index < 0 || index >= activities.length) return;

    final current = activities[index];
    final updated = TourActivity(
      id: current.id,
      activityName: current.activityName,
      activityPlace: current.activityPlace,
      activityType: value,
      latitude: current.latitude,
      longitude: current.longitude,
      question: current.question,
      questionType: current.questionType,
      answerOptions: List<String>.from(current.answerOptions),
      correctAnswer: current.correctAnswer,
      photoChallengeEnabled: current.photoChallengeEnabled,
      photoChallengeText: current.photoChallengeText,
    );

    activities[index] = updated;
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
      activityPlace: current.activityPlace,
      activityType: current.activityType,
      latitude: current.latitude,
      longitude: current.longitude,
      question: current.question,
      questionType: current.questionType,
      answerOptions: List<String>.from(current.answerOptions),
      correctAnswer: value,
      photoChallengeEnabled: current.photoChallengeEnabled,
      photoChallengeText: current.photoChallengeText,
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
        activityPlace: currentActivity.activityPlace,
        activityType: currentActivity.activityType,
        latitude: currentActivity.latitude,
        longitude: currentActivity.longitude,
        question: currentActivity.question,
        questionType: value,
        answerOptions: List<String>.from(currentActivity.answerOptions),
        correctAnswer: value,
        photoChallengeEnabled: currentActivity.photoChallengeEnabled,
        photoChallengeText: currentActivity.photoChallengeText,
       
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

    if (activities.isEmpty) {
      Get.snackbar('Error', 'Please add at least 1 activity');
      return;
    }

    if (selectedDestination.value.isEmpty) {
      Get.snackbar('Error', 'Please select destination');
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
          durationValue: durationValue.value,
          durationUnit: durationUnit.value,
          price: price.value.trim(),
          maxGroupSize: maxGroupSize.value.trim(),
          tourDescription: tourDescription.value.trim(),
          availableDates: selectedDates.value.isNotEmpty
              ? selectedDates.value
              : null,
          activityType: selectedActivityType.value.isNotEmpty
              ? selectedActivityType.value
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
          durationValue: durationValue.value,
          durationUnit: durationUnit.value,
          price: price.value.trim(),
          maxGroupSize: maxGroupSize.value.trim(),
          tourDescription: tourDescription.value.trim(),
          availableDates: selectedDates.value.isNotEmpty
              ? selectedDates.value
              : null,
          activityType: selectedActivityType.value.isNotEmpty
              ? selectedActivityType.value
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

  @override
  void onClose() {
    tourTitleController.dispose();
    tourDescriptionController.dispose();
    durationValueController.dispose();
    priceController.dispose();
    maxGroupSizeController.dispose();
    selectedDatesController.dispose();
    for (var controller in correctAnswerControllers) {
      controller.dispose();
    }
    for (final t in _activityGeocodeDebounce.values) {
      t.cancel();
    }

    for (final c in _activityPlaceSearchControllers.values) {
      c.dispose();
    }
    _activityPlaceSearchControllers.clear();

    _activityGeocodeDebounce.clear();
    _lastGeocodeQuery.clear();
    _lastGeocodeDialogQuery.clear();
    _lastGeocodeDialogShownAt.clear();
    super.onClose();
  }
}
