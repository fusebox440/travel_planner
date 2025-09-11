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
