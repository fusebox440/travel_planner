import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Exception thrown when currency conversion fails
class CurrencyConversionException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  CurrencyConversionException(this.message, {this.code, this.originalError});

  @override
  String toString() =>
      'CurrencyConversionException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Currency information including name, symbol, and flag
class Currency {
  final String code;
  final String name;
  final String symbol;
  final String flag;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
  });
}

class CurrencyService {
  CurrencyService._privateConstructor();
  static final CurrencyService _instance =
      CurrencyService._privateConstructor();
  factory CurrencyService() => _instance;

  static const _ratesCacheKey = 'currency_rates';
  static const _timestampCacheKey = 'currency_rates_timestamp';
  static const _favoritesCacheKey = 'favorite_currencies';
  static const _apiUrl = 'https://api.exchangerate.host/latest';
  static const _fallbackApiUrl = 'https://api.exchangeratesapi.io/latest';

  /// Round a number to a specific precision
  double _roundToPrecision(double value, int precision) {
    final mod = pow(10.0, precision);
    return (value * mod).round() / mod;
  }

  /// Cache the current exchange rates
  Future<void> _cacheRates(Map<String, double> rates, int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ratesCacheKey, jsonEncode(rates));
    await prefs.setInt(_timestampCacheKey, timestamp);
  }

  /// Load exchange rates from cache
  Future<Map<String, double>> _loadRatesFromCache() async {
    if (_cachedRates.isNotEmpty) return _cachedRates;

    final prefs = await SharedPreferences.getInstance();
    final ratesString = prefs.getString(_ratesCacheKey);
    if (ratesString != null) {
      final rates = (jsonDecode(ratesString) as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      _cachedRates = rates;
      return rates;
    }
    throw CurrencyConversionException(
      'No cached rates available',
      code: 'NO_CACHE',
    );
  }

  Map<String, double> _cachedRates = {};
  Set<String> _favoriteCurrencies = {};
  bool _isInitialized = false;

  static const _supportedCurrencies = {
    'USD': Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸'),
    'EUR': Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
    'GBP':
        Currency(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧'),
    'JPY':
        Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵'),
    'AUD': Currency(
        code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', flag: '🇦🇺'),
    'CAD': Currency(
        code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', flag: '🇨🇦'),
    'CHF':
        Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr', flag: '🇨🇭'),
    'CNY':
        Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳'),
    'INR':
        Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳'),
    'NZD': Currency(
        code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', flag: '🇳🇿'),
    'SGD': Currency(
        code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', flag: '🇸🇬'),
    'HKD': Currency(
        code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', flag: '🇭🇰'),
    'KRW': Currency(
        code: 'KRW', name: 'South Korean Won', symbol: '₩', flag: '🇰🇷'),
  };

  List<String> get availableCurrencies => _supportedCurrencies.keys.toList();
  List<Currency> get availableCurrencyInfo =>
      _supportedCurrencies.values.toList();
  Set<String> get favoriteCurrencies => _favoriteCurrencies;

  /// Initialize the service and load cached data
  Future<void> init() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    // Load favorite currencies
    final favorites = prefs.getStringList(_favoritesCacheKey);
    if (favorites != null) {
      _favoriteCurrencies = favorites.toSet();
    } else {
      // Default favorites
      _favoriteCurrencies = {'USD', 'EUR', 'GBP'}.toSet();
      await prefs.setStringList(
          _favoritesCacheKey, _favoriteCurrencies.toList());
    }

    // Load cached rates
    await _loadRatesFromCache();
    _isInitialized = true;
  }

  /// Get current exchange rates, with fallback and caching
  /// Get current exchange rates with automatic fallback and caching.
  ///
  /// This method will:
  /// 1. Check if cached rates are still valid (less than 24 hours old)
  /// 2. If cache is expired, try the primary exchange rate API
  /// 3. If primary API fails, try the fallback API
  /// 4. If both APIs fail, use cached rates
  ///
  /// @param base The base currency code (default: USD)
  /// @throws CurrencyConversionException if both APIs fail and no cache is available
  Future<Map<String, double>> getExchangeRates({String base = 'USD'}) async {
    if (!_isInitialized) await init();

    final prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getInt(_timestampCacheKey);
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check if cache is expired (24 hours)
    if (lastFetchTimestamp == null ||
        (now - lastFetchTimestamp > 24 * 60 * 60 * 1000)) {
      debugPrint("Fetching fresh currency rates from API...");
      try {
        // Try primary API
        final response = await http
            .get(Uri.parse('$_apiUrl?base=$base'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final rates = (data['rates'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );
          await _cacheRates(rates, now);
          _cachedRates = rates;
          return rates;
        }
        throw CurrencyConversionException(
          'Primary API failed with status: ${response.statusCode}',
          code: 'API_ERROR',
        );
      } catch (e) {
        debugPrint("Primary API failed, trying fallback. Error: $e");
        try {
          // Try fallback API
          final response = await http
              .get(Uri.parse('$_fallbackApiUrl?base=$base'))
              .timeout(const Duration(seconds: 5));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final rates = (data['rates'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            );
            await _cacheRates(rates, now);
            _cachedRates = rates;
            return rates;
          }
          throw CurrencyConversionException(
            'Fallback API failed with status: ${response.statusCode}',
            code: 'FALLBACK_API_ERROR',
          );
        } catch (fallbackError) {
          debugPrint("Fallback API failed, using cache. Error: $fallbackError");
          // If both APIs fail, try to use cache
          try {
            return await _loadRatesFromCache();
          } catch (cacheError) {
            throw CurrencyConversionException(
              'All exchange rate sources failed. Try again later.',
              code: 'ALL_SOURCES_FAILED',
              originalError: fallbackError,
            );
          }
        }
      }
    }

    debugPrint("Using cached currency rates.");
    return await _loadRatesFromCache();
  }

  /// Convert amount from one currency to another
  Future<double> convert(double amount, String from, String to) async {
    if (!_supportedCurrencies.containsKey(from)) {
      throw CurrencyConversionException(
        'Unsupported source currency: $from',
        code: 'UNSUPPORTED_CURRENCY',
      );
    }
    if (!_supportedCurrencies.containsKey(to)) {
      throw CurrencyConversionException(
        'Unsupported target currency: $to',
        code: 'UNSUPPORTED_CURRENCY',
      );
    }

    try {
      final rates = await getExchangeRates(base: from);
      if (!rates.containsKey(to)) {
        throw CurrencyConversionException(
          'No conversion rate available for $from to $to',
          code: 'RATE_NOT_FOUND',
        );
      }

      final rate = rates[to]!;
      // Round to 2 decimal places for most currencies, 0 for JPY and KRW
      final precision = (to == 'JPY' || to == 'KRW') ? 0 : 2;
      return _roundToPrecision(amount * rate, precision);
    } catch (e) {
      if (e is CurrencyConversionException) rethrow;
      throw CurrencyConversionException(
        'Failed to convert currency',
        code: 'CONVERSION_ERROR',
        originalError: e,
      );
    }
  }

  /// Get the currency info for a given currency code
  Currency? getCurrencyInfo(String code) => _supportedCurrencies[code];

  /// Format amount in the given currency with proper symbol
  String formatAmount(double amount, String currencyCode) {
    final currency = getCurrencyInfo(currencyCode);
    if (currency == null) return amount.toString();

    final precision = (currencyCode == 'JPY' || currencyCode == 'KRW') ? 0 : 2;
    final formattedAmount =
        _roundToPrecision(amount, precision).toStringAsFixed(precision);

    // Place symbol based on currency convention
    switch (currencyCode) {
      case 'USD':
      case 'AUD':
      case 'CAD':
      case 'NZD':
      case 'SGD':
      case 'HKD':
        return '${currency.symbol}$formattedAmount';
      case 'EUR':
        return '$formattedAmount${currency.symbol}';
      default:
        return '$formattedAmount ${currency.symbol}';
    }
  }

  /// Add a currency to favorites
  Future<void> addToFavorites(String currencyCode) async {
    if (!_supportedCurrencies.containsKey(currencyCode)) {
      throw CurrencyConversionException(
        'Unsupported currency: $currencyCode',
        code: 'UNSUPPORTED_CURRENCY',
      );
    }

    _favoriteCurrencies.add(currencyCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesCacheKey, _favoriteCurrencies.toList());
  }

  /// Remove a currency from favorites
  Future<void> removeFromFavorites(String currencyCode) async {
    _favoriteCurrencies.remove(currencyCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesCacheKey, _favoriteCurrencies.toList());
  }
}
