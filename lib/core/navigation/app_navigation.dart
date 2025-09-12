import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_planner/features/trips/presentation/screens/trip_list_screen.dart';
import 'package:travel_planner/features/weather/presentation/screens/weather_screen.dart';
import 'package:travel_planner/features/maps/presentation/screens/map_screen.dart';
import 'package:travel_planner/features/reviews/presentation/screens/reviews_screen.dart';
import 'package:travel_planner/features/gamification/badges_screen.dart';
import 'package:travel_planner/core/gamification/gamification.dart'
    as gamification;
import 'package:travel_planner/core/gamification/gamification_provider.dart';

// Bottom navigation provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'My Trips ✈️';
      case 1:
        return 'Packing List 🎒';
      case 2:
        return 'Weather 🌤️';
      case 3:
        return 'Maps 🗺️';
      case 4:
        return 'Reviews ⭐';
      default:
        return 'Travel Planner';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final gamificationState = ref.watch(gamificationProvider);

    return gamification.CelebrationOverlay(
      showCelebration: gamificationState.showCelebration,
      onCelebrationComplete: () {
        ref.read(gamificationProvider.notifier).clearCelebration();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getScreenTitle(currentIndex)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // Gamification summary button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BadgesScreen(),
                    ),
                  );
                },
                icon: Stack(
                  children: [
                    const Icon(Icons.emoji_events, size: 28),
                    Consumer(
                      builder: (context, ref, child) {
                        final unlockedCount =
                            ref.watch(unlockedBadgesCountProvider);
                        if (unlockedCount > 0) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '$unlockedCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: currentIndex,
          children: [
            const TripListScreen(),
            // Use a placeholder for packing list - will be replaced with proper trip selection
            const Center(child: Text('Select a trip to view packing list 🎒')),
            const WeatherScreen(),
            const MapScreen(),
            const ReviewsScreen(
                placeName: 'Current Location'), // TODO: Dynamic location
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: (index) =>
                ref.read(bottomNavIndexProvider.notifier).state = index,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            elevation: 8,
            items: [
              BottomNavigationBarItem(
                icon: _AnimatedIcon(
                  icon: Icons.card_travel_rounded,
                  isSelected: currentIndex == 0,
                ),
                activeIcon: _AnimatedIcon(
                  icon: Icons.card_travel_rounded,
                  isSelected: true,
                ),
                label: 'Trips ✈️',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedIcon(
                  icon: Icons.backpack_rounded,
                  isSelected: currentIndex == 1,
                ),
                activeIcon: _AnimatedIcon(
                  icon: Icons.backpack_rounded,
                  isSelected: true,
                ),
                label: 'Packing 🎒',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedIcon(
                  icon: Icons.wb_sunny_rounded,
                  isSelected: currentIndex == 2,
                ),
                activeIcon: _AnimatedIcon(
                  icon: Icons.wb_sunny_rounded,
                  isSelected: true,
                ),
                label: 'Weather ☀️',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedIcon(
                  icon: Icons.map_rounded,
                  isSelected: currentIndex == 3,
                ),
                activeIcon: _AnimatedIcon(
                  icon: Icons.map_rounded,
                  isSelected: true,
                ),
                label: 'Maps 🗺️',
              ),
              BottomNavigationBarItem(
                icon: _AnimatedIcon(
                  icon: Icons.star_rounded,
                  isSelected: currentIndex == 4,
                ),
                activeIcon: _AnimatedIcon(
                  icon: Icons.star_rounded,
                  isSelected: true,
                ),
                label: 'Reviews ⭐',
              ),
            ],
          ),
        ),
        floatingActionButton:
            _buildFloatingActionButton(context, ref, currentIndex),
      ),
    );
  }

  Widget? _buildFloatingActionButton(
      BuildContext context, WidgetRef ref, int currentIndex) {
    late IconData fabIcon;
    late String fabLabel;
    late VoidCallback onPressed;

    switch (currentIndex) {
      case 0: // Trips
        fabIcon = Icons.add_rounded;
        fabLabel = 'Add Trip';
        onPressed = () {
          // Navigate to add trip screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Trip - Coming Soon! 🎉')),
          );
        };
        break;
      case 1: // Packing
        fabIcon = Icons.add_shopping_cart_rounded;
        fabLabel = 'Add Item';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Packing Item - Coming Soon! 🎒')),
          );
        };
        break;
      case 2: // Weather
        fabIcon = Icons.refresh_rounded;
        fabLabel = 'Refresh';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Weather Refreshed! 🌤️')),
          );
        };
        break;
      case 3: // Maps
        fabIcon = Icons.my_location_rounded;
        fabLabel = 'My Location';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Finding Your Location! 📍')),
          );
        };
        break;
      case 4: // Reviews
        fabIcon = Icons.rate_review_rounded;
        fabLabel = 'Add Review';
        onPressed = () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Review - Coming Soon! ⭐')),
          );
        };
        break;
      default:
        return null;
    }

    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(fabIcon),
      label: Text(fabLabel),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      foregroundColor: Theme.of(context).colorScheme.onSecondary,
      elevation: 6,
    );
  }
}

class _AnimatedIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _AnimatedIcon({
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
