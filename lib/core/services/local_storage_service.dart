import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_planner/core/services/image_service.dart';
import 'package:travel_planner/src/models/activity.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/trip.dart';

class LocalStorageService {
  LocalStorageService._privateConstructor();
  static final LocalStorageService _instance =
      LocalStorageService._privateConstructor();
  factory LocalStorageService() => _instance;

  static const String _tripsBoxName = 'trips';
  static const String _daysBoxName = 'days';
  static const String _activitiesBoxName = 'activities';
  static const String _expensesBoxName = 'expenses';
  static const String _packingItemsBoxName = 'packing_items';

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      // Adapter registrations moved to main.dart to avoid duplicates

      await Hive.openBox<Trip>(_tripsBoxName);
      await Hive.openBox<Day>(_daysBoxName);
      await Hive.openBox<Activity>(_activitiesBoxName);
      await Hive.openBox<Expense>(_expensesBoxName);
      await Hive.openBox<PackingItem>(_packingItemsBoxName);
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  Box<Trip> _getTripsBox() => Hive.box<Trip>(_tripsBoxName);

  List<Trip> getTrips() {
    try {
      final box = _getTripsBox();
      final trips = box.values.toList();
      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    } catch (e) {
      debugPrint('Error getting trips: $e');
      return [];
    }
  }

  Future<void> saveTrip(Trip trip) async {
    try {
      final box = _getTripsBox();
      await box.put(trip.id, trip);
    } catch (e) {
      debugPrint('Error saving trip ${trip.id}: $e');
      rethrow;
    }
  }

  /// Deletes a trip and all its associated data.
  Future<void> deleteTrip(String id) async {
    try {
      final tripsBox = _getTripsBox();
      final tripToDelete = tripsBox.get(id);

      if (tripToDelete != null) {
        // 1. Delete all associated images from device storage
        for (final day in tripToDelete.days) {
          for (final activity in day.activities) {
            await ImageService().deleteMultipleImages(activity.imagePaths);
          }
        }

        // 2. Delete all associated PackingItems
        final packingItemsBox = Hive.box<PackingItem>(_packingItemsBoxName);
        final packingItemKeys =
            tripToDelete.packingList.map((item) => item.id).toList();
        await packingItemsBox.deleteAll(packingItemKeys);

        // 3. Delete all associated Days and their Activities
        final daysBox = Hive.box<Day>(_daysBoxName);
        final dayKeys = tripToDelete.days.map((day) => day.id).toList();
        await daysBox.deleteAll(dayKeys);

        // 4. Finally, delete the trip itself
        await tripsBox.delete(id);
        debugPrint('Successfully deleted trip $id and all associated data.');
      }
    } catch (e) {
      debugPrint('Error deleting trip $id: $e');
      rethrow;
    }
  }
}
