import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:travel_planner/features/packing_list/data/packing_list_service.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';
import 'package:travel_planner/src/models/trip.dart';

// Provider for the service - ensures initialization
final packingListServiceProvider = Provider<PackingListService>((ref) {
  final service = PackingListService();
  // Initialize immediately when provider is created
  service.init();
  return service;
});

// StateNotifier for a single packing list
class PackingListNotifier extends StateNotifier<AsyncValue<PackingList?>> {
  final PackingListService _service;
  final String _tripId;
  final Trip _trip;

  PackingListNotifier(this._service, this._tripId, this._trip)
      : super(const AsyncValue.loading()) {
    _loadOrCreateList();
  }

  Future<void> _loadOrCreateList() async {
    try {
      // Ensure service is initialized first
      await _service.init();

      var list = await _service.getPackingListForTrip(_tripId);
      if (list == null) {
        // Create packing list with trip metadata
        list = await _service.createAndSuggestPackingList(
          tripId: _tripId,
          tripType: TripType.leisure, // Fixed enum case
          durationInDays: _trip.endDate.difference(_trip.startDate).inDays,
          weather: WeatherCondition.mild, // Fixed enum reference and case
        );
      }
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(String title, String category) async {
    final list = state.value;
    if (list == null) return;

    final newItem = PackingItem.create(
      title: title,
      category: category,
      quantity: 1, // Required parameter
    );

    // Save the new item to storage
    await newItem.save();

    // Update the packing list to include the new item ID
    final updatedList = list.copyWith(
      itemIds: [...list.itemIds, newItem.id],
    );
    await _service.updatePackingList(updatedList);
    state = AsyncValue.data(updatedList);
  }

  Future<void> toggleItem(String itemId) async {
    final list = state.value;
    if (list == null) return;

    // Get the item from Hive and toggle its isPacked status
    final box = Hive.box<PackingItem>('packing_items');
    final item = box.get(itemId);
    if (item != null) {
      final updatedItem = item.copyWith(isPacked: !item.isPacked);
      await updatedItem.save();

      // Create a new list object to trigger state refresh
      final updatedList = list.copyWith(itemIds: list.itemIds);
      await _service.updatePackingList(updatedList);
      state = AsyncValue.data(updatedList);
    }
  }

  Future<void> deleteItem(String itemId) async {
    final list = state.value;
    if (list == null) return;

    // Remove item from storage
    final box = Hive.box<PackingItem>('packing_items');
    await box.delete(itemId);

    // Update the packing list to remove the item ID
    final updatedItemIds = list.itemIds.where((id) => id != itemId).toList();
    final updatedList = list.copyWith(itemIds: updatedItemIds);
    await _service.updatePackingList(updatedList);
    state = AsyncValue.data(updatedList);
  }

  Future<void> resetList() async {
    final list = state.value;
    if (list == null) return;

    await _service.deletePackingList(list.id);
    state = const AsyncValue.loading();
    await _loadOrCreateList();
  }
}

// The final provider that the UI will use
final packingListProvider = StateNotifierProvider.family<PackingListNotifier,
    AsyncValue<PackingList?>, Trip>((ref, trip) {
  final service = ref.watch(packingListServiceProvider);
  return PackingListNotifier(service, trip.id, trip);
});
