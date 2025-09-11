import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/design_tokens.dart';
import 'package:travel_planner/widgets/app_drawer.dart';

/// Defines the size variants for the adaptive AppBar.
enum AppBarSize { compact, normal, large }

/// A custom, adaptive AppBar that adjusts its size and layout.
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBarSize size;
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const AdaptiveAppBar({
    super.key,
    this.size = AppBarSize.normal,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget titleWidget = Text(
      title,
      style: size == AppBarSize.large
          ? theme.textTheme.headlineMedium
              ?.copyWith(color: theme.colorScheme.onSurface)
          : theme.textTheme.titleLarge,
    );

    if (subtitle != null) {
      titleWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          titleWidget,
          Text(subtitle!, style: theme.textTheme.bodySmall),
        ],
      );
    }

    return AppBar(
      title: titleWidget,
      actions: actions,
      // The back button is automatically handled by the router.
    );
  }

  @override
  Size get preferredSize {
    switch (size) {
      case AppBarSize.compact:
        return const Size.fromHeight(48.0);
      case AppBarSize.normal:
        return const Size.fromHeight(kToolbarHeight);
      case AppBarSize.large:
        return const Size.fromHeight(112.0);
    }
  }
}

/// A responsive scaffold that adapts to screen width.
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    const double wideBreakpoint = 900.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= wideBreakpoint;

    final drawerToUse = isWideScreen ? null : (drawer ?? const AppDrawer());

    return Scaffold(
      appBar: appBar,
      drawer: drawerToUse,
      endDrawer: endDrawer,
      body: Padding(
        padding: DesignTokens.spacingM,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor,
    );
  }
}
