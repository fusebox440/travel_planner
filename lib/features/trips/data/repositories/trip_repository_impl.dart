import 'package:travel_planner/core/services/local_storage_service.dart';
import 'package:travel_planner/features/trips/domain/repositories/itrip_repository.dart';
import 'package:travel_planner/src/models/trip.dart';

// Concrete implementation of the ITripRepository interface.
// This class uses the LocalStorageService to interact with Hive.
class TripRepositoryImpl implements ITripRepository {
  final LocalStorageService storageService;

  // The repository depends on the storage service (Dependency Injection).
  TripRepositoryImpl({required this.storageService});

  @override
  Future<void> addTrip(Trip trip) async {
    // The repository's job is to delegate the call to the appropriate service.
    await storageService.saveTrip(trip);
  }

  @override
  Future<void> deleteTrip(String id) async {
    await storageService.deleteTrip(id);
  }

  @override
  Future<List<Trip>> getTrips() async {
    // We can wrap the service call to add more logic here in the future,
    // e.g., fetching from a cache or a remote API first.
    return storageService.getTrips();
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    // Since Hive's put() handles both create and update, we call the same method.
    await storageService.saveTrip(trip);
  }
}