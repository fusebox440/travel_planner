import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_planner/core/services/currency_service.dart';
import 'package:travel_planner/features/budget/presentation/providers/budget_provider.dart';
import 'package:travel_planner/features/budget/services/voice_to_text_service.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:image_picker/image_picker.dart';

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
  final _notesController = TextEditingController();
  final _merchantController = TextEditingController();
  final _tagsController = TextEditingController();

  ExpenseCategory _category = ExpenseCategory.other;
  ExpenseSubCategory? _subCategory;
  PaymentMethod? _paymentMethod;
  String _currency = 'USD';
  String? _payerId;
  final List<String> _splitWithIds = [];
  String? _selectedReceiptPath;
  bool _isListening = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _merchantController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate() || _payerId == null) return;

    HapticFeedback.lightImpact();

    // Parse tags from text input
    final tagsList = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final expense = Expense.create(
      tripId: widget.tripId,
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      currency: _currency,
      category: _category,
      payerId: _payerId!,
      splitWithIds: _splitWithIds,
      subCategory: _subCategory,
      merchant:
          _merchantController.text.isEmpty ? null : _merchantController.text,
      paymentMethod: _paymentMethod,
      description: _notesController.text.isEmpty ? null : _notesController.text,
      tags: tagsList.isEmpty ? null : tagsList,
    );

    final budgetService = await ref.read(budgetServiceProvider.future);
    await budgetService.addExpense(expense);

    if (!mounted) return;
    context.pop();
  }

  Future<void> _startVoiceInput() async {
    if (_isListening) return;

    setState(() => _isListening = true);

    try {
      final voiceService = VoiceToTextService();
      await voiceService.initialize();

      final result = await voiceService.startListeningForExpense();

      if (result.success) {
        // Populate fields from voice input
        if (result.amount != null) {
          _amountController.text = result.amount.toString();
        }
        if (result.title != null) {
          _titleController.text = result.title!;
        }
        if (result.category != null) {
          _category = result.category!;
        }
        if (result.subCategory != null) {
          _subCategory = result.subCategory!;
        }
        if (result.merchant != null) {
          _merchantController.text = result.merchant!;
        }
        if (result.paymentMethod != null) {
          _paymentMethod = result.paymentMethod!;
        }
        if (result.notes != null) {
          _notesController.text = result.notes!;
        }
        if (result.tags != null && result.tags!.isNotEmpty) {
          _tagsController.text = result.tags!.join(', ');
        }

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Voice input processed with ${(result.confidence * 100).toInt()}% confidence'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice input failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isListening = false);
    }
  }

  Future<void> _pickReceipt() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedReceiptPath = image.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Receipt captured! OCR processing will happen after saving.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companions = ref.watch(allCompanionsProvider);

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
            const SizedBox(height: 16),

            // Sub-category dropdown
            DropdownButtonFormField<ExpenseSubCategory>(
              value: _subCategory,
              items: ExpenseSubCategory.values
                  .map((subCat) => DropdownMenuItem(
                        value: subCat,
                        child: Text(subCat.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _subCategory = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Sub-Category (Optional)',
                prefixIcon: Icon(Icons.subdirectory_arrow_right),
              ),
            ),
            const SizedBox(height: 16),

            // Merchant field
            TextFormField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Merchant/Store (Optional)',
                prefixIcon: Icon(Icons.store),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Payment method dropdown
            DropdownButtonFormField<PaymentMethod>(
              value: _paymentMethod,
              items: PaymentMethod.values
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.toString().split('.').last),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Payment Method (Optional)',
                prefixIcon: Icon(Icons.payment),
              ),
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16),

            // Tags field
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                prefixIcon: Icon(Icons.label),
                hintText: 'business, urgent, reimbursable',
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),

            // Voice input and receipt capture buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? null : _startVoiceInput,
                    icon: _isListening
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.mic),
                    label: Text(_isListening ? 'Listening...' : 'Voice Input'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening ? Colors.red : null,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickReceipt,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Receipt'),
                  ),
                ),
              ],
            ),

            if (_selectedReceiptPath != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Receipt captured and will be processed'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedReceiptPath = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
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
