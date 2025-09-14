# API Keys Setup Instructions

## Overview
This directory contains API key configuration files for the Travel Planner app. You need to configure these keys for full functionality.

## Required API Keys

### 1. Google Maps API Key (Required)
- **Service:** Google Maps Platform
- **URL:** https://console.cloud.google.com/google/maps-apis
- **Usage:** Map display, geocoding, places search
- **Setup Steps:**
  1. Go to Google Cloud Console
  2. Create a new project or select existing
  3. Enable Google Maps SDK for Android/iOS
  4. Create API key in Credentials section
  5. Restrict key to your app (recommended)

### 2. OpenWeather API Key (Required)  
- **Service:** OpenWeatherMap
- **URL:** https://openweathermap.org/api
- **Usage:** Weather information and forecasts
- **Setup Steps:**
  1. Sign up at OpenWeatherMap
  2. Get free API key from dashboard
  3. Note: Free tier allows 60 calls/minute

## Optional API Keys

### 3. Google Translate API Key
- **Service:** Google Cloud Translation
- **URL:** https://cloud.google.com/translate/docs/setup
- **Usage:** Text translation feature
- **Note:** Paid service after free tier

### 4. Google Places API Key
- **Service:** Google Places API
- **URL:** https://console.cloud.google.com/google/maps-apis
- **Usage:** Enhanced place search and details
- **Note:** Can use same key as Google Maps

### 5. Currency Exchange API Key
- **Service:** Fixer.io or OpenExchangeRates
- **URL:** https://fixer.io/dashboard
- **Usage:** Real-time currency conversion
- **Note:** Free tier available

### 6. Flight Search API Key
- **Service:** Skyscanner API (via RapidAPI)
- **URL:** https://rapidapi.com/apidojo/api/skyscanner1
- **Usage:** Flight search and booking
- **Note:** Freemium model

## Configuration Instructions

1. **Open the file:** `config/keys/api_keys.dart`
2. **Replace placeholders** with your actual API keys:
   ```dart
   static const String googleMapsApiKey = 'AIzaSyC...'; // Your actual key
   ```
3. **Save the file**
4. **Restart the app** to apply changes

## Security Best Practices

### For Development
- Keep API keys in the `api_keys.dart` file
- Add sensitive config files to `.gitignore`
- Never commit real API keys to version control

### For Production
- Use environment variables or secure key management
- Implement key rotation policies
- Monitor API usage and set up alerts
- Use API key restrictions (IP, app, referrer)

## Troubleshooting

### Common Issues
1. **"API key not valid"** - Check key format and restrictions
2. **"Quota exceeded"** - Check your API usage limits
3. **"Service not enabled"** - Enable required APIs in Cloud Console
4. **"Referrer not allowed"** - Update API key restrictions

### Testing Configuration
The app includes a validation method to check if keys are properly configured:
```dart
if (!ApiKeys.isConfigured) {
  print('Unconfigured keys: ${ApiKeys.unconfiguredKeys}');
}
```

## Support
- Google Maps: https://developers.google.com/maps/support
- OpenWeather: https://openweathermap.org/support
- Firebase: https://firebase.google.com/support

---
**Last Updated:** December 2024




# API Documentation and Keys Management

## Required APIs

### 1. Google Maps API
- **Purpose**: Maps integration, location services, and place details
- **Required APIs**:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Places API
  - Geocoding API
  - Directions API
- **Environment Variables**:
  ```dart
  static const String GOOGLE_MAPS_API_KEY = 'YOUR_API_KEY';
  ```
- **Setup Instructions**:
  1. Go to Google Cloud Console
  2. Create a new project
  3. Enable required APIs
  4. Create credentials
  5. Add restrictions (Android, iOS, Web)

### 2. Weather API (OpenWeatherMap)
- **Purpose**: Weather forecasts and alerts
- **Required Endpoints**:
  - Current weather
  - 5-day forecast
  - Weather alerts
- **Environment Variables**:
  ```dart
  static const String WEATHER_API_KEY = 'YOUR_API_KEY';
  ```
- **Base URLs**:
  - Production: `https://api.openweathermap.org/data/2.5`
  - Documentation: `https://openweathermap.org/api`

### 3. Currency Exchange API
- **Purpose**: Real-time currency conversion
- **Required Endpoints**:
  - Latest rates
  - Historical rates
  - Currency list
- **Environment Variables**:
  ```dart
  static const String CURRENCY_API_KEY = 'YOUR_API_KEY';
  ```
- **Rate Limits**: Document your API plan limits
- **Caching Strategy**: Implement 1-hour cache for rates

### 4. Firebase Configuration
- **Required Services**:
  - Firebase Analytics
  - Crashlytics
  - Performance Monitoring
  - Cloud Messaging
- **Environment Setup**:
  ```dart
  // firebase_options.dart
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
  );
  ```

### 5. Translation API (Google Cloud Translation)
- **Purpose**: Multi-language support
- **Required Features**:
  - Text translation
  - Language detection
  - Document translation
- **Environment Variables**:
  ```dart
  static const String TRANSLATION_API_KEY = 'YOUR_API_KEY';
  ```

## API Keys Management

### Local Development
1. Create `lib/core/config/api_keys.dart`:
```dart
class ApiKeys {
  static const String googleMapsKey = 'YOUR_KEY';
  static const String weatherKey = 'YOUR_KEY';
  static const String currencyKey = 'YOUR_KEY';
  static const String translationKey = 'YOUR_KEY';
}
```

### Production Environment
1. Use CI/CD environment variables
2. Implement key encryption
3. Use Firebase Remote Config for dynamic keys

## Error Handling

### API Error Response Structure
```dart
class ApiError {
  final String code;
  final String message;
  final String? details;
  
  ApiError({
    required this.code,
    required this.message,
    this.details,
  });
}
```

### Error Codes
- `AUTH_ERROR`: API key issues
- `RATE_LIMIT`: Exceeded API limits
- `NETWORK_ERROR`: Connection issues
- `INVALID_REQUEST`: Bad request parameters
- `SERVER_ERROR`: API server issues

## Rate Limiting & Caching

### Rate Limit Implementation
```dart
class ApiRateLimiter {
  final String apiKey;
  final int maxRequests;
  final Duration window;
  
  // Implementation
}
```

### Caching Strategy
```dart
class ApiCache {
  final Duration defaultDuration;
  final int maxSize;
  
  // Implementation
}
```

## Security Guidelines

1. Never commit API keys to version control
2. Implement key rotation mechanism
3. Use API key restrictions (IP, domain, etc.)
4. Monitor API usage and costs
5. Implement request signing when required

## Testing

### API Mock Data
```dart
class MockApiResponses {
  static const Map<String, dynamic> weatherResponse = {
    // Mock data
  };
  
  static const Map<String, dynamic> currencyResponse = {
    // Mock data
  };
}
```

### Testing Guidelines
1. Use mock responses for tests
2. Test API error scenarios
3. Test rate limiting
4. Test caching behavior
5. Test offline behavior

## Monitoring

1. Track API response times
2. Monitor rate limit usage
3. Track API errors
4. Monitor cache hit rates
5. Track API costs
