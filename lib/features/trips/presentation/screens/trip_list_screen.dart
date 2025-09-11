import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_planner/core/services/settings_service.dart';
import 'package:travel_planner/core/theme/app_theme.dart';
import 'package:travel_planner/features/trips/presentation/providers/trip_providers.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/widgets/animated_staggered_list.dart';
import 'package:travel_planner/widgets/background_layer.dart';
import 'package:travel_planner/widgets/skeletons.dart';
import 'package:travel_planner/widgets/trip_card.dart';

// Filter providers
enum TripFilter { all, upcoming, past }
final tripFilterProvider = StateProvider<TripFilter>((ref) => TripFilter.all);
final searchQueryProvider = StateProvider<String>((ref) => '');
final filteredTripsProvider = Provider<List<Trip>>((ref) {
  final filter = ref.watch(tripFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final tripsAsyncValue = ref.watch(tripListProvider);

  if (tripsAsyncValue.isLoading || tripsAsyncValue.hasError) return [];
  final trips = tripsAsyncValue.value ?? [];

  return trips.where((trip) {
    final matchesFilter = switch (filter) {
      TripFilter.all => true,
      TripFilter.upcoming => trip.startDate.isAfter(DateTime.now()),
      TripFilter.past => trip.startDate.isBefore(DateTime.now()),
    };
    final matchesSearch = trip.title.toLowerCase().contains(searchQuery) ||
        trip.locationName.toLowerCase().contains(searchQuery);
    return matchesFilter && matchesSearch;
  }).toList();
});

class TripListScreen extends ConsumerWidget {
  const TripListScreen({super.key});

  /// Shows a confirmation dialog before deleting a trip.
  void _confirmDelete(BuildContext context, WidgetRef ref, Trip trip) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip?'),
        content: Text('Are you sure you want to delete "${trip.title}"? This will also delete all associated days, activities, and photos. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(tripListProvider.notifier).deleteTrip(trip.id);
    }
  }

  void _showCelebration(BuildContext context) {
    final batterySaverEnabled = SettingsService().getBatterySaver();
    if (batterySaverEnabled) return;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: Lottie.asset(
            'assets/lottie/confetti.json',
            repeat: false,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsyncValue = ref.watch(tripListProvider);
    final filteredTrips = ref.watch(filteredTripsProvider);
    final themeMode = ref.watch(themeProvider);

    final screenContent = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Trips'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(themeMode == AppThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            onPressed: () {
              HapticFeedback.lightImpact();
              final newMode = themeMode == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
              ref.read(themeProvider.notifier).setThemeMode(newMode);
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.go('/settings');
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context, ref),
          Expanded(
            child: tripsAsyncValue.when(
              data: (trips) {
                if (trips.isEmpty) return _buildEmptyState(context);
                if (filteredTrips.isEmpty) return const Center(child: Text('No trips match your search.'));
                return _buildTripList(context, ref, filteredTrips);
              },
              loading: () => ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TripCardSkeleton(),
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          HapticFeedback.lightImpact();
          final result = await context.push<bool>('/trip/create');
          if (result == true && context.mounted) {
            _showCelebration(context);
          }
        },
        tooltip: 'Add Trip',
        child: const Icon(Icons.add),
      ),
    );

    return BackgroundLayer(
      isAnimationEnabled: true,
      child: screenContent,
    );
  }

  Widget _buildTripList(BuildContext context, WidgetRef ref, List<Trip> trips) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return AnimatedStaggeredList(
          isGridView: isWide,
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return TripCard(
              trip: trip,
              onTap: () => context.go('/trip/${trip.id}'),
              onDelete: () => _confirmDelete(context, ref, trip),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) =>
            ref.read(searchQueryProvider.notifier).state = value,
            decoration: const InputDecoration(
              hintText: 'Search trips...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<TripFilter>(
            segments: const [
              ButtonSegment(value: TripFilter.all, label: Text('All'), icon: Icon(Icons.list_alt)),
              ButtonSegment(value: TripFilter.upcoming, label: Text('Upcoming'), icon: Icon(Icons.flight_takeoff)),
              ButtonSegment(value: TripFilter.past, label: Text('Past'), icon: Icon(Icons.history)),
            ],
            selected: {ref.watch(tripFilterProvider)},
            onSelectionChanged: (newSelection) {
              HapticFeedback.lightImpact();
              ref.read(tripFilterProvider.notifier).state = newSelection.first;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/empty_travel.json',
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 24),
          Text(
            'No trips yet.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first adventure!',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}