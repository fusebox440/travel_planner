import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_planner/core/config/api_keys.dart';
import 'package:travel_planner/features/weather/domain/models/weather.dart';
import 'package:travel_planner/features/weather/domain/models/forecast.dart';

/// Exception thrown when weather data fetching fails
class WeatherException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  WeatherException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'WeatherException: $message ${code != null ? '(Code: $code)' : ''}';
}

class WeatherService {
  final http.Client _client;

  WeatherService._privateConstructor({http.Client? client})
      : _client = client ?? http.Client();
  static final WeatherService _instance = WeatherService._privateConstructor();
  factory WeatherService({http.Client? client}) => client != null
      ? WeatherService._privateConstructor(client: client)
      : _instance;

  static const _weatherCacheKey = 'weather_cache';
  static const _forecastCacheKey = 'forecast_cache';
  late final Box<Weather> _weatherCache;
  late final Box<List<Forecast>> _forecastCache;

  /// Initialize Hive boxes for caching
  Future<void> init() async {
    _weatherCache = await Hive.openBox<Weather>(_weatherCacheKey);
    _forecastCache = await Hive.openBox<List<Forecast>>(_forecastCacheKey);
  }

  /// Get current weather for a city
  Future<Weather> getCurrentWeather(String city) async {
    try {
      // Check cache first
      final cached = _weatherCache.get(city);
      if (cached != null && !cached.isStale) {
        debugPrint('Returning cached weather for $city');
        return cached;
      }

      // Fetch from API
      final url = Uri.parse(
        '${ApiKeys.openWeatherMapBaseUrl}/weather?q=$city&appid=${ApiKeys.openWeatherMap}',
      );

      final response = await _client.get(url).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw WeatherException(
              'Request timed out',
              code: 'TIMEOUT',
            ),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final weather = Weather.fromJson(data, city);

        // Cache the result
        await _weatherCache.put(city, weather);
        return weather;
      }

      throw WeatherException(
        'Failed to fetch weather data',
        code: 'API_ERROR_${response.statusCode}',
      );
    } catch (e) {
      if (e is WeatherException) rethrow;

      // Try to return cached data even if stale
      final cached = _weatherCache.get(city);
      if (cached != null) {
        debugPrint('Returning stale cached weather for $city');
        return cached;
      }

      throw WeatherException(
        'Failed to get weather data',
        code: 'FETCH_ERROR',
        originalError: e,
      );
    }
  }

  /// Get 7-day forecast for a city
  Future<List<Forecast>> getForecast(String city) async {
    try {
      // Check cache first
      final cached = _forecastCache.get(city);
      if (cached != null && !cached.any((f) => f.isStale)) {
        debugPrint('Returning cached forecast for $city');
        return cached;
      }

      // Get coordinates first (required by OneCall API)
      final geoUrl = Uri.parse(
        '${ApiKeys.openWeatherMapBaseUrl}/weather?q=$city&appid=${ApiKeys.openWeatherMap}',
      );

      final geoResponse = await _client.get(geoUrl).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw WeatherException(
              'Request timed out',
              code: 'TIMEOUT',
            ),
          );

      if (geoResponse.statusCode != 200) {
        throw WeatherException(
          'Failed to get city coordinates',
          code: 'GEO_ERROR_${geoResponse.statusCode}',
        );
      }

      final geoData = jsonDecode(geoResponse.body);
      final lat = geoData['coord']['lat'];
      final lon = geoData['coord']['lon'];

      // Fetch forecast using coordinates
      final forecastUrl = Uri.parse(
        '${ApiKeys.openWeatherMapBaseUrl}/onecall?lat=$lat&lon=$lon&exclude=current,minutely,hourly,alerts&appid=${ApiKeys.openWeatherMap}',
      );

      final forecastResponse = await _client.get(forecastUrl).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw WeatherException(
              'Request timed out',
              code: 'TIMEOUT',
            ),
          );

      if (forecastResponse.statusCode == 200) {
        final data = jsonDecode(forecastResponse.body);
        final forecasts = (data['daily'] as List)
            .take(7)
            .map((day) => Forecast.fromJson(day, city))
            .toList();

        // Cache the result
        await _forecastCache.put(city, forecasts);
        return forecasts;
      }

      throw WeatherException(
        'Failed to fetch forecast data',
        code: 'API_ERROR_${forecastResponse.statusCode}',
      );
    } catch (e) {
      if (e is WeatherException) rethrow;

      // Try to return cached data even if stale
      final cached = _forecastCache.get(city);
      if (cached != null) {
        debugPrint('Returning stale cached forecast for $city');
        return cached;
      }

      throw WeatherException(
        'Failed to get forecast data',
        code: 'FETCH_ERROR',
        originalError: e,
      );
    }
  }

  /// Clear weather cache for testing
  @visibleForTesting
  Future<void> clearCache() async {
    await _weatherCache.clear();
    await _forecastCache.clear();
  }
}
