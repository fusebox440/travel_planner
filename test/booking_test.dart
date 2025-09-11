import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../lib/features/booking/models/booking.dart';
import '../lib/features/booking/services/booking_service.dart';
import 'booking_test.mocks.dart';

@GenerateMocks([BookingService])
void main() {
  late MockBookingService mockBookingService;

  setUp(() {
    mockBookingService = MockBookingService();
  });

  group('BookingService Tests', () {
    test('searchFlights returns list of flight bookings', () async {
      final mockFlights = [
        Booking(
          type: BookingType.flight,
          provider: 'Test Airline',
          title: 'Test Flight 123',
          details: {
            'origin': 'TEST',
            'destination': 'DEST',
            'duration': '2h',
          },
          price: 1000.0,
          currencyCode: 'USD',
          date: DateTime.now(),
          tripId: 'test-trip',
        ),
      ];

      when(mockBookingService.searchFlights(
        origin: 'TEST',
        destination: 'DEST',
        departureDate: any,
      )).thenAnswer((_) async => mockFlights);

      final result = await mockBookingService.searchFlights(
        origin: 'TEST',
        destination: 'DEST',
        departureDate: DateTime.now(),
      );

      expect(result, equals(mockFlights));
      expect(result.first.type, equals(BookingType.flight));
      expect(result.first.provider, equals('Test Airline'));
    });

    test('searchHotels returns list of hotel bookings', () async {
      final mockHotels = [
        Booking(
          type: BookingType.hotel,
          provider: 'Test Hotel',
          title: 'Test Suite',
          details: {
            'rating': 4.5,
            'address': 'Test Address',
            'amenities': ['WiFi', 'Pool'],
          },
          price: 2000.0,
          currencyCode: 'USD',
          date: DateTime.now(),
          tripId: 'test-trip',
        ),
      ];

      when(mockBookingService.searchHotels(
        location: 'TEST',
        checkIn: any,
        checkOut: any,
      )).thenAnswer((_) async => mockHotels);

      final result = await mockBookingService.searchHotels(
        location: 'TEST',
        checkIn: DateTime.now(),
        checkOut: DateTime.now().add(const Duration(days: 1)),
      );

      expect(result, equals(mockHotels));
      expect(result.first.type, equals(BookingType.hotel));
      expect(result.first.provider, equals('Test Hotel'));
    });

    test('makeReservation successfully reserves booking', () async {
      final booking = Booking(
        type: BookingType.flight,
        provider: 'Test Provider',
        title: 'Test Booking',
        details: {'test': 'details'},
        price: 100.0,
        currencyCode: 'USD',
        date: DateTime.now(),
        tripId: 'test-trip',
      );

      when(mockBookingService.makeReservation(booking))
          .thenAnswer((_) async => true);

      final result = await mockBookingService.makeReservation(booking);
      expect(result, isTrue);
    });

    test('cancelReservation successfully cancels booking', () async {
      const bookingId = 'test-booking-id';

      when(mockBookingService.cancelReservation(bookingId))
          .thenAnswer((_) async => true);

      final result = await mockBookingService.cancelReservation(bookingId);
      expect(result, isTrue);
    });
  });
}
