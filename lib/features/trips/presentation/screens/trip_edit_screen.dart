import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/trips/presentation/providers/trip_providers.dart';
// FIX: Import the new public form widget
import 'package:travel_planner/features/trips/presentation/widgets/trip_form.dart';

class TripEditScreen extends ConsumerWidget {
  final String tripId;
  const TripEditScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripValue = ref.watch(tripDetailProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Trip'),
      ),
      body: tripValue.when(
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('Trip not found.'));
          }
          // FIX: Use the public TripForm widget and pass the trip data
          return TripForm(initialTrip: trip);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}