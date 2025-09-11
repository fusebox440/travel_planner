import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

// Service provider
final bookingServiceProvider = Provider((ref) => BookingService());

// State notifiers
class BookingSearchState {
  final List<Booking> searchResults;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> activeFilters;

  BookingSearchState({
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
    this.activeFilters = const {},
  });

  BookingSearchState copyWith({
    List<Booking>? searchResults,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? activeFilters,
  }) {
    return BookingSearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      activeFilters: activeFilters ?? this.activeFilters,
    );
  }
}

class BookingSearchNotifier extends StateNotifier<BookingSearchState> {
  final BookingService _bookingService;

  BookingSearchNotifier(this._bookingService) : super(BookingSearchState());

  Future<void> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    int? adults,
    double? maxPrice,
    String? preferredAirline,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _bookingService.searchFlights(
        origin: origin,
        destination: destination,
        departureDate: departureDate,
        returnDate: returnDate,
        adults: adults,
        maxPrice: maxPrice,
        preferredAirline: preferredAirline,
      );
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
        activeFilters: {
          'origin': origin,
          'destination': destination,
          'departureDate': departureDate,
          'returnDate': returnDate,
          'adults': adults,
          'maxPrice': maxPrice,
          'preferredAirline': preferredAirline,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchHotels({
    required String location,
    required DateTime checkIn,
    required DateTime checkOut,
    int? rooms,
    int? guests,
    double? maxPrice,
    double? minRating,
    List<String>? amenities,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _bookingService.searchHotels(
        location: location,
        checkIn: checkIn,
        checkOut: checkOut,
        rooms: rooms,
        guests: guests,
        maxPrice: maxPrice,
        minRating: minRating,
        amenities: amenities,
      );
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
        activeFilters: {
          'location': location,
          'checkIn': checkIn,
          'checkOut': checkOut,
          'rooms': rooms,
          'guests': guests,
          'maxPrice': maxPrice,
          'minRating': minRating,
          'amenities': amenities,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchCars({
    required String location,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    String? vehicleType,
    double? maxPrice,
    bool? withInsurance,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _bookingService.searchCars(
        location: location,
        pickupDate: pickupDate,
        dropoffDate: dropoffDate,
        vehicleType: vehicleType,
        maxPrice: maxPrice,
        withInsurance: withInsurance,
      );
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
        activeFilters: {
          'location': location,
          'pickupDate': pickupDate,
          'dropoffDate': dropoffDate,
          'vehicleType': vehicleType,
          'maxPrice': maxPrice,
          'withInsurance': withInsurance,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> searchActivities({
    required String location,
    required DateTime date,
    int? participants,
    double? maxPrice,
    double? minRating,
    List<String>? categories,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await _bookingService.searchActivities(
        location: location,
        date: date,
        participants: participants,
        maxPrice: maxPrice,
        minRating: minRating,
        categories: categories,
      );
      state = state.copyWith(
        searchResults: results,
        isLoading: false,
        activeFilters: {
          'location': location,
          'date': date,
          'participants': participants,
          'maxPrice': maxPrice,
          'minRating': minRating,
          'categories': categories,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    state = state.copyWith(
      activeFilters: {...state.activeFilters, ...newFilters},
    );
  }

  void clearFilters() {
    state = state.copyWith(activeFilters: {});
  }
}

// Saved bookings state management
class SavedBookingsNotifier extends StateNotifier<List<Booking>> {
  final BookingService _bookingService;
  final Box<Booking> _bookingsBox;

  SavedBookingsNotifier(this._bookingService, this._bookingsBox)
      : super(_bookingsBox.values.toList());

  Future<void> addBooking(Booking booking) async {
    try {
      final success = await _bookingService.makeReservation(booking);
      if (success) {
        await _bookingsBox.put(booking.id, booking);
        state = [...state, booking];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      final success = await _bookingService.cancelReservation(bookingId);
      if (success) {
        final booking = state.firstWhere((b) => b.id == bookingId);
        final updatedBooking =
            booking.copyWith(status: BookingStatus.cancelled);
        await _bookingsBox.put(bookingId, updatedBooking);
        state =
            state.map((b) => b.id == bookingId ? updatedBooking : b).toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  List<Booking> getBookingsForTrip(String tripId) {
    return state.where((booking) => booking.tripId == tripId).toList();
  }
}

// Providers
final bookingSearchProvider =
    StateNotifierProvider<BookingSearchNotifier, BookingSearchState>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  return BookingSearchNotifier(bookingService);
});

final savedBookingsProvider =
    StateNotifierProvider<SavedBookingsNotifier, List<Booking>>((ref) {
  final bookingService = ref.watch(bookingServiceProvider);
  final bookingsBox = Hive.box<Booking>('bookings');
  return SavedBookingsNotifier(bookingService, bookingsBox);
});
