import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/nlu_intent.dart';
import 'nlu_service.dart';
import 'suggestion_service.dart';

// These services will be properly implemented later
abstract class CurrencyService {
  Future<double> convert(double amount, String from, String to);
}

abstract class WeatherService {
  Future<Map<String, dynamic>> getWeather(String location, [DateTime? date]);
}

abstract class MapsService {
  Future<Map<String, dynamic>> getDirections(String origin, String destination);
}

abstract class BookingService {
  Future<List<Map<String, dynamic>>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departDate,
    DateTime? returnDate,
    int? passengers,
  });
}

abstract class PackingListService {
  Future<List<Map<String, dynamic>>> generateSuggestions({
    required String destination,
    required int duration,
  });
}

// Stub implementation
class StubCurrencyService implements CurrencyService {
  @override
  Future<double> convert(double amount, String from, String to) async {
    return amount * 1.2; // Dummy conversion rate
  }
}

class StubWeatherService implements WeatherService {
  @override
  Future<Map<String, dynamic>> getWeather(String location,
      [DateTime? date]) async {
    return {
      'temperature': 22,
      'condition': 'sunny',
      'location': location,
      'date': date?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}

class StubBookingService implements BookingService {
  @override
  Future<List<Map<String, dynamic>>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departDate,
    DateTime? returnDate,
    int? passengers,
  }) async {
    return [
      {
        'id': '1',
        'airline': 'Demo Airlines',
        'flightNumber': 'DA123',
        'origin': origin,
        'destination': destination,
        'departureTime': departDate.toString(),
        'price': 299.99,
      }
    ];
  }
}

class StubPackingListService implements PackingListService {
  @override
  Future<List<Map<String, dynamic>>> generateSuggestions({
    required String destination,
    required int duration,
  }) async {
    return [
      {
        'category': 'Essentials',
        'items': ['Passport', 'Phone charger']
      },
      {
        'category': 'Clothes',
        'items': ['T-shirts', 'Jeans']
      },
    ];
  }
}

class AssistantResponse {
  final ChatMessage message;
  final List<Suggestion> suggestions;
  final Map<String, dynamic>? actions;

  const AssistantResponse({
    required this.message,
    this.suggestions = const [],
    this.actions,
  });
}

class AssistantService {
  final NluService _nluService;
  final SuggestionService _suggestionService;
  final CurrencyService _currencyService;
  final WeatherService _weatherService;
  final BookingService _bookingService;
  final PackingListService _packingListService;

  AssistantService({
    required NluService nluService,
    required SuggestionService suggestionService,
    required CurrencyService currencyService,
    required WeatherService weatherService,
    required BookingService bookingService,
    required PackingListService packingListService,
  })  : _nluService = nluService,
        _suggestionService = suggestionService,
        _currencyService = currencyService,
        _weatherService = weatherService,
        _bookingService = bookingService,
        _packingListService = packingListService;

  Future<AssistantResponse> processMessage(
    String text,
    String? locale,
    Map<String, dynamic> appState,
    List<ChatMessage> conversationHistory,
  ) async {
    try {
      final intent = await _nluService.parse(text, locale: locale);
      final response = await _handleIntent(intent, appState);

      final suggestions = _suggestionService.getSuggestionsForChat(
        [...conversationHistory, response.message],
        appState,
      );

      return AssistantResponse(
        message: response.message,
        suggestions: suggestions,
        actions: response.actions,
      );
    } catch (e, s) {
      debugPrint('Error processing message: $e\n$s');
      return AssistantResponse(
        message: ChatMessage(
          sender: MessageSender.assistant,
          text:
              'I apologize, but I encountered an error processing your request. Please try again.',
          meta: {'error': e.toString()},
        ),
      );
    }
  }

  Future<AssistantResponse> _handleIntent(
    NluIntent intent,
    Map<String, dynamic> appState,
  ) async {
    switch (intent.type) {
      case IntentType.weather:
        return _handleWeatherIntent(intent);
      case IntentType.currencyConvert:
        return _handleCurrencyIntent(intent);
      case IntentType.searchFlight:
        return _handleFlightSearchIntent(intent);
      case IntentType.addActivity:
        return _handleAddActivityIntent(intent);
      case IntentType.bookHotel:
        return _handleBookHotelIntent(intent);
      case IntentType.mapsDirections:
        return _handleMapsIntent(intent);
      case IntentType.packingSuggest:
        return _handlePackingIntent(intent);
      case IntentType.faq:
        return _handleFaqIntent(intent);
      case IntentType.smallTalk:
        return _handleSmallTalkIntent(intent);
    }
  }

  Future<AssistantResponse> _handleWeatherIntent(NluIntent intent) async {
    final location = intent.getStringEntity('location') ?? 'current location';
    final date = intent.getDateTimeEntity('date');

    final weather = await _weatherService.getWeather(location, date);

    return AssistantResponse(
      message: ChatMessage(
        sender: MessageSender.assistant,
        text: _formatWeatherResponse(weather),
        intent: intent.type.toString(),
        meta: {
          'location': location,
          'date': date?.toIso8601String(),
          'weather': weather,
        },
      ),
    );
  }

  Future<AssistantResponse> _handleCurrencyIntent(NluIntent intent) async {
    final from = intent.getStringEntity('from')!;
    final to = intent.getStringEntity('to')!;
    final amount = intent.getNumericEntity('amount')!;

    final result = await _currencyService.convert(
      amount.toDouble(),
      from,
      to,
    );

    return AssistantResponse(
      message: ChatMessage(
        sender: MessageSender.assistant,
        text:
            '${amount.toStringAsFixed(2)} $from = ${result.toStringAsFixed(2)} $to',
        intent: intent.type.toString(),
        meta: {
          'from': from,
          'to': to,
          'amount': amount,
          'result': result,
        },
      ),
    );
  }

  Future<AssistantResponse> _handleFlightSearchIntent(NluIntent intent) async {
    final origin = intent.getStringEntity('origin')!;
    final destination = intent.getStringEntity('destination')!;
    final departDate = intent.getDateTimeEntity('departDate')!;
    final returnDate = intent.getDateTimeEntity('returnDate');
    final passengers = intent.getNumericEntity('passengers')?.toInt() ?? 1;

    final flights = await _bookingService.searchFlights(
      origin: origin,
      destination: destination,
      departDate: departDate,
      returnDate: returnDate,
      passengers: passengers,
    );

    return AssistantResponse(
      message: ChatMessage(
        sender: MessageSender.assistant,
        text: _formatFlightResults(flights),
        intent: intent.type.toString(),
        meta: {
          'origin': origin,
          'destination': destination,
          'departDate': departDate.toIso8601String(),
          if (returnDate != null) 'returnDate': returnDate.toIso8601String(),
          'passengers': passengers,
          'flights': flights,
        },
      ),
      actions: {'showFlights': flights},
    );
  }

  Future<AssistantResponse> _handleAddActivityIntent(NluIntent intent) async {
    final title = intent.getStringEntity('title')!;
    final date = intent.getDateTimeEntity('date')!;
    final location = intent.getStringEntity('location');
    final notes = intent.getStringEntity('notes');

    // For now, just return the response without actually adding the activity
    return AssistantResponse(
      message: ChatMessage(
        sender: MessageSender.assistant,
        text:
            'I would add "$title" to your itinerary for ${_formatDate(date)}${location != null ? ' at $location' : ''}.',
        intent: intent.type.toString(),
        meta: {
          'title': title,
          'date': date.toIso8601String(),
          if (location != null) 'location': location,
          if (notes != null) 'notes': notes,
        },
      ),
      actions: {
        'addActivity': {
          'title': title,
          'date': date.toIso8601String(),
          if (location != null) 'location': location,
          if (notes != null) 'notes': notes,
        }
      },
    );
  }

  Future<AssistantResponse> _handleBookHotelIntent(NluIntent intent) async {
    // Implementation similar to flight search
    throw UnimplementedError();
  }

  Future<AssistantResponse> _handleMapsIntent(NluIntent intent) async {
    // Implementation for maps/directions
    throw UnimplementedError();
  }

  Future<AssistantResponse> _handlePackingIntent(NluIntent intent) async {
    final destination = intent.getStringEntity('destination')!;
    final duration = intent.getNumericEntity('duration')?.toInt() ?? 7;

    final suggestions = await _packingListService.generateSuggestions(
      destination: destination,
      duration: duration,
    );

    return AssistantResponse(
      message: ChatMessage(
        sender: MessageSender.assistant,
        text:
            'Here\'s what I recommend packing for your $duration-day trip to $destination:\n\n${_formatPackingList(suggestions)}',
        intent: intent.type.toString(),
        meta: {
          'destination': destination,
          'duration': duration,
          'suggestions': suggestions,
        },
      ),
      actions: {'showPackingList': suggestions},
    );
  }

  Future<AssistantResponse> _handleFaqIntent(NluIntent intent) async {
    // Implementation for FAQ responses
    throw UnimplementedError();
  }

  Future<AssistantResponse> _handleSmallTalkIntent(NluIntent intent) async {
    return AssistantResponse(
      message: ChatMessage(
        sender: MessageSender.assistant,
        text: _getSmallTalkResponse(intent.getStringEntity('text')!),
        intent: intent.type.toString(),
      ),
    );
  }

  String _formatWeatherResponse(Map<String, dynamic> weather) {
    // Format weather data into a natural response
    throw UnimplementedError();
  }

  String _formatFlightResults(List<Map<String, dynamic>> flights) {
    // Format flight search results
    throw UnimplementedError();
  }

  String _formatPackingList(List<Map<String, dynamic>> items) {
    // Format packing list suggestions
    throw UnimplementedError();
  }

  String _formatDate(DateTime date) {
    // Format date in a user-friendly way
    throw UnimplementedError();
  }

  String _getSmallTalkResponse(String text) {
    // Return appropriate small talk response
    throw UnimplementedError();
  }
}
