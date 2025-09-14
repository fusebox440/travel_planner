import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/travel_statistics.dart';
import '../../data/analytics_service.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService());

final travelStatisticsProvider = FutureProvider<TravelStatistics>((ref) async {
  final service = ref.read(analyticsServiceProvider);

  // Try to get cached statistics first
  final cached = await service.getCachedStatistics();
  if (cached != null &&
      DateTime.now().difference(cached.lastUpdated).inHours < 1) {
    return cached;
  }

  // Generate fresh statistics
  return await service.generateStatistics();
});

final yearlySpendingProvider = FutureProvider<Map<String, double>>((ref) async {
  final service = ref.read(analyticsServiceProvider);
  return await service.getYearlySpending();
});

final tripHistoryProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(analyticsServiceProvider);
  return await service.getTripHistory();
});

// Provider to refresh statistics manually
final refreshStatisticsProvider =
    StateNotifierProvider<RefreshNotifier, bool>((ref) {
  return RefreshNotifier(ref);
});

class RefreshNotifier extends StateNotifier<bool> {
  final Ref _ref;

  RefreshNotifier(this._ref) : super(false);

  Future<void> refreshStatistics() async {
    state = true;
    try {
      final service = _ref.read(analyticsServiceProvider);
      await service.clearCache();

      // Invalidate providers to trigger refresh
      _ref.invalidate(travelStatisticsProvider);
      _ref.invalidate(yearlySpendingProvider);
      _ref.invalidate(tripHistoryProvider);
    } finally {
      state = false;
    }
  }
}
