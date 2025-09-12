import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/features/budget/data/budget_service.dart';
import 'package:travel_planner/src/models/companion.dart';
import 'package:travel_planner/src/models/expense.dart';

final budgetServiceProvider = FutureProvider<BudgetService>((ref) {
  return BudgetService.getInstance();
});

final tripExpensesProvider =
    FutureProvider.family<List<Expense>, String>((ref, tripId) async {
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return budgetService.getTripExpenses(tripId);
});

final tripCompanionsProvider =
    FutureProvider.family<List<Companion>, List<String>>(
        (ref, companionIds) async {
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return budgetService.getTripCompanions(companionIds);
});

final allCompanionsProvider = FutureProvider<List<Companion>>((ref) async {
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return budgetService.getAllCompanions();
});

final categoryTotalsProvider = FutureProvider.family<
    Map<ExpenseCategory, double>,
    ({String tripId, String currency})>((ref, params) async {
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return budgetService.calculateCategoryTotals(params.tripId, params.currency);
});

final tripTotalProvider =
    FutureProvider.family<double, ({String tripId, String currency})>(
        (ref, params) async {
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return budgetService.calculateTripTotal(params.tripId, params.currency);
});

final balancesProvider = FutureProvider.family<Map<String, double>,
    ({String tripId, String currency})>((ref, params) async {
  final budgetService = await ref.watch(budgetServiceProvider.future);
  return budgetService.calculateBalances(params.tripId, params.currency);
});
