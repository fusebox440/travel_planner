import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:travel_planner/features/accessibility/domain/models/accessibility_settings.dart';

class AccessibilityService {
  static const String _boxName = 'accessibility_settings';
  static AccessibilityService? _instance;

  Box<AccessibilitySettings>? _settingsBox;
  AccessibilitySettings _currentSettings = AccessibilitySettings();

  // Singleton pattern
  static AccessibilityService get instance {
    _instance ??= AccessibilityService._();
    return _instance!;
  }

  AccessibilityService._();

  /// Initialize the accessibility service
  Future<void> initialize() async {
    try {
      _settingsBox = await Hive.openBox<AccessibilitySettings>(_boxName);
      _currentSettings = _settingsBox?.get('settings',
              defaultValue: AccessibilitySettings()) ??
          AccessibilitySettings();

      // Auto-detect system accessibility settings
      await _detectSystemAccessibilitySettings();
    } catch (e) {
      debugPrint('Failed to initialize AccessibilityService: $e');
      _currentSettings = AccessibilitySettings();
    }
  }

  /// Get current accessibility settings
  AccessibilitySettings get settings => _currentSettings;

  /// Update accessibility settings
  Future<void> updateSettings(AccessibilitySettings newSettings) async {
    _currentSettings = newSettings;
    await _settingsBox?.put('settings', newSettings);

    // Apply system-level changes if needed
    await _applySystemSettings(newSettings);
  }

  /// Update a specific setting
  Future<void> updateSetting<T>(T value,
      AccessibilitySettings Function(AccessibilitySettings, T) updater) async {
    final newSettings = updater(_currentSettings, value);
    await updateSettings(newSettings);
  }

  /// Enable/disable high contrast
  Future<void> toggleHighContrast() async {
    await updateSettings(_currentSettings.copyWith(
      isHighContrastEnabled: !_currentSettings.isHighContrastEnabled,
    ));
  }

  /// Set font size scale
  Future<void> setFontSize(double scale) async {
    await updateSettings(_currentSettings.copyWith(fontSize: scale));
  }

  /// Enable/disable screen reader support
  Future<void> toggleScreenReader() async {
    await updateSettings(_currentSettings.copyWith(
      isScreenReaderEnabled: !_currentSettings.isScreenReaderEnabled,
    ));
  }

  /// Enable/disable keyboard navigation
  Future<void> toggleKeyboardNavigation() async {
    await updateSettings(_currentSettings.copyWith(
      isKeyboardNavigationEnabled:
          !_currentSettings.isKeyboardNavigationEnabled,
    ));
  }

  /// Enable/disable reduced animations
  Future<void> toggleReducedAnimations() async {
    await updateSettings(_currentSettings.copyWith(
      areAnimationsReduced: !_currentSettings.areAnimationsReduced,
    ));
  }

  /// Set color scheme for accessibility
  Future<void> setColorScheme(AccessibilityColorScheme scheme) async {
    await updateSettings(_currentSettings.copyWith(colorScheme: scheme));
  }

  /// Get semantic label based on current settings
  String getSemanticLabel(String brief, String verbose) {
    return _currentSettings.isSemanticLabelsVerbose ? verbose : brief;
  }

  /// Get animation duration based on current settings
  Duration getAnimationDuration(Duration defaultDuration) {
    return _currentSettings.shouldReduceMotion
        ? Duration.zero
        : defaultDuration;
  }

  /// Provide haptic feedback if enabled
  Future<void> hapticFeedback() async {
    if (_currentSettings.isHapticFeedbackEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Provide sound feedback if enabled
  Future<void> soundFeedback() async {
    if (_currentSettings.isSoundFeedbackEnabled) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Announce message for screen readers
  Future<void> announce(String message) async {
    if (_currentSettings.isScreenReaderEnabled) {
      // Use a simple approach for announcements
      debugPrint('Screen Reader: $message');
    }
  }

  /// Check if widget should be focusable based on accessibility settings
  bool shouldBeFocusable(bool defaultFocusable) {
    if (_currentSettings.isKeyboardNavigationEnabled) {
      return true;
    }
    return defaultFocusable;
  }

  /// Get focus color based on accessibility settings
  Color getFocusColor(ColorScheme colorScheme) {
    if (_currentSettings.isFocusIndicatorEnhanced) {
      return _currentSettings.isHighContrastEnabled
          ? Colors.yellow
          : colorScheme.primary;
    }
    return colorScheme.outline;
  }

  /// Auto-detect system accessibility settings
  Future<void> _detectSystemAccessibilitySettings() async {
    try {
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;

      // Detect high contrast
      bool systemHighContrast =
          platformDispatcher.accessibilityFeatures.highContrast;

      // Detect reduced motion
      bool systemReducedMotion =
          platformDispatcher.accessibilityFeatures.disableAnimations;

      // Detect text scale factor
      double systemTextScale =
          1.0; // Default since textScaleFactorTestValue is not available

      // Update settings if system preferences are different
      if (systemHighContrast != _currentSettings.isHighContrastEnabled ||
          systemReducedMotion != _currentSettings.areAnimationsReduced ||
          (systemTextScale != 1.0 &&
              systemTextScale != _currentSettings.fontSize)) {
        await updateSettings(_currentSettings.copyWith(
          isHighContrastEnabled: systemHighContrast,
          areAnimationsReduced: systemReducedMotion,
          fontSize: systemTextScale != 1.0
              ? systemTextScale
              : _currentSettings.fontSize,
        ));
      }
    } catch (e) {
      debugPrint('Failed to detect system accessibility settings: $e');
    }
  }

  /// Apply system-level accessibility changes
  Future<void> _applySystemSettings(AccessibilitySettings settings) async {
    try {
      // Note: Most system-level changes are handled by Flutter automatically
      // This method is for any custom system integrations
      debugPrint('Applied accessibility settings: ${settings.toJson()}');
    } catch (e) {
      debugPrint('Failed to apply system accessibility settings: $e');
    }
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    await updateSettings(AccessibilitySettings());
  }

  /// Get accessibility summary for debugging
  Map<String, dynamic> getAccessibilitySummary() {
    return {
      'settings': _currentSettings.toJson(),
      'isInitialized': _settingsBox != null,
      'systemInfo': {
        'platform': Theme.of(WidgetsBinding.instance.rootElement!).platform,
        'textScale': 1.0, // Using default as textScaleFactor is deprecated
      },
    };
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _settingsBox?.close();
    _settingsBox = null;
    _instance = null;
  }
}

/// Enum for haptic feedback types
enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}
