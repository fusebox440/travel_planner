import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/currency/presentation/providers/currency_provider.dart';
import 'package:travel_planner/widgets/ui_components.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  final double? initialAmount;
  final String? fromCurrency;

  const CurrencyConverterScreen({super.key, this.initialAmount, this.fromCurrency});

  @override
  ConsumerState<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends ConsumerState<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';
  double _convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount.toString();
    }
    if (widget.fromCurrency != null) {
      _fromCurrency = widget.fromCurrency!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convert() {
    HapticFeedback.lightImpact();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount > 0) {
      final result = ref.read(currencyProvider.notifier).convertCurrency(amount, _fromCurrency, _toCurrency);
      setState(() {
        _convertedAmount = result;
      });
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = ref.watch(currencyProvider);
    final theme = Theme.of(context);

    // This UI logic is now robust enough to handle the error state
    if (currencyState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Currency Converter')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (currencyState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Currency Converter')),
        body: Center(child: Text(currencyState.error!)),
      );
    }

    final currencyCodes = currencyState.rates.keys.toSet().toList()..sort();

    if (!currencyCodes.contains(_fromCurrency)) _fromCurrency = currencyCodes.isNotEmpty ? currencyCodes.first : '';
    if (!currencyCodes.contains(_toCurrency)) _toCurrency = currencyCodes.length > 1 ? currencyCodes[1] : (currencyCodes.isNotEmpty ? currencyCodes.first : '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormInput(
              label: 'Amount',
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildCurrencyDropdown('From', _fromCurrency, currencyCodes, (val) => setState(() => _fromCurrency = val!))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.swap_horiz),
                ),
                Expanded(child: _buildCurrencyDropdown('To', _toCurrency, currencyCodes, (val) => setState(() => _toCurrency = val!))),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(text: 'Convert', onPressed: _convert),
            const SizedBox(height: 24),
            if (_convertedAmount > 0)
              Text(
                'Result: ${_convertedAmount.toStringAsFixed(2)} $_toCurrency',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          items: items.map((code) => DropdownMenuItem(value: code, child: Text(code))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}