import 'package:hive/hive.dart';

// part 'accessibility_settings.g.dart';

@HiveType(typeId: 52)
class AccessibilitySettings extends HiveObject {
  @HiveField(0)
  final bool isHighContrastEnabled;

  @HiveField(1)
  final double fontSize; // Scale factor (0.8 to 2.0)

  @HiveField(2)
  final bool isScreenReaderEnabled;

  @HiveField(3)
  final bool isKeyboardNavigationEnabled;

  @HiveField(4)
  final bool areAnimationsReduced;

  @HiveField(5)
  final bool isColorBlindnessAssistEnabled;

  @HiveField(6)
  final AccessibilityColorScheme colorScheme;

  @HiveField(7)
  final bool isSemanticLabelsVerbose;

  @HiveField(8)
  final bool isFocusIndicatorEnhanced;

  @HiveField(9)
  final bool isSoundFeedbackEnabled;

  @HiveField(10)
  final bool isHapticFeedbackEnabled;

  AccessibilitySettings({
    this.isHighContrastEnabled = false,
    this.fontSize = 1.0,
    this.isScreenReaderEnabled = false,
    this.isKeyboardNavigationEnabled = false,
    this.areAnimationsReduced = false,
    this.isColorBlindnessAssistEnabled = false,
    this.colorScheme = AccessibilityColorScheme.standard,
    this.isSemanticLabelsVerbose = false,
    this.isFocusIndicatorEnhanced = false,
    this.isSoundFeedbackEnabled = true,
    this.isHapticFeedbackEnabled = true,
  });

  AccessibilitySettings copyWith({
    bool? isHighContrastEnabled,
    double? fontSize,
    bool? isScreenReaderEnabled,
    bool? isKeyboardNavigationEnabled,
    bool? areAnimationsReduced,
    bool? isColorBlindnessAssistEnabled,
    AccessibilityColorScheme? colorScheme,
    bool? isSemanticLabelsVerbose,
    bool? isFocusIndicatorEnhanced,
    bool? isSoundFeedbackEnabled,
    bool? isHapticFeedbackEnabled,
  }) {
    return AccessibilitySettings(
      isHighContrastEnabled:
          isHighContrastEnabled ?? this.isHighContrastEnabled,
      fontSize: fontSize ?? this.fontSize,
      isScreenReaderEnabled:
          isScreenReaderEnabled ?? this.isScreenReaderEnabled,
      isKeyboardNavigationEnabled:
          isKeyboardNavigationEnabled ?? this.isKeyboardNavigationEnabled,
      areAnimationsReduced: areAnimationsReduced ?? this.areAnimationsReduced,
      isColorBlindnessAssistEnabled:
          isColorBlindnessAssistEnabled ?? this.isColorBlindnessAssistEnabled,
      colorScheme: colorScheme ?? this.colorScheme,
      isSemanticLabelsVerbose:
          isSemanticLabelsVerbose ?? this.isSemanticLabelsVerbose,
      isFocusIndicatorEnhanced:
          isFocusIndicatorEnhanced ?? this.isFocusIndicatorEnhanced,
      isSoundFeedbackEnabled:
          isSoundFeedbackEnabled ?? this.isSoundFeedbackEnabled,
      isHapticFeedbackEnabled:
          isHapticFeedbackEnabled ?? this.isHapticFeedbackEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isHighContrastEnabled': isHighContrastEnabled,
      'fontSize': fontSize,
      'isScreenReaderEnabled': isScreenReaderEnabled,
      'isKeyboardNavigationEnabled': isKeyboardNavigationEnabled,
      'areAnimationsReduced': areAnimationsReduced,
      'isColorBlindnessAssistEnabled': isColorBlindnessAssistEnabled,
      'colorScheme': colorScheme.name,
      'isSemanticLabelsVerbose': isSemanticLabelsVerbose,
      'isFocusIndicatorEnhanced': isFocusIndicatorEnhanced,
      'isSoundFeedbackEnabled': isSoundFeedbackEnabled,
      'isHapticFeedbackEnabled': isHapticFeedbackEnabled,
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      isHighContrastEnabled: json['isHighContrastEnabled'] as bool? ?? false,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 1.0,
      isScreenReaderEnabled: json['isScreenReaderEnabled'] as bool? ?? false,
      isKeyboardNavigationEnabled:
          json['isKeyboardNavigationEnabled'] as bool? ?? false,
      areAnimationsReduced: json['areAnimationsReduced'] as bool? ?? false,
      isColorBlindnessAssistEnabled:
          json['isColorBlindnessAssistEnabled'] as bool? ?? false,
      colorScheme: AccessibilityColorScheme.values.firstWhere(
        (e) => e.name == json['colorScheme'],
        orElse: () => AccessibilityColorScheme.standard,
      ),
      isSemanticLabelsVerbose:
          json['isSemanticLabelsVerbose'] as bool? ?? false,
      isFocusIndicatorEnhanced:
          json['isFocusIndicatorEnhanced'] as bool? ?? false,
      isSoundFeedbackEnabled: json['isSoundFeedbackEnabled'] as bool? ?? true,
      isHapticFeedbackEnabled: json['isHapticFeedbackEnabled'] as bool? ?? true,
    );
  }
}

@HiveType(typeId: 53)
enum AccessibilityColorScheme {
  @HiveField(0)
  standard,

  @HiveField(1)
  highContrast,

  @HiveField(2)
  protanopia, // Red-green colorblindness

  @HiveField(3)
  deuteranopia, // Green-red colorblindness

  @HiveField(4)
  tritanopia, // Blue-yellow colorblindness

  @HiveField(5)
  monochrome, // Complete colorblindness
}

/// Utility extensions for accessibility
extension AccessibilitySettingsExtensions on AccessibilitySettings {
  /// Returns the effective text scale factor
  double get textScaleFactor => fontSize.clamp(0.8, 2.0);

  /// Checks if reduced motion should be used
  bool get shouldReduceMotion => areAnimationsReduced;

  /// Checks if enhanced focus indicators should be shown
  bool get shouldShowEnhancedFocus =>
      isFocusIndicatorEnhanced || isKeyboardNavigationEnabled;

  /// Gets the duration for animations (reduced if accessibility requires it)
  Duration getAnimationDuration(Duration defaultDuration) {
    return shouldReduceMotion ? Duration.zero : defaultDuration;
  }

  /// Gets the appropriate semantic label based on verbosity setting
  String getSemanticLabel(String brief, String verbose) {
    return isSemanticLabelsVerbose ? verbose : brief;
  }
}
