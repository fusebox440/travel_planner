import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/nlu_intent.dart';

class Suggestion {
  final String text;
  final String? intent;
  final Map<String, dynamic>? data;
  final bool isQuickReply;

  const Suggestion({
    required this.text,
    this.intent,
    this.data,
    this.isQuickReply = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Suggestion &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          intent == other.intent &&
          mapEquals(data, other.data) &&
          isQuickReply == other.isQuickReply;

  @override
  int get hashCode =>
      text.hashCode ^ intent.hashCode ^ data.hashCode ^ isQuickReply.hashCode;
}

class SuggestionService {
  List<Suggestion> getSuggestionsForChat(
    List<ChatMessage> messages,
    Map<String, dynamic> appState,
  ) {
    if (messages.isEmpty) {
      return _getInitialSuggestions(appState);
    }

    final lastMessage = messages.last;
    if (lastMessage.isAssistant && lastMessage.intent != null) {
      return _getSuggestionsForIntent(
        lastMessage.intent!,
        lastMessage.meta ?? {},
        appState,
      );
    }

    return _getContextualSuggestions(messages, appState);
  }

  List<Suggestion> _getInitialSuggestions(Map<String, dynamic> appState) {
    final suggestions = <Suggestion>[];

    // If there's an active trip
    if (appState['activeTrip'] != null) {
      suggestions.add(
        Suggestion(
          text: 'Show my itinerary',
          intent: IntentType.addActivity.toString(),
          isQuickReply: true,
        ),
      );
    }

    // If there's a location set
    if (appState['location'] != null) {
      suggestions.add(
        Suggestion(
          text: "What's the weather like?",
          intent: IntentType.weather.toString(),
          data: {'location': appState['location']},
          isQuickReply: true,
        ),
      );
    }

    // Add some general suggestions
    suggestions.addAll([
      Suggestion(
        text: 'Help me plan a trip',
        intent: IntentType.searchFlight.toString(),
        isQuickReply: true,
      ),
      Suggestion(
        text: 'Convert currency',
        intent: IntentType.currencyConvert.toString(),
        isQuickReply: true,
      ),
    ]);

    return suggestions;
  }

  List<Suggestion> _getSuggestionsForIntent(
    String intent,
    Map<String, dynamic> meta,
    Map<String, dynamic> appState,
  ) {
    final suggestions = <Suggestion>[];

    // Add intent-specific follow-up suggestions
    switch (intent) {
      case 'IntentType.weather':
        if (appState['location'] != null) {
          suggestions.add(
            Suggestion(
              text: 'What about tomorrow?',
              intent: IntentType.weather.toString(),
              data: {
                'location': appState['location'],
                'date': DateTime.now().add(const Duration(days: 1)),
              },
              isQuickReply: true,
            ),
          );
        }
        break;

      case 'IntentType.searchFlight':
        suggestions.addAll([
          Suggestion(
            text: 'Show hotels nearby',
            intent: IntentType.bookHotel.toString(),
            data: {'location': meta['destination']},
            isQuickReply: true,
          ),
          Suggestion(
            text: 'What should I pack?',
            intent: IntentType.packingSuggest.toString(),
            data: {
              'destination': meta['destination'],
              'duration': meta['duration'],
            },
            isQuickReply: true,
          ),
        ]);
        break;

      case 'IntentType.addActivity':
        suggestions.addAll([
          Suggestion(
            text: 'Get directions',
            intent: IntentType.mapsDirections.toString(),
            data: {'destination': meta['location']},
            isQuickReply: true,
          ),
          Suggestion(
            text: 'Find restaurants nearby',
            intent: IntentType.searchFlight.toString(),
            data: {'location': meta['location']},
            isQuickReply: true,
          ),
        ]);
        break;
    }

    return suggestions;
  }

  List<Suggestion> _getContextualSuggestions(
    List<ChatMessage> messages,
    Map<String, dynamic> appState,
  ) {
    final suggestions = <Suggestion>[];

    // Check recent conversation topics
    final recentTopics = _analyzeRecentTopics(messages);

    if (recentTopics.contains('location') && appState['location'] != null) {
      suggestions.add(
        Suggestion(
          text: 'Show on map',
          intent: IntentType.mapsDirections.toString(),
          data: {'location': appState['location']},
          isQuickReply: true,
        ),
      );
    }

    if (recentTopics.contains('weather')) {
      suggestions.add(
        Suggestion(
          text: 'Get 5-day forecast',
          intent: IntentType.weather.toString(),
          data: {'extended': true},
          isQuickReply: true,
        ),
      );
    }

    // Add contextual quick replies based on app state
    if (appState['activeTrip'] != null) {
      suggestions.add(
        Suggestion(
          text: 'Add to itinerary',
          intent: IntentType.addActivity.toString(),
          data: {'tripId': appState['activeTrip']['id']},
          isQuickReply: true,
        ),
      );
    }

    return suggestions;
  }

  Set<String> _analyzeRecentTopics(List<ChatMessage> messages) {
    final topics = <String>{};
    final recentMessages = messages.reversed.take(5); // Look at last 5 messages

    for (final message in recentMessages) {
      if (message.intent != null) {
        switch (message.intent) {
          case 'IntentType.weather':
            topics.add('weather');
            if (message.meta?['location'] != null) {
              topics.add('location');
            }
            break;
          case 'IntentType.mapsDirections':
          case 'IntentType.searchFlight':
          case 'IntentType.bookHotel':
            topics.add('location');
            break;
          case 'IntentType.currencyConvert':
            topics.add('currency');
            break;
        }
      }

      // Simple keyword matching for topics
      final text = message.text.toLowerCase();
      if (text.contains('weather') ||
          text.contains('temperature') ||
          text.contains('forecast')) {
        topics.add('weather');
      }
      if (text.contains('map') ||
          text.contains('direction') ||
          text.contains('navigate')) {
        topics.add('location');
      }
      if (text.contains('currency') ||
          text.contains('money') ||
          text.contains('price')) {
        topics.add('currency');
      }
    }

    return topics;
  }
}
