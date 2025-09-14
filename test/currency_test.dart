import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/core/services/currency_service.dart';
import 'package:travel_planner/features/currency/presentation/providers/currency_provider.dart';

// Create a mock of the service, not the notifier.
class MockCurrencyService implements CurrencyService {
  final bool shouldFail;
  MockCurrencyService({this.shouldFail = false});

  @override
  Future<Map<String, double>> getExchangeRates({String base = 'USD'}) async {
    if (shouldFail) {
      throw Exception('Failed to fetch');
    }
    // Return a fixed set of rates for predictable testing.
    return {
      'EUR': 0.9,
      'INR': 83.0,
      'JPY': 150.0,
    };
  }

  @override
  List<String> get availableCurrencies => ['USD', 'EUR', 'GBP', 'JPY'];

  @override
  List<Currency> get availableCurrencyInfo => [
        Currency(code: 'USD', name: 'US Dollar', symbol: '\$', flag: '🇺🇸'),
        Currency(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺'),
      ];

  @override
  Set<String> get favoriteCurrencies => {'USD', 'EUR'};

  @override
  Future<void> init() async {}

  @override
  Future<void> addToFavorites(String currencyCode) async {}

  @override
  Future<void> removeFromFavorites(String currencyCode) async {}

  @override
  Future<double> convert(double amount, String from, String to) async =>
      amount * 0.9;

  @override
  String formatAmount(double amount, String currencyCode) =>
      '\$${amount.toStringAsFixed(2)}';

  @override
  Currency? getCurrencyInfo(String currencyCode) {
    return Currency(
        code: currencyCode, name: 'Test Currency', symbol: '\$', flag: '🏳️');
  }
}

void main() {
  group('CurrencyNotifier', () {
    test('correctly converts currency pairs on successful fetch', () async {
      // Arrange: Create the notifier with the successful mock service.
      final notifier = CurrencyNotifier(MockCurrencyService());
      // Act: Wait for the async _fetchRates to complete.
      await Future.delayed(Duration.zero);

      // Assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, null);
      expect(notifier.state.rates.containsKey('USD'),
          true); // USD is added automatically

      // Act & Assert for conversions
      final usdToInr = notifier.convertCurrency(10, 'USD', 'INR');
      expect(usdToInr, closeTo(830.0, 0.01));

      final eurToJpy = notifier.convertCurrency(100, 'EUR', 'JPY');
      expect(eurToJpy, closeTo(16666.67, 0.01));
    });

    test('sets an error state when the service fails', () async {
      // Arrange: Create the notifier with the failing mock service.
      final notifier = CurrencyNotifier(MockCurrencyService(shouldFail: true));
      // Act: Wait for the async _fetchRates to complete.
      await Future.delayed(Duration.zero);

      // Assert
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNotNull);
      expect(notifier.state.rates, isEmpty);
    });
  });
}
