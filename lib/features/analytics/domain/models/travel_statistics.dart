import 'package:hive/hive.dart';

part 'travel_statistics.g.dart';

@HiveType(typeId: 40)
class TravelStatistics extends HiveObject {
  @HiveField(0)
  final int totalTrips;

  @HiveField(1)
  final double totalSpent;

  @HiveField(2)
  final int totalDays;

  @HiveField(3)
  final List<String> topDestinations;

  @HiveField(4)
  final Map<String, double> spendingByCategory;

  @HiveField(5)
  final Map<String, int> monthlyTripCount;

  @HiveField(6)
  final Map<String, double> monthlySpending;

  @HiveField(7)
  final double averageTripCost;

  @HiveField(8)
  final double averageTripDuration;

  @HiveField(9)
  final String favoriteMonth;

  @HiveField(10)
  final String mostExpensiveDestination;

  @HiveField(11)
  final DateTime lastUpdated;

  TravelStatistics({
    required this.totalTrips,
    required this.totalSpent,
    required this.totalDays,
    required this.topDestinations,
    required this.spendingByCategory,
    required this.monthlyTripCount,
    required this.monthlySpending,
    required this.averageTripCost,
    required this.averageTripDuration,
    required this.favoriteMonth,
    required this.mostExpensiveDestination,
    required this.lastUpdated,
  });

  TravelStatistics copyWith({
    int? totalTrips,
    double? totalSpent,
    int? totalDays,
    List<String>? topDestinations,
    Map<String, double>? spendingByCategory,
    Map<String, int>? monthlyTripCount,
    Map<String, double>? monthlySpending,
    double? averageTripCost,
    double? averageTripDuration,
    String? favoriteMonth,
    String? mostExpensiveDestination,
    DateTime? lastUpdated,
  }) {
    return TravelStatistics(
      totalTrips: totalTrips ?? this.totalTrips,
      totalSpent: totalSpent ?? this.totalSpent,
      totalDays: totalDays ?? this.totalDays,
      topDestinations: topDestinations ?? this.topDestinations,
      spendingByCategory: spendingByCategory ?? this.spendingByCategory,
      monthlyTripCount: monthlyTripCount ?? this.monthlyTripCount,
      monthlySpending: monthlySpending ?? this.monthlySpending,
      averageTripCost: averageTripCost ?? this.averageTripCost,
      averageTripDuration: averageTripDuration ?? this.averageTripDuration,
      favoriteMonth: favoriteMonth ?? this.favoriteMonth,
      mostExpensiveDestination:
          mostExpensiveDestination ?? this.mostExpensiveDestination,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TravelStatistics &&
        other.totalTrips == totalTrips &&
        other.totalSpent == totalSpent &&
        other.totalDays == totalDays &&
        other.topDestinations.toString() == topDestinations.toString() &&
        other.spendingByCategory.toString() == spendingByCategory.toString() &&
        other.monthlyTripCount.toString() == monthlyTripCount.toString() &&
        other.monthlySpending.toString() == monthlySpending.toString() &&
        other.averageTripCost == averageTripCost &&
        other.averageTripDuration == averageTripDuration &&
        other.favoriteMonth == favoriteMonth &&
        other.mostExpensiveDestination == mostExpensiveDestination &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return totalTrips.hashCode ^
        totalSpent.hashCode ^
        totalDays.hashCode ^
        topDestinations.hashCode ^
        spendingByCategory.hashCode ^
        monthlyTripCount.hashCode ^
        monthlySpending.hashCode ^
        averageTripCost.hashCode ^
        averageTripDuration.hashCode ^
        favoriteMonth.hashCode ^
        mostExpensiveDestination.hashCode ^
        lastUpdated.hashCode;
  }

  @override
  String toString() {
    return 'TravelStatistics(totalTrips: $totalTrips, totalSpent: $totalSpent, totalDays: $totalDays, topDestinations: $topDestinations, spendingByCategory: $spendingByCategory, monthlyTripCount: $monthlyTripCount, monthlySpending: $monthlySpending, averageTripCost: $averageTripCost, averageTripDuration: $averageTripDuration, favoriteMonth: $favoriteMonth, mostExpensiveDestination: $mostExpensiveDestination, lastUpdated: $lastUpdated)';
  }
}
