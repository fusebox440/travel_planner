import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_planner/features/budget/presentation/providers/budget_provider.dart';
import 'package:travel_planner/features/budget/services/export_service.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:travel_planner/widgets/empty_state_widget.dart';
import 'package:travel_planner/widgets/skeletons.dart';
import 'package:fl_chart/fl_chart.dart';

class BudgetOverviewScreen extends ConsumerStatefulWidget {
  final String tripId;
  const BudgetOverviewScreen({super.key, required this.tripId});

  @override
  ConsumerState<BudgetOverviewScreen> createState() =>
      _BudgetOverviewScreenState();
}

class _BudgetOverviewScreenState extends ConsumerState<BudgetOverviewScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ExpenseCategory? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod;
  DateTimeRange? _dateRange;
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Expenses'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category filter
                DropdownButtonFormField<ExpenseCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: [
                    const DropdownMenuItem<ExpenseCategory>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...ExpenseCategory.values.map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.toString().split('.').last),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Payment method filter
                DropdownButtonFormField<PaymentMethod>(
                  value: _selectedPaymentMethod,
                  decoration: const InputDecoration(
                    labelText: 'Payment Method',
                    prefixIcon: Icon(Icons.payment),
                  ),
                  items: [
                    const DropdownMenuItem<PaymentMethod>(
                      value: null,
                      child: Text('All Payment Methods'),
                    ),
                    ...PaymentMethod.values.map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.toString().split('.').last),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedPaymentMethod = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Date range filter
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: Text(_dateRange == null
                      ? 'All Dates'
                      : '${DateFormat.MMMd().format(_dateRange!.start)} - ${DateFormat.MMMd().format(_dateRange!.end)}'),
                  onTap: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      initialDateRange: _dateRange,
                    );
                    if (range != null) {
                      setDialogState(() {
                        _dateRange = range;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setDialogState(() {
                  _selectedCategory = null;
                  _selectedPaymentMethod = null;
                  _dateRange = null;
                });
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Trigger rebuild with new filters
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportExpenses() async {
    try {
      final exportService = ExportService();

      // Show export options dialog
      final format = await showDialog<ExportFormat>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Format'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                onTap: () => Navigator.pop(context, ExportFormat.csv),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('PDF'),
                onTap: () => Navigator.pop(context, ExportFormat.pdf),
              ),
            ],
          ),
        ),
      );

      if (format != null) {
        ExportResult result;

        if (format == ExportFormat.csv) {
          result = await exportService.exportToCSV(
            tripId: widget.tripId,
            startDate: _dateRange?.start,
            endDate: _dateRange?.end,
            categories: _selectedCategory != null ? [_selectedCategory!] : null,
          );
        } else {
          result = await exportService.exportToPDF(
            tripId: widget.tripId,
            startDate: _dateRange?.start,
            endDate: _dateRange?.end,
            categories: _selectedCategory != null ? [_selectedCategory!] : null,
          );
        }

        if (result.success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Exported ${result.recordCount} expenses to ${result.fileName}'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    return expenses.where((expense) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchMatch = (expense.description
                    ?.toLowerCase()
                    .contains(_searchQuery) ==
                true) ||
            expense.merchant?.toLowerCase().contains(_searchQuery) == true ||
            (expense.tags
                    ?.any((tag) => tag.toLowerCase().contains(_searchQuery)) ==
                true);

        if (!searchMatch) return false;
      }

      // Category filter
      if (_selectedCategory != null && expense.category != _selectedCategory) {
        return false;
      }

      // Payment method filter
      if (_selectedPaymentMethod != null &&
          expense.paymentMethod != _selectedPaymentMethod) {
        return false;
      }

      // Date range filter
      if (_dateRange != null) {
        final expenseDate = expense.date;
        if (expenseDate.isBefore(_dateRange!.start) ||
            expenseDate.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(tripExpensesProvider(widget.tripId));
    final currency = 'USD'; // TODO: Make this configurable per trip

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showSearch = false;
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                autofocus: true,
              )
            : const Text('Budget Overview'),
        actions: [
          if (!_showSearch) ...[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _showSearch = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: _exportExpenses,
            ),
            IconButton(
              icon: const Icon(Icons.group),
              tooltip: 'Manage Companions',
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/trip/${widget.tripId}/budget/manage-companions');
              },
            ),
          ],
          if (_showSearch)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearch = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          final filteredExpenses = _filterExpenses(expenses);

          if (expenses.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No Expenses Yet',
              description:
                  'Start tracking your trip expenses by adding your first one.',
            );
          }

          if (filteredExpenses.isEmpty && expenses.isNotEmpty) {
            return EmptyStateWidget(
              icon: Icons.search_off,
              title: 'No Matching Expenses',
              description: 'Try adjusting your search or filter criteria.',
            );
          }

          return Column(
            children: [
              // Show filter summary if filters are active
              if (_searchQuery.isNotEmpty ||
                  _selectedCategory != null ||
                  _selectedPaymentMethod != null ||
                  _dateRange != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      Text(
                        '${filteredExpenses.length} of ${expenses.length} expenses',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_searchQuery.isNotEmpty)
                        Chip(
                          label: Text('Search: $_searchQuery'),
                          onDeleted: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          deleteIconColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      if (_selectedCategory != null)
                        Chip(
                          label: Text(
                              'Category: ${_selectedCategory.toString().split('.').last}'),
                          onDeleted: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                          deleteIconColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      if (_selectedPaymentMethod != null)
                        Chip(
                          label: Text(
                              'Payment: ${_selectedPaymentMethod.toString().split('.').last}'),
                          onDeleted: () {
                            setState(() {
                              _selectedPaymentMethod = null;
                            });
                          },
                          deleteIconColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      if (_dateRange != null)
                        Chip(
                          label: Text(
                              'Date: ${DateFormat.MMMd().format(_dateRange!.start)} - ${DateFormat.MMMd().format(_dateRange!.end)}'),
                          onDeleted: () {
                            setState(() {
                              _dateRange = null;
                            });
                          },
                          deleteIconColor:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              _ExpenseChart(tripId: widget.tripId, currency: currency),
              const Divider(),
              Expanded(
                child: _ExpenseList(expenses: filteredExpenses),
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
          context.push('/trip/${widget.tripId}/budget/add-expense');
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
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    expense.description ?? 'Untitled Expense',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${expense.currency} ${expense.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getCategoryIcon(expense.category),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      expense.category.toString().split('.').last,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (expense.subCategory != null) ...[
                      const Text(' • '),
                      Text(
                        expense.subCategory.toString().split('.').last,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      DateFormat.MMMd().format(expense.date),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                if (expense.merchant != null ||
                    expense.paymentMethod != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (expense.merchant != null) ...[
                        Icon(
                          Icons.store,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expense.merchant!,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (expense.merchant != null &&
                          expense.paymentMethod != null)
                        const Text(' • '),
                      if (expense.paymentMethod != null) ...[
                        Icon(
                          _getPaymentMethodIcon(expense.paymentMethod!),
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          expense.paymentMethod.toString().split('.').last,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ],
                if (expense.tags?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 2.0,
                    children: expense.tags!
                        .take(3)
                        .map(
                          (tag) => Chip(
                            label: Text(
                              tag,
                              style: theme.textTheme.labelSmall,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
            onTap: () {
              // TODO: Navigate to expense detail/edit screen
            },
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
      case ExpenseCategory.healthcare:
        return Icons.local_hospital;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.business:
        return Icons.business;
      case ExpenseCategory.utilities:
        return Icons.electrical_services;
      case ExpenseCategory.insurance:
        return Icons.security;
      case ExpenseCategory.communication:
        return Icons.phone;
      case ExpenseCategory.emergencies:
        return Icons.warning;
      case ExpenseCategory.gifts:
        return Icons.card_giftcard;
      case ExpenseCategory.fees:
        return Icons.attach_money;
      case ExpenseCategory.custom:
        return Icons.edit;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.debitCard:
        return Icons.payment;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance;
      case PaymentMethod.digitalWallet:
        return Icons.wallet;
      case PaymentMethod.other:
        return Icons.more_horiz;
    }
  }
}
