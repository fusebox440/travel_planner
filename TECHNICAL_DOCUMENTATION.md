# Travel Planner - Technical Documentation

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Implemented Features](#implemented-features)  
3. [Data Models](#data-models)
4. [State Management](#state-management)
5. [Testing Status](#testing-status)
6. [Known Issues & Next Steps](#known-issues--next-steps)

## Architecture Overview

### Clean Architecture Pattern
The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Core functionality
│   ├── error/              # Error handling
│   ├── state/              # Base state management
│   ├── storage/            # Local storage abstractions
│   ├── services/           # Core services
│   └── theme/              # App theming
├── features/               # Feature modules
│   ├── assistant/          # AI assistant feature
│   ├── trips/              # Trip management
│   ├── budget/             # Budget tracking
│   ├── maps/               # Maps integration
│   ├── weather/            # Weather service
│   ├── currency/           # Currency conversion
│   ├── packing_list/       # Packing lists
│   └── ...                 # Other features
├── src/models/             # Shared data models
└── widgets/                # Shared UI components
```

### Technology Stack
- **Frontend**: Flutter 3.x with Material Design 3
- **State Management**: Riverpod 2.x (Provider pattern)
- **Local Storage**: Hive 4.x (NoSQL database)
- **Navigation**: Go Router for declarative routing
- **Networking**: HTTP/Dio for API calls
- **Maps**: Google Maps Flutter plugin
- **Testing**: flutter_test with mockito for mocking

## Implemented Features

### 1. Virtual Assistant
#### Core Implementation
- **ChatMessage Model** (Hive TypeId: 1)
  - Properties:
    - ID (UUID)
    - Text content
    - Sender type (user/assistant)
    - Timestamp
    - Attachments (optional List<String>)
    - Intent (for assistant responses)
  - Methods:
    - fromJson/toJson serialization
    - User/Assistant factory constructors
    - Null-safe attachment handling
  - Persistence: Hive storage with adapter

- **ChatSession Model** (Hive TypeId: 2)
  - Properties:
    - ID (UUID)
    - Title
    - Messages list
    - Creation timestamp
    - Trip ID (optional)
  - Features:
    - Message threading
    - Context preservation
    - Trip association
    - Session management

- **Services Architecture**
  - AssistantService: Main response generation with intent routing
  - ChatStorageService: Session persistence with Hive
  - NluService: Intent detection and classification
  - VoiceService: Speech-to-text & text-to-speech
  - SuggestionService: Context-aware smart suggestions

#### Features Status
- [x] Natural conversation UI with message cards
- [x] Voice input/output integration
- [x] Intent detection and routing
- [x] Smart contextual suggestions
- [x] Session management
- [x] Message persistence
- [x] Trip context awareness
- [x] Offline capability
- [x] Error handling

#### Technical Details
```dart
// Core provider implementation
final chatProvider = AsyncNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

// State management
class ChatState {
  final List<ChatSession> sessions;
  final ChatSession? currentSession;
  final List<String> suggestions;
  final bool isListening;
  final bool isTyping;
}

// Voice integration
class VoiceService {
  final SpeechToText _speechToText;
  final FlutterTts _flutterTts;
  final _transcriptController = StreamController<String>.broadcast();
}
```

### 2. Trip Management
#### Core Implementation
- **Trip Model** (`lib/src/models/trip.dart`) - Hive TypeId: 3
  - Properties:
    - ID (UUID)
    - Title
    - Description  
    - Start Date
    - End Date
    - Destination
    - Cover Image (optional)
    - Created/Updated timestamps
  - Methods:
    - create() factory constructor
    - copyWith() for immutability
    - duration calculation property
  - Persistence: Hive storage with adapter

- **Repository Pattern Implementation**
  - ITripRepository interface (`lib/features/trips/domain/repositories/`)
  - TripRepositoryImpl concrete implementation
  - LocalStorageService for Hive operations
  - Clean separation of data access logic

#### Features Status
- [x] CRUD operations for trips with repository pattern
- [x] Trip duration calculation
- [x] Trip details view with cover images
- [x] Trip list view with sorting and filtering
- [x] Trip status tracking
- [x] Hive-based local persistence
- [x] Clean architecture compliance

### 3. Booking Management
#### Core Implementation
- **Booking Model** (`lib/features/booking/models/booking.dart`) - Hive TypeId: 4
  - Properties:
    - ID (UUID)
    - BookingType enum (flight, hotel, car, activity)
    - Provider name
    - Title
    - Details (Map<String, dynamic>)
    - Price (double)
    - Currency Code
    - Date
    - Trip ID (for association)
    - BookingStatus enum (reserved, cancelled, completed)
    - Created At timestamp
  - Persistence: Hive storage with type adapter

- **Services Architecture**
  - BookingService: Core booking logic
  - MockBookingProvider: Development/testing API
  - BookingSearchNotifier: State management
  - Integration with currency conversion

#### Features Status
- [x] Search flights, hotels, cars, activities
- [x] Advanced filtering by price, rating, amenities
- [x] Make and manage reservations
- [x] Cancel reservations with status tracking
- [x] Detailed booking views
- [x] Trip-wise booking organization
- [x] Mock API integration implemented
- [x] Real-time currency conversion

### 4. Budget Management
#### Core Implementation
- **Expense Model** (`lib/src/models/expense.dart`) - Hive TypeId: 5
  - Properties:
    - ID (UUID)
    - Trip ID (foreign key)
    - Amount (double)
    - Original Currency
    - Base Currency (for calculations)
    - Expense Category enum
    - Date
    - Payer ID
    - Split With IDs (List<String>)
    - Description
    - Receipt Image (optional)
  - Advanced features:
    - Automatic currency conversion
    - Expense splitting logic
    - Receipt attachment

- **Budget Service** (`lib/features/budget/data/budget_service.dart`)
  - Async currency conversion methods
  - Real-time expense calculations
  - Multi-currency budget tracking
  - Expense categorization and analysis

#### Features Status
- [x] Add/Edit/Delete expenses with proper validation
- [x] Category-wise expense tracking and filtering
- [x] Multi-currency support with real-time conversion
- [x] Expense splitting among multiple users
- [x] Receipt attachment and storage
- [x] Basic expense reports and summaries

## Data Models & Type ID Management

### Critical Issue: Hive Type ID Conflicts
**Current Status**: Multiple type ID conflicts preventing code generation
- Multiple models using same typeId values (4, 5, 6, 7, 10, 12, 13)
- This prevents proper Hive adapter generation and causes runtime conflicts

**Type ID Assignment Strategy**:
```
0-9: Core Models (Trip, Activity, Day, Expense, etc.)
10-19: Feature Models (Assistant, Booking, Weather, etc.) 
20-29: Enum Types (Categories, Status, etc.)
30+: Future Extensions
```

### Detected Conflicts: RESOLVED ✅
**New Type ID Assignments**:
```
Core Models (0-9):
- 0: Trip 
- 1: Day
- 2: Activity  
- 3: PackingItem (moved from 7)
- 4: PackingList (moved from 13)
- 5: Companion (moved from 12)
- 6: Expense (moved from 3)

Feature Models (10-19):
- 10: Weather (moved from 4)
- 11: Forecast (moved from 5) 
- 12: Place (moved from 5)
- 13: Itinerary (moved from 7)
- 14: ItineraryDay (moved from 8)
- 15: Booking (moved from 6)
- 16: ItineraryItem (moved from 10)
- 17: ChatSession (moved from 13)
- 18: ChatMessage (moved from 12)
- 19: Available

Enum Types (20-29):
- 20: BookingType (moved from 4)
- 21: BookingStatus (moved from 5)
- 22: ItineraryItemType (moved from 9)
- 23: MessageSender (moved from 11)
- 24: ExpenseCategory (moved from 10)
- 25-29: Available
```

**Resolution Status**: All type ID conflicts resolved, ready for code generation

### 3. Maps Integration
#### Core Implementation
- Google Maps integration
- Location services
- Permission handling

#### Features
- [x] Display trip locations
- [x] Current location tracking
- [x] Basic route display
- [x] Location search
- [x] Basic POI display

### 4. Weather Feature
#### Core Implementation
- **Weather Service**
  - Current weather
  - 5-day forecast
  - Weather alerts
  - Unit conversion

#### Features
- [x] Weather display for destinations
- [x] Temperature unit conversion
- [x] Weather icons and descriptions
- [x] Basic weather alerts
- [x] Comprehensive unit tests

### 5. Currency Conversion
#### Core Implementation
- **Currency Service**
  - Real-time exchange rates
  - Offline rate storage
  - Rate caching
  - Multiple currency support

#### Features
- [x] Real-time conversion
- [x] Offline conversion
- [x] Rate history
- [x] Popular currency pairs
- [x] Unit tests

### 6. Packing List
#### Core Implementation
- **PackingList Model**
  - Properties:
    - ID
    - TripID
    - Items
    - Categories
  - Methods:
    - addItem()
    - removeItem()
    - toggleItem()
    - calculateProgress()

#### Features
- [x] Create/Edit lists
- [x] Item categories
- [x] Check/uncheck items
- [x] Progress tracking
- [x] Basic templates

## Technical Architecture

### 1. State Management (Implemented)
```dart
// Base state implementation
abstract class BaseState {
  final bool isLoading;
  final String? error;
  final bool isInitialized;
}

// Base state notifier
abstract class BaseStateNotifier<T extends BaseState> extends StateNotifier<T> {
  // Error handling
  // Loading state management
  // State persistence
}
```

### 2. Data Layer (Implemented)
```dart
// Repository pattern
abstract class BaseRepository<T> {
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
  Future<T?> get(String id);
  Future<List<T>> getAll();
}

// Offline storage
class OfflineStorage {
  // Hive implementation
  // Cache management
  // Data synchronization
}
```

### 3. Error Handling (Implemented)
```dart
class AppErrorHandler {
  // Crashlytics integration
  // User-friendly messages
  // Error logging
  // Error reporting
}
```

### 4. Analytics (Implemented)
```dart
class Analytics {
  // Screen tracking
  // Custom events
  // User properties
  // Performance metrics
}
```

## Infrastructure

### 1. CI/CD Pipeline (Implemented)
```yaml
name: CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk
```

### 2. Performance Optimization (Implemented)
```dart
class PerformanceOptimizer {
  // Memory caching
  // Widget optimization
  // List view optimization
  // Resource management
}
```

## Pending Features

### 1. Enhanced Booking Features
- [ ] Real API integrations:
  ```dart
  // Integration with actual booking APIs
  class BookingApiConfig {
    // Skyscanner/Amadeus for flights
    // Booking.com/Hotels.com for hotels
    // Rental car providers
    // GetYourGuide/Viator for activities
  }
  ```
- [ ] Advanced filtering
- [ ] Price alerts
- [ ] Booking recommendations
- [ ] E-ticket generation
- [ ] Calendar integration

### 2. Review System
- [ ] Models needed:
  ```dart
  class Review {
    String id;
    String placeId;
    String userId;
    double rating;
    String content;
    List<String> photos;
    DateTime createdAt;
  }
  ```
- [ ] Review CRUD operations
- [ ] Rating calculation
- [ ] Photo management
- [ ] Review moderation

### 2. Translation Service
- [ ] Text translation API integration
- [ ] Offline translation support
- [ ] Language detection
- [ ] Phrase book
- [ ] Voice translation

### 3. Advanced Trip Features
- [ ] Trip sharing
- [ ] Trip templates
- [ ] Activity scheduling
- [ ] Trip recommendations
- [ ] Travel alerts

### 4. Enhanced Maps Features
- [ ] Offline maps
- [ ] Custom markers
- [ ] Route optimization
- [ ] Place details
- [ ] Favorite places

### 5. Budget Analytics
- [ ] Expense trends
- [ ] Budget forecasting
- [ ] Category analysis
- [ ] Split expense settlement
- [ ] Export reports

## Technical Debt

### 1. Testing
- [ ] Integration tests
- [ ] Widget tests for all screens
- [ ] Performance tests
- [ ] Load testing
- [ ] E2E tests

### 2. Documentation
- [ ] API documentation
- [ ] Code comments
- [ ] Architecture diagrams
- [ ] User documentation
- [ ] Contribution guidelines

### 3. Performance
- [ ] Image optimization
- [ ] Network caching
- [ ] State management optimization
- [ ] Memory leak prevention
- [ ] Startup time optimization

## Known Issues

1. Booking Feature
   - Using mock data (API integration pending)
   - Limited filter options
   - Basic UI implementation
   - Need real-world testing
   - Payment integration pending

2. Performance
   - Large lists can cause jank
   - Image loading optimization needed
   - State management memory usage

2. UI/UX
   - Dark mode inconsistencies
   - Accessibility improvements needed
   - Responsive design issues

3. Technical
   - Firebase setup required
   - API keys management
   - Offline sync conflicts

## Next Steps Priority List

### High Priority
1. Complete core feature tests
2. Implement offline maps
3. Add error boundary widgets
4. Optimize performance
5. Enhance error handling

### Medium Priority
1. Implement review system
2. Add translation service
3. Enhance budget analytics
4. Add trip templates
5. Improve UI/UX

### Low Priority
1. Add more animations
2. Implement voice features
3. Add social features
4. Enhance accessibility
5. Add more customization options

## Required Resources

### APIs Needed
1. Translation API
2. Places API
3. Weather API (enhanced)
4. Currency API (enhanced)
5. Maps API (offline support)

### Development Tools
1. Firebase setup
2. Analytics implementation
3. Performance monitoring
4. Test coverage tools
5. Documentation generation

This document will be updated as features are implemented or requirements change.
