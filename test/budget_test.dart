import 'package:flutter_test/flutter_test.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/mock/docs';
}

void main() {
  group('Budget Feature Tests', () {
    late Box<Expense> expenseBox;
    late Box<Companion> companionBox;

    setUpAll(() async {
      // Mock the path provider
      PathProviderPlatform.instance = MockPathProviderPlatform();

      await Hive.initFlutter();

      // Register adapters if not already registered
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(ExpenseAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(CompanionAdapter());
      }
      if (!Hive.isAdapterRegistered(26)) {
        Hive.registerAdapter(ExpenseCategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(35)) {
        Hive.registerAdapter(ExpenseSubCategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(38)) {
        Hive.registerAdapter(PaymentMethodAdapter());
      }

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

      // Add expense directly to box for testing
      await expenseBox.put(expense.id, expense);

      // Test retrieval logic
      final expenses = expenseBox.values
          .where((expense) => expense.tripId == 'trip1')
          .toList();
      expect(expenses.length, 1);
      expect(expenses.first.amount, 100.0);
      expect(expenses.first.category, ExpenseCategory.food);
    });

    test('Calculating expense totals by category', () async {
      // Add multiple expenses directly to box
      await expenseBox.put(
          'expense1',
          Expense.create(
            tripId: 'trip1',
            title: 'Lunch',
            amount: 50.0,
            currency: 'USD',
            category: ExpenseCategory.food,
            payerId: 'user1',
            splitWithIds: ['user2'],
          ));

      await expenseBox.put(
          'expense2',
          Expense.create(
            tripId: 'trip1',
            title: 'Dinner',
            amount: 100.0,
            currency: 'USD',
            category: ExpenseCategory.food,
            payerId: 'user1',
            splitWithIds: ['user2'],
          ));

      await expenseBox.put(
          'expense3',
          Expense.create(
            tripId: 'trip1',
            title: 'Hotel',
            amount: 200.0,
            currency: 'USD',
            category: ExpenseCategory.accommodation,
            payerId: 'user1',
            splitWithIds: ['user2'],
          ));

      // Test category totals calculation manually
      final expenses = expenseBox.values
          .where((expense) => expense.tripId == 'trip1')
          .toList();

      final totals = <ExpenseCategory, double>{};
      for (final expense in expenses) {
        totals[expense.category] =
            (totals[expense.category] ?? 0) + expense.amount;
      }

      expect(totals[ExpenseCategory.food], 150.0);
      expect(totals[ExpenseCategory.accommodation], 200.0);
    });

    tearDownAll(() async {
      await expenseBox.deleteFromDisk();
      await companionBox.deleteFromDisk();
    });
  });
}
