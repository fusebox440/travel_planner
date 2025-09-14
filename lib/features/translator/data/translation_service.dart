import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:travel_planner/features/translator/domain/models/translation.dart';

class TranslationService {
  static const String _apiBaseUrl = String.fromEnvironment(
    'TRANSLATION_API_URL',
    defaultValue: 'https://libretranslate.com',
  );
  static const String _apiKey = String.fromEnvironment('TRANSLATION_API_KEY');
  static const String _translationsBoxName = 'translations';

  // Singleton pattern
  TranslationService._privateConstructor();
  static final TranslationService _instance =
      TranslationService._privateConstructor();
  factory TranslationService() => _instance;

  static bool get hasApiKey => _apiKey.isNotEmpty;

  late final Box<Translation> _translationsBox;
  final Map<String, String> _cache = {};

  static final Map<String, String> supportedLanguages = {
    'auto': 'Auto Detect',
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'it': 'Italian',
    'pt': 'Portuguese',
    'ru': 'Russian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh': 'Chinese',
  };

  Future<void> init() async {
    _translationsBox = await Hive.openBox<Translation>(_translationsBoxName);
  }

  String _getCacheKey(String text, String from, String to) => '$text|$from|$to';

  Future<String> translateText(String text, String from, String to) async {
    // Check cache first
    final cacheKey = _getCacheKey(text, from, to);
    if (_cache.containsKey(cacheKey)) {
      debugPrint('Translation cache hit: $cacheKey');
      return _cache[cacheKey]!;
    }

    // Check if we have network connectivity
    try {
      final result = await http.get(Uri.parse('$_apiBaseUrl/health'));
      if (result.statusCode != 200) {
        throw Exception('Translation service unavailable');
      }
    } catch (e) {
      debugPrint('Network connectivity check failed: $e');
      // Look for an exact match in saved translations
      final savedMatch = _translationsBox.values.firstWhere(
        (t) =>
            t.sourceText == text &&
            t.fromLanguage == from &&
            t.toLanguage == to,
        orElse: () => throw Exception(
            'No internet connection and no cached translation available'),
      );
      return savedMatch.translatedText;
    }

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (hasApiKey) 'Authorization': 'Bearer $_apiKey',
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/translate'),
        headers: headers,
        body: jsonEncode({
          'q': text,
          'source': from == 'auto' ? await detectLanguage(text) : from,
          'target': to,
          if (hasApiKey) 'api_key': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final translatedText =
            jsonDecode(response.body)['translatedText'] as String;

        // Cache the result with expiration time
        _cache[cacheKey] = translatedText;

        // Save to history
        final translation = Translation(
          sourceText: text,
          translatedText: translatedText,
          fromLanguage: from,
          toLanguage: to,
          timestamp: DateTime.now(),
        );
        await _translationsBox.add(translation);

        return translatedText;
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      rethrow;
    }
  }

  Future<String> detectLanguage(String text) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (hasApiKey) 'Authorization': 'Bearer $_apiKey',
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/detect'),
        headers: headers,
        body: jsonEncode({
          'q': text,
          if (hasApiKey) 'api_key': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> detections = jsonDecode(response.body);
        if (detections.isNotEmpty) {
          final detection = detections.first;
          final language = detection['language'] as String;
          final confidence = detection['confidence'] as double? ?? 0.0;

          // If confidence is too low, return 'auto' to let the translation API handle it
          if (confidence < 0.5) {
            debugPrint(
                'Low confidence language detection ($confidence): defaulting to auto');
            return 'auto';
          }
          return language;
        }
        debugPrint('No language detected, falling back to auto');
        return 'auto';
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Language detection failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Language detection error: $e');
      // In case of network error, default to 'auto'
      return 'auto';
    }
  }

  Future<void> saveFavorite(Translation translation) async {
    final updatedTranslation = Translation(
      sourceText: translation.sourceText,
      translatedText: translation.translatedText,
      fromLanguage: translation.fromLanguage,
      toLanguage: translation.toLanguage,
      timestamp: translation.timestamp,
      isFavorite: true,
    );
    await _translationsBox.put(translation.key, updatedTranslation);
  }

  Future<void> removeFavorite(Translation translation) async {
    final updatedTranslation = Translation(
      sourceText: translation.sourceText,
      translatedText: translation.translatedText,
      fromLanguage: translation.fromLanguage,
      toLanguage: translation.toLanguage,
      timestamp: translation.timestamp,
      isFavorite: false,
    );
    await _translationsBox.put(translation.key, updatedTranslation);
  }

  List<Translation> getFavorites() {
    return _translationsBox.values.where((t) => t.isFavorite).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<Translation> getRecentTranslations({int limit = 50}) {
    return _translationsBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp))
      ..take(limit);
  }

  Future<void> clearHistory() async {
    await _translationsBox.clear();
    _cache.clear();
  }

  Future<bool> checkApiHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/health'),
        headers: {
          if (hasApiKey) 'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('API health check failed: $e');
      return false;
    }
  }

  // Stub for future OCR support
  Future<String> translateFromImage(
      String imagePath, String targetLanguage) async {
    // TODO: Implement OCR integration
    throw UnimplementedError('OCR translation not yet implemented');
  }
}
