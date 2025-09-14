import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:travel_planner/features/weather/data/weather_service.dart';
import 'package:travel_planner/features/weather/domain/models/weather.dart';
import 'package:travel_planner/features/weather/domain/models/forecast.dart';

@GenerateMocks([], customMocks: [MockSpec<http.Client>(as: #MockHttpClient)])
import 'weather_test.mocks.dart';

void main() {
  group('WeatherService', () {
    const city = 'London';
    final mockWeatherResponse = {
      'weather': [
        {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
      ],
      'main': {
        'temp': 293.15,
        'feels_like': 292.15,
        'humidity': 70,
      },
      'wind': {'speed': 3.5},
      'name': city,
      'coord': {'lat': 51.5074, 'lon': -0.1278},
    };

    final mockForecastResponse = {
      'daily': List.generate(
          7,
          (index) => {
                'dt': DateTime.now()
                        .add(Duration(days: index))
                        .millisecondsSinceEpoch ~/
                    1000,
                'temp': {'min': 290.15, 'max': 295.15},
                'weather': [
                  {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
                ],
                'humidity': 70,
                'wind_speed': 3.5,
              })
    };

    late MockHttpClient mockClient;
    late WeatherService weatherService;

    setUp(() {
      mockClient = MockHttpClient();
      weatherService = WeatherService(client: mockClient);
    });

    test('getCurrentWeather returns Weather object on success', () async {
      when(mockClient.get(argThat(isA<Uri>()))).thenAnswer(
          (_) async => http.Response(json.encode(mockWeatherResponse), 200));

      final weather = await weatherService.getCurrentWeather(city);

      expect(weather, isA<Weather>());
      expect(weather.cityName, equals(city));
      expect(weather.condition, equals('Clear'));
      expect(weather.description, equals('clear sky'));
      expect(weather.temperature, equals(293.15));
      expect(weather.humidity, equals(70));
      expect(weather.windSpeed, equals(3.5));
    });

    test('getCurrentWeather throws exception on API error', () async {
      when(mockClient.get(argThat(isA<Uri>())))
          .thenAnswer((_) async => http.Response('Not found', 404));

      expect(
        () => weatherService.getCurrentWeather(city),
        throwsA(isA<WeatherException>()),
      );
    });

    test('getForecast returns List<Forecast> on success', () async {
      // Mock both API calls (weather for coordinates and forecast)
      when(mockClient.get(argThat(isA<Uri>()))).thenAnswer((invocation) {
        final url = invocation.positionalArguments[0] as Uri;
        if (url.toString().contains('onecall')) {
          return Future.value(
              http.Response(json.encode(mockForecastResponse), 200));
        }
        return Future.value(
            http.Response(json.encode(mockWeatherResponse), 200));
      });

      final forecasts = await weatherService.getForecast(city);

      expect(forecasts, isA<List<Forecast>>());
      expect(forecasts.length, equals(7));

      final firstForecast = forecasts.first;
      expect(firstForecast.cityName, equals(city));
      expect(firstForecast.condition, equals('Clear'));
      expect(firstForecast.minTemperature, equals(290.15));
      expect(firstForecast.maxTemperature, equals(295.15));
      expect(firstForecast.humidity, equals(70));
      expect(firstForecast.windSpeed, equals(3.5));
    });

    test('getForecast throws WeatherException on error', () {
      when(mockClient.get(argThat(isA<Uri>())))
          .thenAnswer((_) async => http.Response('Server error', 500));

      expect(
        () => weatherService.getForecast(city),
        throwsA(isA<WeatherException>()),
      );
    });

    test('Weather temperature conversions are correct', () {
      const kelvin = 293.15; // 20°C, 68°F
      final weather = Weather(
        temperature: kelvin,
        feelsLike: kelvin,
        humidity: 70,
        windSpeed: 3.5,
        condition: 'Clear',
        description: 'clear sky',
        icon: '01d',
        cityName: city,
        timestamp: DateTime.now(),
      );

      expect(weather.temperatureInCelsius, closeTo(20, 0.1));
      expect(weather.temperatureInFahrenheit, closeTo(68, 0.1));
      expect(
        weather.formatTemperature(useFahrenheit: false),
        equals('20°C'),
      );
      expect(
        weather.formatTemperature(useFahrenheit: true),
        equals('68°F'),
      );
    });

    test('Forecast temperature conversions are correct', () {
      const minKelvin = 290.15; // 17°C, 62.6°F
      const maxKelvin = 295.15; // 22°C, 71.6°F
      final forecast = Forecast(
        date: DateTime.now(),
        minTemperature: minKelvin,
        maxTemperature: maxKelvin,
        condition: 'Clear',
        description: 'clear sky',
        icon: '01d',
        cityName: city,
        humidity: 70,
        windSpeed: 3.5,
        timestamp: DateTime.now(),
      );

      expect(forecast.minTemperatureInCelsius, closeTo(17, 0.1));
      expect(forecast.maxTemperatureInCelsius, closeTo(22, 0.1));
      expect(forecast.minTemperatureInFahrenheit, closeTo(62.6, 0.1));
      expect(forecast.maxTemperatureInFahrenheit, closeTo(71.6, 0.1));
      expect(
        forecast.formatTemperatureRange(useFahrenheit: false),
        equals('17°C - 22°C'),
      );
      expect(
        forecast.formatTemperatureRange(useFahrenheit: true),
        equals('63°F - 72°F'),
      );
    });

    test('Weather model handles missing optional fields', () {
      final minimalWeatherResponse = {
        'weather': [
          {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
        ],
        'main': {
          'temp': 293.15,
          'feels_like': 293.15,
          'humidity': 70,
        },
        'name': city,
      };

      when(mockClient.get(argThat(isA<Uri>()))).thenAnswer(
          (_) async => http.Response(json.encode(minimalWeatherResponse), 200));

      expect(
        () => weatherService.getCurrentWeather(city),
        returnsNormally,
      );
    });
  });
}
