import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/features/budget/presentation/providers/budget_provider.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:travel_planner/widgets/empty_state_widget.dart';
import 'package:travel_planner/widgets/skeletons.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetOverviewScreen extends ConsumerWidget {
  final String tripId;
  const BudgetOverviewScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(tripExpensesProvider(tripId));
    final currency = 'USD'; // TODO: Make this configurable per trip

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Manage Companions',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/budget/$tripId/manage-companions');
            },
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No Expenses Yet',
              message:
                  'Start tracking your trip expenses by adding your first one.',
            );
          }

          return Column(
            children: [
              _ExpenseChart(tripId: tripId, currency: currency),
              const Divider(),
              Expanded(
                child: _ExpenseList(expenses: expenses),
              ),
            ],
          );
        },
        loading: () => const _LoadingState(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/budget/$tripId/add-expense');
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.7,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const Expanded(
          child: Column(
            children: [
              ActivityItemSkeleton(),
              ActivityItemSkeleton(),
              ActivityItemSkeleton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpenseChart extends ConsumerWidget {
  final String tripId;
  final String currency;

  const _ExpenseChart({required this.tripId, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryTotalsAsync = ref.watch(
      categoryTotalsProvider((tripId: tripId, currency: currency)),
    );

    return AspectRatio(
      aspectRatio: 1.7,
      child: categoryTotalsAsync.when(
        data: (totals) {
          final total = totals.values.fold(0.0, (sum, amount) => sum + amount);
          final sections = totals.entries.map((entry) {
            final percent = entry.value / total;
            return PieChartSectionData(
              value: entry.value,
              title:
                  '${(percent * 100).toStringAsFixed(1)}%\n${entry.key.name}',
              radius: 100,
              titleStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            );
          }).toList();

          return Container(
            margin: const EdgeInsets.all(16),
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 0,
                sectionsSpace: 2,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<Expense> expenses;

  const _ExpenseList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return ListTile(
          title: Text(expense.title),
          subtitle: Text(
            DateFormat.yMMMd().format(expense.date),
            style: theme.textTheme.bodySmall,
          ),
          trailing: Text(
            '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium,
          ),
          leading: Icon(
            _getCategoryIcon(expense.category),
            color: theme.colorScheme.primary,
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.accommodation:
        return Icons.hotel;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}
