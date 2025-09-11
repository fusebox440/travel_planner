import 'package:dio/dio.dart';
import '../models/booking.dart';

class BookingService {
  static const String _baseUrl = 'https://api.example.com/v1';
  final Dio _dio;

  BookingService()
      : _dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 3),
        ));

  // Flight search parameters
  Future<List<Booking>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    int? adults = 1,
    double? maxPrice,
    String? preferredAirline,
  }) async {
    try {
      final response = await _dio.get(
        '/flights/search',
        queryParameters: {
          'origin': origin,
          'destination': destination,
          'departureDate': departureDate.toIso8601String(),
          if (returnDate != null) 'returnDate': returnDate.toIso8601String(),
          'adults': adults,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (preferredAirline != null) 'airline': preferredAirline,
        },
      );

      return (response.data['results'] as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      // For now, return mock data
      return _getMockFlights();
    }
  }

  Future<List<Booking>> searchHotels({
    required String location,
    required DateTime checkIn,
    required DateTime checkOut,
    int? rooms = 1,
    int? guests = 1,
    double? maxPrice,
    double? minRating,
    List<String>? amenities,
  }) async {
    try {
      final response = await _dio.get(
        '/hotels/search',
        queryParameters: {
          'location': location,
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
          'rooms': rooms,
          'guests': guests,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (minRating != null) 'minRating': minRating,
          if (amenities != null) 'amenities': amenities.join(','),
        },
      );

      return (response.data['results'] as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      // For now, return mock data
      return _getMockHotels();
    }
  }

  Future<List<Booking>> searchCars({
    required String location,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    String? vehicleType,
    double? maxPrice,
    bool? withInsurance,
  }) async {
    try {
      final response = await _dio.get(
        '/cars/search',
        queryParameters: {
          'location': location,
          'pickupDate': pickupDate.toIso8601String(),
          'dropoffDate': dropoffDate.toIso8601String(),
          if (vehicleType != null) 'vehicleType': vehicleType,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (withInsurance != null) 'withInsurance': withInsurance,
        },
      );

      return (response.data['results'] as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      // For now, return mock data
      return _getMockCars();
    }
  }

  Future<List<Booking>> searchActivities({
    required String location,
    required DateTime date,
    int? participants = 1,
    double? maxPrice,
    double? minRating,
    List<String>? categories,
  }) async {
    try {
      final response = await _dio.get(
        '/activities/search',
        queryParameters: {
          'location': location,
          'date': date.toIso8601String(),
          'participants': participants,
          if (maxPrice != null) 'maxPrice': maxPrice,
          if (minRating != null) 'minRating': minRating,
          if (categories != null) 'categories': categories.join(','),
        },
      );

      return (response.data['results'] as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      // For now, return mock data
      return _getMockActivities();
    }
  }

  Future<bool> makeReservation(Booking booking) async {
    try {
      await _dio.post(
        '/bookings/reserve',
        data: booking.toJson(),
      );
      return true;
    } catch (e) {
      // For testing, always return success
      return true;
    }
  }

  Future<bool> cancelReservation(String bookingId) async {
    try {
      await _dio.post('/bookings/$bookingId/cancel');
      return true;
    } catch (e) {
      // For testing, always return success
      return true;
    }
  }

  // Mock Data Generators
  List<Booking> _getMockFlights() {
    return [
      Booking(
        type: BookingType.flight,
        provider: 'Indigo Airlines',
        title: 'Indigo Flight 6E 345',
        details: {
          'origin': 'DEL',
          'destination': 'BOM',
          'duration': '2h 10m',
          'aircraft': 'Airbus A320',
        },
        price: 5999.0,
        currencyCode: 'INR',
        date: DateTime.now().add(const Duration(days: 7)),
        tripId: 'mock-trip-1',
      ),
      // Add more mock flights...
    ];
  }

  List<Booking> _getMockHotels() {
    return [
      Booking(
        type: BookingType.hotel,
        provider: 'Taj Hotels',
        title: 'Taj Palace Delhi',
        details: {
          'rating': 4.8,
          'address': 'Diplomatic Enclave, New Delhi',
          'amenities': ['Pool', 'Spa', 'WiFi'],
        },
        price: 15000.0,
        currencyCode: 'INR',
        date: DateTime.now().add(const Duration(days: 7)),
        tripId: 'mock-trip-1',
      ),
      // Add more mock hotels...
    ];
  }

  List<Booking> _getMockCars() {
    return [
      Booking(
        type: BookingType.car,
        provider: 'Zoomcar',
        title: 'Toyota Innova',
        details: {
          'type': 'SUV',
          'seats': 7,
          'transmission': 'Automatic',
          'fuelType': 'Diesel',
        },
        price: 3000.0,
        currencyCode: 'INR',
        date: DateTime.now().add(const Duration(days: 7)),
        tripId: 'mock-trip-1',
      ),
      // Add more mock cars...
    ];
  }

  List<Booking> _getMockActivities() {
    return [
      Booking(
        type: BookingType.activity,
        provider: 'GetYourGuide',
        title: 'Taj Mahal Sunrise Tour',
        details: {
          'duration': '4 hours',
          'rating': 4.7,
          'included': ['Guide', 'Transport', 'Breakfast'],
        },
        price: 2500.0,
        currencyCode: 'INR',
        date: DateTime.now().add(const Duration(days: 7)),
        tripId: 'mock-trip-1',
      ),
      // Add more mock activities...
    ];
  }
}
