import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/services/currency_service.dart';

class CurrencyState {
  final Map<String, double> rates;
  final bool isLoading;
  final String? error;

  CurrencyState({this.rates = const {}, this.isLoading = true, this.error});

  CurrencyState copyWith({Map<String, double>? rates, bool? isLoading, String? error, bool clearError = false}) {
    return CurrencyState(
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final CurrencyService _currencyService;
  CurrencyNotifier(this._currencyService) : super(CurrencyState()) {
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    try {
      final rates = await _currencyService.getExchangeRates();
      if (!rates.containsKey('USD')) {
        rates['USD'] = 1.0;
      }
      state = state.copyWith(rates: rates, isLoading: false, clearError: true);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load rates. Please check your connection.', isLoading: false);
    }
  }

  double convertCurrency(double amount, String from, String to) {
    if (state.rates.isEmpty || !state.rates.containsKey(from) || !state.rates.containsKey(to)) {
      return 0.0;
    }
    double amountInUsd = amount / state.rates[from]!;
    double convertedAmount = amountInUsd * state.rates[to]!;
    return convertedAmount;
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  // You could use ref.watch here if your service was also in a provider
  return CurrencyNotifier(CurrencyService());
});