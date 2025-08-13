import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/trip.dart';

class BackupService {
  BackupService._privateConstructor();
  static final BackupService _instance = BackupService._privateConstructor();
  factory BackupService() => _instance;

  /// Exports all trips to a timestamped JSON file.
  Future<File> exportTripsToJson() async {
    final tripsBox = Hive.box<Trip>('trips');
    final trips = tripsBox.values.toList();
    final jsonString = jsonEncode(trips.map((trip) => trip.toJson()).toList());

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final file = File('${directory.path}/travel_planner_backup_$timestamp.json');

    await file.writeAsString(jsonString);
    debugPrint('Backup saved to: ${file.path}');
    return file;
  }

  /// Imports trips from a JSON file, skipping duplicates.
  /// Returns the number of trips successfully imported.
  Future<int> importTripsFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }
      final jsonString = await file.readAsString();
      final List<dynamic> tripList = jsonDecode(jsonString);

      final tripsBox = Hive.box<Trip>('trips');
      final dayBox = Hive.box<Day>('days');
      int importedCount = 0;

      for (final tripJson in tripList) {
        // Basic schema validation
        if (tripJson is Map<String, dynamic> && tripJson.containsKey('id')) {
          final trip = Trip.fromJson(tripJson, dayBox);
          // Conflict resolution: if a trip with the same ID exists, skip it.
          if (!tripsBox.containsKey(trip.id)) {
            await tripsBox.put(trip.id, trip);
            importedCount++;
          }
        }
      }
      debugPrint('Successfully imported $importedCount trips.');
      return importedCount;
    } catch (e) {
      debugPrint("Error importing from JSON: $e");
      rethrow;
    }
  }
}