import 'package:get/get.dart';
import 'package:tour_app/services/weather_service.dart';

class WeatherController extends GetxController {
  final WeatherService _weatherService = WeatherService();

  final Rx<WeatherData?> weather = Rx<WeatherData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString selectedCity = 'Riyadh'.obs;

  static const List<String> cities = [
    'Riyadh',
    'Jeddah',
    'AlUla',
    'Mecca',
    'Medina',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchWeather();
  }

  Future<void> fetchWeather({String? city}) async {
    if (city != null) selectedCity.value = city;
    isLoading.value = true;
    hasError.value = false;
    weather.value = await _weatherService.fetchWeather(city: selectedCity.value);
    if (weather.value == null) hasError.value = true;
    isLoading.value = false;
  }
}
