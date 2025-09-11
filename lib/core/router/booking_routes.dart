import 'package:go_router/go_router.dart';
import '../../features/booking/models/booking.dart';
import '../../features/booking/screens/booking_search_screen.dart';
import '../../features/booking/screens/booking_details_screen.dart';
import '../../features/booking/screens/my_bookings_screen.dart';

// ... (existing routes)

final bookingRoutes = [
  GoRoute(
    path: '/bookings/search',
    builder: (context, state) => const BookingSearchScreen(),
  ),
  GoRoute(
    path: '/bookings/details',
    builder: (context, state) => BookingDetailsScreen(
      booking: state.extra as Booking,
    ),
  ),
  GoRoute(
    path: '/bookings/my',
    builder: (context, state) => const MyBookingsScreen(),
  ),
];
