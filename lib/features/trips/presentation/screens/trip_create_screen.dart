import 'package:flutter/material.dart';
// FIX: Import the new public form widget
import 'package:travel_planner/features/trips/presentation/widgets/trip_form.dart';

class TripCreateScreen extends StatelessWidget {
  const TripCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a New Trip'),
      ),
      // FIX: Use the public TripForm widget
      body: const TripForm(),
    );
  }
}