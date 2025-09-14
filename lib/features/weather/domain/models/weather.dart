import 'package:hive/hive.dart';

part 'weather.g.dart';

/// A model representing weather information for a specific location.
///
/// This class includes comprehensive weather data such as temperature,
/// humidity, wind speed, and weather conditions. It supports both Celsius
/// and Fahrenheit temperature formats and includes utilities for data freshness
/// checking and OpenWeatherMap icon URL generation.
///
/// Example:
/// ```dart
/// final weather = Weather.fromJson(apiResponse, 'London');
/// print(weather.formatTemperature(useFahrenheit: false)); // "20°C"
/// print(weather.isStale); // false (if within 30 minutes)
/// ```
@HiveType(typeId: 10) // Feature models range 10-19
class Weather {
  /// Temperature in Kelvin
  @HiveField(0)
  final double temperature;

  /// "Feels like" temperature in Kelvin
  @HiveField(1)
  final double feelsLike;

  /// Humidity percentage (0-100)
  @HiveField(2)
  final double humidity;

  /// Wind speed in meters per second
  @HiveField(3)
  final double windSpeed;

  /// Main weather condition (e.g., "Clear", "Rain", "Clouds")
  @HiveField(4)
  final String condition;

  /// Detailed weather description
  @HiveField(5)
  final String description;

  /// OpenWeatherMap icon code
  @HiveField(6)
  final String icon;

  /// Name of the city
  @HiveField(7)
  final String cityName;

  /// Timestamp when this weather data was retrieved
  @HiveField(8)
  final DateTime timestamp;

  const Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.timestamp,
  });

  /// Creates a [Weather] instance from OpenWeatherMap API response.
  ///
  /// [json] should be the decoded JSON response from the OpenWeatherMap API.
  /// [cityName] is the name of the city for which weather is being requested.
  ///
  /// Throws [FormatException] if the JSON doesn't contain required fields.
  factory Weather.fromJson(Map<String, dynamic> json, String cityName) {
    try {
      final weather = json['weather'][0];
      final main = json['main'];
      final wind = json['wind'];

      return Weather(
        temperature: (main['temp'] as num).toDouble(),
        feelsLike: (main['feels_like'] as num).toDouble(),
        humidity: (main['humidity'] as num).toDouble(),
        windSpeed: (wind['speed'] as num).toDouble(),
        condition: weather['main'] as String,
        description: weather['description'] as String,
        icon: weather['icon'] as String,
        cityName: cityName,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw FormatException(
        'Invalid weather data format. Please ensure the API response is correct.',
        json,
      );
    }
  }

  /// Returns the URL for the weather condition icon from OpenWeatherMap.
  ///
  /// The returned URL can be used directly in an Image widget:
  /// ```dart
  /// Image.network(weather.iconUrl)
  /// ```
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Converts the temperature from Kelvin to Celsius.
  ///
  /// Returns the temperature in Celsius as a double.
  double get temperatureInCelsius => temperature - 273.15;

  /// Converts the temperature from Kelvin to Fahrenheit.
  ///
  /// Returns the temperature in Fahrenheit as a double.
  double get temperatureInFahrenheit => (temperature - 273.15) * 9 / 5 + 32;

  /// Formats the temperature for display.
  ///
  /// [useFahrenheit] determines whether to format in Fahrenheit (true) or Celsius (false).
  ///
  /// Returns a formatted string with the temperature and unit symbol, e.g., "20°C" or "68°F".
  String formatTemperature({bool useFahrenheit = false}) {
    final temp = useFahrenheit ? temperatureInFahrenheit : temperatureInCelsius;
    return '${temp.round()}°${useFahrenheit ? 'F' : 'C'}';
  }

  /// Formats the wind speed for display.
  ///
  /// [useImperial] determines whether to format in mph (true) or m/s (false).
  ///
  /// Returns a formatted string with the wind speed and unit, e.g., "5 m/s" or "11 mph".
  String formatWindSpeed({bool useImperial = false}) {
    if (useImperial) {
      final mph = windSpeed * 2.237; // Convert m/s to mph
      return '${mph.round()} mph';
    }
    return '${windSpeed.round()} m/s';
  }

  /// Formats the humidity for display.
  ///
  /// Returns a formatted string with the humidity percentage, e.g., "65%".
  String formatHumidity() => '${humidity.round()}%';

  /// Checks if the weather data is stale.
  ///
  /// Weather data is considered stale if it's older than 30 minutes.
  /// This is useful for determining when to refresh the weather data.
  ///
  /// Returns true if the data is older than 30 minutes, false otherwise.
  bool get isStale => DateTime.now().difference(timestamp).inMinutes > 30;

  /// Returns the age of the weather data in minutes.
  int get ageInMinutes => DateTime.now().difference(timestamp).inMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weather &&
          runtimeType == other.runtimeType &&
          temperature == other.temperature &&
          feelsLike == other.feelsLike &&
          humidity == other.humidity &&
          windSpeed == other.windSpeed &&
          condition == other.condition &&
          description == other.description &&
          icon == other.icon &&
          cityName == other.cityName;

  @override
  int get hashCode =>
      temperature.hashCode ^
      feelsLike.hashCode ^
      humidity.hashCode ^
      windSpeed.hashCode ^
      condition.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      cityName.hashCode;
}
