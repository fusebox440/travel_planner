import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/budget/data/budget_service.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('Budget Feature Tests', () {
    late Box<Expense> expenseBox;
    late Box<Companion> companionBox;
    late BudgetService budgetService;

    setUpAll(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(ExpenseAdapter());
      Hive.registerAdapter(CompanionAdapter());
      Hive.registerAdapter(ExpenseCategoryAdapter());
      expenseBox = await Hive.openBox<Expense>('test_expenses');
      companionBox = await Hive.openBox<Companion>('test_companions');
      budgetService = await BudgetService.getInstance();
    });

    setUp(() async {
      await expenseBox.clear();
      await companionBox.clear();
    });

    test('Add expense to budget', () async {
      final expense = Expense.create(
        tripId: 'test_trip',
        title: 'Test Expense',
        amount: 100.0,
        currency: 'USD',
        category: ExpenseCategory.food,
        payerId: 'user1',
        splitWithIds: ['user2'],
      );

      await budgetService.addExpense(expense);

      final expenses = budgetService.getTripExpenses('test_trip');
      expect(expenses.length, 1);
      expect(expenses.first.amount, 100.0);
      expect(expenses.first.title, 'Test Expense');
      expect(expenses.first.category, ExpenseCategory.food);
    });

    test('Calculate category totals', () async {
      // Add multiple expenses in different categories
      await budgetService.addExpense(Expense.create(
        tripId: 'test_trip',
        title: 'Lunch',
        amount: 50.0,
        currency: 'USD',
        category: ExpenseCategory.food,
        payerId: 'user1',
        splitWithIds: ['user2'],
      ));

      await budgetService.addExpense(Expense.create(
        tripId: 'test_trip',
        title: 'Hotel',
        amount: 200.0,
        currency: 'USD',
        category: ExpenseCategory.accommodation,
        payerId: 'user1',
        splitWithIds: ['user2'],
      ));

      final totals =
          await budgetService.calculateCategoryTotals('test_trip', 'USD');
      expect(totals[ExpenseCategory.food], 50.0);
      expect(totals[ExpenseCategory.accommodation], 200.0);
      expect(totals[ExpenseCategory.entertainment], null);
    });

    test('Calculate split expenses', () async {
      await budgetService.addExpense(Expense.create(
        tripId: 'test_trip',
        title: 'Group Dinner',
        amount: 100.0,
        currency: 'USD',
        category: ExpenseCategory.food,
        payerId: 'user1',
        splitWithIds: ['user2', 'user3'],
      ));

      final balances =
          await budgetService.calculateBalances('test_trip', 'USD');

      // Payer paid 100 but owes 33.33 (split three ways)
      expect(balances['user1']?.toStringAsFixed(2), '66.67');
      // Other users owe 33.33 each
      expect(balances['user2']?.toStringAsFixed(2), '-33.33');
      expect(balances['user3']?.toStringAsFixed(2), '-33.33');
    });

    test('Currency conversion in expenses', () async {
      await budgetService.addExpense(Expense.create(
        tripId: 'test_trip',
        title: 'Lunch in EUR',
        amount: 50.0,
        currency: 'EUR',
        category: ExpenseCategory.food,
        payerId: 'user1',
        splitWithIds: ['user2'],
      ));

      final total = budgetService.calculateTripTotal('test_trip', 'USD');
      expect(total, isNotNull);
      expect(total, isPositive);
    });

    tearDownAll(() async {
      await expenseBox.deleteFromDisk();
      await companionBox.deleteFromDisk();
      budgetService.dispose();
    });
  });
}
