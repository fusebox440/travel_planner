import 'package:flutter/material.dart';
import '../models/itinerary.dart';
import '../../booking/models/booking.dart';
import 'email_parser.dart';

class ItineraryService {
  // Singleton instance
  static final ItineraryService _instance = ItineraryService._internal();
  factory ItineraryService() => _instance;
  ItineraryService._internal();

  Future<Itinerary> createItinerary(
      String tripId, DateTime startDate, int days) async {
    final itinerary = Itinerary(tripId: tripId);

    for (var i = 0; i < days; i++) {
      final day = ItineraryDay(
        date: startDate.add(Duration(days: i)),
      );
      itinerary.addDay(day);
    }

    return itinerary;
  }

  Future<void> importBookings(
      Itinerary itinerary, List<Booking> bookings) async {
    for (final booking in bookings) {
      // Find the day that matches the booking date
      final day = itinerary.days.firstWhere(
        (day) => _isSameDay(day.date, booking.date),
        orElse: () {
          final newDay = ItineraryDay(date: booking.date);
          itinerary.addDay(newDay);
          return newDay;
        },
      );

      // Convert booking to itinerary item
      final item = _convertBookingToItineraryItem(booking);
      day.addItem(item);
    }

    // Sort days by date
    itinerary.days.sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> importFromEmail(Itinerary itinerary, String emailContent) async {
    final parser = EmailParser();
    final items = await parser.parseEmailContent(emailContent);

    for (final item in items) {
      // Find or create the day - items should have a date property,
      // if not we need to get it from their context
      final itemDate = _getItemDate(item);
      if (itemDate == null) continue;

      final day = itinerary.days.firstWhere(
        (day) => _isSameDay(day.date, itemDate),
        orElse: () {
          final newDay = ItineraryDay(date: itemDate);
          itinerary.addDay(newDay);
          return newDay;
        },
      );

      // Add the item to the day
      day.addItem(item);
    }

    // Sort days by date
    itinerary.days.sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> reorderItems(
    Itinerary itinerary,
    String sourceDayId,
    String targetDayId,
    int oldIndex,
    int newIndex,
  ) async {
    final sourceDay = itinerary.days.firstWhere((day) => day.id == sourceDayId);

    if (sourceDayId == targetDayId) {
      // Reorder within the same day
      sourceDay.reorderItems(oldIndex, newIndex);
    } else {
      // Move item to different day
      final targetDay =
          itinerary.days.firstWhere((day) => day.id == targetDayId);
      final item = sourceDay.items.removeAt(oldIndex);
      targetDay.items.insert(newIndex, item);
    }

    itinerary.lastModified = DateTime.now();
  }

  ItineraryItem _convertBookingToItineraryItem(Booking booking) {
    final itemType = _getItemTypeFromBooking(booking.type);
    TimeOfDay startTime;
    TimeOfDay? endTime;

    // Extract times from booking details
    switch (booking.type) {
      case BookingType.flight:
        startTime = _parseTime(booking.details['departureTime'] ?? '09:00');
        endTime = _parseTime(booking.details['arrivalTime']);
        break;
      case BookingType.hotel:
        startTime = const TimeOfDay(hour: 15, minute: 0); // Default check-in
        endTime = const TimeOfDay(hour: 11, minute: 0); // Default check-out
        break;
      case BookingType.activity:
        startTime = _parseTime(booking.details['startTime'] ?? '09:00');
        endTime = _parseTime(booking.details['endTime']);
        break;
      default:
        startTime = const TimeOfDay(hour: 9, minute: 0);
    }

    return ItineraryItem(
      title: booking.title,
      type: itemType,
      startTime: startTime,
      endTime: endTime,
      location: booking.details['location'] ?? booking.details['address'],
      bookingId: booking.id,
      details: booking.details,
    );
  }

  ItineraryItemType _getItemTypeFromBooking(BookingType bookingType) {
    switch (bookingType) {
      case BookingType.flight:
        return ItineraryItemType.flight;
      case BookingType.hotel:
        return ItineraryItemType.accommodation;
      case BookingType.car:
        return ItineraryItemType.transportation;
      case BookingType.activity:
        return ItineraryItemType.activity;
    }
  }

  TimeOfDay _parseTime(String? timeString) {
    if (timeString == null) return const TimeOfDay(hour: 9, minute: 0);

    final parts = timeString.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 9, minute: 0);

    try {
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Helper method to get date for an item from email parser
  // Since ItineraryItem doesn't have date, we need to get it from context
  DateTime? _getItemDate(ItineraryItem item) {
    // If we have booking details with date, use that
    if (item.details?['date'] != null) {
      try {
        return DateTime.parse(item.details!['date']);
      } catch (e) {
        // Ignore parsing error
      }
    }

    // Default to today if no date found
    return DateTime.now();
  }
}
