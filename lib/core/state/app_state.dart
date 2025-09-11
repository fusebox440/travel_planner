import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/error/error_handler.dart';

// Base state class for consistent state management
abstract class BaseState {
  final bool isLoading;
  final String? error;

  const BaseState({
    this.isLoading = false,
    this.error,
  });
}

// Base state notifier with error handling
abstract class BaseStateNotifier<T extends BaseState> extends StateNotifier<T> {
  BaseStateNotifier(T initialState) : super(initialState);

  Future<void> handleError(dynamic error, dynamic stackTrace) async {
    AppErrorHandler.handleError(error, stackTrace);
  }

  // Helper method to handle async operations
  Future<void> handleAsync(
    Future<void> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      setLoading(true);
      await operation();
    } catch (error, stackTrace) {
      await handleError(error, stackTrace);
      setError(errorMessage ?? error.toString());
    } finally {
      setLoading(false);
    }
  }

  void setLoading(bool loading) {
    state = createState(isLoading: loading);
  }

  void setError(String error) {
    state = createState(error: error);
  }

  void clearError() {
    state = createState(error: null);
  }

  // To be implemented by subclasses to create new state instances
  T createState({
    bool? isLoading,
    String? error,
  });
}

// Application state for global app state
class AppState extends BaseState {
  final bool isAuthenticated;
  final String? currentLocale;
  final String? currentTheme;

  const AppState({
    super.isLoading,
    super.error,
    this.isAuthenticated = false,
    this.currentLocale,
    this.currentTheme,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    String? currentLocale,
    String? currentTheme,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentLocale: currentLocale ?? this.currentLocale,
      currentTheme: currentTheme ?? this.currentTheme,
    );
  }
}

// Global app state notifier
class AppStateNotifier extends BaseStateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  @override
  AppState createState({
    bool? isLoading,
    String? error,
  }) {
    return state.copyWith(
      isLoading: isLoading,
      error: error,
    );
  }

  void setAuthenticated(bool authenticated) {
    state = state.copyWith(isAuthenticated: authenticated);
  }

  void setLocale(String locale) {
    state = state.copyWith(currentLocale: locale);
  }

  void setTheme(String theme) {
    state = state.copyWith(currentTheme: theme);
  }
}

// Global providers
final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
