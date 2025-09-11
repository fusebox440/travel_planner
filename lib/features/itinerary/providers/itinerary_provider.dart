import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/itinerary.dart';
import '../services/itinerary_service.dart';
import '../../booking/models/booking.dart';
import '../../booking/providers/booking_provider.dart';

// Service provider
final itineraryServiceProvider = Provider((ref) => ItineraryService());

// State for the itinerary
class ItineraryState {
  final Itinerary? itinerary;
  final bool isLoading;
  final String? error;
  final String? selectedDayId;
  final String? selectedItemId;
  final bool isDragging;

  ItineraryState({
    this.itinerary,
    this.isLoading = false,
    this.error,
    this.selectedDayId,
    this.selectedItemId,
    this.isDragging = false,
  });

  ItineraryState copyWith({
    Itinerary? itinerary,
    bool? isLoading,
    String? error,
    String? selectedDayId,
    String? selectedItemId,
    bool? isDragging,
  }) {
    return ItineraryState(
      itinerary: itinerary ?? this.itinerary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDayId: selectedDayId ?? this.selectedDayId,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}

class ItineraryNotifier extends StateNotifier<ItineraryState> {
  final ItineraryService _service;
  final Box<Itinerary> _itinerariesBox;
  final String tripId;

  ItineraryNotifier(this._service, this._itinerariesBox, this.tripId)
      : super(ItineraryState()) {
    _loadItinerary();
  }

  Future<void> _loadItinerary() async {
    state = state.copyWith(isLoading: true);
    try {
      final itinerary =
          _itinerariesBox.values.firstWhere((i) => i.tripId == tripId);
      state = state.copyWith(
        itinerary: itinerary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load itinerary',
        isLoading: false,
      );
    }
  }

  Future<void> createItinerary(DateTime startDate, int days) async {
    state = state.copyWith(isLoading: true);
    try {
      final itinerary = await _service.createItinerary(
        tripId,
        startDate,
        days,
      );
      await _itinerariesBox.put(itinerary.id, itinerary);
      state = state.copyWith(
        itinerary: itinerary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to create itinerary',
        isLoading: false,
      );
    }
  }

  Future<void> importBookings(List<Booking> bookings) async {
    if (state.itinerary == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _service.importBookings(state.itinerary!, bookings);
      await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to import bookings',
        isLoading: false,
      );
    }
  }

  Future<void> importFromEmail(String emailContent) async {
    if (state.itinerary == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _service.importFromEmail(state.itinerary!, emailContent);
      await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to import from email',
        isLoading: false,
      );
    }
  }

  Future<void> addDay(DateTime date) async {
    if (state.itinerary == null) return;

    final day = ItineraryDay(date: date);
    state.itinerary!.addDay(day);
    await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
    state = state.copyWith(itinerary: state.itinerary);
  }

  Future<void> removeDay(String dayId) async {
    if (state.itinerary == null) return;

    state.itinerary!.removeDay(dayId);
    await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
    state = state.copyWith(itinerary: state.itinerary);
  }

  Future<void> addItem(String dayId, ItineraryItem item) async {
    if (state.itinerary == null) return;

    final day = state.itinerary!.days.firstWhere((d) => d.id == dayId);
    day.addItem(item);
    await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
    state = state.copyWith(itinerary: state.itinerary);
  }

  Future<void> updateItem(
    String dayId,
    ItineraryItem updatedItem,
  ) async {
    if (state.itinerary == null) return;

    final day = state.itinerary!.days.firstWhere((d) => d.id == dayId);
    day.updateItem(updatedItem);
    await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
    state = state.copyWith(itinerary: state.itinerary);
  }

  Future<void> removeItem(String dayId, String itemId) async {
    if (state.itinerary == null) return;

    final day = state.itinerary!.days.firstWhere((d) => d.id == dayId);
    day.removeItem(itemId);
    await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
    state = state.copyWith(itinerary: state.itinerary);
  }

  Future<void> reorderItems(
    String sourceDayId,
    String targetDayId,
    int oldIndex,
    int newIndex,
  ) async {
    if (state.itinerary == null) return;

    await _service.reorderItems(
      state.itinerary!,
      sourceDayId,
      targetDayId,
      oldIndex,
      newIndex,
    );
    await _itinerariesBox.put(state.itinerary!.id, state.itinerary!);
    state = state.copyWith(itinerary: state.itinerary);
  }

  void setSelectedDay(String? dayId) {
    state = state.copyWith(selectedDayId: dayId);
  }

  void setSelectedItem(String? itemId) {
    state = state.copyWith(selectedItemId: itemId);
  }

  void setDragging(bool isDragging) {
    state = state.copyWith(isDragging: isDragging);
  }
}

// Providers
final itineraryProvider =
    StateNotifierProvider.family<ItineraryNotifier, ItineraryState, String>(
        (ref, tripId) {
  final service = ref.watch(itineraryServiceProvider);
  final itinerariesBox = Hive.box<Itinerary>('itineraries');
  return ItineraryNotifier(service, itinerariesBox, tripId);
});
