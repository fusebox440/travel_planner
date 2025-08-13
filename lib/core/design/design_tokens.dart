import 'package:flutter/material.dart';

/// A centralized class for all design system constants.
/// This ensures consistency across the app for colors, spacing, radii, and elevations.
class DesignTokens {
  // Private constructor to prevent instantiation.
  DesignTokens._();

  //============================================================================
  // C O L O R   T O K E N S
  //============================================================================
  // These are the raw color values. They are mapped to semantic roles
  // in the ThemePalette instances below.

  // --- Primary Colors ---
  static const _PrimaryColors primary = _PrimaryColors();

  // --- Secondary Colors ---
  static const _SecondaryColors secondary = _SecondaryColors();

  // --- Utility Colors ---
  static const _UtilityColors utility = _UtilityColors();

  // --- Neutral Colors (Greyscale) ---
  static const _NeutralColors neutral = _NeutralColors();

  //============================================================================
  // T H E M E   P A L E T T E S
  //============================================================================
  // These palettes map the raw color tokens to their semantic meaning
  // within a specific theme (light, dark, grey).

  /// The standard light theme palette.
  static final ThemePalette lightPalette = ThemePalette(
    primary: primary.blue, // Use for ColorScheme.primary
    onPrimary: neutral.white, // Use for ColorScheme.onPrimary
    secondary: secondary.green, // Use for ColorScheme.secondary
    background: neutral.grey50, // Use for ColorScheme.background
    surface: neutral.white, // Use for ColorScheme.surface
    error: utility.red, // Use for ColorScheme.error
    success: utility.green,
  );

  /// The standard dark theme palette.
  static final ThemePalette darkPalette = ThemePalette(
    primary: primary.blue,
    onPrimary: neutral.white,
    secondary: secondary.green,
    background: neutral.grey900,
    surface: neutral.grey800,
    error: utility.red,
    success: utility.green,
  );

  /// A muted, greyscale theme palette.
  static final ThemePalette greyPalette = ThemePalette(
    primary: neutral.grey700,
    onPrimary: neutral.white,
    secondary: neutral.grey500,
    background: neutral.grey100,
    surface: neutral.white,
    error: utility.red,
    success: utility.green,
  );

  //============================================================================
  // S P A C I N G   T O K E N S
  //============================================================================
  // Use these for consistent padding and margins throughout the app.

  /// 4.0 logical pixels. Use for tight spacing, like between an icon and text.
  static const EdgeInsets spacingXS = EdgeInsets.all(4.0);

  /// 8.0 logical pixels. Standard spacing for small elements.
  static const EdgeInsets spacingS = EdgeInsets.all(8.0);

  /// 16.0 logical pixels. Default margin and padding for most components.
  static const EdgeInsets spacingM = EdgeInsets.all(16.0);

  /// 24.0 logical pixels. Use for spacing between larger sections.
  static const EdgeInsets spacingL = EdgeInsets.all(24.0);

  /// 32.0 logical pixels. Use for large, spacious layouts.
  static const EdgeInsets spacingXL = EdgeInsets.all(32.0);

  //============================================================================
  // R A D I U S   T O K E N S
  //============================================================================
  // Use these for consistent border radiuses on cards, buttons, etc.

  /// 4.0 logical pixels. For small elements like tags.
  static final BorderRadius radiusSmall = BorderRadius.circular(4.0);

  /// 8.0 logical pixels. Default radius for cards and inputs.
  static final BorderRadius radiusMedium = BorderRadius.circular(8.0);

  /// 16.0 logical pixels. For larger components like bottom sheets.
  static final BorderRadius radiusLarge = BorderRadius.circular(16.0);

  /// 24.0 logical pixels. For circular elements like FABs.
  static final BorderRadius radiusXL = BorderRadius.circular(24.0);

  //============================================================================
  // E L E V A T I O N   T O K E N S
  //============================================================================
  // Use these for consistent shadow effects, indicating layering.

  /// Low elevation (e.g., for cards).
  static const double elevationLow = 2.0;

  /// Medium elevation (e.g., for AppBars).
  static const double elevationMedium = 4.0;

  /// High elevation (e.g., for Dialogs, Floating Action Buttons).
  static const double elevationHigh = 8.0;
}

// --- Helper Classes for Organization ---

/// A simple data class to hold the semantic colors for a theme.
class ThemePalette {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color success;

  ThemePalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.success,
  });
}

class _PrimaryColors {
  const _PrimaryColors();
  final Color blue = const Color(0xFF0D47A1); // Deep, trustworthy blue
}

class _SecondaryColors {
  const _SecondaryColors();
  final Color green = const Color(0xFF4CAF50); // Vibrant, earthy green
}

class _UtilityColors {
  const _UtilityColors();
  final Color red = const Color(0xFFD32F2F); // Standard error red
  final Color green = const Color(0xFF28a745); // Standard success green
}

class _NeutralColors {
  const _NeutralColors();
  final Color white = const Color(0xFFFFFFFF);
  final Color grey50 = const Color(0xFFFAFAFA);
  final Color grey100 = const Color(0xFFF5F5F5);
  final Color grey200 = const Color(0xFFEEEEEE);
  final Color grey300 = const Color(0xFFE0E0E0);
  final Color grey400 = const Color(0xFFBDBDBD);
  final Color grey500 = const Color(0xFF9E9E9E);
  final Color grey600 = const Color(0xFF757575);
  final Color grey700 = const Color(0xFF616161);
  final Color grey800 = const Color(0xFF424242);
  final Color grey900 = const Color(0xFF212121);
  final Color black = const Color(0xFF000000);
}