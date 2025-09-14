/// API keys template for external services
/// Copy this file to api_keys.dart and add your actual API keys
class ApiKeys {
  /// OpenWeatherMap API key
  /// Get your key from: https://openweathermap.org/api
  static const String openWeatherMap = 'YOUR_OPENWEATHERMAP_API_KEY_HERE';

  /// Base URL for OpenWeatherMap API
  static const String openWeatherMapBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  /// Google Maps API key
  /// Get your key from: https://console.cloud.google.com/
  static const String googleMaps = 'YOUR_GOOGLE_MAPS_API_KEY_HERE';

  /// Transit API key (Google Maps Directions API)
  static const String transitApi = 'YOUR_TRANSIT_API_KEY_HERE';

  /// Translation API key (Google Translate API)
  static const String translationApi = 'YOUR_TRANSLATION_API_KEY_HERE';

  /// Firebase configuration
  static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY_HERE';
  static const String firebaseAppId = 'YOUR_FIREBASE_APP_ID_HERE';
  static const String firebaseMessagingSenderId = 'YOUR_FIREBASE_MESSAGING_SENDER_ID_HERE';
  static const String firebaseProjectId = 'YOUR_FIREBASE_PROJECT_ID_HERE';
  static const String firebaseAuthDomain = 'YOUR_FIREBASE_AUTH_DOMAIN_HERE';
  static const String firebaseStorageBucket = 'YOUR_FIREBASE_STORAGE_BUCKET_HERE';
}