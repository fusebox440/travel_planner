import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/packing_list/data/packing_list_service.dart';
import 'package:travel_planner/src/models/packing_item.dart';
import 'package:travel_planner/src/models/packing_list.dart';
import 'package:travel_planner/src/models/trip.dart'; // Assuming Trip model exists

// Provider for the service
final packingListServiceProvider = Provider((ref) => PackingListService());

// StateNotifier for a single packing list
class PackingListNotifier extends StateNotifier<AsyncValue<PackingList?>> {
  final PackingListService _service;
  final String _tripId;
  final Trip _trip;

  PackingListNotifier(this._service, this._tripId, this._trip) : super(const AsyncValue.loading()) {
    _loadOrCreateList();
  }

  Future<void> _loadOrCreateList() async {
    try {
      var list = await _service.getPackingListForTrip(_tripId);
      if (list == null) {
        // Mock metadata for suggestion generation. In a real app, this would come from the trip.
        list = await _service.createAndSuggestPackingList(
          tripId: _tripId,
          tripType: TripType.Leisure, // Example
          durationInDays: _trip.endDate.difference(_trip.startDate).inDays,
          weather: WeatherCondition.Mild, // Example
        );
      }
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(String name, ItemCategory category) async {
    final list = state.value;
    if (list == null) return;

    final newItem = PackingItem.create(name: name, category: category);
    list.items.add(newItem);
    await _service.updatePackingList(list);
    state = AsyncValue.data(list);
  }

  Future<void> toggleItem(String itemId) async {
    final list = state.value;
    if (list == null) return;

    final item = list.items.firstWhere((it) => it.id == itemId);
    item.isChecked = !item.isChecked;
    await _service.updatePackingList(list);
    state = AsyncValue.data(list);
  }

  Future<void> deleteItem(String itemId) async {
    final list = state.value;
    if (list == null) return;

    list.items.removeWhere((it) => it.id == itemId);
    await _service.updatePackingList(list);
    state = AsyncValue.data(list);
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
final packingListProvider = StateNotifierProvider.family<PackingListNotifier, AsyncValue<PackingList?>, Trip>((ref, trip) {
  final service = ref.watch(packingListServiceProvider);
  return PackingListNotifier(service, trip.id, trip);
});