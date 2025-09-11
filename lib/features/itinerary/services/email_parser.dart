import 'package:flutter/material.dart';
import '../models/itinerary.dart';

class EmailParser {
  static final RegExp _datePattern = RegExp(
    r'\b(\d{1,2}(?:st|nd|rd|th)?\s+(?:Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s+\d{4})\b',
    caseSensitive: false,
  );

  static final RegExp _timePattern = RegExp(
    r'\b(\d{1,2}:\d{2}(?:\s*[AaPp][Mm])?)\b',
  );

  static final List<RegExp> _flightPatterns = [
    RegExp(r'Flight\s+(?:number\s+)?([A-Z0-9]{2,}\s*\d+)'),
    RegExp(r'([A-Z0-9]{2})\s*(\d{3,4})'),
  ];

  static final List<RegExp> _hotelPatterns = [
    RegExp(r'Hotel:\s*(.*?)(?:\n|$)'),
    RegExp(r'Check-in:\s*(.*?)(?:\n|$)'),
    RegExp(r'Check-out:\s*(.*?)(?:\n|$)'),
  ];

  Future<List<ItineraryItem>> parseEmailContent(String content) async {
    final items = <ItineraryItem>[];
    final lines = content.split('\n');

    DateTime? currentDate;
    Map<String, dynamic> currentItem = {};

    for (final line in lines) {
      // Try to find a date
      final dateMatch = _datePattern.firstMatch(line);
      if (dateMatch != null) {
        if (currentItem.isNotEmpty) {
          items.add(_createItineraryItem(currentItem, currentDate!));
          currentItem = {};
        }
        currentDate = _parseDate(dateMatch.group(1)!);
        continue;
      }

      // If we have a date, look for items
      if (currentDate != null) {
        // Check for flight information
        for (final pattern in _flightPatterns) {
          final match = pattern.firstMatch(line);
          if (match != null) {
            if (currentItem.isNotEmpty) {
              items.add(_createItineraryItem(currentItem, currentDate));
              currentItem = {};
            }
            currentItem['type'] = ItineraryItemType.flight;
            currentItem['flightNumber'] = match.group(1);

            // Look for times in the same line
            final times = _timePattern.allMatches(line).toList();
            if (times.length >= 2) {
              currentItem['departureTime'] = times[0].group(1);
              currentItem['arrivalTime'] = times[1].group(1);
            }
            continue;
          }
        }

        // Check for hotel information
        for (final pattern in _hotelPatterns) {
          final match = pattern.firstMatch(line);
          if (match != null) {
            if (currentItem['type'] != ItineraryItemType.accommodation) {
              if (currentItem.isNotEmpty) {
                items.add(_createItineraryItem(currentItem, currentDate));
                currentItem = {};
              }
              currentItem['type'] = ItineraryItemType.accommodation;
            }
            final key = pattern.pattern.contains('Hotel:')
                ? 'hotelName'
                : pattern.pattern.contains('Check-in:')
                    ? 'checkIn'
                    : 'checkOut';
            currentItem[key] = match.group(1)?.trim();
            continue;
          }
        }

        // Look for activity information (time followed by description)
        final timeMatch = _timePattern.firstMatch(line);
        if (timeMatch != null) {
          final time = timeMatch.group(1)!;
          final description = line.substring(timeMatch.end).trim();
          if (description.isNotEmpty) {
            if (currentItem.isNotEmpty) {
              items.add(_createItineraryItem(currentItem, currentDate));
            }
            currentItem = {
              'type': ItineraryItemType.activity,
              'startTime': time,
              'description': description,
            };
          }
        }
      }
    }

    // Add the last item if any
    if (currentItem.isNotEmpty && currentDate != null) {
      items.add(_createItineraryItem(currentItem, currentDate));
    }

    return items;
  }

  DateTime _parseDate(String dateStr) {
    // Remove ordinal indicators (st, nd, rd, th)
    dateStr = dateStr.replaceAll(RegExp(r'(?:st|nd|rd|th)'), '');

    // Parse the date
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      // If standard parsing fails, try manual parsing
      final parts = dateStr.split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = _getMonthNumber(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      // Return today's date if parsing fails
      return DateTime.now();
    }
  }

  int _getMonthNumber(String month) {
    final months = {
      'jan': 1,
      'january': 1,
      'feb': 2,
      'february': 2,
      'mar': 3,
      'march': 3,
      'apr': 4,
      'april': 4,
      'may': 5,
      'jun': 6,
      'june': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'august': 8,
      'sep': 9,
      'september': 9,
      'oct': 10,
      'october': 10,
      'nov': 11,
      'november': 11,
      'dec': 12,
      'december': 12,
    };
    return months[month.toLowerCase()] ?? 1;
  }

  TimeOfDay _parseTimeOfDay(String? timeStr) {
    if (timeStr == null) return const TimeOfDay(hour: 9, minute: 0);

    // Remove any whitespace and convert to uppercase
    timeStr = timeStr.trim().toUpperCase();

    // Check if time is in 12-hour format
    final isPM = timeStr.endsWith('PM');
    timeStr = timeStr.replaceAll(RegExp(r'[AaPpMm]'), '').trim();

    final parts = timeStr.split(':');
    if (parts.length != 2) return const TimeOfDay(hour: 9, minute: 0);

    try {
      var hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      // Convert to 24-hour format if necessary
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  ItineraryItem _createItineraryItem(Map<String, dynamic> data, DateTime date) {
    final type = data['type'] as ItineraryItemType;
    String title;
    TimeOfDay startTime;
    TimeOfDay? endTime;
    String? location;
    Map<String, dynamic> details = {};

    switch (type) {
      case ItineraryItemType.flight:
        title = 'Flight ${data['flightNumber']}';
        startTime = _parseTimeOfDay(data['departureTime']);
        endTime = _parseTimeOfDay(data['arrivalTime']);
        details = {
          'flightNumber': data['flightNumber'],
          if (data['departureAirport'] != null)
            'departure': data['departureAirport'],
          if (data['arrivalAirport'] != null) 'arrival': data['arrivalAirport'],
        };
        break;

      case ItineraryItemType.accommodation:
        title = data['hotelName'] ?? 'Hotel Stay';
        startTime = _parseTimeOfDay(data['checkIn'] ?? '15:00');
        endTime = _parseTimeOfDay(data['checkOut'] ?? '11:00');
        location = data['hotelName'];
        break;

      case ItineraryItemType.activity:
      default:
        title = data['description'] ?? 'Activity';
        startTime = _parseTimeOfDay(data['startTime']);
        endTime = _parseTimeOfDay(data['endTime']);
        location = data['location'];
    }

    return ItineraryItem(
      title: title,
      type: type,
      startTime: startTime,
      endTime: endTime,
      location: location,
      details: details.isNotEmpty ? details : null,
    );
  }
}
