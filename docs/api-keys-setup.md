# API Keys Setup Guide

This project requires several API keys for full functionality. This guide explains how to set them up securely.

## Required API Keys

### 1. OpenWeatherMap API
- **Purpose**: Weather information and forecasts
- **Get your key**: https://openweathermap.org/api
- **Free tier**: Available with basic features

### 2. Google Maps API
- **Purpose**: Maps, places search, and directions
- **Get your key**: https://console.cloud.google.com/
- **Required APIs**: 
  - Maps JavaScript API
  - Places API
  - Directions API

### 3. Transit API (Optional)
- **Purpose**: Public transportation information
- **Get your key**: Depends on your region's transit API provider

### 4. Translation API (Optional)
- **Purpose**: Multi-language support
- **Get your key**: Google Translate API or LibreTranslate
- **Note**: Currently uses environment variables

### 5. Firebase Configuration
- **Purpose**: Authentication, database, analytics
- **Get your config**: https://console.firebase.google.com/
- **Required services**:
  - Authentication
  - Firestore Database
  - Analytics
  - Crashlytics
  - Performance Monitoring
  - Storage

## Setup Instructions

### Step 1: Copy API Keys Template
```bash
cp lib/core/config/api_keys_template.dart lib/core/config/api_keys.dart
```

### Step 2: Add Your API Keys
Edit `lib/core/config/api_keys.dart` and replace all placeholder values:

```dart
class ApiKeys {
  static const String openWeatherMap = 'your_actual_openweathermap_key';
  static const String googleMaps = 'your_actual_google_maps_key';
  static const String transitApi = 'your_actual_transit_key';
  static const String translationApi = 'your_actual_translation_key';
  
  // Firebase keys (update firebase_options.dart instead)
  // These are managed in firebase_options.dart file
}
```

### Step 3: Update Firebase Configuration
1. Download `google-services.json` from Firebase Console
2. Place it in the `android/app/` directory
3. Update `lib/firebase_options.dart` with your Firebase configuration

### Step 4: Set Environment Variables (for Translation)
For translation services, you can also use environment variables:

```bash
export TRANSLATION_API_KEY=your_translation_api_key
export TRANSLATION_API_URL=https://your-translation-service.com
```

## Security Notes

- ✅ `api_keys.dart` is already in `.gitignore`
- ✅ `google-services.json` is already in `.gitignore`
- ✅ Firebase options use placeholder values by default
- ✅ Translation service supports environment variables

## Verification

After setting up your API keys, you can test the following features:

1. **Weather**: Check if weather data loads on the home screen
2. **Maps**: Verify map functionality in the maps tab
3. **Firebase**: Test user authentication and data sync
4. **Translation**: Test language switching if implemented

## Troubleshooting

### Common Issues

1. **Maps not loading**: Check Google Maps API key and enabled APIs
2. **Weather not showing**: Verify OpenWeatherMap API key
3. **Firebase errors**: Ensure all required Firebase services are enabled
4. **Build failures**: Make sure `api_keys.dart` exists with valid syntax

### API Key Validation

Most API services provide test endpoints to validate your keys:

- OpenWeatherMap: `https://api.openweathermap.org/data/2.5/weather?q=London&appid=YOUR_KEY`
- Google Maps: Check the Maps JavaScript API in Google Cloud Console

## Support

If you encounter issues with API key setup:

1. Check the official documentation for each service
2. Verify your API keys have the necessary permissions
3. Ensure billing is set up for paid services (Google Maps)
4. Check API quotas and limits

## Important Security Reminders

- ⚠️ Never commit actual API keys to version control
- ⚠️ Use environment variables in production
- ⚠️ Regularly rotate your API keys
- ⚠️ Monitor API usage to detect unauthorized access