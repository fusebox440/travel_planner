import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(savedBookingsProvider);
    final groupedBookings = _groupBookingsByTrip(bookings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: CustomScrollView(
        slivers: [
          if (bookings.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text('No bookings found'),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tripId = groupedBookings.keys.elementAt(index);
                  final tripBookings = groupedBookings[tripId]!;
                  return _buildTripSection(context, tripId, tripBookings);
                },
                childCount: groupedBookings.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripSection(
    BuildContext context,
    String tripId,
    List<Booking> bookings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Trip: $tripId', // TODO: Get actual trip name
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        ...bookings.map((booking) => Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: BookingCard(
                booking: booking,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/bookings/details',
                  arguments: booking,
                ),
              ),
            )),
        const Divider(height: 32),
      ],
    );
  }

  Map<String, List<Booking>> _groupBookingsByTrip(List<Booking> bookings) {
    return bookings.fold<Map<String, List<Booking>>>(
      {},
      (grouped, booking) {
        if (!grouped.containsKey(booking.tripId)) {
          grouped[booking.tripId] = [];
        }
        grouped[booking.tripId]!.add(booking);
        return grouped;
      },
    );
  }
}
