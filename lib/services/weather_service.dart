import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int weatherCode;
  final double windSpeed;
  final double humidity;
  final String city;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.city,
  });

  String get conditionLabel {
    if (weatherCode == 0) return 'Clear Sky';
    if (weatherCode <= 3) return 'Partly Cloudy';
    if (weatherCode <= 9) return 'Foggy';
    if (weatherCode <= 29) return 'Drizzle';
    if (weatherCode <= 39) return 'Sandstorm';
    if (weatherCode <= 49) return 'Foggy';
    if (weatherCode <= 59) return 'Drizzle';
    if (weatherCode <= 69) return 'Rain';
    if (weatherCode <= 79) return 'Snow';
    if (weatherCode <= 84) return 'Rain Showers';
    if (weatherCode <= 94) return 'Thunderstorm';
    return 'Thunderstorm';
  }

  String get conditionIcon {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 9) return '🌫️';
    if (weatherCode <= 29) return '🌧️';
    if (weatherCode <= 39) return '🌪️';
    if (weatherCode <= 49) return '🌫️';
    if (weatherCode <= 59) return '🌦️';
    if (weatherCode <= 69) return '🌧️';
    if (weatherCode <= 79) return '❄️';
    if (weatherCode <= 84) return '🌦️';
    if (weatherCode <= 94) return '⛈️';
    return '⛈️';
  }
}

class WeatherService {
  // Saudi Arabia cities with their coordinates
  static const Map<String, Map<String, double>> _cities = {
    'Riyadh': {'lat': 24.6877, 'lon': 46.7219},
    'Jeddah': {'lat': 21.5433, 'lon': 39.1728},
    'AlUla': {'lat': 26.6148, 'lon': 37.9229},
    'Mecca': {'lat': 21.3891, 'lon': 39.8579},
    'Medina': {'lat': 24.5247, 'lon': 39.5692},
  };

  Future<WeatherData?> fetchWeather({String city = 'Riyadh'}) async {
    final coords = _cities[city] ?? _cities['Riyadh']!;
    final lat = coords['lat']!;
    final lon = coords['lon']!;

    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      '&temperature_unit=celsius'
      '&timezone=auto',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>;

      return WeatherData(
        temperature: (current['temperature_2m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toDouble(),
        city: city,
      );
    } catch (_) {
      return null;
    }
  }
}
