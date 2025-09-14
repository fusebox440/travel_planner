import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accessibility_providers.dart';
import '../../domain/models/accessibility_settings.dart';

/// Provider for accessibility-aware theme data
final accessibilityThemeProvider =
    Provider.family<ThemeData, Brightness>((ref, brightness) {
  final settings = ref.watch(accessibilitySettingsProvider);
  final colorScheme = ref.watch(accessibilityColorSchemeProvider);

  return AccessibilityThemeManager.getTheme(
    brightness: brightness,
    settings: settings,
    colorScheme: colorScheme,
  );
});

/// Provider for high contrast theme data
final highContrastThemeProvider =
    Provider.family<ThemeData, Brightness>((ref, brightness) {
  final settings = ref.watch(accessibilitySettingsProvider);

  return AccessibilityThemeManager.getHighContrastTheme(
    brightness: brightness,
    fontSize: settings.fontSize,
  );
});

/// Manager class for accessibility-aware themes
class AccessibilityThemeManager {
  /// Get theme data based on accessibility settings
  static ThemeData getTheme({
    required Brightness brightness,
    required AccessibilitySettings settings,
    required AccessibilityColorScheme colorScheme,
  }) {
    // Start with base theme
    ThemeData baseTheme =
        brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();

    // Apply accessibility modifications
    if (settings.isHighContrastEnabled) {
      return getHighContrastTheme(
          brightness: brightness, fontSize: settings.fontSize);
    }

    // Apply color scheme modifications
    ColorScheme effectiveColorScheme = _getAccessibilityColorScheme(
      baseTheme.colorScheme,
      colorScheme,
      settings.isColorBlindnessAssistEnabled,
    );

    return baseTheme.copyWith(
      colorScheme: effectiveColorScheme,
      textTheme: _getAccessibilityTextTheme(baseTheme.textTheme, settings),
      elevatedButtonTheme:
          _getAccessibilityElevatedButtonTheme(settings, effectiveColorScheme),
      outlinedButtonTheme:
          _getAccessibilityOutlinedButtonTheme(settings, effectiveColorScheme),
      textButtonTheme:
          _getAccessibilityTextButtonTheme(settings, effectiveColorScheme),
      inputDecorationTheme:
          _getAccessibilityInputDecorationTheme(settings, effectiveColorScheme),
      cardTheme: _getAccessibilityCardTheme(settings, effectiveColorScheme),
      listTileTheme: _getAccessibilityListTileTheme(settings),
      focusColor: settings.isFocusIndicatorEnhanced
          ? effectiveColorScheme.primary.withValues(alpha: 0.3)
          : null,
      dividerTheme: DividerThemeData(
        color: effectiveColorScheme.outline,
        thickness: settings.isHighContrastEnabled ? 2 : 1,
      ),
    );
  }

  /// Get high contrast theme
  static ThemeData getHighContrastTheme({
    required Brightness brightness,
    double fontSize = 1.0,
  }) {
    final bool isLight = brightness == Brightness.light;

    final ColorScheme highContrastColorScheme = ColorScheme(
      brightness: brightness,
      primary: isLight ? Colors.black : Colors.white,
      onPrimary: isLight ? Colors.white : Colors.black,
      secondary: isLight ? const Color(0xFF0066CC) : const Color(0xFF66B3FF),
      onSecondary: isLight ? Colors.white : Colors.black,
      error: isLight ? const Color(0xFFCC0000) : const Color(0xFFFF6666),
      onError: Colors.white,
      surface: isLight ? Colors.white : Colors.black,
      onSurface: isLight ? Colors.black : Colors.white,
      outline: isLight ? Colors.black54 : Colors.white54,
      outlineVariant: isLight ? Colors.black38 : Colors.white38,
      surfaceContainerHighest:
          isLight ? const Color(0xFFF5F5F5) : const Color(0xFF1A1A1A),
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: highContrastColorScheme,
      textTheme: _getHighContrastTextTheme(fontSize, isLight),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highContrastColorScheme.primary,
          foregroundColor: highContrastColorScheme.onPrimary,
          side: BorderSide(color: highContrastColorScheme.primary, width: 2),
          textStyle:
              TextStyle(fontSize: 16 * fontSize, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: highContrastColorScheme.primary,
          side: BorderSide(color: highContrastColorScheme.primary, width: 2),
          textStyle:
              TextStyle(fontSize: 16 * fontSize, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide:
              BorderSide(color: highContrastColorScheme.outline, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: highContrastColorScheme.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: highContrastColorScheme.primary, width: 3),
        ),
        labelStyle: TextStyle(
          color: highContrastColorScheme.onSurface,
          fontSize: 16 * fontSize,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: highContrastColorScheme.onSurface.withValues(alpha: 0.7),
          fontSize: 16 * fontSize,
        ),
      ),
      cardTheme: CardThemeData(
        color: highContrastColorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: highContrastColorScheme.outline, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: highContrastColorScheme.outline,
        thickness: 2,
      ),
      focusColor: highContrastColorScheme.primary.withValues(alpha: 0.5),
    );
  }

  /// Get accessibility-modified color scheme
  static ColorScheme _getAccessibilityColorScheme(
    ColorScheme baseColorScheme,
    AccessibilityColorScheme accessibilityScheme,
    bool isColorBlindnessAssistEnabled,
  ) {
    switch (accessibilityScheme) {
      case AccessibilityColorScheme.standard:
        return baseColorScheme;

      case AccessibilityColorScheme.highContrast:
        return baseColorScheme.copyWith(
          primary: baseColorScheme.brightness == Brightness.light
              ? Colors.black
              : Colors.white,
          onPrimary: baseColorScheme.brightness == Brightness.light
              ? Colors.white
              : Colors.black,
        );

      case AccessibilityColorScheme.protanopia:
        return _applyProtanopiaFilter(baseColorScheme);

      case AccessibilityColorScheme.deuteranopia:
        return _applyDeuteranopiaFilter(baseColorScheme);

      case AccessibilityColorScheme.tritanopia:
        return _applyTritanopiaFilter(baseColorScheme);

      case AccessibilityColorScheme.monochrome:
        return _applyMonochromeFilter(baseColorScheme);
    }
  }

  /// Get accessibility-modified text theme
  static TextTheme _getAccessibilityTextTheme(
    TextTheme baseTextTheme,
    AccessibilitySettings settings,
  ) {
    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize:
            (baseTextTheme.displayLarge?.fontSize ?? 57) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w400,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize:
            (baseTextTheme.displayMedium?.fontSize ?? 45) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w400,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize:
            (baseTextTheme.displaySmall?.fontSize ?? 36) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w400,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize:
            (baseTextTheme.headlineLarge?.fontSize ?? 32) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w400,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize:
            (baseTextTheme.headlineMedium?.fontSize ?? 28) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w400,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize:
            (baseTextTheme.headlineSmall?.fontSize ?? 24) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w500,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize:
            (baseTextTheme.titleLarge?.fontSize ?? 22) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w500,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize:
            (baseTextTheme.titleMedium?.fontSize ?? 16) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w500,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize:
            (baseTextTheme.titleSmall?.fontSize ?? 14) * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * settings.fontSize,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize:
            (baseTextTheme.bodyMedium?.fontSize ?? 14) * settings.fontSize,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * settings.fontSize,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize:
            (baseTextTheme.labelLarge?.fontSize ?? 14) * settings.fontSize,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize:
            (baseTextTheme.labelMedium?.fontSize ?? 12) * settings.fontSize,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize:
            (baseTextTheme.labelSmall?.fontSize ?? 11) * settings.fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Get high contrast text theme
  static TextTheme _getHighContrastTextTheme(double fontSize, bool isLight) {
    final color = isLight ? Colors.black : Colors.white;

    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 57 * fontSize, fontWeight: FontWeight.bold, color: color),
      displayMedium: TextStyle(
          fontSize: 45 * fontSize, fontWeight: FontWeight.bold, color: color),
      displaySmall: TextStyle(
          fontSize: 36 * fontSize, fontWeight: FontWeight.bold, color: color),
      headlineLarge: TextStyle(
          fontSize: 32 * fontSize, fontWeight: FontWeight.bold, color: color),
      headlineMedium: TextStyle(
          fontSize: 28 * fontSize, fontWeight: FontWeight.bold, color: color),
      headlineSmall: TextStyle(
          fontSize: 24 * fontSize, fontWeight: FontWeight.bold, color: color),
      titleLarge: TextStyle(
          fontSize: 22 * fontSize, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(
          fontSize: 16 * fontSize, fontWeight: FontWeight.w600, color: color),
      titleSmall: TextStyle(
          fontSize: 14 * fontSize, fontWeight: FontWeight.w600, color: color),
      bodyLarge: TextStyle(
          fontSize: 16 * fontSize, fontWeight: FontWeight.w500, color: color),
      bodyMedium: TextStyle(
          fontSize: 14 * fontSize, fontWeight: FontWeight.w500, color: color),
      bodySmall: TextStyle(
          fontSize: 12 * fontSize, fontWeight: FontWeight.w500, color: color),
      labelLarge: TextStyle(
          fontSize: 14 * fontSize, fontWeight: FontWeight.w600, color: color),
      labelMedium: TextStyle(
          fontSize: 12 * fontSize, fontWeight: FontWeight.w600, color: color),
      labelSmall: TextStyle(
          fontSize: 11 * fontSize, fontWeight: FontWeight.w600, color: color),
    );
  }

  // Color blindness filter methods
  static ColorScheme _applyProtanopiaFilter(ColorScheme colorScheme) {
    // Simulate protanopia (red-green color blindness - missing red cones)
    return colorScheme.copyWith(
      primary: _protanopiaFilter(colorScheme.primary),
      secondary: _protanopiaFilter(colorScheme.secondary),
      error: Colors.orange, // Replace red with orange for better visibility
    );
  }

  static ColorScheme _applyDeuteranopiaFilter(ColorScheme colorScheme) {
    // Simulate deuteranopia (green-red color blindness - missing green cones)
    return colorScheme.copyWith(
      primary: _deuteranopiaFilter(colorScheme.primary),
      secondary: _deuteranopiaFilter(colorScheme.secondary),
    );
  }

  static ColorScheme _applyTritanopiaFilter(ColorScheme colorScheme) {
    // Simulate tritanopia (blue-yellow color blindness - missing blue cones)
    return colorScheme.copyWith(
      primary: _tritanopiaFilter(colorScheme.primary),
      secondary: _tritanopiaFilter(colorScheme.secondary),
    );
  }

  static ColorScheme _applyMonochromeFilter(ColorScheme colorScheme) {
    // Convert to monochrome
    return colorScheme.copyWith(
      primary: _toGrayscale(colorScheme.primary),
      secondary: _toGrayscale(colorScheme.secondary),
      error: Colors.grey.shade800,
    );
  }

  // Helper methods for color transformations
  static Color _protanopiaFilter(Color color) {
    // Simplified protanopia simulation - reduce red component
    return Color.fromARGB(
      (color.a * 255).round(),
      (color.r * 255 * 0.567).round(),
      (color.g * 255 * 1.2).clamp(0, 255).round(),
      (color.b * 255).round(),
    );
  }

  static Color _deuteranopiaFilter(Color color) {
    // Simplified deuteranopia simulation - reduce green component
    return Color.fromARGB(
      (color.a * 255).round(),
      (color.r * 255 * 1.1).clamp(0, 255).round(),
      (color.g * 255 * 0.558).round(),
      (color.b * 255).round(),
    );
  }

  static Color _tritanopiaFilter(Color color) {
    // Simplified tritanopia simulation - reduce blue component
    return Color.fromARGB(
      (color.a * 255).round(),
      (color.r * 255).round(),
      (color.g * 255).round(),
      (color.b * 255 * 0.567).round(),
    );
  }

  static Color _toGrayscale(Color color) {
    final gray =
        (color.r * 255 * 0.299 + color.g * 255 * 0.587 + color.b * 255 * 0.114)
            .round();
    return Color.fromARGB((color.a * 255).round(), gray, gray, gray);
  }

  // Button theme helpers
  static ElevatedButtonThemeData _getAccessibilityElevatedButtonTheme(
    AccessibilitySettings settings,
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 16 * settings.fontSize,
          fontWeight: settings.isFocusIndicatorEnhanced
              ? FontWeight.bold
              : FontWeight.w500,
        ),
        side: settings.isFocusIndicatorEnhanced
            ? BorderSide(color: colorScheme.primary, width: 2)
            : null,
      ),
    );
  }

  static OutlinedButtonThemeData _getAccessibilityOutlinedButtonTheme(
    AccessibilitySettings settings,
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 16 * settings.fontSize,
          fontWeight: settings.isFocusIndicatorEnhanced
              ? FontWeight.bold
              : FontWeight.w500,
        ),
        side: BorderSide(
          color: colorScheme.primary,
          width: settings.isFocusIndicatorEnhanced ? 2 : 1,
        ),
      ),
    );
  }

  static TextButtonThemeData _getAccessibilityTextButtonTheme(
    AccessibilitySettings settings,
    ColorScheme colorScheme,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 16 * settings.fontSize,
          fontWeight: settings.isFocusIndicatorEnhanced
              ? FontWeight.bold
              : FontWeight.w500,
        ),
      ),
    );
  }

  static InputDecorationTheme _getAccessibilityInputDecorationTheme(
    AccessibilitySettings settings,
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      labelStyle: TextStyle(fontSize: 16 * settings.fontSize),
      hintStyle: TextStyle(fontSize: 16 * settings.fontSize),
      focusedBorder: settings.isFocusIndicatorEnhanced
          ? OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary, width: 3),
            )
          : null,
    );
  }

  static CardThemeData _getAccessibilityCardTheme(
    AccessibilitySettings settings,
    ColorScheme colorScheme,
  ) {
    return CardThemeData(
      elevation: settings.isFocusIndicatorEnhanced ? 4 : 1,
      shape: settings.isFocusIndicatorEnhanced
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side:
                  BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
            )
          : null,
    );
  }

  static ListTileThemeData _getAccessibilityListTileTheme(
      AccessibilitySettings settings) {
    return ListTileThemeData(
      titleTextStyle: TextStyle(
        fontSize: 16 * settings.fontSize,
        fontWeight: settings.isFocusIndicatorEnhanced
            ? FontWeight.w600
            : FontWeight.w500,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: 14 * settings.fontSize,
      ),
    );
  }
}
