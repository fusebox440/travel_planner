import 'package:flutter/material.dart';
import 'package:travel_planner/core/design/design_tokens.dart';

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
          ? theme.textTheme.headlineMedium?.copyWith(color: theme.colorScheme.onSurface)
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

/// A responsive scaffold that adapts its navigation based on screen width.
/// It shows a side navigation rail on wide screens (>= 900px) and a
/// bottom navigation bar on narrow screens.
class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationRailDestination> destinations;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    const double wideBreakpoint = 900.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= wideBreakpoint) {
          // --- WIDE LAYOUT (Side Rail) ---
          return Scaffold(
            appBar: appBar,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations,
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  // The main content area with consistent padding
                  child: Padding(
                    padding: DesignTokens.spacingM,
                    child: body,
                  ),
                ),
              ],
            ),
            floatingActionButton: floatingActionButton,
          );
        } else {
          // --- NARROW LAYOUT (Bottom Bar) ---
          return Scaffold(
            appBar: appBar,
            // The main content area with consistent padding
            body: Padding(
              padding: DesignTokens.spacingM,
              child: body,
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: onDestinationSelected,
              items: destinations.map((dest) {
                return BottomNavigationBarItem(
                  icon: dest.icon,
                  label: (dest.label as Text).data,
                );
              }).toList(),
            ),
            floatingActionButton: floatingActionButton,
          );
        }
      },
    );
  }
}