import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/theme/app_theme.dart';

const ColorFilter greyscaleColorFilter = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0,      0,      0,      1, 0,
]);

class GreyModeFilter extends ConsumerWidget {
  final Widget child;
  const GreyModeFilter({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX: Read our custom AppThemeMode provider
    final appThemeMode = ref.watch(themeProvider);
    if (appThemeMode == AppThemeMode.grey) {
      return ColorFiltered(
        colorFilter: greyscaleColorFilter,
        child: child,
      );
    }
    return child;
  }
}

class MotionAdjuster {
  MotionAdjuster._();

  static Duration getDuration(BuildContext context, Duration standardDuration) {
    // FIX: Read our custom AppThemeMode provider
    final appThemeMode = ProviderScope.containerOf(context).read(themeProvider);
    if (appThemeMode == AppThemeMode.grey) {
      return const Duration(milliseconds: 20);
    }
    return standardDuration;
  }
}