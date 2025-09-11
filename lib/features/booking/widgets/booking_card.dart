import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(booking.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                booking.provider,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(booking.date),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    '${booking.price} ${booking.currencyCode}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTypeSpecificInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSpecificInfo() {
    switch (booking.type) {
      case BookingType.flight:
        return Row(
          children: [
            const Icon(Icons.flight_takeoff, size: 16),
            const SizedBox(width: 8),
            Text(
              '${booking.details['origin']} → ${booking.details['destination']}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
      case BookingType.hotel:
        return Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                booking.details['address'] as String,
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case BookingType.car:
        return Row(
          children: [
            const Icon(Icons.directions_car, size: 16),
            const SizedBox(width: 8),
            Text(
              '${booking.details['type']} - ${booking.details['seats']} seats',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
      case BookingType.activity:
        return Row(
          children: [
            const Icon(Icons.schedule, size: 16),
            const SizedBox(width: 8),
            Text(
              booking.details['duration'] as String,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        );
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.reserved:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
