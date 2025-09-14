import 'package:hive/hive.dart';
import '../domain/models/travel_statistics.dart';
import '../../../src/models/trip.dart';
import '../../../src/models/expense.dart';

extension ExpenseCategoryExtension on ExpenseCategory {
  String get name {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.accommodation:
        return 'Accommodation';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.healthcare:
        return 'Healthcare';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.business:
        return 'Business';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.communication:
        return 'Communication';
      case ExpenseCategory.emergencies:
        return 'Emergencies';
      case ExpenseCategory.gifts:
        return 'Gifts';
      case ExpenseCategory.fees:
        return 'Fees';
      case ExpenseCategory.custom:
        return 'Custom';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}

class AnalyticsService {
  static const String _boxName = 'analytics';
  static const String _statsKey = 'travel_statistics';

  Box<TravelStatistics>? _analyticsBox;

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _analyticsBox = await Hive.openBox<TravelStatistics>(_boxName);
    } else {
      _analyticsBox = Hive.box<TravelStatistics>(_boxName);
    }
  }

  Future<TravelStatistics> generateStatistics() async {
    await init();

    final tripsBox = await Hive.openBox<Trip>('trips');
    final expensesBox = await Hive.openBox<Expense>('expenses');

    final trips = tripsBox.values.toList();
    final expenses = expensesBox.values.toList();

    // Calculate basic statistics
    final totalTrips = trips.length;
    final totalDays =
        trips.fold<int>(0, (sum, trip) => sum + _calculateTripDays(trip));

    // Calculate spending from expenses
    double totalSpent = 0.0;
    final Map<String, double> spendingByCategory = {};

    for (final expense in expenses) {
      totalSpent += expense.amount;
      final categoryName = expense.category.name;
      spendingByCategory[categoryName] =
          (spendingByCategory[categoryName] ?? 0) + expense.amount;
    }

    // Calculate destination statistics
    final destinationCount = <String, int>{};
    final destinationSpending = <String, double>{};

    for (final trip in trips) {
      final destination = trip.locationName;
      destinationCount[destination] = (destinationCount[destination] ?? 0) + 1;

      // Find expenses for this trip
      final tripExpenses = expenses.where((e) => e.tripId == trip.id).toList();
      final tripSpent =
          tripExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

      if (tripSpent > 0) {
        destinationSpending[destination] =
            (destinationSpending[destination] ?? 0) + tripSpent;
      }
    }

    final topDestinations = destinationCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topDestinationNames =
        topDestinations.take(5).map((e) => e.key).toList();

    // Calculate monthly statistics
    final monthlyTripCount = <String, int>{};
    final monthlySpending = <String, double>{};

    for (final trip in trips) {
      final monthKey =
          '${trip.startDate.year}-${trip.startDate.month.toString().padLeft(2, '0')}';
      monthlyTripCount[monthKey] = (monthlyTripCount[monthKey] ?? 0) + 1;

      // Find expenses for this trip
      final tripExpenses = expenses.where((e) => e.tripId == trip.id).toList();
      final tripSpent =
          tripExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

      if (tripSpent > 0) {
        monthlySpending[monthKey] =
            (monthlySpending[monthKey] ?? 0) + tripSpent;
      }
    }

    // Calculate averages
    final averageTripCost = totalTrips > 0 ? totalSpent / totalTrips : 0.0;
    final averageTripDuration =
        totalTrips > 0 ? totalDays / totalTrips.toDouble() : 0.0;

    // Find favorite month (most trips)
    final favoriteMonth = monthlyTripCount.entries.isEmpty
        ? 'N/A'
        : monthlyTripCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    // Find most expensive destination
    final mostExpensiveDestination = destinationSpending.entries.isEmpty
        ? 'N/A'
        : destinationSpending.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;

    final statistics = TravelStatistics(
      totalTrips: totalTrips,
      totalSpent: totalSpent,
      totalDays: totalDays,
      topDestinations: topDestinationNames,
      spendingByCategory: spendingByCategory,
      monthlyTripCount: monthlyTripCount,
      monthlySpending: monthlySpending,
      averageTripCost: averageTripCost,
      averageTripDuration: averageTripDuration,
      favoriteMonth: favoriteMonth,
      mostExpensiveDestination: mostExpensiveDestination,
      lastUpdated: DateTime.now(),
    );

    // Cache the statistics
    await _analyticsBox?.put(_statsKey, statistics);

    return statistics;
  }

  Future<TravelStatistics?> getCachedStatistics() async {
    await init();
    return _analyticsBox?.get(_statsKey);
  }

  Future<void> clearCache() async {
    await init();
    await _analyticsBox?.delete(_statsKey);
  }

  int _calculateTripDays(Trip trip) {
    return trip.endDate.difference(trip.startDate).inDays + 1;
  }

  Future<Map<String, double>> getYearlySpending() async {
    final expensesBox = await Hive.openBox<Expense>('expenses');
    final tripsBox = await Hive.openBox<Trip>('trips');

    final expenses = expensesBox.values.toList();
    final trips = tripsBox.values.toList();

    final yearlySpending = <String, double>{};

    for (final trip in trips) {
      final year = trip.startDate.year.toString();
      final tripExpenses = expenses.where((e) => e.tripId == trip.id);
      final tripSpent =
          tripExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

      if (tripSpent > 0) {
        yearlySpending[year] = (yearlySpending[year] ?? 0) + tripSpent;
      }
    }

    return yearlySpending;
  }

  Future<List<Map<String, dynamic>>> getTripHistory() async {
    final tripsBox = await Hive.openBox<Trip>('trips');
    final expensesBox = await Hive.openBox<Expense>('expenses');

    final trips = tripsBox.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));

    return trips.map((trip) {
      final tripExpenses = expensesBox.values.where((e) => e.tripId == trip.id);
      final spent = tripExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);

      return {
        'trip': trip,
        'spent': spent,
        'duration': trip.endDate.difference(trip.startDate).inDays + 1,
        'expenseCount': tripExpenses.length,
      };
    }).toList();
  }
}
