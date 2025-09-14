import 'package:go_router/go_router.dart';
import 'package:travel_planner/features/translator/presentation/screens/saved_phrases_screen.dart';
import 'package:travel_planner/features/translator/presentation/screens/translator_screen.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:hive/hive.dart';

final translatorRoutes = [
  GoRoute(
    path: '/translator/:tripId',
    builder: (context, state) {
      final tripId = state.pathParameters['tripId']!;
      // TODO: Fetch trip from service/provider using tripId
      // For now, create a minimal trip object with required parameters
      final now = DateTime.now();
      final trip = Trip(
        id: tripId,
        title: 'Current Trip',
        locationName: 'Unknown Location',
        locationLat: 0.0,
        locationLng: 0.0,
        startDate: now,
        endDate: now.add(const Duration(days: 7)),
        createdAt: now,
        lastModified: now,
        days: HiveList(Hive.box<Day>('days')),
        packingList: HiveList(Hive.box<PackingItem>('packing_items')),
        companions: HiveList(Hive.box<Companion>('companions')),
      );
      return TranslatorScreen(trip: trip);
    },
  ),
  GoRoute(
    path: '/translator/saved',
    builder: (context, state) => const SavedPhrasesScreen(),
  ),
];
