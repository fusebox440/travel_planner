import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//==============================================================================
// B U T T O N S
//==============================================================================

/// A consistent rounded border shape for all custom buttons.
final _buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14.0),
);

/// A consistent padding for buttons to ensure adequate tap targets.
const _buttonPadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);

///
/// A standard filled button for primary actions.
///
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      shape: _buttonShape,
      padding: _buttonPadding,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );

    final action = onPressed == null ? null : () {
      HapticFeedback.lightImpact();
      onPressed!();
    };

    return icon != null
        ? ElevatedButton.icon(
      style: style,
      onPressed: action,
      icon: Icon(icon),
      label: Text(text),
    )
        : ElevatedButton(
      style: style,
      onPressed: action,
      child: Text(text),
    );
  }
}

///
/// A button with less emphasis, typically for secondary actions.
///
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      shape: _buttonShape,
      padding: _buttonPadding,
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
      foregroundColor: Theme.of(context).colorScheme.primary,
    );

    final action = onPressed == null ? null : () {
      HapticFeedback.lightImpact();
      onPressed!();
    };

    return icon != null
        ? OutlinedButton.icon(
      style: style,
      onPressed: action,
      icon: Icon(icon),
      label: Text(text),
    )
        : OutlinedButton(
      style: style,
      onPressed: action,
      child: Text(text),
    );
  }
}

///
/// A button with the lowest emphasis, for tertiary actions like 'Cancel'.
///
class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const GhostButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      shape: _buttonShape,
      padding: _buttonPadding,
      foregroundColor: Theme.of(context).colorScheme.primary,
    );

    final action = onPressed == null ? null : () {
      HapticFeedback.lightImpact();
      onPressed!();
    };

    return icon != null
        ? TextButton.icon(
      style: style,
      onPressed: action,
      icon: Icon(icon),
      label: Text(text),
    )
        : TextButton(
      style: style,
      onPressed: action,
      child: Text(text),
    );
  }
}

//==============================================================================
// F O R M   I N P U T
//==============================================================================

///
/// A complete form input field with a label, text field, and inline error message.
///
class FormInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool obscureText;

  const FormInput({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}


//==============================================================================
// B O T T O M   S H E E T
//==============================================================================

///
/// A styled container for modal bottom sheets with a drag handle.
///
class BottomSheetContainer extends StatelessWidget {
  final Widget child;
  const BottomSheetContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Content
            child,
          ],
        ),
      ),
    );
  }
}