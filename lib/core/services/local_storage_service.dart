import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travel_planner/src/models/activity.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:travel_planner/src/models/packing_item.dart'; // Import the new model
import 'package:travel_planner/src/models/trip.dart';

class LocalStorageService {
  LocalStorageService._privateConstructor();
  static final LocalStorageService _instance = LocalStorageService._privateConstructor();
  factory LocalStorageService() => _instance;

  static const String _tripsBoxName = 'trips';
  static const String _daysBoxName = 'days';
  static const String _activitiesBoxName = 'activities';
  static const String _expensesBoxName = 'expenses';
  static const String _packingItemsBoxName = 'packing_items'; // Add new box name

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(TripAdapter());
      Hive.registerAdapter(DayAdapter());
      Hive.registerAdapter(ActivityAdapter());
      Hive.registerAdapter(ExpenseAdapter());
      Hive.registerAdapter(ExpenseCategoryAdapter());
      Hive.registerAdapter(PackingItemAdapter()); // Register the new adapter

      await Hive.openBox<Trip>(_tripsBoxName);
      await Hive.openBox<Day>(_daysBoxName);
      await Hive.openBox<Activity>(_activitiesBoxName);
      await Hive.openBox<Expense>(_expensesBoxName);
      await Hive.openBox<PackingItem>(_packingItemsBoxName); // Open the new box
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

  Future<void> deleteTrip(String id) async {
    try {
      final box = _getTripsBox();
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting trip $id: $e');
      rethrow;
    }
  }

  Future<File> exportTripsToJson() async {
    final trips = getTrips();
    final jsonString = jsonEncode(trips.map((trip) => trip.toJson()).toList());

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/travel_planner_backup.json');
    await file.writeAsString(jsonString);
    return file;
  }

  Future<void> importTripsFromJson(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final List<dynamic> tripList = jsonDecode(jsonString);

      final tripsBox = _getTripsBox();
      final dayBox = Hive.box<Day>(_daysBoxName);

      for (final tripJson in tripList) {
        if (tripJson is Map<String, dynamic> && tripJson.containsKey('id')) {
          final trip = Trip.fromJson(tripJson, dayBox);
          if (!tripsBox.containsKey(trip.id)) {
            await tripsBox.put(trip.id, trip);
          }
        }
      }
    } catch (e) {
      debugPrint("Error importing from JSON: $e");
      rethrow;
    }
  }
}