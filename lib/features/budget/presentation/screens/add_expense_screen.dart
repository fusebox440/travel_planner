import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_planner/core/services/currency_service.dart';
import 'package:travel_planner/features/budget/presentation/providers/budget_provider.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String tripId;
  const AddExpenseScreen({super.key, required this.tripId});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.other;
  String _currency = 'USD';
  String? _payerId;
  final List<String> _splitWithIds = [];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate() || _payerId == null) return;

    HapticFeedback.lightImpact();

    final expense = Expense.create(
      tripId: widget.tripId,
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      currency: _currency,
      category: _category,
      payerId: _payerId!,
      splitWithIds: _splitWithIds,
    );

    final budgetService = await ref.read(budgetServiceProvider.future);
    await budgetService.addExpense(expense);

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companions = ref.watch(tripCompanionsProvider(_splitWithIds));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    items: CurrencyService()
                        .availableCurrencies
                        .map((curr) => DropdownMenuItem(
                              value: curr,
                              child: Text(curr),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _currency = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ExpenseCategory>(
              value: _category,
              items: ExpenseCategory.values
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Split Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            companions.when(
              data: (companionsList) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _payerId,
                    items: companionsList
                        .map((comp) => DropdownMenuItem(
                              value: comp.id,
                              child: Text(comp.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _payerId = value;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Paid By',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select who paid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ...companionsList
                      .where((comp) => comp.id != _payerId)
                      .map((comp) => CheckboxListTile(
                            title: Text(comp.name),
                            value: _splitWithIds.contains(comp.id),
                            onChanged: (checked) {
                              setState(() {
                                if (checked ?? false) {
                                  _splitWithIds.add(comp.id);
                                } else {
                                  _splitWithIds.remove(comp.id);
                                }
                              });
                            },
                          ))
                      .toList(),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSubmit,
        icon: const Icon(Icons.save),
        label: const Text('Save Expense'),
      ),
    );
  }
}
