import 'package:hive/hive.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/core/services/currency_service.dart';

class BudgetService {
  static const String _expenseBoxName = 'expenses';
  static const String _companionBoxName = 'companions';

  final Box<Expense> _expenseBox;
  final Box<Companion> _companionBox;
  final CurrencyService _currencyService;

  BudgetService._({
    required Box<Expense> expenseBox,
    required Box<Companion> companionBox,
    required CurrencyService currencyService,
  })  : _expenseBox = expenseBox,
        _companionBox = companionBox,
        _currencyService = currencyService;

  static BudgetService? _instance;

  static Future<BudgetService> getInstance() async {
    if (_instance == null) {
      final expenseBox = await Hive.openBox<Expense>(_expenseBoxName);
      final companionBox = await Hive.openBox<Companion>(_companionBoxName);
      final currencyService = CurrencyService();

      _instance = BudgetService._(
        expenseBox: expenseBox,
        companionBox: companionBox,
        currencyService: currencyService,
      );
    }
    return _instance!;
  }

  // Expense Methods
  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _expenseBox.delete(id);
  }

  List<Expense> getTripExpenses(String tripId) {
    return _expenseBox.values
        .where((expense) => expense.tripId == tripId)
        .toList();
  }

  // Companion Methods - now work with trip-specific companions
  Future<void> addCompanionToTrip(String tripId, Companion companion) async {
    final tripsBox = Hive.box<Trip>('trips');
    final trip = tripsBox.get(tripId);
    if (trip != null) {
      // First save the companion to its own box
      await _companionBox.put(companion.id, companion);

      // Then add it to the trip's companions list
      trip.companions.add(companion);
      await trip.save();
    }
  }

  Future<void> updateCompanionInTrip(String tripId, Companion companion) async {
    // Update the companion in the global companion box
    await _companionBox.put(companion.id, companion);

    // The companion reference in the trip's HiveList will automatically update
    // since HiveList maintains references to objects in the box
  }

  Future<void> deleteCompanionFromTrip(
      String tripId, String companionId) async {
    final tripsBox = Hive.box<Trip>('trips');
    final trip = tripsBox.get(tripId);
    if (trip != null) {
      // Remove from trip's companions list
      trip.companions.removeWhere((comp) => comp.id == companionId);
      await trip.save();

      // Also delete from the global companion box
      await _companionBox.delete(companionId);
    }
  }

  List<Companion> getTripCompanions(String tripId) {
    final tripsBox = Hive.box<Trip>('trips');
    final trip = tripsBox.get(tripId);
    if (trip != null) {
      return trip.companions.toList();
    }
    return [];
  }

  // Balance Calculations
  Future<Map<String, double>> calculateBalances(
      String tripId, String targetCurrency) async {
    final expenses = getTripExpenses(tripId);
    final balances = <String, double>{};

    for (final expense in expenses) {
      final amount = await _currencyService.convert(
        expense.amount,
        expense.currency,
        targetCurrency,
      );

      // Add amount to payer's balance (positive)
      balances[expense.payerId] = (balances[expense.payerId] ?? 0) + amount;

      // Calculate split amount
      final splitAmount = amount / (expense.splitWithIds.length + 1);

      // Subtract split amount from each person's balance
      for (final personId in expense.splitWithIds) {
        balances[personId] = (balances[personId] ?? 0) - splitAmount;
      }
      // Don't forget to subtract from the payer as well
      balances[expense.payerId] =
          (balances[expense.payerId] ?? 0) - splitAmount;
    }

    return balances;
  }

  Future<Map<ExpenseCategory, double>> calculateCategoryTotals(
    String tripId,
    String targetCurrency,
  ) async {
    final expenses = getTripExpenses(tripId);
    final totals = <ExpenseCategory, double>{};

    for (final expense in expenses) {
      final amount = await _currencyService.convert(
        expense.amount,
        expense.currency,
        targetCurrency,
      );

      totals[expense.category] = (totals[expense.category] ?? 0) + amount;
    }

    return totals;
  }

  Future<double> calculateTripTotal(
      String tripId, String targetCurrency) async {
    final expenses = getTripExpenses(tripId);
    double total = 0.0;

    for (final expense in expenses) {
      final amount = await _currencyService.convert(
        expense.amount,
        expense.currency,
        targetCurrency,
      );
      total += amount;
    }

    return total;
  }

  void dispose() {
    // Cleanup if needed
  }
}
