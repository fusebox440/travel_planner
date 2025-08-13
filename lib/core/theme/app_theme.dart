import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_planner/core/services/settings_service.dart';

// Re-introduce Grey theme mode
enum AppThemeMode { light, dark, grey }

// The provider now holds the enum instead of ThemeMode
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  final SettingsService _settingsService = SettingsService();

  ThemeNotifier() : super(AppThemeMode.light) {
    state = _settingsService.getThemeMode();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await _settingsService.setThemeMode(mode);
  }
}

class AppTheme {
  AppTheme._();

  static const _lightSeedColor = Color(0xFF0D47A1);
  static const _darkSeedColor = Color(0xFF4CAF50);
  static const _greySeedColor = Colors.blueGrey; // Seed for the grey theme

  static final ThemeData lightTheme = _buildTheme(Brightness.light, _lightSeedColor);
  static final ThemeData darkTheme = _buildTheme(Brightness.dark, _darkSeedColor);
  static final ThemeData greyTheme = _buildGreyTheme(); // Special builder for grey

  static ThemeData _buildGreyTheme() {
    final baseTheme = _buildTheme(Brightness.light, _greySeedColor);
    final colorScheme = baseTheme.colorScheme;

    return baseTheme.copyWith(
      // Override specific components for high-contrast outlines
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0, // Remove shadows for a flatter look
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colorScheme.outlineVariant, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.onSurface, width: 2), // High-contrast border
          ),
          elevation: 0,
        ),
      ),
    );
  }

  static ThemeData _buildTheme(Brightness brightness, Color seedColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final textTheme = GoogleFonts.poppinsTextTheme(ThemeData(brightness: brightness).textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme.copyWith(
        bodyMedium: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        titleLarge: textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLowest,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}