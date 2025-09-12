import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Accessibility service for managing app accessibility features
class AccessibilityService {
  static const _platform = MethodChannel('travel_planner/accessibility');

  /// Enable high contrast mode
  static Future<void> enableHighContrast() async {
    try {
      await _platform.invokeMethod('enableHighContrast');
    } on PlatformException catch (e) {
      print('Failed to enable high contrast: ${e.message}');
    }
  }

  /// Enable voice guidance
  static Future<void> enableVoiceGuidance() async {
    try {
      await _platform.invokeMethod('enableVoiceGuidance');
    } on PlatformException catch (e) {
      print('Failed to enable voice guidance: ${e.message}');
    }
  }

  /// Announce message for screen readers
  static void announceMessage(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if device has accessibility services enabled
  static Future<bool> isAccessibilityEnabled() async {
    try {
      return await _platform.invokeMethod('isAccessibilityEnabled') ?? false;
    } on PlatformException {
      return false;
    }
  }
}

/// Accessibility settings state
class AccessibilityState {
  final bool isHighContrast;
  final bool isLargeText;
  final bool isVoiceEnabled;
  final bool isScreenReaderEnabled;
  final double textScaleFactor;
  final bool reduceAnimations;

  const AccessibilityState({
    this.isHighContrast = false,
    this.isLargeText = false,
    this.isVoiceEnabled = false,
    this.isScreenReaderEnabled = false,
    this.textScaleFactor = 1.0,
    this.reduceAnimations = false,
  });

  AccessibilityState copyWith({
    bool? isHighContrast,
    bool? isLargeText,
    bool? isVoiceEnabled,
    bool? isScreenReaderEnabled,
    double? textScaleFactor,
    bool? reduceAnimations,
  }) {
    return AccessibilityState(
      isHighContrast: isHighContrast ?? this.isHighContrast,
      isLargeText: isLargeText ?? this.isLargeText,
      isVoiceEnabled: isVoiceEnabled ?? this.isVoiceEnabled,
      isScreenReaderEnabled:
          isScreenReaderEnabled ?? this.isScreenReaderEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
    );
  }
}

/// Accessibility notifier for managing accessibility state
class AccessibilityNotifier extends StateNotifier<AccessibilityState> {
  AccessibilityNotifier() : super(const AccessibilityState()) {
    _initializeAccessibility();
  }

  void _initializeAccessibility() async {
    // Check device accessibility settings
    final isAccessibilityEnabled =
        await AccessibilityService.isAccessibilityEnabled();
    if (isAccessibilityEnabled) {
      state = state.copyWith(isScreenReaderEnabled: true);
    }
  }

  void toggleHighContrast() {
    final newValue = !state.isHighContrast;
    state = state.copyWith(isHighContrast: newValue);

    if (newValue) {
      AccessibilityService.enableHighContrast();
      AccessibilityService.announceMessage('High contrast mode enabled');
    } else {
      AccessibilityService.announceMessage('High contrast mode disabled');
    }
  }

  void toggleLargeText() {
    final newValue = !state.isLargeText;
    state = state.copyWith(
      isLargeText: newValue,
      textScaleFactor: newValue ? 1.3 : 1.0,
    );

    AccessibilityService.announceMessage(
        newValue ? 'Large text enabled' : 'Large text disabled');
  }

  void toggleVoiceGuidance() {
    final newValue = !state.isVoiceEnabled;
    state = state.copyWith(isVoiceEnabled: newValue);

    if (newValue) {
      AccessibilityService.enableVoiceGuidance();
      AccessibilityService.announceMessage('Voice guidance enabled');
    } else {
      AccessibilityService.announceMessage('Voice guidance disabled');
    }
  }

  void toggleReduceAnimations() {
    final newValue = !state.reduceAnimations;
    state = state.copyWith(reduceAnimations: newValue);

    AccessibilityService.announceMessage(newValue
        ? 'Reduced animations enabled'
        : 'Reduced animations disabled');
  }

  void setTextScaleFactor(double factor) {
    state = state.copyWith(
      textScaleFactor: factor.clamp(0.8, 2.0),
      isLargeText: factor > 1.0,
    );
  }
}

/// Provider for accessibility state
final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilityState>((ref) {
  return AccessibilityNotifier();
});

/// Accessible button wrapper
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final bool isLoading;
  final double minTouchTarget;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.isLoading = false,
    this.minTouchTarget = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              minWidth: minTouchTarget,
              minHeight: minTouchTarget,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible text widget with automatic scaling
class AccessibleText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final String? semanticLabel;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: style?.copyWith(
          fontSize: (style?.fontSize ?? 14) * accessibility.textScaleFactor,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        textScaleFactor: accessibility.textScaleFactor,
      ),
    );
  }
}

/// Screen reader announcement widget
class ScreenReaderAnnouncement extends StatefulWidget {
  final String message;
  final Widget child;

  const ScreenReaderAnnouncement({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  State<ScreenReaderAnnouncement> createState() =>
      _ScreenReaderAnnouncementState();
}

class _ScreenReaderAnnouncementState extends State<ScreenReaderAnnouncement> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityService.announceMessage(widget.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Focus management helper
class FocusManager {
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }
}

/// Voice input helper
class VoiceInputHelper {
  static Future<String?> startVoiceInput() async {
    try {
      const platform = MethodChannel('travel_planner/voice');
      final result = await platform.invokeMethod<String>('startVoiceInput');
      return result;
    } on PlatformException catch (e) {
      print('Voice input failed: ${e.message}');
      return null;
    }
  }
}

/// Accessibility settings screen
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);
    final accessibilityNotifier = ref.read(accessibilityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const AccessibleText(
          'Accessibility Settings',
          semanticLabel: 'Accessibility Settings Screen',
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // High Contrast Mode
          Card(
            child: SwitchListTile(
              title: const AccessibleText(
                'High Contrast Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const AccessibleText(
                'Increases contrast for better visibility',
                style: TextStyle(fontSize: 12),
              ),
              value: accessibility.isHighContrast,
              onChanged: (_) => accessibilityNotifier.toggleHighContrast(),
              secondary: const Icon(Icons.contrast, size: 32),
            ),
          ),

          const SizedBox(height: 16),

          // Large Text
          Card(
            child: SwitchListTile(
              title: const AccessibleText(
                'Large Text',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const AccessibleText(
                'Makes text bigger and easier to read',
                style: TextStyle(fontSize: 12),
              ),
              value: accessibility.isLargeText,
              onChanged: (_) => accessibilityNotifier.toggleLargeText(),
              secondary: const Icon(Icons.format_size, size: 32),
            ),
          ),

          const SizedBox(height: 16),

          // Voice Guidance
          Card(
            child: SwitchListTile(
              title: const AccessibleText(
                'Voice Guidance',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const AccessibleText(
                'Spoken feedback for actions and navigation',
                style: TextStyle(fontSize: 12),
              ),
              value: accessibility.isVoiceEnabled,
              onChanged: (_) => accessibilityNotifier.toggleVoiceGuidance(),
              secondary: const Icon(Icons.record_voice_over, size: 32),
            ),
          ),

          const SizedBox(height: 16),

          // Reduce Animations
          Card(
            child: SwitchListTile(
              title: const AccessibleText(
                'Reduce Animations',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const AccessibleText(
                'Minimizes motion for better focus',
                style: TextStyle(fontSize: 12),
              ),
              value: accessibility.reduceAnimations,
              onChanged: (_) => accessibilityNotifier.toggleReduceAnimations(),
              secondary: const Icon(Icons.motion_photos_off, size: 32),
            ),
          ),

          const SizedBox(height: 24),

          // Text Size Slider
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields, size: 32),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: AccessibleText(
                          'Text Size',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AccessibleText(
                    'Sample text at current size',
                    style: TextStyle(
                      fontSize: 14 * accessibility.textScaleFactor,
                    ),
                    semanticLabel: 'Sample text showing current text size',
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Text size adjustment slider',
                    value: '${(accessibility.textScaleFactor * 100).round()}%',
                    child: Slider(
                      value: accessibility.textScaleFactor,
                      min: 0.8,
                      max: 2.0,
                      divisions: 12,
                      label:
                          '${(accessibility.textScaleFactor * 100).round()}%',
                      onChanged: accessibilityNotifier.setTextScaleFactor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AccessibleText(
                        'Small',
                        style: TextStyle(
                          fontSize: 12 * accessibility.textScaleFactor,
                          color: Colors.grey[600],
                        ),
                      ),
                      AccessibleText(
                        'Large',
                        style: TextStyle(
                          fontSize: 12 * accessibility.textScaleFactor,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Voice Input Test
          Card(
            child: ListTile(
              leading: const Icon(Icons.mic, size: 32),
              title: const AccessibleText(
                'Test Voice Input',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const AccessibleText(
                'Try speaking to test voice recognition',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () async {
                final result = await VoiceInputHelper.startVoiceInput();
                if (result != null && context.mounted) {
                  AccessibilityService.announceMessage('You said: $result');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: AccessibleText('Voice input: $result'),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
