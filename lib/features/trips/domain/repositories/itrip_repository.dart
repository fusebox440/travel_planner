import 'package:travel_planner/src/models/trip.dart';

// Abstract class defining the contract for trip-related data operations.
// The rest of the app will depend on this interface, not the concrete implementation.
abstract class ITripRepository {

  // Retrieves all trips from the data source.
  Future<List<Trip>> getTrips();

  // Adds a new trip to the data source.
  Future<void> addTrip(Trip trip);

  // Updates an existing trip.
  Future<void> updateTrip(Trip trip);

  // Deletes a trip by its unique ID.
  Future<void> deleteTrip(String id);
}
