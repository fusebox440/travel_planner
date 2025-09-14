import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/accessibility/accessibility.dart';

/// Accessible card component with proper focus and semantics
class AccessibleCard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isSelected;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.backgroundColor,
    this.padding,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: isSelected,
      child: Card(
        color: backgroundColor ??
            (accessibility.isHighContrast
                ? (isSelected ? Colors.yellow[100] : Colors.white)
                : null),
        elevation: accessibility.isHighContrast ? 8 : 4,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Accessible form field with voice input support
class AccessibleFormField extends ConsumerStatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enableVoiceInput;
  final String? semanticLabel;

  const AccessibleFormField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.enableVoiceInput = true,
    this.semanticLabel,
  });

  @override
  ConsumerState<AccessibleFormField> createState() =>
      _AccessibleFormFieldState();
}

class _AccessibleFormFieldState extends ConsumerState<AccessibleFormField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = ref.watch(accessibilityProvider);

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      textField: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccessibleText(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: accessibility.isLargeText ? 18 : 16,
              color: accessibility.isHighContrast ? Colors.black : null,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            style: TextStyle(
              fontSize: accessibility.isLargeText ? 18 : 16,
              color: accessibility.isHighContrast ? Colors.black : null,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: accessibility.isHighContrast
                    ? Colors.grey[700]
                    : Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  width: accessibility.isHighContrast ? 2 : 1,
                  color:
                      accessibility.isHighContrast ? Colors.black : Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  width: 2,
                  color: accessibility.isHighContrast
                      ? Colors.blue[800]!
                      : Theme.of(context).primaryColor,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              suffixIcon:
                  widget.enableVoiceInput && accessibility.isVoiceEnabled
                      ? IconButton(
                          onPressed: _startVoiceInput,
                          icon: Icon(
                            Icons.mic,
                            color: accessibility.isHighContrast
                                ? Colors.blue[800]
                                : Theme.of(context).primaryColor,
                          ),
                          tooltip: 'Voice input',
                        )
                      : null,
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }

  void _startVoiceInput() async {
    final result = await VoiceInputHelper.startVoiceInput();
    if (result != null) {
      _controller.text = result;
      widget.onChanged?.call(result);
      AccessibilityService.announceMessage('Voice input completed');
    }
  }
}

/// Accessible list tile with enhanced touch targets
class AccessibleListTile extends ConsumerWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool isSelected;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      selected: isSelected,
      child: Container(
        decoration: BoxDecoration(
          color: accessibility.isHighContrast && isSelected
              ? Colors.yellow[100]
              : null,
          border: accessibility.isHighContrast
              ? Border.all(color: Colors.grey[400]!)
              : null,
        ),
        child: ListTile(
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          minVerticalPadding: 12,
          visualDensity: VisualDensity.comfortable,
        ),
      ),
    );
  }
}

/// Accessible navigation rail for larger screens
class AccessibleNavigationRail extends ConsumerWidget {
  final List<NavigationRailDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final Widget? leading;
  final Widget? trailing;

  const AccessibleNavigationRail({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    this.onDestinationSelected,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return Semantics(
      label: 'Main navigation',
      child: NavigationRail(
        destinations: destinations
            .map((dest) => NavigationRailDestination(
                  icon: Semantics(
                    label: dest.label is Text
                        ? (dest.label as Text).data ?? ''
                        : 'Navigation item',
                    button: true,
                    child: dest.icon,
                  ),
                  selectedIcon: dest.selectedIcon,
                  label: dest.label is Text
                      ? AccessibleText(
                          (dest.label as Text).data ?? '',
                          style: TextStyle(
                            fontSize: accessibility.isLargeText ? 14 : 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : dest.label,
                ))
            .toList(),
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        leading: leading,
        trailing: trailing,
        backgroundColor: accessibility.isHighContrast ? Colors.white : null,
        selectedIconTheme: IconThemeData(
          color: accessibility.isHighContrast
              ? Colors.blue[800]
              : Theme.of(context).primaryColor,
          size: 28,
        ),
        unselectedIconTheme: IconThemeData(
          color: accessibility.isHighContrast
              ? Colors.grey[700]
              : Colors.grey[600],
          size: 24,
        ),
        labelType: NavigationRailLabelType.all,
        useIndicator: true,
        indicatorColor: accessibility.isHighContrast
            ? Colors.yellow[200]
            : Theme.of(context).primaryColor.withOpacity(0.2),
      ),
    );
  }
}

/// Skip link widget for keyboard navigation
class SkipLink extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final FocusNode focusNode;

  const SkipLink({
    super.key,
    required this.text,
    required this.onPressed,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: 0,
      child: Focus(
        focusNode: focusNode,
        onFocusChange: (hasFocus) {
          // Move the skip link into view when focused
        },
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

/// High contrast theme data
class HighContrastTheme {
  static ThemeData getHighContrastTheme(BuildContext context) {
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
        bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
        titleLarge: TextStyle(
          color: Colors.black,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue[800],
          side: BorderSide(color: Colors.blue[800]!, width: 2),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(48, 48),
        ),
      ),
    );
  }
}
