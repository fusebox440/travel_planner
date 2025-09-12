import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_planner/core/services/settings_service.dart';

// Enhanced theme modes including kid-friendly and high contrast options
enum AppThemeMode { light, dark, grey, kidMode, highContrast }

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

  // Child-friendly color palette
  static const Color playfulBlue = Color(0xFF4F46E5);
  static const Color mintGreen = Color(0xFF06D6A0);
  static const Color sunnyOrange = Color(0xFFFFB347);
  static const Color softPink = Color(0xFFFF8A8A);
  static const Color sunnyYellow = Color(0xFFFFF176);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color leafGreen = Color(0xFF98FB98);
  static const Color lavenderPurple = Color(0xFFDDA0DD);

  static const _lightSeedColor = Color(0xFF0D47A1);
  static const _darkSeedColor = Color(0xFF4CAF50);
  static const _greySeedColor = Colors.blueGrey;
  static const _kidSeedColor = Color(0xFF4F46E5); // Playful blue for kids

  static final ThemeData lightTheme =
      _buildTheme(Brightness.light, _lightSeedColor);
  static final ThemeData darkTheme =
      _buildTheme(Brightness.dark, _darkSeedColor);
  static final ThemeData greyTheme = _buildGreyTheme();
  static final ThemeData kidModeTheme =
      _buildKidModeTheme(); // New kid-friendly theme
  static final ThemeData highContrastTheme =
      _buildHighContrastTheme(); // High contrast theme

  static ThemeData _buildKidModeTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _kidSeedColor,
      brightness: Brightness.light,
    );
    final textTheme = GoogleFonts.comfortaaTextTheme(
        ThemeData(brightness: Brightness.light).textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme.copyWith(
        primary: playfulBlue,
        secondary: mintGreen,
        tertiary: sunnyOrange,
        surface: const Color(0xFFF8FAFC),
        background: const Color(0xFFF0F9FF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F9FF),
      textTheme: textTheme.copyWith(
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 18, // Larger text for kids
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 26, // Extra large titles
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: playfulBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: playfulBlue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: playfulBlue.withOpacity(0.3), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: playfulBlue, width: 3),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: playfulBlue,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(
              vertical: 20, horizontal: 32), // Larger touch targets
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          elevation: 6,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: sunnyOrange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
      ),
    );
  }

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
            side: BorderSide(
                color: colorScheme.onSurface, width: 2), // High-contrast border
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
    final textTheme = GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: brightness).textTheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: textTheme.copyWith(
        bodyMedium:
            textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        titleLarge:
            textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
        headlineSmall:
            textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }

  static ThemeData _buildHighContrastTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue[800],
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ).copyWith(
        primary: Colors.blue[800]!,
        secondary: Colors.orange[700]!,
        surface: Colors.white,
        background: Colors.white,
        error: Colors.red[800]!,
      ),
      scaffoldBackgroundColor: Colors.white,
      cardColor: Colors.white,
      dividerColor: Colors.black,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
        bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue[800],
          side: BorderSide(color: Colors.blue[800]!, width: 2),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }

  static ThemeData getThemeData(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return lightTheme;
      case AppThemeMode.dark:
        return darkTheme;
      case AppThemeMode.grey:
        return greyTheme;
      case AppThemeMode.kidMode:
        return kidModeTheme;
      case AppThemeMode.highContrast:
        return highContrastTheme;
    }
  }
}
