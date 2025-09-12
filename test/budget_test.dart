import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/features/budget/data/budget_service.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('Budget Feature Tests', () {
    late Box<Expense> expenseBox;
    late Box<Companion> companionBox;

    setUpAll(() async {
      await Hive.initFlutter();
      // Adapters registered in main.dart - avoid duplicates in tests
      expenseBox = await Hive.openBox<Expense>('test_expenses');
      companionBox = await Hive.openBox<Companion>('test_companions');
    });

    setUp(() async {
      await expenseBox.clear();
      await companionBox.clear();
    });

    test('Adding and retrieving an expense', () async {
      final expense = Expense.create(
        tripId: 'trip1',
        title: 'Dinner',
        amount: 100.0,
        currency: 'USD',
        category: ExpenseCategory.food,
        payerId: 'user1',
        splitWithIds: ['user2'],
      );

      final budgetService = await BudgetService.getInstance();
      await budgetService.addExpense(expense);

      final expenses = budgetService.getTripExpenses('trip1');
      expect(expenses.length, 1);
      expect(expenses.first.amount, 100.0);
      expect(expenses.first.category, ExpenseCategory.food);
    });

    test('Calculating expense totals by category', () async {
      final budgetService = await BudgetService.getInstance();

      // Add multiple expenses
      await budgetService.addExpense(Expense.create(
        tripId: 'trip1',
        title: 'Lunch',
        amount: 50.0,
        currency: 'USD',
        category: ExpenseCategory.food,
        payerId: 'user1',
        splitWithIds: ['user2'],
      ));

      await budgetService.addExpense(Expense.create(
        tripId: 'trip1',
        title: 'Dinner',
        amount: 100.0,
        currency: 'USD',
        category: ExpenseCategory.food,
        payerId: 'user1',
        splitWithIds: ['user2'],
      ));

      await budgetService.addExpense(Expense.create(
        tripId: 'trip1',
        title: 'Hotel',
        amount: 200.0,
        currency: 'USD',
        category: ExpenseCategory.accommodation,
        payerId: 'user1',
        splitWithIds: ['user2'],
      ));

      final totals = budgetService.calculateCategoryTotals('trip1', 'USD');
      expect(totals[ExpenseCategory.food], 150.0);
      expect(totals[ExpenseCategory.accommodation], 200.0);
    });

    tearDownAll(() async {
      await expenseBox.deleteFromDisk();
      await companionBox.deleteFromDisk();
    });
  });
}
