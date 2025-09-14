import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accessibility_providers.dart';
import '../../domain/models/accessibility_settings.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends ConsumerState<AccessibilitySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(accessibilitySettingsProvider);
    final notifier = ref.watch(accessibilitySettingsProvider.notifier);
    final operations = ref.watch(accessibilityOperationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
        actions: [
          IconButton(
            onPressed: () async {
              await operations.provideFeedback(
                announcement:
                    'Resetting all accessibility settings to defaults',
              );
              await notifier.resetToDefaults();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Accessibility settings reset to defaults'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Visual Accessibility Section
          _AccessibilitySection(
            title: 'Visual Accessibility',
            icon: Icons.visibility,
            children: [
              _AccessibilitySwitchTile(
                title: 'High Contrast Mode',
                subtitle: 'Increase contrast for better visibility',
                value: settings.isHighContrastEnabled,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'High contrast enabled'
                        : 'High contrast disabled',
                  );
                  await notifier.toggleHighContrast();
                },
                semanticLabel:
                    'Toggle high contrast mode for improved visibility',
              ),
              const SizedBox(height: 16),
              _FontSizeSlider(
                value: settings.fontSize,
                onChanged: (value) async {
                  await notifier.setFontSize(value);
                },
                operations: operations,
              ),
              const SizedBox(height: 16),
              _ColorSchemeSelector(
                currentScheme: settings.colorScheme,
                onSchemeChanged: (scheme) async {
                  await operations.provideFeedback(
                    announcement: 'Color scheme changed to ${scheme.name}',
                  );
                  await notifier.setColorScheme(scheme);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Motor Accessibility Section
          _AccessibilitySection(
            title: 'Motor Accessibility',
            icon: Icons.touch_app,
            children: [
              _AccessibilitySwitchTile(
                title: 'Keyboard Navigation',
                subtitle:
                    'Enable navigation using keyboard or external devices',
                value: settings.isKeyboardNavigationEnabled,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'Keyboard navigation enabled'
                        : 'Keyboard navigation disabled',
                  );
                  await notifier.toggleKeyboardNavigation();
                },
                semanticLabel: 'Toggle keyboard navigation support',
              ),
              _AccessibilitySwitchTile(
                title: 'Enhanced Focus Indicators',
                subtitle:
                    'Show enhanced visual indicators for focused elements',
                value: settings.isFocusIndicatorEnhanced,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'Enhanced focus indicators enabled'
                        : 'Enhanced focus indicators disabled',
                  );
                  await notifier.toggleEnhancedFocusIndicators();
                },
                semanticLabel:
                    'Toggle enhanced focus indicators for better navigation',
              ),
              _AccessibilitySwitchTile(
                title: 'Reduced Animations',
                subtitle: 'Reduce motion and animations throughout the app',
                value: settings.areAnimationsReduced,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement:
                        value ? 'Animations reduced' : 'Animations restored',
                  );
                  await notifier.toggleReducedAnimations();
                },
                semanticLabel:
                    'Toggle reduced animations for motion sensitivity',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Screen Reader Section
          _AccessibilitySection(
            title: 'Screen Reader',
            icon: Icons.record_voice_over,
            children: [
              _AccessibilitySwitchTile(
                title: 'Screen Reader Support',
                subtitle: 'Optimize the app for screen readers',
                value: settings.isScreenReaderEnabled,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'Screen reader support enabled'
                        : 'Screen reader support disabled',
                  );
                  await notifier.toggleScreenReader();
                },
                semanticLabel: 'Toggle screen reader optimization',
              ),
              _AccessibilitySwitchTile(
                title: 'Verbose Descriptions',
                subtitle: 'Provide detailed descriptions for screen readers',
                value: settings.isSemanticLabelsVerbose,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'Verbose descriptions enabled'
                        : 'Verbose descriptions disabled',
                  );
                  await notifier.toggleVerboseSemanticLabels();
                },
                semanticLabel: 'Toggle verbose semantic descriptions',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Feedback Section
          _AccessibilitySection(
            title: 'Feedback',
            icon: Icons.feedback,
            children: [
              _AccessibilitySwitchTile(
                title: 'Sound Feedback',
                subtitle: 'Play sounds for user interactions',
                value: settings.isSoundFeedbackEnabled,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'Sound feedback enabled'
                        : 'Sound feedback disabled',
                  );
                  await notifier.toggleSoundFeedback();
                },
                semanticLabel: 'Toggle sound feedback for interactions',
              ),
              _AccessibilitySwitchTile(
                title: 'Haptic Feedback',
                subtitle: 'Provide vibration feedback for interactions',
                value: settings.isHapticFeedbackEnabled,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'Haptic feedback enabled'
                        : 'Haptic feedback disabled',
                  );
                  await notifier.toggleHapticFeedback();
                },
                semanticLabel: 'Toggle haptic vibration feedback',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Color Vision Section
          _AccessibilitySection(
            title: 'Color Vision',
            icon: Icons.color_lens,
            children: [
              _AccessibilitySwitchTile(
                title: 'Color Blindness Assistance',
                subtitle: 'Adjust colors for color vision differences',
                value: settings.isColorBlindnessAssistEnabled,
                onChanged: (value) async {
                  await operations.provideFeedback(
                    announcement: value
                        ? 'Color blindness assistance enabled'
                        : 'Color blindness assistance disabled',
                  );
                  await notifier.toggleColorBlindnessAssist();
                },
                semanticLabel: 'Toggle color blindness assistance features',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccessibilitySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _AccessibilitySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AccessibilitySwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;

  const _AccessibilitySwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _FontSizeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final AccessibilityOperations operations;

  const _FontSizeSlider({
    required this.value,
    required this.onChanged,
    required this.operations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.text_fields, size: 16),
            Expanded(
              child: Slider(
                value: value,
                min: 0.8,
                max: 2.0,
                divisions: 12,
                label: '${(value * 100).round()}%',
                onChanged: (newValue) {
                  operations.provideFeedback();
                  onChanged(newValue);
                },
                semanticFormatterCallback: (double value) {
                  return '${(value * 100).round()} percent font size';
                },
              ),
            ),
            const Icon(Icons.text_fields, size: 24),
          ],
        ),
        Text(
          'Preview: ${(value * 100).round()}% size',
          style: TextStyle(fontSize: 16 * value),
        ),
      ],
    );
  }
}

class _ColorSchemeSelector extends StatelessWidget {
  final AccessibilityColorScheme currentScheme;
  final ValueChanged<AccessibilityColorScheme> onSchemeChanged;

  const _ColorSchemeSelector({
    required this.currentScheme,
    required this.onSchemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Scheme',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: AccessibilityColorScheme.values.map((scheme) {
            final isSelected = scheme == currentScheme;
            return FilterChip(
              label: Text(_getSchemeDisplayName(scheme)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSchemeChanged(scheme);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getSchemeDisplayName(AccessibilityColorScheme scheme) {
    switch (scheme) {
      case AccessibilityColorScheme.standard:
        return 'Standard';
      case AccessibilityColorScheme.highContrast:
        return 'High Contrast';
      case AccessibilityColorScheme.protanopia:
        return 'Protanopia';
      case AccessibilityColorScheme.deuteranopia:
        return 'Deuteranopia';
      case AccessibilityColorScheme.tritanopia:
        return 'Tritanopia';
      case AccessibilityColorScheme.monochrome:
        return 'Monochrome';
    }
  }
}
