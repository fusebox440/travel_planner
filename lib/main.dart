import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_planner/core/router/app_router.dart';

// Import all Hive models for adapter registration
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/activity.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:travel_planner/src/models/item_category.dart';
import 'package:travel_planner/features/weather/domain/models/weather.dart';
import 'package:travel_planner/features/weather/domain/models/forecast.dart';
import 'package:travel_planner/features/maps/domain/models/place.dart';
import 'package:travel_planner/features/itinerary/models/itinerary.dart';
import 'package:travel_planner/features/booking/models/booking.dart';
import 'package:travel_planner/features/assistant/models/chat_session.dart';
import 'package:travel_planner/features/assistant/models/chat_message.dart';

import 'package:travel_planner/core/services/local_storage_service.dart';
import 'package:travel_planner/core/services/notification_service.dart';
import 'package:travel_planner/core/services/onboarding_service.dart';
import 'package:travel_planner/core/services/settings_service.dart';
import 'package:travel_planner/core/theme/app_theme.dart';
import 'package:travel_planner/firebase_options.dart';
import 'package:travel_planner/core/error/error_handler.dart';
import 'package:travel_planner/core/storage/offline_storage.dart';
import 'package:travel_planner/core/analytics/analytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase Crashlytics
  if (!kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }

  // Initialize Analytics
  Analytics().initialize();

  // Initialize Error Handler
  AppErrorHandler.init();

  // Initialize Offline Storage
  await OfflineStorage.init();

  // Initialize Hive and register adapters
  await Hive.initFlutter();

  // Core Models (0-9)
  Hive.registerAdapter(TripAdapter()); // typeId: 0
  Hive.registerAdapter(DayAdapter()); // typeId: 1
  Hive.registerAdapter(ActivityAdapter()); // typeId: 2
  Hive.registerAdapter(PackingItemAdapter()); // typeId: 3
  Hive.registerAdapter(PackingListAdapter()); // typeId: 4
  Hive.registerAdapter(CompanionAdapter()); // typeId: 5
  Hive.registerAdapter(ExpenseAdapter()); // typeId: 6

  // Feature Models (10-19)
  Hive.registerAdapter(WeatherAdapter()); // typeId: 10
  Hive.registerAdapter(ForecastAdapter()); // typeId: 11
  Hive.registerAdapter(PlaceAdapter()); // typeId: 12
  Hive.registerAdapter(ItineraryAdapter()); // typeId: 13
  Hive.registerAdapter(ItineraryDayAdapter()); // typeId: 14
  Hive.registerAdapter(BookingAdapter()); // typeId: 15
  Hive.registerAdapter(ItineraryItemAdapter()); // typeId: 16
  Hive.registerAdapter(ChatSessionAdapter()); // typeId: 17
  Hive.registerAdapter(ChatMessageAdapter()); // typeId: 18

  // Enum Types (20-29)
  Hive.registerAdapter(BookingTypeAdapter()); // typeId: 20
  Hive.registerAdapter(BookingStatusAdapter()); // typeId: 21
  Hive.registerAdapter(ItineraryItemTypeAdapter()); // typeId: 22
  Hive.registerAdapter(MessageSenderAdapter()); // typeId: 23
  Hive.registerAdapter(ExpenseCategoryAdapter()); // typeId: 24
  Hive.registerAdapter(ItemCategoryAdapter()); // typeId: 25

  // Open necessary boxes
  await Hive.openBox<Booking>('bookings');
  await Hive.openBox<PackingItem>('packing_items');
  await Hive.openBox<PackingList>('packing_lists');

  // Initialize Services
  await LocalStorageService().init();
  await NotificationService().init();
  await SettingsService().init();
  await OnboardingService().init();

  // Initialize Performance Monitoring
  if (!kDebugMode) {
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  }

  // Determine the initial route
  final hasSeenOnboarding = OnboardingService().hasSeenOnboarding();
  final initialLocation = hasSeenOnboarding ? '/' : '/onboarding';

  runApp(
    ProviderScope(
      child: MyApp(initialLocation: initialLocation),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final String initialLocation;
  const MyApp({super.key, required this.initialLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pass the initial location to the router provider
    final router = ref.watch(appRouterProvider(initialLocation));
    final themeMode = ref.watch(themeProvider);

    final ThemeData theme;
    switch (themeMode) {
      case AppThemeMode.light:
        theme = AppTheme.lightTheme;
        break;
      case AppThemeMode.dark:
        theme = AppTheme.darkTheme;
        break;
      case AppThemeMode.grey:
        theme = AppTheme.greyTheme;
        break;
    }

    return MaterialApp.router(
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}
