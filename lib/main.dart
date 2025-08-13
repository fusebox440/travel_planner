import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/router/app_router.dart';
import 'package:travel_planner/core/services/local_storage_service.dart';
import 'package:travel_planner/core/services/notification_service.dart';
import 'package:travel_planner/core/services/onboarding_service.dart';
import 'package:travel_planner/core/services/settings_service.dart';
import 'package:travel_planner/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize all services
  await LocalStorageService().init();
  await NotificationService().init();
  await SettingsService().init();
  await OnboardingService().init(); // Initialize onboarding service

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