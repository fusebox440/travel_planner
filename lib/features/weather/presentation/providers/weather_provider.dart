import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/weather/data/weather_service.dart';
import 'package:travel_planner/features/weather/domain/models/weather.dart';
import 'package:travel_planner/features/weather/domain/models/forecast.dart';

/// State class for weather data
class WeatherState {
  final Weather? currentWeather;
  final List<Forecast>? forecast;
  final String? errorMessage;
  final bool isLoading;
  final bool useFahrenheit;

  const WeatherState({
    this.currentWeather,
    this.forecast,
    this.errorMessage,
    this.isLoading = false,
    this.useFahrenheit = false,
  });

  WeatherState copyWith({
    Weather? currentWeather,
    List<Forecast>? forecast,
    String? errorMessage,
    bool? isLoading,
    bool? useFahrenheit,
  }) {
    return WeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      useFahrenheit: useFahrenheit ?? this.useFahrenheit,
    );
  }
}

/// Provider for weather service
final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

/// Provider for weather state
final weatherStateProvider =
    StateNotifierProvider<WeatherStateNotifier, WeatherState>((ref) {
  final weatherService = ref.watch(weatherServiceProvider);
  return WeatherStateNotifier(weatherService);
});

/// Notifier class for managing weather state
class WeatherStateNotifier extends StateNotifier<WeatherState> {
  final WeatherService _weatherService;
  String? _lastCity;

  WeatherStateNotifier(this._weatherService) : super(const WeatherState());

  /// Toggle temperature unit between Celsius and Fahrenheit
  void toggleTemperatureUnit() {
    state = state.copyWith(useFahrenheit: !state.useFahrenheit);
  }

  /// Fetch weather data for a city
  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);
    _lastCity = city;

    try {
      final weather = await _weatherService.getCurrentWeather(city);
      final forecast = await _weatherService.getForecast(city);

      state = state.copyWith(
        currentWeather: weather,
        forecast: forecast,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Refresh weather data for the last queried city
  Future<void> refreshWeather() async {
    if (_lastCity == null) return;
    await fetchWeather(_lastCity!);
  }
}
