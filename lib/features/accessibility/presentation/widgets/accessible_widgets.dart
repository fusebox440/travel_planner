import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/accessibility_providers.dart';

/// Accessibility-aware button that provides appropriate feedback and styling
class AccessibleButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonStyle? style;
  final String? announcement;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.style,
    this.announcement,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(accessibilityOperationsProvider);
    final shouldShowEnhancedFocus = ref.watch(shouldShowEnhancedFocusProvider);
    final focusColor = ref
        .watch(accessibilityFocusColorProvider(Theme.of(context).colorScheme));

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return Container(
              decoration: shouldShowEnhancedFocus && isFocused
                  ? BoxDecoration(
                      border: Border.all(color: focusColor, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: ElevatedButton(
                onPressed: onPressed != null
                    ? () async {
                        await operations.provideFeedback(
                          announcement: announcement,
                        );
                        onPressed!();
                      }
                    : null,
                style: style,
                child: tooltip != null
                    ? Tooltip(
                        message: tooltip!,
                        child: child,
                      )
                    : child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Accessibility-aware text widget that adjusts to font size settings
class AccessibleText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final String? semanticLabel;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AccessibleText(
    this.text, {
    super.key,
    this.style,
    this.semanticLabel,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(fontScaleFactorProvider);

    final effectiveStyle = style?.copyWith(
          fontSize: (style?.fontSize ?? 14) * fontScale,
        ) ??
        TextStyle(fontSize: 14 * fontScale);

    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: effectiveStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Accessibility-aware animated widget that respects motion preferences
class AccessibleAnimatedContainer extends ConsumerWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final Matrix4? transform;

  const AccessibleAnimatedContainer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.ease,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveDuration = ref.watch(animationDurationProvider(duration));

    return AnimatedContainer(
      duration: effectiveDuration,
      curve: curve,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      child: child,
    );
  }
}

/// Accessibility-aware card widget with enhanced focus handling
class AccessibleCard extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.margin,
    this.padding,
    this.color,
    this.elevation,
    this.shape,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(accessibilityOperationsProvider);
    final shouldShowEnhancedFocus = ref.watch(shouldShowEnhancedFocusProvider);
    final focusColor = ref
        .watch(accessibilityFocusColorProvider(Theme.of(context).colorScheme));

    Widget cardWidget = Card(
      margin: margin,
      color: color,
      elevation: elevation,
      shape: shape,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      cardWidget = Focus(
        child: Builder(
          builder: (context) {
            final isFocused = Focus.of(context).hasFocus;

            return Container(
              decoration: shouldShowEnhancedFocus && isFocused
                  ? BoxDecoration(
                      border: Border.all(color: focusColor, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: InkWell(
                onTap: () async {
                  await operations.provideFeedback();
                  onTap!();
                },
                borderRadius: BorderRadius.circular(12),
                child: Semantics(
                  label: semanticLabel,
                  button: true,
                  child: cardWidget,
                ),
              ),
            );
          },
        ),
      );
    } else if (semanticLabel != null) {
      cardWidget = Semantics(
        label: semanticLabel,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// Accessibility-aware text field with enhanced focus indicators
class AccessibleTextField extends ConsumerWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? semanticLabel;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;
  final InputDecoration? decoration;

  const AccessibleTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.semanticLabel,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
    this.decoration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontScale = ref.watch(fontScaleFactorProvider);
    final shouldShowEnhancedFocus = ref.watch(shouldShowEnhancedFocusProvider);
    final focusColor = ref
        .watch(accessibilityFocusColorProvider(Theme.of(context).colorScheme));

    return Semantics(
      label: semanticLabel ?? labelText ?? hintText,
      textField: true,
      child: Focus(
        child: Builder(
          builder: (context) {
            // Focus management for accessibility

            return TextField(
              controller: controller,
              onChanged: onChanged,
              onTap: onTap,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              maxLines: maxLines,
              maxLength: maxLength,
              style: TextStyle(fontSize: 16 * fontScale),
              decoration: (decoration ?? InputDecoration()).copyWith(
                hintText: hintText,
                labelText: labelText,
                focusedBorder: shouldShowEnhancedFocus
                    ? OutlineInputBorder(
                        borderSide: BorderSide(color: focusColor, width: 2),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Accessibility-aware list tile with proper semantics
class AccessibleListTile extends ConsumerWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool enabled;

  const AccessibleListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(accessibilityOperationsProvider);
    final shouldShowEnhancedFocus = ref.watch(shouldShowEnhancedFocusProvider);
    final focusColor = ref
        .watch(accessibilityFocusColorProvider(Theme.of(context).colorScheme));

    return Focus(
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;

          return Container(
            decoration: shouldShowEnhancedFocus && isFocused
                ? BoxDecoration(
                    border: Border.all(color: focusColor, width: 2),
                  )
                : null,
            child: Semantics(
              label: semanticLabel,
              button: onTap != null,
              enabled: enabled,
              child: ListTile(
                leading: leading,
                title: title,
                subtitle: subtitle,
                trailing: trailing,
                enabled: enabled,
                onTap: onTap != null
                    ? () async {
                        await operations.provideFeedback();
                        onTap!();
                      }
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Accessibility-aware floating action button
class AccessibleFloatingActionButton extends ConsumerWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final String? heroTag;

  const AccessibleFloatingActionButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(accessibilityOperationsProvider);

    return Semantics(
      label: semanticLabel ?? tooltip,
      button: true,
      enabled: onPressed != null,
      child: FloatingActionButton(
        onPressed: onPressed != null
            ? () async {
                await operations.provideFeedback(
                  announcement: semanticLabel,
                );
                onPressed!();
              }
            : null,
        tooltip: tooltip,
        heroTag: heroTag,
        child: child,
      ),
    );
  }
}
