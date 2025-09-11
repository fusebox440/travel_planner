import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class Analytics {
  static final Analytics _instance = Analytics._internal();
  factory Analytics() => _instance;
  Analytics._internal();

  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver observer;

  void initialize() {
    _analytics = FirebaseAnalytics.instance;
    observer = FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // Screen tracking
  Future<void> logScreen(String screenName) async {
    try {
      await _analytics.setCurrentScreen(screenName: screenName);
    } catch (e) {
      debugPrint('Failed to log screen view: $e');
    }
  }

  // Event tracking
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      debugPrint('Failed to log event: $e');
    }
  }

  // User property tracking
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('Failed to set user property: $e');
    }
  }

  // Predefined events
  Future<void> logLogin({String? method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method},
    );
  }

  Future<void> logSignUp({String? method}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': method},
    );
  }

  Future<void> logTripCreated({
    required String tripId,
    required String destination,
    required int duration,
  }) async {
    await logEvent(
      name: 'trip_created',
      parameters: {
        'trip_id': tripId,
        'destination': destination,
        'duration': duration,
      },
    );
  }

  Future<void> logExpenseAdded({
    required String tripId,
    required String category,
    required double amount,
    required String currency,
  }) async {
    await logEvent(
      name: 'expense_added',
      parameters: {
        'trip_id': tripId,
        'category': category,
        'amount': amount,
        'currency': currency,
      },
    );
  }

  Future<void> logError({
    required String error,
    required String errorDetails,
  }) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error': error,
        'details': errorDetails,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logPerformanceMetric({
    required String metricName,
    required double value,
    Map<String, dynamic>? additionalParams,
  }) async {
    final params = {
      'value': value,
      'timestamp': DateTime.now().toIso8601String(),
      if (additionalParams != null) ...additionalParams,
    };

    await logEvent(
      name: 'performance_metric',
      parameters: params,
    );
  }
}

// Predefined analytics events
class AnalyticsEvents {
  static const String viewTrip = 'view_trip';
  static const String createTrip = 'create_trip';
  static const String editTrip = 'edit_trip';
  static const String deleteTrip = 'delete_trip';
  static const String addExpense = 'add_expense';
  static const String viewBudget = 'view_budget';
  static const String updatePackingList = 'update_packing_list';
  static const String viewMap = 'view_map';
  static const String searchLocation = 'search_location';
  static const String viewWeather = 'view_weather';
  static const String changeCurrency = 'change_currency';
  static const String viewSettings = 'view_settings';
}

// Analytics mixin for widgets
mixin AnalyticsMixin {
  void logScreenView(String screenName) {
    Analytics().logScreen(screenName);
  }

  void logCustomEvent(String eventName, [Map<String, dynamic>? params]) {
    Analytics().logEvent(name: eventName, parameters: params);
  }
}
