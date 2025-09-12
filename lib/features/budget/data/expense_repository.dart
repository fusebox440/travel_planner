import 'package:hive/hive.dart';
import '../../../src/models/expense.dart';
import '../models/receipt.dart';
import 'receipt_repository.dart';

abstract class ExpenseRepository {
  Future<Expense> createExpense(Expense expense);
  Future<Expense?> getExpenseById(String id);
  Future<List<Expense>> getExpensesByTripId(String tripId);
  Future<List<Expense>> getAllExpenses();

  Future<Expense> updateExpense(Expense expense);
  Future<bool> deleteExpense(String id);

  // Enhanced search and filtering
  Future<List<Expense>> searchExpenses({
    String? query,
    List<ExpenseCategory>? categories,
    List<ExpenseSubCategory>? subCategories,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? merchant,
    List<String>? tags,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
  });

  // Analytics and aggregation
  Future<Map<ExpenseCategory, double>> getTotalsByCategory({String? tripId});
  Future<Map<ExpenseSubCategory, double>> getTotalsBySubCategory(
      {String? tripId});
  Future<Map<String, double>> getTotalsByMerchant({String? tripId});
  Future<Map<PaymentMethod, double>> getTotalsByPaymentMethod({String? tripId});

  // Receipt management
  Future<List<Receipt>> getReceiptsForExpense(String expenseId);
  Future<Expense> attachReceiptToExpense(String expenseId, String receiptId);
  Future<Expense> detachReceiptFromExpense(String expenseId, String receiptId);

  // Export functionality
  Future<List<Map<String, dynamic>>> getExpensesForExport({
    DateTime? startDate,
    DateTime? endDate,
    List<ExpenseCategory>? categories,
    String? tripId,
  });

  Future<void> clearAll();
}

class HiveExpenseRepository implements ExpenseRepository {
  static const String _boxName = 'expenses';
  late final Box<Expense> _box;
  final ReceiptRepository _receiptRepository;

  HiveExpenseRepository({required ReceiptRepository receiptRepository})
      : _receiptRepository = receiptRepository;

  Future<void> initialize() async {
    _box = await Hive.openBox<Expense>(_boxName);
  }

  @override
  Future<Expense> createExpense(Expense expense) async {
    await _box.put(expense.id, expense);
    return expense;
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    return _box.get(id);
  }

  @override
  Future<List<Expense>> getExpensesByTripId(String tripId) async {
    return _box.values.where((expense) => expense.tripId == tripId).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending
  }

  @override
  Future<List<Expense>> getAllExpenses() async {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Expense> updateExpense(Expense expense) async {
    await _box.put(expense.id, expense);
    return expense;
  }

  @override
  Future<bool> deleteExpense(String id) async {
    try {
      // Also delete associated receipts
      final expense = await getExpenseById(id);
      if (expense?.receiptIds != null) {
        for (final receiptId in expense!.receiptIds!) {
          await _receiptRepository.deleteReceipt(receiptId);
        }
      }

      await _box.delete(id);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Expense>> searchExpenses({
    String? query,
    List<ExpenseCategory>? categories,
    List<ExpenseSubCategory>? subCategories,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? merchant,
    List<String>? tags,
    PaymentMethod? paymentMethod,
    bool? isRecurring,
  }) async {
    return _box.values.where((expense) {
      // Text query filter
      if (query != null && query.isNotEmpty) {
        final queryLower = query.toLowerCase();
        if (!expense.title.toLowerCase().contains(queryLower) &&
            !(expense.note?.toLowerCase().contains(queryLower) ?? false) &&
            !(expense.merchant?.toLowerCase().contains(queryLower) ?? false) &&
            !(expense.description?.toLowerCase().contains(queryLower) ??
                false)) {
          return false;
        }
      }

      // Category filter
      if (categories != null && categories.isNotEmpty) {
        if (!categories.contains(expense.category)) return false;
      }

      // Sub-category filter
      if (subCategories != null && subCategories.isNotEmpty) {
        if (expense.subCategory == null ||
            !subCategories.contains(expense.subCategory)) {
          return false;
        }
      }

      // Amount filter
      if (minAmount != null && expense.amount < minAmount) return false;
      if (maxAmount != null && expense.amount > maxAmount) return false;

      // Date filter
      if (startDate != null && expense.date.isBefore(startDate)) return false;
      if (endDate != null && expense.date.isAfter(endDate)) return false;

      // Merchant filter
      if (merchant != null && merchant.isNotEmpty) {
        if (expense.merchant == null ||
            !expense.merchant!.toLowerCase().contains(merchant.toLowerCase())) {
          return false;
        }
      }

      // Tags filter
      if (tags != null && tags.isNotEmpty) {
        if (expense.tags == null ||
            !tags.any((tag) => expense.tags!.contains(tag))) {
          return false;
        }
      }

      // Payment method filter
      if (paymentMethod != null && expense.paymentMethod != paymentMethod) {
        return false;
      }

      // Recurring filter
      if (isRecurring != null && expense.isRecurring != isRecurring) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<Map<ExpenseCategory, double>> getTotalsByCategory(
      {String? tripId}) async {
    final totals = <ExpenseCategory, double>{};

    // Initialize all categories with 0
    for (final category in ExpenseCategory.values) {
      totals[category] = 0.0;
    }

    final expenses = tripId != null
        ? await getExpensesByTripId(tripId)
        : await getAllExpenses();

    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }

    return totals;
  }

  @override
  Future<Map<ExpenseSubCategory, double>> getTotalsBySubCategory(
      {String? tripId}) async {
    final totals = <ExpenseSubCategory, double>{};

    final expenses = tripId != null
        ? await getExpensesByTripId(tripId)
        : await getAllExpenses();

    for (final expense in expenses) {
      if (expense.subCategory != null) {
        totals[expense.subCategory!] =
            (totals[expense.subCategory!] ?? 0.0) + expense.amount;
      }
    }

    return totals;
  }

  @override
  Future<Map<String, double>> getTotalsByMerchant({String? tripId}) async {
    final totals = <String, double>{};

    final expenses = tripId != null
        ? await getExpensesByTripId(tripId)
        : await getAllExpenses();

    for (final expense in expenses) {
      if (expense.merchant != null && expense.merchant!.isNotEmpty) {
        totals[expense.merchant!] =
            (totals[expense.merchant!] ?? 0.0) + expense.amount;
      }
    }

    return totals;
  }

  @override
  Future<Map<PaymentMethod, double>> getTotalsByPaymentMethod(
      {String? tripId}) async {
    final totals = <PaymentMethod, double>{};

    // Initialize all payment methods with 0
    for (final method in PaymentMethod.values) {
      totals[method] = 0.0;
    }

    final expenses = tripId != null
        ? await getExpensesByTripId(tripId)
        : await getAllExpenses();

    for (final expense in expenses) {
      if (expense.paymentMethod != null) {
        totals[expense.paymentMethod!] =
            (totals[expense.paymentMethod!] ?? 0.0) + expense.amount;
      }
    }

    return totals;
  }

  @override
  Future<List<Receipt>> getReceiptsForExpense(String expenseId) async {
    return await _receiptRepository.getReceiptsByExpenseId(expenseId);
  }

  @override
  Future<Expense> attachReceiptToExpense(
      String expenseId, String receiptId) async {
    final expense = await getExpenseById(expenseId);
    if (expense == null) {
      throw Exception('Expense not found');
    }

    final updatedReceiptIds = <String>[...(expense.receiptIds ?? [])];
    if (!updatedReceiptIds.contains(receiptId)) {
      updatedReceiptIds.add(receiptId);
    }

    final updatedExpense = expense.copyWith(receiptIds: updatedReceiptIds);
    return await updateExpense(updatedExpense);
  }

  @override
  Future<Expense> detachReceiptFromExpense(
      String expenseId, String receiptId) async {
    final expense = await getExpenseById(expenseId);
    if (expense == null) {
      throw Exception('Expense not found');
    }

    final updatedReceiptIds = [...(expense.receiptIds ?? [])]
      ..remove(receiptId);

    final updatedExpense = expense.copyWith(receiptIds: updatedReceiptIds);
    return await updateExpense(updatedExpense);
  }

  @override
  Future<List<Map<String, dynamic>>> getExpensesForExport({
    DateTime? startDate,
    DateTime? endDate,
    List<ExpenseCategory>? categories,
    String? tripId,
  }) async {
    final expenses = await searchExpenses(
      startDate: startDate,
      endDate: endDate,
      categories: categories,
    );

    final filteredExpenses = tripId != null
        ? expenses.where((expense) => expense.tripId == tripId).toList()
        : expenses;

    return filteredExpenses.map((expense) {
      final data = expense.toJson();

      // Add additional fields for export
      data['categoryName'] = expense.category.toString().split('.').last;
      data['subCategoryName'] = expense.subCategory?.toString().split('.').last;
      data['paymentMethodName'] =
          expense.paymentMethod?.toString().split('.').last;

      // Format date for better readability
      data['dateFormatted'] =
          "${expense.date.day}/${expense.date.month}/${expense.date.year}";

      return data;
    }).toList();
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _receiptRepository.clearAll();
  }

  // Additional helper methods

  Future<List<Expense>> getRecentExpenses({int limit = 10}) async {
    final expenses = await getAllExpenses();
    return expenses.take(limit).toList();
  }

  Future<double> getTotalAmount(
      {String? tripId, DateTime? startDate, DateTime? endDate}) async {
    final expenses = tripId != null
        ? await getExpensesByTripId(tripId)
        : await getAllExpenses();

    final filteredExpenses = expenses.where((expense) {
      if (startDate != null && expense.date.isBefore(startDate)) return false;
      if (endDate != null && expense.date.isAfter(endDate)) return false;
      return true;
    });

    return filteredExpenses.fold<double>(
        0.0, (sum, expense) => sum + expense.amount);
  }

  Future<List<String>> getAllMerchants() async {
    final merchants = <String>{};

    for (final expense in _box.values) {
      if (expense.merchant != null && expense.merchant!.isNotEmpty) {
        merchants.add(expense.merchant!);
      }
    }

    return merchants.toList()..sort();
  }

  Future<List<String>> getAllTags() async {
    final tags = <String>{};

    for (final expense in _box.values) {
      if (expense.tags != null) {
        tags.addAll(expense.tags!);
      }
    }

    return tags.toList()..sort();
  }

  Future<Map<String, int>> getExpenseCountsByMonth({String? tripId}) async {
    final expenses = tripId != null
        ? await getExpensesByTripId(tripId)
        : await getAllExpenses();

    final counts = <String, int>{};

    for (final expense in expenses) {
      final monthKey =
          "${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}";
      counts[monthKey] = (counts[monthKey] ?? 0) + 1;
    }

    return counts;
  }
}
