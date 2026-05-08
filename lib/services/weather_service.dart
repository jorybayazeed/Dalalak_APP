import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class WeatherCity {
  final String name;
  final double latitude;
  final double longitude;

  const WeatherCity({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

enum WeatherRiskLevel { normal, caution, warning, danger }

class WeatherSnapshot {
  final DateTime at;
  final double temperatureC;
  final int humidity;
  final int precipitationProbability;
  final double windSpeedKmH;
  final int weatherCode;

  const WeatherSnapshot({
    required this.at,
    required this.temperatureC,
    required this.humidity,
    required this.precipitationProbability,
    required this.windSpeedKmH,
    required this.weatherCode,
  });

  bool get isRainy => precipitationProbability >= 35 || weatherCode >= 51;
}

class WeatherRecommendation {
  final WeatherRiskLevel level;
  final String title;
  final String message;
  final List<String> tips;
  final bool suggestReschedule;
  final bool suggestIndoorAlternative;
  final bool suggestCancel;
  /// اقتراح الذكاء الاصطناعي: نشاط بديل مقترح عندما يكون الطقس غير ملائم
  final String? aiAlternativeActivity;

  const WeatherRecommendation({
    required this.level,
    required this.title,
    required this.message,
    required this.tips,
    this.suggestReschedule = false,
    this.suggestIndoorAlternative = false,
    this.suggestCancel = false,
    this.aiAlternativeActivity,
  });

  /// اقتراح بديل ذكي بناءً على نوع النشاط ومستوى الخطر
  static String? suggestAiAlternative({
    required WeatherRiskLevel level,
    required String activityType,
  }) {
    if (level == WeatherRiskLevel.normal) return null;

    final act = activityType.trim().toLowerCase();

    if (act.contains('beach') || act.contains('water') || act.contains('sea')) {
      if (level == WeatherRiskLevel.caution) {
        return '🏛 Visit a nearby aquarium or marine museum instead — same ocean experience indoors!';
      }
      return '🍽 Explore waterfront restaurants or seafood markets — enjoy the coast without the waves.';
    }

    if (act.contains('adventure') || act.contains('hiking') || act.contains('nature')) {
      if (level == WeatherRiskLevel.caution) {
        return '🌿 Consider a botanical garden or heritage park — great outdoor experience with more shelter.';
      }
      return '🏺 Explore local heritage centres or museums — rich culture without the weather risk.';
    }

    if (act.contains('culture') || act.contains('history') || act.contains('heritage')) {
      return null; // cultural tours often work indoors anyway
    }

    if (act.contains('desert') || act.contains('safari')) {
      if (level == WeatherRiskLevel.caution) {
        return '📸 Sunrise camel photography at the desert edge — shorter and safer exposure to the elements.';
      }
      return '🏛 Visit a traditional souq or old town district — authentic local culture without the heat.';
    }

    if (act.contains('food') || act.contains('culinary')) {
      return null; // food tours are usually indoors
    }

    if (level == WeatherRiskLevel.warning || level == WeatherRiskLevel.danger) {
      return '🏛 Try an indoor cultural experience — museums, art galleries, or local craft workshops make a great alternative.';
    }

    return null;
  }
}

class DailyWeatherSnapshot {
  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final int precipitationProbabilityMax;
  final double windSpeedMaxKmH;
  final int weatherCode;

  const DailyWeatherSnapshot({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.precipitationProbabilityMax,
    required this.windSpeedMaxKmH,
    required this.weatherCode,
  });
}

class GuideActivitySuggestion {
  final String state;
  final String summary;
  final List<DateTime> suggestedDates;
  final String suggestedStartTime;
  final List<String> tips;

  const GuideActivitySuggestion({
    required this.state,
    required this.summary,
    required this.suggestedDates,
    required this.suggestedStartTime,
    required this.tips,
  });
}

class AlternativeLocationSuggestion {
  final String city;
  final double latitude;
  final double longitude;
  final String reason;

  const AlternativeLocationSuggestion({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.reason,
  });
}

class SmartWeatherAssessment {
  final String city;
  final WeatherSnapshot? current;
  final WeatherSnapshot? tripForecast;
  final WeatherRecommendation currentRecommendation;
  final WeatherRecommendation tripRecommendation;
  final GuideActivitySuggestion guideSuggestion;
  final AlternativeLocationSuggestion? alternativeLocation;

  const SmartWeatherAssessment({
    required this.city,
    required this.current,
    required this.tripForecast,
    required this.currentRecommendation,
    required this.tripRecommendation,
    required this.guideSuggestion,
    required this.alternativeLocation,
  });
}

class WeatherService extends GetxService {
  static const Map<String, WeatherCity> _saudiCities = {
    'riyadh': WeatherCity(name: 'Riyadh', latitude: 24.7136, longitude: 46.6753),
    'jeddah': WeatherCity(name: 'Jeddah', latitude: 21.5433, longitude: 39.1728),
    'alula': WeatherCity(name: 'AlUla', latitude: 26.6082, longitude: 37.9232),
    'dammam': WeatherCity(name: 'Dammam', latitude: 26.4207, longitude: 50.0888),
    'abha': WeatherCity(name: 'Abha', latitude: 18.2164, longitude: 42.5053),
    'taif': WeatherCity(name: 'Taif', latitude: 21.2703, longitude: 40.4158),
    'makkah': WeatherCity(name: 'Makkah', latitude: 21.3891, longitude: 39.8579),
    'madinah': WeatherCity(name: 'Madinah', latitude: 24.5247, longitude: 39.5692),
    'diriyah': WeatherCity(name: 'Diriyah', latitude: 24.7386, longitude: 46.5710),
  };

  WeatherCity cityForName(String cityName) {
    final normalized = cityName.trim().toLowerCase();
    if (_saudiCities.containsKey(normalized)) {
      return _saudiCities[normalized]!;
    }

    for (final entry in _saudiCities.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return _saudiCities['riyadh']!;
  }

  DateTime? inferTourDateTime({
    required String availableDates,
    required String startTime,
  }) {
    final date = _parseFirstDate(availableDates);
    if (date == null) return null;

    final parsedTime = _parseStartTime(startTime);
    if (parsedTime == null) {
      return DateTime(date.year, date.month, date.day, 13);
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      parsedTime.$1,
      parsedTime.$2,
    );
  }

  Future<SmartWeatherAssessment> evaluateSmartWeather({
    required String cityName,
    DateTime? tripDateTime,
    required bool isOutdoor,
    String activityType = '',
  }) async {
    final city = cityForName(cityName);

    final forecast = await _fetchForecast(city: city);
    if (forecast == null) {
      const fallback = WeatherRecommendation(
        level: WeatherRiskLevel.caution,
        title: 'Smart Weather Alert',
        message: 'Unable to fetch latest weather data now. Please try again shortly.',
        tips: <String>[
          'Check weather updates before leaving.',
          'Keep a backup indoor plan ready.',
        ],
      );
      return SmartWeatherAssessment(
        city: city.name,
        current: null,
        tripForecast: null,
        currentRecommendation: fallback,
        tripRecommendation: fallback,
        guideSuggestion: const GuideActivitySuggestion(
          state: 'Unavailable',
          summary: 'Guide suggestions are temporarily unavailable.',
          suggestedDates: <DateTime>[],
          suggestedStartTime: '6:00 PM',
          tips: <String>[
            'Retry after a moment.',
            'Choose a flexible activity window.',
          ],
        ),
        alternativeLocation: null,
      );
    }

    final current = forecast.current;
    final trip = tripDateTime == null
        ? current
        : _findNearestHourlySnapshot(
            hourly: forecast.hourly,
            target: tripDateTime,
          );

    final currentRecommendation = _buildRecommendation(
      weather: current,
      isOutdoor: isOutdoor,
    );

    final tripRecommendation = _buildRecommendation(
      weather: trip,
      isOutdoor: isOutdoor,
    );

    final guideSuggestion = _buildGuideSuggestion(
      activityType: activityType,
      daily: forecast.daily,
    );

    AlternativeLocationSuggestion? alternativeLocation;
    if (tripRecommendation.level == WeatherRiskLevel.warning ||
        tripRecommendation.level == WeatherRiskLevel.danger) {
      alternativeLocation = await _findAlternativeLocation(
        currentCity: city,
        activityType: activityType,
      );
    }

    return SmartWeatherAssessment(
      city: city.name,
      current: current,
      tripForecast: trip,
      currentRecommendation: currentRecommendation,
      tripRecommendation: tripRecommendation,
      guideSuggestion: guideSuggestion,
      alternativeLocation: alternativeLocation,
    );
  }

  GuideActivitySuggestion _buildGuideSuggestion({
    required String activityType,
    required List<DailyWeatherSnapshot> daily,
  }) {
    if (daily.isEmpty) {
      return const GuideActivitySuggestion(
        state: 'Unavailable',
        summary: 'No daily forecast data to suggest dates.',
        suggestedDates: <DateTime>[],
        suggestedStartTime: '6:00 PM',
        tips: <String>[
          'Pick flexible dates.',
        ],
      );
    }

    final normalized = activityType.trim().toLowerCase();
    final isIndoor = _isIndoorActivity(normalized);

    bool isSuitable(DailyWeatherSnapshot d) {
      if (isIndoor) {
        return d.windSpeedMaxKmH <= 45;
      }

      if (normalized.contains('beach')) {
        return d.maxTempC >= 24 &&
            d.maxTempC <= 34 &&
            d.precipitationProbabilityMax <= 25 &&
            d.windSpeedMaxKmH <= 28;
      }

      if (normalized.contains('adventure') ||
          normalized.contains('nature') ||
          normalized.contains('wildlife') ||
          normalized.contains('photography')) {
        return d.maxTempC >= 18 &&
            d.maxTempC <= 33 &&
            d.precipitationProbabilityMax <= 30 &&
            d.windSpeedMaxKmH <= 32;
      }

      return d.maxTempC >= 18 &&
          d.maxTempC <= 34 &&
          d.precipitationProbabilityMax <= 30 &&
          d.windSpeedMaxKmH <= 30;
    }

    final suitable = <DailyWeatherSnapshot>[];
    for (final d in daily) {
      if (isSuitable(d)) suitable.add(d);
    }

    String state;
    String summary;

    if (suitable.length >= 5) {
      state = 'Excellent';
      summary = 'Weather is strongly suitable for this activity type.';
    } else if (suitable.length >= 3) {
      state = 'Good';
      summary = 'There are multiple good date options for this activity.';
    } else if (suitable.isNotEmpty) {
      state = 'Limited';
      summary = 'Only a few dates look suitable. Plan carefully.';
    } else {
      state = 'Unsafe Window';
      summary = 'Current forecast window is weak for this activity type.';
    }

    final suggestedDates = suitable
        .take(5)
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toList(growable: false);

    final tips = <String>[
      if (!isIndoor) 'Prefer late afternoon for outdoor comfort.',
      if (isIndoor) 'Indoor activities remain stable in mixed weather.',
      'Re-check weather 24h and 6h before the trip.',
    ];

    String suggestedStartTime;
    if (isIndoor) {
      suggestedStartTime = '11:00 AM';
    } else if (suitable.isNotEmpty && suitable.first.maxTempC >= 35) {
      suggestedStartTime = '6:00 PM';
    } else if (normalized.contains('beach')) {
      suggestedStartTime = '4:30 PM';
    } else {
      suggestedStartTime = '9:00 AM';
    }

    return GuideActivitySuggestion(
      state: state,
      summary: summary,
      suggestedDates: suggestedDates,
      suggestedStartTime: suggestedStartTime,
      tips: tips,
    );
  }

  int _scoreDailySuitability({
    required String activityType,
    required List<DailyWeatherSnapshot> daily,
  }) {
    if (daily.isEmpty) return 0;

    final guide = _buildGuideSuggestion(
      activityType: activityType,
      daily: daily,
    );

    return switch (guide.state) {
      'Excellent' => 4,
      'Good' => 3,
      'Limited' => 2,
      _ => 0,
    };
  }

  Future<AlternativeLocationSuggestion?> _findAlternativeLocation({
    required WeatherCity currentCity,
    required String activityType,
  }) async {
    final currentKey = currentCity.name.toLowerCase();
    final candidateOrder = <String>[
      'abha',
      'taif',
      'madinah',
      'riyadh',
      'jeddah',
      'dammam',
      'alula',
    ];

    int bestScore = -1;
    WeatherCity? bestCity;
    GuideActivitySuggestion? bestGuide;

    for (final key in candidateOrder) {
      final city = _saudiCities[key];
      if (city == null) continue;
      if (city.name.toLowerCase() == currentKey) continue;

      final forecast = await _fetchForecast(city: city);
      if (forecast == null) continue;

      final score = _scoreDailySuitability(
        activityType: activityType,
        daily: forecast.daily,
      );
      if (score <= bestScore) continue;

      bestScore = score;
      bestCity = city;
      bestGuide = _buildGuideSuggestion(
        activityType: activityType,
        daily: forecast.daily,
      );
    }

    if (bestCity == null || bestScore < 2 || bestGuide == null) {
      return null;
    }

    String reason =
        'Better weather window for this activity type is available in ${bestCity.name}.';
    if (bestGuide.suggestedDates.isNotEmpty) {
      final d = bestGuide.suggestedDates.first;
      final ds =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      reason = '$reason Suggested from $ds at ${bestGuide.suggestedStartTime}.';
    }

    return AlternativeLocationSuggestion(
      city: bestCity.name,
      latitude: bestCity.latitude,
      longitude: bestCity.longitude,
      reason: reason,
    );
  }

  bool _isIndoorActivity(String normalized) {
    if (normalized.isEmpty) return false;
    return normalized.contains('entertainment') ||
        normalized.contains('food') ||
        normalized.contains('culinary') ||
        normalized.contains('shopping') ||
        normalized.contains('museum') ||
        normalized.contains('cultural');
  }

  WeatherRecommendation _buildRecommendation({
    required WeatherSnapshot weather,
    required bool isOutdoor,
  }) {
    final temp = weather.temperatureC;
    final rain = weather.precipitationProbability;
    final wind = weather.windSpeedKmH;

    if ((rain >= 70 || weather.weatherCode >= 80) && wind >= 35) {
      return WeatherRecommendation(
        level: WeatherRiskLevel.danger,
        title: 'Weather Safety Alert',
        message:
            'Heavy rain and strong winds may impact trip safety during this time.',
        tips: const <String>[
          'Cancel or reschedule the trip for safety.',
          'Send a weather alert to all tourists.',
          'Switch to an indoor activity immediately.',
        ],
        suggestReschedule: true,
        suggestIndoorAlternative: true,
        suggestCancel: true,
      );
    }

    if (temp >= 39 && isOutdoor) {
      return WeatherRecommendation(
        level: WeatherRiskLevel.warning,
        title: 'Hot Weather Alert',
        message:
            'Expected temperature is very high for outdoor activities at this time.',
        tips: const <String>[
          'Move the trip to evening (after 5 PM).',
          'Shorten outdoor exposure time.',
          'Carry enough water and use sunscreen.',
        ],
        suggestReschedule: true,
      );
    }

    if (rain >= 55 || weather.weatherCode >= 61) {
      return WeatherRecommendation(
        level: WeatherRiskLevel.warning,
        title: 'Rain Alert',
        message: 'Rain is likely during the trip time.',
        tips: const <String>[
          'Bring an umbrella and suitable shoes.',
          'Prepare an indoor backup option.',
          'Track weather updates before departure.',
        ],
        suggestReschedule: true,
        suggestIndoorAlternative: true,
      );
    }

    if ((temp >= 35 && isOutdoor) || rain >= 30 || wind >= 28) {
      return WeatherRecommendation(
        level: WeatherRiskLevel.caution,
        title: 'Smart Weather Suggestion',
        message: 'Weather is manageable, but extra preparation is recommended.',
        tips: const <String>[
          'Plan hydration and shade breaks.',
          'Keep flexible timing if conditions change.',
        ],
      );
    }

    return WeatherRecommendation(
      level: WeatherRiskLevel.normal,
      title: 'Good Weather',
      message: 'Weather looks suitable for the planned activity.',
      tips: const <String>[
        'Enjoy your trip and keep basic weather essentials.',
      ],
    );
  }

  DateTime? _parseFirstDate(String raw) {
    final match = RegExp(r'(\d{2})/(\d{2})/(\d{4})').firstMatch(raw);
    if (match == null) return null;

    final d = int.tryParse(match.group(1) ?? '');
    final m = int.tryParse(match.group(2) ?? '');
    final y = int.tryParse(match.group(3) ?? '');

    if (d == null || m == null || y == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;

    return DateTime(y, m, d);
  }

  (int, int)? _parseStartTime(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return null;

    final h24 = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(clean);
    if (h24 != null) {
      final hour = int.tryParse(h24.group(1) ?? '');
      final min = int.tryParse(h24.group(2) ?? '');
      if (hour == null || min == null) return null;
      if (hour < 0 || hour > 23 || min < 0 || min > 59) return null;
      return (hour, min);
    }

    final h12 = RegExp(r'^(\d{1,2}):(\d{2})\s*([aApP][mM])$').firstMatch(clean);
    if (h12 != null) {
      final h = int.tryParse(h12.group(1) ?? '');
      final min = int.tryParse(h12.group(2) ?? '');
      final ap = (h12.group(3) ?? '').toUpperCase();
      if (h == null || min == null) return null;
      if (h < 1 || h > 12 || min < 0 || min > 59) return null;

      var hour = h % 12;
      if (ap == 'PM') hour += 12;
      return (hour, min);
    }

    return null;
  }

  WeatherSnapshot _findNearestHourlySnapshot({
    required List<WeatherSnapshot> hourly,
    required DateTime target,
  }) {
    if (hourly.isEmpty) {
      throw StateError('Hourly forecast is empty');
    }

    WeatherSnapshot nearest = hourly.first;
    var minDiff = nearest.at.difference(target).abs();

    for (final item in hourly) {
      final diff = item.at.difference(target).abs();
      if (diff < minDiff) {
        nearest = item;
        minDiff = diff;
      }
    }

    return nearest;
  }

  Future<_ForecastResponse?> _fetchForecast({required WeatherCity city}) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,precipitation_probability,wind_speed_10m,weather_code',
      'hourly':
          'temperature_2m,relative_humidity_2m,precipitation_probability,wind_speed_10m,weather_code',
        'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max',
      'forecast_days': '14',
      'timezone': 'auto',
    });

    try {
      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final currentMap = decoded['current'];
      final hourlyMap = decoded['hourly'];
      final dailyMap = decoded['daily'];
      if (currentMap is! Map || hourlyMap is! Map || dailyMap is! Map) {
        return null;
      }

      final current = _parseCurrent(currentMap.cast<String, dynamic>());
      final hourly = _parseHourly(hourlyMap.cast<String, dynamic>());
      final daily = _parseDaily(dailyMap.cast<String, dynamic>());
      if (current == null || hourly.isEmpty || daily.isEmpty) return null;

      return _ForecastResponse(current: current, hourly: hourly, daily: daily);
    } catch (_) {
      return null;
    }
  }

  WeatherSnapshot? _parseCurrent(Map<String, dynamic> map) {
    final timeRaw = (map['time'] ?? '').toString();
    final at = DateTime.tryParse(timeRaw);
    if (at == null) return null;

    return WeatherSnapshot(
      at: at,
      temperatureC: (map['temperature_2m'] as num?)?.toDouble() ?? 0,
      humidity: (map['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      precipitationProbability:
          (map['precipitation_probability'] as num?)?.toInt() ?? 0,
      windSpeedKmH: (map['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      weatherCode: (map['weather_code'] as num?)?.toInt() ?? 0,
    );
  }

  List<WeatherSnapshot> _parseHourly(Map<String, dynamic> map) {
    final times = (map['time'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => e.toString())
        .toList(growable: false);
    final temps = map['temperature_2m'] as List<dynamic>? ?? const <dynamic>[];
    final humids =
        map['relative_humidity_2m'] as List<dynamic>? ?? const <dynamic>[];
    final rains =
        map['precipitation_probability'] as List<dynamic>? ?? const <dynamic>[];
    final winds = map['wind_speed_10m'] as List<dynamic>? ?? const <dynamic>[];
    final codes = map['weather_code'] as List<dynamic>? ?? const <dynamic>[];

    final minLen = [
      times.length,
      temps.length,
      humids.length,
      rains.length,
      winds.length,
      codes.length,
    ].reduce((a, b) => a < b ? a : b);

    final list = <WeatherSnapshot>[];
    for (var i = 0; i < minLen; i++) {
      final at = DateTime.tryParse(times[i]);
      if (at == null) continue;

      list.add(
        WeatherSnapshot(
          at: at,
          temperatureC: (temps[i] as num?)?.toDouble() ?? 0,
          humidity: (humids[i] as num?)?.toInt() ?? 0,
          precipitationProbability: (rains[i] as num?)?.toInt() ?? 0,
          windSpeedKmH: (winds[i] as num?)?.toDouble() ?? 0,
          weatherCode: (codes[i] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return list;
  }

  List<DailyWeatherSnapshot> _parseDaily(Map<String, dynamic> map) {
    final times = (map['time'] as List<dynamic>? ?? const <dynamic>[])
        .map((e) => e.toString())
        .toList(growable: false);
    final maxT = map['temperature_2m_max'] as List<dynamic>? ?? const <dynamic>[];
    final minT = map['temperature_2m_min'] as List<dynamic>? ?? const <dynamic>[];
    final rain =
        map['precipitation_probability_max'] as List<dynamic>? ?? const <dynamic>[];
    final wind =
        map['wind_speed_10m_max'] as List<dynamic>? ?? const <dynamic>[];
    final codes = map['weather_code'] as List<dynamic>? ?? const <dynamic>[];

    final minLen = [
      times.length,
      maxT.length,
      minT.length,
      rain.length,
      wind.length,
      codes.length,
    ].reduce((a, b) => a < b ? a : b);

    final list = <DailyWeatherSnapshot>[];
    for (var i = 0; i < minLen; i++) {
      final dt = DateTime.tryParse(times[i]);
      if (dt == null) continue;

      list.add(
        DailyWeatherSnapshot(
          date: dt,
          maxTempC: (maxT[i] as num?)?.toDouble() ?? 0,
          minTempC: (minT[i] as num?)?.toDouble() ?? 0,
          precipitationProbabilityMax: (rain[i] as num?)?.toInt() ?? 0,
          windSpeedMaxKmH: (wind[i] as num?)?.toDouble() ?? 0,
          weatherCode: (codes[i] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return list;
  }
}

class _ForecastResponse {
  final WeatherSnapshot current;
  final List<WeatherSnapshot> hourly;
  final List<DailyWeatherSnapshot> daily;

  const _ForecastResponse({
    required this.current,
    required this.hourly,
    required this.daily,
  });
}
