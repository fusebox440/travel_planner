# Travel Planner Documentation

## Overview
Travel Planner is a comprehensive mobile application built with Flutter that helps users plan and manage their travels efficiently. The app includes features for trip management, expense tracking, currency conversion, language translation, packing lists, and more.

## Architecture
The project follows a feature-first architecture with clean separation of concerns:

```
lib/
├── core/              # Core functionality and shared services
│   ├── design/        # Design system components
│   ├── motion/        # Animation configurations
│   ├── router/        # Application routing
│   ├── services/      # Core services (local storage, etc.)
│   └── theme/         # App theming and styling
├── features/          # Feature modules
│   ├── budget/        # Budget management
│   ├── currency/      # Currency conversion
│   ├── expenses/      # Expense tracking
│   ├── onboarding/   # User onboarding
│   ├── packing_list/ # Packing checklist
│   ├── settings/     # App settings
│   ├── translator/   # Language translation
│   └── trips/        # Trip management
├── src/              # Shared models and utilities
│   └── models/       # Data models
└── widgets/          # Reusable UI components
```

## Features

### Trip Management
- Create and manage trips
- Trip details and itinerary
- Location-based services
- Trip sharing capabilities

### Budget & Expenses
- Expense tracking and categorization
- Budget planning and monitoring
- Multi-currency support
- Expense analytics and reports

### Currency Converter
- Real-time exchange rates
- Offline rate caching
- Multiple currency support
- Favorite currencies
- Smart formatting by currency

### Translation
- Multi-language support
- Phrase translation
- Offline language packs
- Travel-specific phrases

### Packing List
- Smart packing suggestions
- Custom item categories
- Checklist management
- Shareable packing lists

### Settings & Preferences
- App customization
- Data management
- Backup and sync
- Notification preferences

## Technical Stack

### Core Dependencies
- Flutter SDK
- Riverpod for state management
- GoRouter for navigation
- Hive for local storage
- HTTP for network requests

### UI Components
- Google Fonts
- Flutter SVG
- Lottie for animations
- Cached Network Image
- FL Chart for analytics

### Features
- Google Maps Flutter
- Geolocator
- Image Picker & Compression
- Share Plus
- Local Notifications

### Development
- Build Runner
- Hive Generator
- Flutter Lints
- Flutter Test

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / VS Code
- iOS development setup (for iOS builds)

### Setup
1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build`
4. Configure environment variables
5. Run the app: `flutter run`

## Contributing

### Code Style
- Follow official Dart style guide
- Use meaningful variable names
- Document public APIs
- Write unit tests for new features

### Git Workflow
1. Create feature branch
2. Implement changes
3. Write/update tests
4. Submit pull request

## Testing
- Unit tests in `/test`
- Widget tests for UI components
- Integration tests for features
- Run tests: `flutter test`

## License
Copyright © 2025 Lakshya Khetan
All rights reserved.
