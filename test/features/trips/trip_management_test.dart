import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('Trip Management Tests', () {
    late Box<Trip> tripBox;
    late TripRepositoryImpl tripRepository;

    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(TripAdapter());
      tripBox = await Hive.openBox<Trip>('test_trips');
      tripRepository = TripRepositoryImpl();
    });

    setUp(() async {
      await tripBox.clear();
    });

    test('Create and retrieve trip', () async {
      final trip = Trip.create(
        title: 'Summer Vacation',
        description: 'A lovely summer trip',
        startDate: DateTime(2025, 7, 1),
        endDate: DateTime(2025, 7, 15),
        destination: 'Hawaii',
      );

      await tripService.addTrip(trip);

      final retrievedTrip = await tripService.getTrip(trip.id);
      expect(retrievedTrip, isNotNull);
      expect(retrievedTrip?.title, 'Summer Vacation');
      expect(retrievedTrip?.destination, 'Hawaii');
    });

    test('Update trip details', () async {
      final trip = Trip.create(
        title: 'Winter Trip',
        description: 'Winter vacation',
        startDate: DateTime(2025, 12, 1),
        endDate: DateTime(2025, 12, 10),
        destination: 'Alps',
      );

      await tripService.addTrip(trip);

      final updatedTrip = trip.copyWith(
        title: 'Ski Trip',
        description: 'Skiing in the Alps',
      );

      await tripService.updateTrip(updatedTrip);

      final retrievedTrip = await tripService.getTrip(trip.id);
      expect(retrievedTrip?.title, 'Ski Trip');
      expect(retrievedTrip?.description, 'Skiing in the Alps');
    });

    test('Calculate trip duration', () async {
      final trip = Trip.create(
        title: 'Weekend Getaway',
        description: 'Quick weekend trip',
        startDate: DateTime(2025, 9, 1),
        endDate: DateTime(2025, 9, 3),
        destination: 'Beach',
      );

      final duration = trip.duration;
      expect(duration.inDays, 2);
    });

    test('Delete trip', () async {
      final trip = Trip.create(
        title: 'To be deleted',
        description: 'This trip will be deleted',
        startDate: DateTime(2025, 10, 1),
        endDate: DateTime(2025, 10, 5),
        destination: 'Mountain',
      );

      await tripService.addTrip(trip);
      await tripService.deleteTrip(trip.id);

      final retrievedTrip = await tripService.getTrip(trip.id);
      expect(retrievedTrip, isNull);
    });

    test('List all trips', () async {
      await tripService.addTrip(Trip.create(
        title: 'Trip 1',
        description: 'First trip',
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 5),
        destination: 'City 1',
      ));

      await tripService.addTrip(Trip.create(
        title: 'Trip 2',
        description: 'Second trip',
        startDate: DateTime(2025, 2, 1),
        endDate: DateTime(2025, 2, 5),
        destination: 'City 2',
      ));

      final trips = await tripService.getAllTrips();
      expect(trips.length, 2);
    });

    tearDownAll(() async {
      await tripBox.deleteFromDisk();
      tripService.dispose();
    });
  });
}
