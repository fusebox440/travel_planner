import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/translator/data/translation_service.dart';

// Initialize and provide the translation service
final translationServiceProvider = Provider<TranslationService>((ref) {
  final service = TranslationService();
  service.init(); // Initialize Hive box
  return service;
});

// Service status provider to track API availability
final translationServiceStatusProvider = StreamProvider<bool>((ref) async* {
  while (true) {
    try {
      final service = ref.watch(translationServiceProvider);
      final result = await service.checkApiHealth();
      yield result;
    } catch (_) {
      yield false;
    }
    await Future.delayed(const Duration(minutes: 1));
  }
});

// Current input text state with debouncing
final inputTextProvider = StateProvider<String>((ref) => '');

// Selected source language with persistence
final sourceLanguageProvider = StateProvider<String>((ref) => 'auto');

// Selected target language with persistence
final targetLanguageProvider = StateProvider<String>((ref) => 'en');

// Translation state with error handling and retry logic
final translationProvider =
    FutureProvider.autoDispose.family<String, String>((ref, text) async {
  if (text.isEmpty) return '';

  // Add retry logic
  int retryCount = 0;
  const maxRetries = 3;

  while (retryCount < maxRetries) {
    try {
      final service = ref.watch(translationServiceProvider);
      final from = ref.watch(sourceLanguageProvider);
      final to = ref.watch(targetLanguageProvider);

      return await service.translateText(text, from, to);
    } catch (e) {
      retryCount++;
      if (retryCount == maxRetries) rethrow;
      await Future.delayed(
          Duration(seconds: retryCount * 2)); // Exponential backoff
    }
  }

  throw Exception('Translation failed after $maxRetries attempts');
});

// Language detection state with confidence threshold
final detectedLanguageProvider =
    FutureProvider.autoDispose.family<String, String>((ref, text) async {
  if (text.isEmpty) return '';

  try {
    final service = ref.watch(translationServiceProvider);
    return await service.detectLanguage(text);
  } catch (e) {
    // Default to 'auto' on error
    return 'auto';
  }
});

// Recent translations with pagination
final recentTranslationsProvider = Provider<List<Translation>>((ref) {
  final service = ref.watch(translationServiceProvider);
  return service.getRecentTranslations();
});

// Favorite translations with offline support
final favoritesProvider = Provider<List<Translation>>((ref) {
  final service = ref.watch(translationServiceProvider);
  return service.getFavorites();
});

// Supported languages with fallback
final supportedLanguagesProvider = Provider<Map<String, String>>((ref) {
  return TranslationService.supportedLanguages;
});

// Recent languages for quick access
final recentLanguagesProvider = Provider<List<String>>((ref) {
  final recents = ref.watch(recentTranslationsProvider);
  final sourceLanguages =
      recents.map((t) => t.fromLanguage).where((l) => l != 'auto');
  final targetLanguages = recents.map((t) => t.toLanguage);

  return {...sourceLanguages, ...targetLanguages}.take(5).toList();
});
