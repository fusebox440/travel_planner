import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import '../../../src/models/expense.dart';

class VoiceToTextService {
  static final VoiceToTextService _instance = VoiceToTextService._internal();
  factory VoiceToTextService() => _instance;
  VoiceToTextService._internal();

  late final SpeechToText _speechToText;
  bool _isInitialized = false;
  bool _isListening = false;

  String _lastResult = '';
  double _confidence = 0.0;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;
  String get lastResult => _lastResult;
  double get confidence => _confidence;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _speechToText = SpeechToText();
      _isInitialized = await _speechToText.initialize(
        onError: _onError,
        onStatus: _onStatus,
      );
    }
    return _isInitialized;
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      throw Exception('VoiceToTextService not initialized');
    }
    return await _speechToText.locales();
  }

  Future<bool> hasPermission() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speechToText.hasPermission;
  }

  Future<VoiceExpenseResult> startListeningForExpense({
    String localeId = 'en_US',
    Duration timeout = const Duration(seconds: 30),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_isInitialized) {
      throw Exception('VoiceToTextService not initialized');
    }

    if (!await hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    final completer = Completer<VoiceExpenseResult>();

    await _speechToText.listen(
      onResult: (result) {
        _lastResult = result.recognizedWords;
        _confidence = result.confidence;

        if (result.finalResult) {
          _isListening = false;
          final expenseData =
              _parseExpenseFromText(result.recognizedWords, result.confidence);
          completer.complete(expenseData);
        }
      },
      listenFor: timeout,
      pauseFor: pauseFor,
      partialResults: true,
      onDevice: false,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      localeId: localeId,
    );

    _isListening = true;
    return completer.future;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      await _speechToText.cancel();
      _isListening = false;
    }
  }

  VoiceExpenseResult _parseExpenseFromText(String text, double confidence) {
    try {
      final parser = ExpenseTextParser(text);

      return VoiceExpenseResult(
        success: true,
        originalText: text,
        confidence: confidence,
        amount: parser.extractAmount(),
        title: parser.extractTitle(),
        category: parser.extractCategory(),
        subCategory: parser.extractSubCategory(),
        merchant: parser.extractMerchant(),
        paymentMethod: parser.extractPaymentMethod(),
        notes: parser.extractNotes(),
        tags: parser.extractTags(),
        suggestions: parser.getSuggestions(),
      );
    } catch (e) {
      return VoiceExpenseResult(
        success: false,
        originalText: text,
        confidence: confidence,
        error: 'Failed to parse expense from text: $e',
      );
    }
  }

  void _onError(dynamic error) {
    _isListening = false;
    print('Speech recognition error: $error');
  }

  void _onStatus(String status) {
    print('Speech recognition status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
    }
  }
}

class VoiceExpenseResult {
  final bool success;
  final String originalText;
  final double confidence;
  final String? error;

  // Extracted expense data
  final double? amount;
  final String? title;
  final ExpenseCategory? category;
  final ExpenseSubCategory? subCategory;
  final String? merchant;
  final PaymentMethod? paymentMethod;
  final String? notes;
  final List<String>? tags;
  final List<String> suggestions;

  VoiceExpenseResult({
    required this.success,
    required this.originalText,
    required this.confidence,
    this.error,
    this.amount,
    this.title,
    this.category,
    this.subCategory,
    this.merchant,
    this.paymentMethod,
    this.notes,
    this.tags,
    this.suggestions = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'originalText': originalText,
      'confidence': confidence,
      'error': error,
      'amount': amount,
      'title': title,
      'category': category?.toString().split('.').last,
      'subCategory': subCategory?.toString().split('.').last,
      'merchant': merchant,
      'paymentMethod': paymentMethod?.toString().split('.').last,
      'notes': notes,
      'tags': tags,
      'suggestions': suggestions,
    };
  }
}

class ExpenseTextParser {
  final String text;
  final String _normalizedText;

  ExpenseTextParser(this.text) : _normalizedText = text.toLowerCase().trim();

  double? extractAmount() {
    // Pattern for amounts: "$50", "50 dollars", "fifty dollars", etc.
    final patterns = [
      RegExp(r'\$(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d{2})?)\s*dollars?', caseSensitive: false),
      RegExp(r'(\d+(?:\.\d{2})?)\s*bucks?', caseSensitive: false),
      RegExp(r'cost\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'spent\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'paid\s*(\d+(?:\.\d{2})?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final amountStr = match.group(1);
        final amount = double.tryParse(amountStr ?? '');
        if (amount != null && amount > 0) {
          return amount;
        }
      }
    }

    // Try to convert words to numbers
    return _convertWordsToNumber();
  }

  String? extractTitle() {
    // Remove amount and common phrases to get the core expense description
    String cleanText = text;

    // Remove common phrases
    final phrasesToRemove = [
      RegExp(r'\$\d+(?:\.\d{2})?'),
      RegExp(r'\d+(?:\.\d{2})?\s*dollars?', caseSensitive: false),
      RegExp(r'i\s+(spent|paid|bought)', caseSensitive: false),
      RegExp(r'(cost|total|amount)', caseSensitive: false),
      RegExp(r'(at|from|in|on)\s+', caseSensitive: false),
      RegExp(r'(with|using)\s+(cash|card|credit)', caseSensitive: false),
    ];

    for (final pattern in phrasesToRemove) {
      cleanText = cleanText.replaceAll(pattern, ' ');
    }

    cleanText = cleanText.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (cleanText.isEmpty) {
      return null;
    }

    // Extract the main item/description
    final words = cleanText.split(' ');
    if (words.length <= 3) {
      return cleanText;
    }

    // Take first few meaningful words
    return words.take(3).join(' ');
  }

  ExpenseCategory? extractCategory() {
    final categoryKeywords = {
      ExpenseCategory.food: [
        'food',
        'restaurant',
        'lunch',
        'dinner',
        'breakfast',
        'snack',
        'coffee',
        'pizza',
        'burger',
        'meal',
        'eating',
        'grocery',
        'groceries',
        'supermarket'
      ],
      ExpenseCategory.transport: [
        'gas',
        'fuel',
        'uber',
        'taxi',
        'bus',
        'train',
        'flight',
        'parking',
        'car',
        'transport',
        'travel',
        'ride',
        'trip'
      ],
      ExpenseCategory.accommodation: [
        'hotel',
        'motel',
        'airbnb',
        'hostel',
        'accommodation',
        'room',
        'stay',
        'lodge',
        'resort'
      ],
      ExpenseCategory.entertainment: [
        'movie',
        'cinema',
        'theater',
        'concert',
        'show',
        'game',
        'entertainment',
        'fun',
        'activity',
        'museum',
        'park'
      ],
      ExpenseCategory.shopping: [
        'shopping',
        'store',
        'mall',
        'clothes',
        'clothing',
        'shirt',
        'shoes',
        'buy',
        'purchase',
        'amazon',
        'online'
      ],
      ExpenseCategory.healthcare: [
        'doctor',
        'hospital',
        'pharmacy',
        'medicine',
        'medical',
        'health',
        'clinic',
        'dentist',
        'drug',
        'prescription'
      ],
      ExpenseCategory.business: [
        'business',
        'work',
        'office',
        'meeting',
        'client',
        'conference',
        'supplies',
        'equipment'
      ],
    };

    for (final category in categoryKeywords.keys) {
      final keywords = categoryKeywords[category]!;
      if (keywords.any((keyword) => _normalizedText.contains(keyword))) {
        return category;
      }
    }

    return null;
  }

  ExpenseSubCategory? extractSubCategory() {
    final subCategoryKeywords = {
      ExpenseSubCategory.breakfast: ['breakfast', 'morning meal'],
      ExpenseSubCategory.lunch: ['lunch', 'noon meal'],
      ExpenseSubCategory.dinner: ['dinner', 'evening meal', 'supper'],
      ExpenseSubCategory.snacks: ['snack', 'snacks', 'chips', 'candy'],
      ExpenseSubCategory.drinks: ['drink', 'drinks', 'coffee', 'beer', 'soda'],
      ExpenseSubCategory.groceries: ['groceries', 'grocery', 'supermarket'],
      ExpenseSubCategory.fastFood: [
        'fast food',
        'mcdonald',
        'burger king',
        'kfc'
      ],
      ExpenseSubCategory.flights: ['flight', 'plane', 'airline', 'airport'],
      ExpenseSubCategory.taxis: ['taxi', 'cab'],
      ExpenseSubCategory.rideshare: ['uber', 'lyft', 'ride share'],
      ExpenseSubCategory.fuel: ['gas', 'fuel', 'gasoline'],
      ExpenseSubCategory.parking: ['parking', 'park'],
      ExpenseSubCategory.hotels: ['hotel', 'motel'],
      ExpenseSubCategory.airbnb: ['airbnb', 'air bnb'],
      ExpenseSubCategory.movies: ['movie', 'cinema', 'theater'],
      ExpenseSubCategory.clothing: ['clothes', 'clothing', 'shirt', 'shoes'],
      ExpenseSubCategory.pharmacy: ['pharmacy', 'drugstore', 'medicine'],
    };

    for (final subCategory in subCategoryKeywords.keys) {
      final keywords = subCategoryKeywords[subCategory]!;
      if (keywords.any((keyword) => _normalizedText.contains(keyword))) {
        return subCategory;
      }
    }

    return null;
  }

  String? extractMerchant() {
    // Look for common merchant indicators
    final patterns = [
      RegExp(r'at\s+([^,\s]+(?:\s+[^,\s]+)*)', caseSensitive: false),
      RegExp(r'from\s+([^,\s]+(?:\s+[^,\s]+)*)', caseSensitive: false),
      RegExp(r'in\s+([^,\s]+(?:\s+[^,\s]+)*)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final merchant = match.group(1)?.trim();
        if (merchant != null && merchant.length >= 2 && merchant.length <= 50) {
          return merchant;
        }
      }
    }

    return null;
  }

  PaymentMethod? extractPaymentMethod() {
    if (_normalizedText.contains('cash')) return PaymentMethod.cash;
    if (_normalizedText.contains('credit card') ||
        _normalizedText.contains('card')) {
      return PaymentMethod.creditCard;
    }
    if (_normalizedText.contains('debit')) return PaymentMethod.debitCard;
    if (_normalizedText.contains('paypal') ||
        _normalizedText.contains('venmo') ||
        _normalizedText.contains('digital wallet')) {
      return PaymentMethod.digitalWallet;
    }
    if (_normalizedText.contains('bank transfer') ||
        _normalizedText.contains('transfer')) {
      return PaymentMethod.bankTransfer;
    }

    return null;
  }

  String? extractNotes() {
    // Extract additional context that wasn't parsed into specific fields
    final cleanText = text.replaceAll(RegExp(r'\$\d+(?:\.\d{2})?'), '').trim();

    if (cleanText.length > 10) {
      return cleanText;
    }

    return null;
  }

  List<String> extractTags() {
    final tags = <String>[];

    // Look for hashtags
    final hashtagPattern = RegExp(r'#(\w+)');
    final hashtagMatches = hashtagPattern.allMatches(text);
    for (final match in hashtagMatches) {
      final tag = match.group(1);
      if (tag != null) {
        tags.add(tag);
      }
    }

    // Add category-based tags
    final category = extractCategory();
    if (category != null) {
      tags.add(category.toString().split('.').last);
    }

    return tags;
  }

  List<String> getSuggestions() {
    final suggestions = <String>[];

    // Add parsing suggestions
    if (extractAmount() == null) {
      suggestions.add(
          'Could not detect amount. Try saying "fifty dollars" or "\$50".');
    }

    if (extractCategory() == null) {
      suggestions.add(
          'Category not detected. Try adding words like "food", "gas", or "shopping".');
    }

    if (extractMerchant() == null) {
      suggestions.add(
          'Merchant not detected. Try saying "at Starbucks" or "from Amazon".');
    }

    return suggestions;
  }

  double? _convertWordsToNumber() {
    final numberWords = {
      'zero': 0,
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10,
      'eleven': 11,
      'twelve': 12,
      'thirteen': 13,
      'fourteen': 14,
      'fifteen': 15,
      'sixteen': 16,
      'seventeen': 17,
      'eighteen': 18,
      'nineteen': 19,
      'twenty': 20,
      'thirty': 30,
      'forty': 40,
      'fifty': 50,
      'sixty': 60,
      'seventy': 70,
      'eighty': 80,
      'ninety': 90,
      'hundred': 100,
      'thousand': 1000,
    };

    final words = _normalizedText.split(' ');
    for (final word in words) {
      if (numberWords.containsKey(word)) {
        return numberWords[word]?.toDouble();
      }
    }

    return null;
  }
}
