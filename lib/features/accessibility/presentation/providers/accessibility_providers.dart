import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:travel_planner/features/accessibility/data/accessibility_service.dart';
import 'package:travel_planner/features/accessibility/domain/models/accessibility_settings.dart';

/// Provider for the accessibility service singleton
final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService.instance;
});

/// Provider for current accessibility settings
final accessibilitySettingsProvider =
    StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>(
        (ref) {
  final service = ref.watch(accessibilityServiceProvider);
  return AccessibilitySettingsNotifier(service);
});

/// Provider for high contrast theme flag
final isHighContrastEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.isHighContrastEnabled;
});

/// Provider for current font scale factor
final fontScaleFactorProvider = Provider<double>((ref) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.textScaleFactor;
});

/// Provider for screen reader enabled flag
final isScreenReaderEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.isScreenReaderEnabled;
});

/// Provider for keyboard navigation enabled flag
final isKeyboardNavigationEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.isKeyboardNavigationEnabled;
});

/// Provider for reduced animations flag
final areAnimationsReducedProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.areAnimationsReduced;
});

/// Provider for enhanced focus indicators flag
final shouldShowEnhancedFocusProvider = Provider<bool>((ref) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.shouldShowEnhancedFocus;
});

/// Provider for accessibility-aware animation duration
final animationDurationProvider =
    Provider.family<Duration, Duration>((ref, defaultDuration) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.getAnimationDuration(defaultDuration);
});

/// Provider for semantic label selection
final semanticLabelProvider =
    Provider.family<String, (String, String)>((ref, labels) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.getSemanticLabel(labels.$1, labels.$2);
});

/// Provider for accessibility color scheme
final accessibilityColorSchemeProvider =
    Provider<AccessibilityColorScheme>((ref) {
  final settings = ref.watch(accessibilitySettingsProvider);
  return settings.colorScheme;
});

/// Provider for focus color based on accessibility settings
final accessibilityFocusColorProvider =
    Provider.family<Color, ColorScheme>((ref, colorScheme) {
  final service = ref.watch(accessibilityServiceProvider);
  return service.getFocusColor(colorScheme);
});

/// State notifier for managing accessibility settings
class AccessibilitySettingsNotifier
    extends StateNotifier<AccessibilitySettings> {
  final AccessibilityService _service;

  AccessibilitySettingsNotifier(this._service) : super(_service.settings);

  /// Update high contrast setting
  Future<void> toggleHighContrast() async {
    await _service.toggleHighContrast();
    state = _service.settings;
  }

  /// Update font size setting
  Future<void> setFontSize(double scale) async {
    await _service.setFontSize(scale);
    state = _service.settings;
  }

  /// Update screen reader setting
  Future<void> toggleScreenReader() async {
    await _service.toggleScreenReader();
    state = _service.settings;
  }

  /// Update keyboard navigation setting
  Future<void> toggleKeyboardNavigation() async {
    await _service.toggleKeyboardNavigation();
    state = _service.settings;
  }

  /// Update reduced animations setting
  Future<void> toggleReducedAnimations() async {
    await _service.toggleReducedAnimations();
    state = _service.settings;
  }

  /// Update color scheme setting
  Future<void> setColorScheme(AccessibilityColorScheme scheme) async {
    await _service.setColorScheme(scheme);
    state = _service.settings;
  }

  /// Update verbose semantic labels setting
  Future<void> toggleVerboseSemanticLabels() async {
    await _service.updateSettings(state.copyWith(
      isSemanticLabelsVerbose: !state.isSemanticLabelsVerbose,
    ));
    state = _service.settings;
  }

  /// Update enhanced focus indicators setting
  Future<void> toggleEnhancedFocusIndicators() async {
    await _service.updateSettings(state.copyWith(
      isFocusIndicatorEnhanced: !state.isFocusIndicatorEnhanced,
    ));
    state = _service.settings;
  }

  /// Update sound feedback setting
  Future<void> toggleSoundFeedback() async {
    await _service.updateSettings(state.copyWith(
      isSoundFeedbackEnabled: !state.isSoundFeedbackEnabled,
    ));
    state = _service.settings;
  }

  /// Update haptic feedback setting
  Future<void> toggleHapticFeedback() async {
    await _service.updateSettings(state.copyWith(
      isHapticFeedbackEnabled: !state.isHapticFeedbackEnabled,
    ));
    state = _service.settings;
  }

  /// Update color blindness assistance setting
  Future<void> toggleColorBlindnessAssist() async {
    await _service.updateSettings(state.copyWith(
      isColorBlindnessAssistEnabled: !state.isColorBlindnessAssistEnabled,
    ));
    state = _service.settings;
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _service.resetToDefaults();
    state = _service.settings;
  }

  /// Provide haptic feedback
  Future<void> hapticFeedback() async {
    await _service.hapticFeedback();
  }

  /// Provide sound feedback
  Future<void> soundFeedback() async {
    await _service.soundFeedback();
  }

  /// Announce message for screen readers
  Future<void> announce(String message) async {
    await _service.announce(message);
  }
}

/// Provider for accessibility operations
final accessibilityOperationsProvider =
    Provider<AccessibilityOperations>((ref) {
  final service = ref.watch(accessibilityServiceProvider);
  final notifier = ref.watch(accessibilitySettingsProvider.notifier);
  return AccessibilityOperations(service, notifier);
});

/// Utility class for accessibility operations
class AccessibilityOperations {
  final AccessibilityService _service;
  final AccessibilitySettingsNotifier _notifier;

  AccessibilityOperations(this._service, this._notifier);

  /// Provide feedback for user interactions
  Future<void> provideFeedback({
    String? announcement,
  }) async {
    await _notifier.hapticFeedback();
    await _notifier.soundFeedback();

    if (announcement != null) {
      await _notifier.announce(announcement);
    }
  }

  /// Check if a widget should be focusable
  bool shouldBeFocusable(bool defaultFocusable) {
    return _service.shouldBeFocusable(defaultFocusable);
  }

  /// Get semantic label based on verbosity setting
  String getSemanticLabel(String brief, String verbose) {
    return _service.getSemanticLabel(brief, verbose);
  }

  /// Get animation duration based on accessibility settings
  Duration getAnimationDuration(Duration defaultDuration) {
    return _service.getAnimationDuration(defaultDuration);
  }
}
