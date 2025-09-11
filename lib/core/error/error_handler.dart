import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppErrorHandler {
  static void init() {
    // Set up error handling for async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleError(error, stack);
      return true;
    };

    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _handleError(details.exception, details.stack);
    };
  }

  static void _handleError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('ERROR: $error');
      if (stackTrace != null) print('STACKTRACE: $stackTrace');
    } else {
      // Report to Firebase Crashlytics in production
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'App Error',
        fatal: true,
      );
    }

    // Show error to user in UI
    _showErrorSnackBar(error.toString());
  }

  // Public method that can be called from other classes
  static void handleError(dynamic error, StackTrace? stackTrace) {
    _handleError(error, stackTrace);
  }

  // Custom error handler for specific error types
  static void handleNetworkError(dynamic error, {String? context}) {
    // Handle network-specific errors
    if (error.toString().contains('SocketException')) {
      _showErrorSnackBar('No internet connection. Please check your network.');
    } else if (error.toString().contains('TimeoutException')) {
      _showErrorSnackBar('Request timed out. Please try again.');
    }

    _handleError(error, StackTrace.current);
  }

  // Custom error handler for business logic errors
  static void handleBusinessError(String message) {
    _showErrorSnackBar(message);
  }

  static void _showErrorSnackBar(String message) {
    final context = navigator.currentContext;
    if (context == null) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static final GlobalKey<NavigatorState> navigator =
      GlobalKey<NavigatorState>();
}
