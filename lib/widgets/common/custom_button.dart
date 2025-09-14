import 'package:flutter/material.dart';

/// Custom button widget with consistent styling
class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                textColor ??
                    (isOutlined
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary),
              ),
            ),
          )
        else if (icon != null)
          Icon(
            icon,
            size: 20,
            color: textColor ??
                (isOutlined
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onPrimary),
          ),
        if ((isLoading || icon != null) && text.isNotEmpty)
          const SizedBox(width: 8),
        if (text.isNotEmpty)
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor ??
                  (isOutlined
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onPrimary),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );

    Widget button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor,
              side: BorderSide(
                color: backgroundColor ?? theme.colorScheme.primary,
              ),
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonChild,
          )
        : FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: backgroundColor ?? theme.colorScheme.primary,
              padding: padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: buttonChild,
          );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height ?? 48,
        child: button,
      );
    }

    return button;
  }
}

/// Icon button with consistent styling
class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget child = isLoading
        ? SizedBox(
            width: size ?? 24,
            height: size ?? 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.colorScheme.primary,
              ),
            ),
          )
        : Icon(
            icon,
            size: size ?? 24,
            color: color ?? theme.colorScheme.onSurface,
          );

    if (backgroundColor != null) {
      child = Container(
        padding: padding ?? const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: child,
      );
    }

    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: child,
      tooltip: tooltip,
      padding: padding ?? const EdgeInsets.all(8),
    );
  }
}

/// Text button with consistent styling
class CustomTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? fontSize;

  const CustomTextButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.textColor,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: textColor ?? theme.colorScheme.primary,
          fontWeight: fontWeight ?? FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
