import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/accessibility/accessibility.dart';
import 'package:travel_planner/core/accessibility/accessible_components.dart';
import 'package:travel_planner/core/performance/performance_manager.dart';
import 'package:travel_planner/core/theme/app_theme.dart';
import 'package:travel_planner/core/navigation/app_navigation.dart';
import 'package:travel_planner/core/gamification/gamification.dart'
    as gamification;
import 'package:travel_planner/core/gamification/gamification_provider.dart';

/// Main app wrapper with accessibility and performance enhancements
class AccessibleTravelPlannerApp extends ConsumerStatefulWidget {
  const AccessibleTravelPlannerApp({super.key});

  @override
  ConsumerState<AccessibleTravelPlannerApp> createState() =>
      _AccessibleTravelPlannerAppState();
}

class _AccessibleTravelPlannerAppState
    extends ConsumerState<AccessibleTravelPlannerApp> {
  @override
  void initState() {
    super.initState();
    // Initialize performance optimizations
    ImageCacheManager.initialize();
    PerformanceManager.optimizeImageCache();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final accessibility = ref.watch(accessibilityProvider);

    return MaterialApp(
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,

      // Apply theme based on accessibility settings
      theme: _getEffectiveTheme(themeMode, accessibility),

      // Custom text scale factor for accessibility
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: accessibility.textScaleFactor,
            boldText: accessibility.isLargeText,
          ),
          child: PerformanceMonitor(
            showOverlay: false, // Set to true for development
            child: gamification.CelebrationOverlay(
              showCelebration: ref.watch(gamificationProvider).showCelebration,
              onCelebrationComplete: () {
                ref.read(gamificationProvider.notifier).clearCelebration();
              },
              child: child ?? const SizedBox(),
            ),
          ),
        );
      },

      home: const AccessibleMainScreen(),

      // Accessibility settings
      shortcuts: _buildKeyboardShortcuts(),

      // Route settings for accessibility
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, _) {
            switch (settings.name) {
              case '/accessibility':
                return const AccessibilitySettingsScreen();
              default:
                return const AccessibleMainScreen();
            }
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Respect reduce animations setting
            if (accessibility.reduceAnimations) {
              return child;
            }

            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.ease)),
              ),
              child: child,
            );
          },
        );
      },
    );
  }

  ThemeData _getEffectiveTheme(
      AppThemeMode themeMode, AccessibilityState accessibility) {
    // Override with high contrast if enabled
    if (accessibility.isHighContrast) {
      return AppTheme.highContrastTheme;
    }

    return AppTheme.getThemeData(themeMode);
  }

  Map<LogicalKeySet, Intent> _buildKeyboardShortcuts() {
    return {
      LogicalKeySet(LogicalKeyboardKey.tab): const NextFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab):
          const PreviousFocusIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
    };
  }
}

/// Main screen wrapper with accessibility enhancements
class AccessibleMainScreen extends ConsumerWidget {
  const AccessibleMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return Semantics(
      label: 'Travel Planner Main Screen',
      child: Focus(
        autofocus: true,
        child: Builder(
          builder: (context) {
            // Use responsive layout based on screen size
            final screenWidth = MediaQuery.of(context).size.width;
            final isTablet = screenWidth > 600;

            if (isTablet && !accessibility.reduceAnimations) {
              return _buildTabletLayout(context, ref);
            } else {
              return _buildPhoneLayout(context, ref);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: Row(
        children: [
          // Navigation rail for tablets
          AccessibleNavigationRail(
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.flight),
                label: const Text('Trips'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.luggage),
                label: const Text('Packing'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.wb_sunny),
                label: const Text('Weather'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.map),
                label: const Text('Maps'),
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.star),
                label: const Text('Reviews'),
              ),
            ],
            selectedIndex: currentIndex,
            onDestinationSelected: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
            },
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/accessibility');
                },
                child: const Icon(Icons.accessibility),
              ),
            ),
          ),

          // Main content
          Expanded(
            child: _buildMainContent(currentIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context, WidgetRef ref) {
    return const MainNavigationScreen();
  }

  Widget _buildMainContent(int currentIndex) {
    // Add skip links for keyboard navigation
    final screens = [
      _wrapWithSkipLink(
        const Center(child: Text('Trips Screen - Coming Soon! ✈️')),
        'Skip to trips content',
      ),
      _wrapWithSkipLink(
        const Center(child: Text('Packing List - Coming Soon! 🎒')),
        'Skip to packing content',
      ),
      _wrapWithSkipLink(
        const Center(child: Text('Weather Screen - Coming Soon! 🌤️')),
        'Skip to weather content',
      ),
      _wrapWithSkipLink(
        const Center(child: Text('Maps Screen - Coming Soon! 🗺️')),
        'Skip to maps content',
      ),
      _wrapWithSkipLink(
        const Center(child: Text('Reviews Screen - Coming Soon! ⭐')),
        'Skip to reviews content',
      ),
    ];

    return IndexedStack(
      index: currentIndex,
      children: screens,
    );
  }

  Widget _wrapWithSkipLink(Widget child, String skipText) {
    return Stack(
      children: [
        child,
        SkipLink(
          text: skipText,
          onPressed: () {
            // Focus on the main content
          },
          focusNode: FocusNode(),
        ),
      ],
    );
  }
}

/// Accessibility-aware route transitions
class AccessiblePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final bool reduceAnimations;

  AccessiblePageRoute({
    required this.child,
    this.reduceAnimations = false,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          pageBuilder: (context, animation, _) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (reduceAnimations) {
              return child;
            }

            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Performance-aware image loading
class AccessibleNetworkImage extends ConsumerWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AccessibleNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessibility = ref.watch(accessibilityProvider);

    return Semantics(
      image: true,
      label: 'Travel image',
      child: OptimizedImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: SkeletonLoader(
          width: width ?? 200,
          height: height ?? 200,
        ),
        errorWidget: Container(
          width: width ?? 200,
          height: height ?? 200,
          decoration: BoxDecoration(
            color: accessibility.isHighContrast
                ? Colors.grey[300]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: accessibility.isHighContrast
                ? Colors.grey[700]
                : Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

/// Accessibility service integration
class AccessibilityIntegration {
  static void announceNavigation(String screenName) {
    AccessibilityService.announceMessage('Navigated to $screenName');
  }

  static void announceAction(String action) {
    AccessibilityService.announceMessage(action);
  }

  static void announceSuccess(String message) {
    AccessibilityService.announceMessage('Success: $message');
  }

  static void announceError(String error) {
    AccessibilityService.announceMessage('Error: $error');
  }
}
