import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_planner/widgets/ui_components.dart';

class ExpenseDetailScreen extends ConsumerWidget {
  final String tripId;
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.tripId, required this.expenseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, you would fetch the specific expense details here.
    // For this example, we'll use mock data.
    const double mockAmount = 150.0;
    const String mockCurrency = 'USD';

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Amount: $mockAmount $mockCurrency', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Convert Currency',
              onPressed: () {
                context.go(
                  '/currency-converter',
                  extra: {
                    'amount': mockAmount,
                    'from': mockCurrency,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}