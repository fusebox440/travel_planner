import 'package:flutter/foundation.dart';
import '../models/nlu_intent.dart';

abstract class NluService {
  Future<NluIntent> parse(String text, {String? locale});
}

class LocalNluService implements NluService {
  @override
  Future<NluIntent> parse(String text, {String? locale}) async {
    final normalizedText = text.toLowerCase();

    // Weather intent patterns
    final weatherPattern = RegExp(
      r'weather|temperature|forecast|rain|sunny|cloudy',
      caseSensitive: false,
    );
    if (weatherPattern.hasMatch(normalizedText)) {
      final locationPattern = RegExp(r'in\s+([a-zA-Z\s]+)');
      final match = locationPattern.firstMatch(normalizedText);
      final location = match?.group(1)?.trim() ?? 'current location';

      // Extract date if present
      DateTime? date;
      if (normalizedText.contains('tomorrow')) {
        date = DateTime.now().add(const Duration(days: 1));
      } else if (normalizedText.contains('today')) {
        date = DateTime.now();
      }

      return NluIntent.weather(location: location, date: date);
    }

    // Currency conversion patterns
    final currencyPattern = RegExp(
      r'convert\s+(\d+(?:\.\d+)?)\s*([a-zA-Z]{3})\s+(?:to\s+)?([a-zA-Z]{3})',
      caseSensitive: false,
    );
    final currencyMatch = currencyPattern.firstMatch(normalizedText);
    if (currencyMatch != null) {
      final amount = double.parse(currencyMatch.group(1)!);
      final from = currencyMatch.group(2)!.toUpperCase();
      final to = currencyMatch.group(3)!.toUpperCase();
      return NluIntent.currencyConvert(
        from: from,
        to: to,
        amount: amount,
      );
    }

    // Add activity patterns
    final addActivityPattern = RegExp(
      r'add\s+(.*?)(?:\s+(?:at|on)\s+(.+?))?(?:\s+in\s+(.+?))?(?:\s*$|\s+notes?:?\s+(.+))',
      caseSensitive: false,
    );
    final activityMatch = addActivityPattern.firstMatch(normalizedText);
    if (activityMatch != null) {
      final title = activityMatch.group(1)!.trim();
      final timeStr = activityMatch.group(2);
      final location = activityMatch.group(3);
      final notes = activityMatch.group(4);

      // Default to current date if no date/time specified
      DateTime date = DateTime.now();
      if (timeStr != null) {
        try {
          if (timeStr.contains('tomorrow')) {
            date = DateTime.now().add(const Duration(days: 1));
          } else if (timeStr.contains('today')) {
            date = DateTime.now();
          }
          // Add more date parsing logic as needed
        } catch (e) {
          debugPrint('Failed to parse date: $e');
        }
      }

      return NluIntent.addActivity(
        title: title,
        date: date,
        location: location,
        notes: notes,
      );
    }

    // Flight search patterns
    final flightPattern = RegExp(
      r'(?:search\s+)?flights?\s+(?:from\s+)?([a-zA-Z\s]+)\s+to\s+([a-zA-Z\s]+)(?:\s+on\s+(.+?))?(?:\s+for\s+(\d+)\s+(?:person|people|passengers?))?',
      caseSensitive: false,
    );
    final flightMatch = flightPattern.firstMatch(normalizedText);
    if (flightMatch != null) {
      final origin = flightMatch.group(1)!.trim();
      final destination = flightMatch.group(2)!.trim();
      final dateStr = flightMatch.group(3);
      final passengersStr = flightMatch.group(4);

      DateTime departDate = DateTime.now();
      if (dateStr != null) {
        if (dateStr.contains('tomorrow')) {
          departDate = DateTime.now().add(const Duration(days: 1));
        }
        // Add more date parsing logic as needed
      }

      int? passengers;
      if (passengersStr != null) {
        passengers = int.tryParse(passengersStr);
      }

      return NluIntent.searchFlight(
        origin: origin,
        destination: destination,
        departDate: departDate,
        passengers: passengers,
      );
    }

    // Fallback to small talk if no other intent matches
    return NluIntent(
      type: IntentType.smallTalk,
      entities: {'text': text},
      confidence: 0.5,
    );
  }
}

class RemoteNluService implements NluService {
  final String apiUrl;
  final String? apiKey;

  RemoteNluService({
    required this.apiUrl,
    this.apiKey,
  });

  @override
  Future<NluIntent> parse(String text, {String? locale}) async {
    // TODO: Implement remote NLU service integration
    // This is a stub that should be implemented with your chosen NLU service
    throw UnimplementedError('Remote NLU service not implemented');
  }
}

class FallbackNluService implements NluService {
  final NluService primary;
  final NluService fallback;

  FallbackNluService({
    required this.primary,
    required this.fallback,
  });

  @override
  Future<NluIntent> parse(String text, {String? locale}) async {
    try {
      return await primary.parse(text, locale: locale);
    } catch (e) {
      debugPrint('Primary NLU service failed: $e');
      return fallback.parse(text, locale: locale);
    }
  }
}
