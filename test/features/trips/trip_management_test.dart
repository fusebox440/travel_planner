import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:travel_planner/core/services/local_storage_service.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Mock service for testing
class MockStorageService implements LocalStorageService {
  final Map<String, Trip> _trips = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> saveTrip(Trip trip) async {
    _trips[trip.id] = trip;
  }

  @override
  List<Trip> getTrips() {
    return _trips.values.toList();
  }

  Trip? getTrip(String id) {
    return _trips[id];
  }

  @override
  Future<void> deleteTrip(String id) async {
    _trips.remove(id);
  }

  Future<void> updateTrip(Trip trip) async {
    _trips[trip.id] = trip;
  }
}

// Simple trip service for testing
class TripService {
  final TripRepositoryImpl _repository;

  TripService(this._repository);

  Future<void> addTrip(Trip trip) => _repository.addTrip(trip);
  Future<List<Trip>> getTrips() => _repository.getTrips();
  Future<void> updateTrip(Trip trip) => _repository.updateTrip(trip);
  Future<void> deleteTrip(String id) => _repository.deleteTrip(id);

  // Helper to find trip by id
  Future<Trip?> getTrip(String id) async {
    final trips = await getTrips();
    try {
      return trips.firstWhere((trip) => trip.id == id);
    } catch (e) {
      return null;
    }
  }

  void dispose() {}
}

// Helper function to create a trip for testing
Trip createTestTrip({
  String? id,
  required String title,
  String description = '',
  required DateTime startDate,
  required DateTime endDate,
  required String locationName,
  double locationLat = 0.0,
  double locationLng = 0.0,
}) {
  final now = DateTime.now();

  // Create empty HiveLists
  final dayBox = Hive.box<Day>('days');
  final packingItemBox = Hive.box<PackingItem>('packing_items');
  final companionBox = Hive.box<Companion>('companions');

  final days = HiveList<Day>(dayBox);
  final packingList = HiveList<PackingItem>(packingItemBox);
  final companions = HiveList<Companion>(companionBox);

  return Trip(
    id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    locationName: locationName,
    locationLat: locationLat,
    locationLng: locationLng,
    startDate: startDate,
    endDate: endDate,
    createdAt: now,
    lastModified: now,
    days: days,
    packingList: packingList,
    companions: companions,
  );
}

void main() {
  group('Trip Management Tests', () {
    late TripRepositoryImpl tripRepository;
    late TripService tripService;
    late MockStorageService mockStorageService;

    setUpAll(() async {
      await Hive.initFlutter();

      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TripAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(DayAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(PackingItemAdapter());
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(CompanionAdapter());
      }

      // Open boxes
      if (!Hive.isBoxOpen('days')) {
        await Hive.openBox<Day>('days');
      }
      if (!Hive.isBoxOpen('packing_items')) {
        await Hive.openBox<PackingItem>('packing_items');
      }
      if (!Hive.isBoxOpen('companions')) {
        await Hive.openBox<Companion>('companions');
      }

      mockStorageService = MockStorageService();
      tripRepository = TripRepositoryImpl(storageService: mockStorageService);
      tripService = TripService(tripRepository);
    });

    setUp(() async {
      // Clear the mock data before each test
      mockStorageService._trips.clear();
    });

    test('Create and retrieve trip', () async {
      final trip = createTestTrip(
        title: 'Summer Vacation',
        startDate: DateTime(2025, 7, 1),
        endDate: DateTime(2025, 7, 15),
        locationName: 'Hawaii',
      );

      await tripService.addTrip(trip);

      final retrievedTrip = await tripService.getTrip(trip.id);
      expect(retrievedTrip, isNotNull);
      expect(retrievedTrip?.title, 'Summer Vacation');
      expect(retrievedTrip?.locationName, 'Hawaii');
    });

    test('Update trip details', () async {
      final trip = createTestTrip(
        title: 'Winter Trip',
        startDate: DateTime(2025, 12, 1),
        endDate: DateTime(2025, 12, 10),
        locationName: 'Alps',
      );

      await tripService.addTrip(trip);

      final updatedTrip = trip.copyWith(
        title: 'Ski Trip',
      );

      await tripService.updateTrip(updatedTrip);

      final retrievedTrip = await tripService.getTrip(trip.id);
      expect(retrievedTrip?.title, 'Ski Trip');
      expect(retrievedTrip?.locationName, 'Alps');
    });

    test('Calculate trip duration', () async {
      final trip = createTestTrip(
        title: 'Weekend Getaway',
        startDate: DateTime(2025, 9, 1),
        endDate: DateTime(2025, 9, 3),
        locationName: 'Beach',
      );

      final duration = trip.endDate.difference(trip.startDate);
      expect(duration.inDays, 2);
    });

    test('Delete trip', () async {
      final trip = createTestTrip(
        title: 'To be deleted',
        startDate: DateTime(2025, 10, 1),
        endDate: DateTime(2025, 10, 5),
        locationName: 'Mountain',
      );

      await tripService.addTrip(trip);
      await tripService.deleteTrip(trip.id);

      final retrievedTrip = await tripService.getTrip(trip.id);
      expect(retrievedTrip, isNull);
    });

    test('List all trips', () async {
      await tripService.addTrip(createTestTrip(
        title: 'Trip 1',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 5),
        locationName: 'City 1',
      ));

      await tripService.addTrip(createTestTrip(
        title: 'Trip 2',
        startDate: DateTime(2025, 2, 1),
        endDate: DateTime(2025, 2, 5),
        locationName: 'City 2',
      ));

      final trips = await tripService.getTrips();
      expect(trips.length, 2);
    });

    tearDownAll(() async {
      tripService.dispose();
      await Hive.close();
    });
  });
}
