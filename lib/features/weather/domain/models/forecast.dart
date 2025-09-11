import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'forecast.g.dart';

@HiveType(typeId: 11) // Feature models range 10-19
class Forecast {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double minTemperature;

  @HiveField(2)
  final double maxTemperature;

  @HiveField(3)
  final String condition;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String icon;

  @HiveField(6)
  final String cityName;

  @HiveField(7)
  final double humidity;

  @HiveField(8)
  final double windSpeed;

  @HiveField(9)
  final DateTime timestamp;

  const Forecast({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.condition,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.humidity,
    required this.windSpeed,
    required this.timestamp,
  });

  factory Forecast.fromJson(Map<String, dynamic> json, String cityName) {
    final weather = json['weather'][0];
    final temp = json['temp'];

    return Forecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemperature: (temp['min'] as num).toDouble(),
      maxTemperature: (temp['max'] as num).toDouble(),
      condition: weather['main'] as String,
      description: weather['description'] as String,
      icon: weather['icon'] as String,
      cityName: cityName,
      humidity: (json['humidity'] as num).toDouble(),
      windSpeed: (json['wind_speed'] as num).toDouble(),
      timestamp: DateTime.now(),
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Convert min temperature from Kelvin to Celsius
  double get minTemperatureInCelsius => minTemperature - 273.15;

  /// Convert max temperature from Kelvin to Celsius
  double get maxTemperatureInCelsius => maxTemperature - 273.15;

  /// Convert min temperature from Kelvin to Fahrenheit
  double get minTemperatureInFahrenheit =>
      (minTemperature - 273.15) * 9 / 5 + 32;

  /// Convert max temperature from Kelvin to Fahrenheit
  double get maxTemperatureInFahrenheit =>
      (maxTemperature - 273.15) * 9 / 5 + 32;

  /// Format temperature range based on locale
  String formatTemperatureRange({bool useFahrenheit = false}) {
    final min =
        useFahrenheit ? minTemperatureInFahrenheit : minTemperatureInCelsius;
    final max =
        useFahrenheit ? maxTemperatureInFahrenheit : maxTemperatureInCelsius;
    return '${min.round()}° / ${max.round()}°${useFahrenheit ? 'F' : 'C'}';
  }

  /// Check if forecast data is stale (older than 3 hours)
  bool get isStale => DateTime.now().difference(timestamp).inHours > 3;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Forecast &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          minTemperature == other.minTemperature &&
          maxTemperature == other.maxTemperature &&
          condition == other.condition &&
          description == other.description &&
          icon == other.icon &&
          cityName == other.cityName &&
          humidity == other.humidity &&
          windSpeed == other.windSpeed;

  @override
  int get hashCode =>
      date.hashCode ^
      minTemperature.hashCode ^
      maxTemperature.hashCode ^
      condition.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      cityName.hashCode ^
      humidity.hashCode ^
      windSpeed.hashCode;
}
