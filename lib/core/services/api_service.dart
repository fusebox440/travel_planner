import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl =
      'https://api.example.com'; // Replace with your actual base URL

  // Weather API endpoints
  static const String _weatherEndpoint = '/weather';

  // Currency API endpoints
  static const String _currencyEndpoint = '/currency/convert';

  // Maps API endpoints
  static const String _placesEndpoint = '/places';
  static const String _directionsEndpoint = '/directions';

  // Singleton instance
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Weather API Methods
  Future<Map<String, dynamic>> getWeatherForecast(String location) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_weatherEndpoint?location=$location'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  // Currency API Methods
  Future<double> convertCurrency(
    String from,
    String to,
    double amount,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_currencyEndpoint?from=$from&to=$to&amount=$amount'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result'];
    } else {
      throw Exception('Failed to convert currency');
    }
  }

  // Places API Methods
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_placesEndpoint?query=$query'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['places']);
    } else {
      throw Exception('Failed to search places');
    }
  }

  Future<Map<String, dynamic>> getDirections(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$_directionsEndpoint?'
          'startLat=$startLat&startLng=$startLng&'
          'endLat=$endLat&endLng=$endLng'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get directions');
    }
  }
}
