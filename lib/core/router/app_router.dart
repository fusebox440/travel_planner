import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_planner/features/onboarding/onboarding_screen.dart';
import 'package:travel_planner/features/packing_list/presentation/screens/packing_list_screen.dart';
import 'package:travel_planner/features/settings/presentation/screens/about_screen.dart';
import 'package:travel_planner/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:travel_planner/features/settings/presentation/screens/settings_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_create_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_detail_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_edit_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_list_screen.dart';

// A provider that takes the initial location as a parameter
final appRouterProvider = Provider.family<GoRouter, String>((ref, initialLocation) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const TripListScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
        // Nested routes for sub-pages of settings
        routes: [
          GoRoute(
            path: 'about',
            name: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
          GoRoute(
            path: 'privacy',
            name: 'privacy',
            builder: (context, state) => const PrivacyPolicyScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/trip/create',
        name: 'trip_create',
        builder: (context, state) => const TripCreateScreen(),
      ),
      GoRoute(
        path: '/trip/:id',
        name: 'trip_detail',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return TripDetailScreen(tripId: tripId);
        },
        // Nested route for the packing list, associated with a specific trip
        routes: [
          GoRoute(
            path: 'packing-list',
            name: 'packing_list',
            builder: (context, state) {
              final tripId = state.pathParameters['id']!;
              return PackingListScreen(tripId: tripId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/trip/:id/edit',
        name: 'trip_edit',
        builder: (context, state) {
          final tripId = state.pathParameters['id']!;
          return TripEditScreen(tripId: tripId);
        },
      ),
    ],
  );
});