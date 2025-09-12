import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/core/services/image_service.dart';
import 'package:travel_planner/core/services/local_storage_service.dart';
import 'package:travel_planner/core/services/notification_service.dart';
import 'package:travel_planner/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:travel_planner/features/trips/domain/repositories/itrip_repository.dart';
import 'package:travel_planner/src/models/activity.dart';
import 'package:travel_planner/src/models/day.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/trip.dart';

// 1. Provider for the LocalStorageService singleton
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// 2. Provider for the TripRepository implementation
final tripRepositoryProvider = Provider<ITripRepository>((ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return TripRepositoryImpl(storageService: storageService);
});

// 3. Provider to manage the list of all trips
final tripListProvider =
    AsyncNotifierProvider<TripListNotifier, List<Trip>>(() {
  return TripListNotifier();
});

class TripListNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() {
    return ref.watch(tripRepositoryProvider).getTrips();
  }

  // --- Trip Methods ---
  Future<void> addTrip(Trip trip) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(tripRepositoryProvider).addTrip(trip);
      ref.invalidateSelf();
      await future;
      return state.value!;
    });
  }

  Future<void> updateTrip(Trip trip) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(tripRepositoryProvider).updateTrip(trip);
      ref.invalidateSelf();
      await future;
      return state.value!;
    });
  }

  Future<void> deleteTrip(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(tripRepositoryProvider).deleteTrip(id);
      ref.invalidateSelf();
      await future;
      return state.value!;
    });
  }

  // --- Day & Activity Methods ---
  Future<void> addDayToTrip(String tripId, Day day) async {
    state = await AsyncValue.guard(() async {
      final trip = state.value?.firstWhere((t) => t.id == tripId);
      if (trip != null) {
        // Save the day to its own Hive box first
        final daysBox = Hive.box<Day>('days');
        await daysBox.put(day.id, day);

        // Then add it to the trip's days list
        trip.days.add(day);
        await trip.save();
      }
      return state.value!;
    });
  }

  Future<void> addActivityToDay(
      String tripId, String dayId, Activity activity) async {
    state = await AsyncValue.guard(() async {
      final trip = state.value?.firstWhere((t) => t.id == tripId);
      final day = trip?.days.firstWhere((d) => d.id == dayId);
      if (day != null) {
        // Save the activity to its own Hive box first
        final activitiesBox = Hive.box<Activity>('activities');
        await activitiesBox.put(activity.id, activity);

        // Then add it to the day's activities list
        day.activities.add(activity);
        await day.save();
      }
      return state.value!;
    });
  }

  Future<void> deleteActivity(
      String tripId, String dayId, String activityId) async {
    state = await AsyncValue.guard(() async {
      final trip = state.value?.firstWhere((t) => t.id == tripId);
      final day = trip?.days.firstWhere((d) => d.id == dayId);
      if (day != null) {
        final activityToDelete =
            day.activities.firstWhere((a) => a.id == activityId);
        await ImageService().deleteMultipleImages(activityToDelete.imagePaths);

        // Remove from day's activities list
        day.activities.removeWhere((a) => a.id == activityId);
        await day.save();

        // Also delete from the activities Hive box
        final activitiesBox = Hive.box<Activity>('activities');
        await activitiesBox.delete(activityId);
      }
      return state.value!;
    });
  }

  Future<void> toggleActivityReminder(
      String tripId, String dayId, String activityId, bool setReminder) async {
    state = await AsyncValue.guard(() async {
      final trip = state.value?.firstWhere((t) => t.id == tripId);
      final day = trip?.days.firstWhere((d) => d.id == dayId);
      final activity = day?.activities.firstWhere((a) => a.id == activityId);

      if (activity != null) {
        if (setReminder) {
          final reminderId = DateTime.now().millisecondsSinceEpoch % 2147483647;
          final reminderTime =
              activity.startTime.subtract(const Duration(minutes: 15));
          await NotificationService().scheduleReminder(
            id: reminderId,
            title: trip!.title,
            body:
                'Upcoming: ${activity.title} at ${DateFormat.jm().format(activity.startTime)}',
            scheduledTime: reminderTime,
          );
          activity.reminderId = reminderId;
        } else {
          if (activity.reminderId != null) {
            await NotificationService().cancelReminder(activity.reminderId!);
          }
          activity.reminderId = null;
        }
        await activity.save();
      }
      return state.value!;
    });
  }

  // --- Packing List Methods ---
  Future<void> addPackingItem(String tripId, PackingItem item) async {
    state = await AsyncValue.guard(() async {
      final trip = state.value?.firstWhere((t) => t.id == tripId);
      if (trip != null) {
        final box = Hive.box<PackingItem>('packing_items');
        await box.put(item.id, item); // Save item to its own box first
        trip.packingList.add(item);
        await trip.save();
      }
      return state.value!;
    });
  }

  Future<void> updatePackingItem(String tripId, PackingItem item) async {
    state = await AsyncValue.guard(() async {
      if (item.isInBox) {
        await item.save(); // Item is already in a box, just save changes
      }
      return state.value!;
    });
  }

  Future<void> deletePackingItem(String tripId, String itemId) async {
    state = await AsyncValue.guard(() async {
      final trip = state.value?.firstWhere((t) => t.id == tripId);
      if (trip != null) {
        trip.packingList.removeWhere((i) => i.id == itemId);
        await trip.save();

        final box = Hive.box<PackingItem>('packing_items');
        await box.delete(itemId); // Delete item from its own box
      }
      return state.value!;
    });
  }

  Future<void> addPackingListFromTemplate(
      String tripId, List<PackingItem> items) async {
    state = await AsyncValue.guard(() async {
      final trip = state.value?.firstWhere((t) => t.id == tripId);
      if (trip != null) {
        final box = Hive.box<PackingItem>('packing_items');
        // Save all new items to their own box first
        for (final item in items) {
          await box.put(item.id, item);
        }
        trip.packingList.addAll(items);
        await trip.save();
      }
      return state.value!;
    });
  }
}

// 4. Provider to get a single trip by its ID
final tripDetailProvider =
    FutureProvider.family<Trip?, String>((ref, tripId) async {
  final trips = await ref.watch(tripListProvider.future);
  try {
    return trips.firstWhere((trip) => trip.id == tripId);
  } catch (e) {
    return null;
  }
});
