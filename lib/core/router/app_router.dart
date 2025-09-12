import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_planner/features/assistant/ui/screens/chat_screen.dart';
import 'package:travel_planner/features/budget/presentation/screens/add_expense_screen.dart';
import 'package:travel_planner/features/budget/presentation/screens/budget_overview_screen.dart';
import 'package:travel_planner/features/budget/presentation/screens/manage_companions_screen.dart';
import 'package:travel_planner/features/currency/presentation/screens/currency_converter_screen.dart';

import 'package:travel_planner/features/onboarding/onboarding_screen.dart';
import 'package:travel_planner/features/packing_list/presentation/screens/packing_list_screen.dart';
import 'package:travel_planner/features/weather/presentation/screens/weather_screen.dart';
import 'package:travel_planner/features/settings/presentation/screens/about_screen.dart';
import 'package:travel_planner/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:travel_planner/features/settings/presentation/screens/settings_screen.dart';
import 'package:travel_planner/features/translator/presentation/screens/saved_phrases_screen.dart';
import 'package:travel_planner/features/translator/presentation/screens/translator_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_create_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_detail_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_edit_screen.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_list_screen.dart';
import 'package:travel_planner/features/world_clock/world_clock.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/features/booking/screens/booking_search_screen.dart';
import 'package:travel_planner/features/booking/screens/booking_details_screen.dart';
import 'package:travel_planner/features/booking/screens/my_bookings_screen.dart';
import 'package:travel_planner/features/booking/models/booking.dart';

// A provider that takes the initial location as a parameter to handle onboarding logic
final appRouterProvider =
    Provider.family<GoRouter, String>((ref, initialLocation) {
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
        path: '/assistant',
        name: 'assistant',
        builder: (context, state) => const ChatScreen(),
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
        // Nested routes for pages related to a specific trip
        routes: [
          GoRoute(
            path: 'translator',
            name: 'trip_translator',
            builder: (context, state) {
              final trip = state.extra as Trip;
              return TranslatorScreen(trip: trip);
            },
          ),
          GoRoute(
            path: 'translator/saved',
            name: 'trip_translator_saved',
            builder: (context, state) {
              return const SavedPhrasesScreen();
            },
          ),
          GoRoute(
            path: 'packing-list',
            name: 'packing_list',
            builder: (context, state) {
              // The entire Trip object is passed as an 'extra' parameter
              // to provide metadata for suggestion generation.
              final trip = state.extra as Trip;
              return PackingListScreen(trip: trip);
            },
          ),
          GoRoute(
            path: 'budget',
            name: 'budget',
            builder: (context, state) {
              final tripId = state.pathParameters['id']!;
              return BudgetOverviewScreen(tripId: tripId);
            },
            routes: [
              GoRoute(
                path: 'add-expense',
                name: 'add_expense',
                builder: (context, state) {
                  final tripId = state.pathParameters['id']!;
                  return AddExpenseScreen(tripId: tripId);
                },
              ),
              GoRoute(
                path: 'manage-companions',
                name: 'manage_companions',
                builder: (context, state) {
                  final tripId = state.pathParameters['id']!;
                  return ManageCompanionsScreen(tripId: tripId);
                },
              ),
            ],
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
      GoRoute(
        path: '/currency-converter',
        name: 'currency_converter',
        builder: (context, state) {
          // Safely extract optional parameters for pre-filling the converter
          final extras = state.extra as Map<String, dynamic>?;
          return CurrencyConverterScreen(
            initialAmount: extras?['amount'] as double?,
            fromCurrency: extras?['from'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/weather',
        name: 'weather',
        builder: (context, state) {
          final extras = state.extra as Map<String, String>?;
          return WeatherScreen(initialCity: extras?['city']);
        },
      ),
      GoRoute(
        path: '/world-clock',
        name: 'world_clock',
        builder: (context, state) => const WorldClockScreen(),
      ),
      // Booking routes
      GoRoute(
        path: '/bookings/search',
        name: 'booking_search',
        builder: (context, state) => const BookingSearchScreen(),
      ),
      GoRoute(
        path: '/bookings/details',
        name: 'booking_details',
        builder: (context, state) => BookingDetailsScreen(
          booking: state.extra as Booking,
        ),
      ),
      GoRoute(
        path: '/bookings/my',
        name: 'my_bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
    ],
  );
});
