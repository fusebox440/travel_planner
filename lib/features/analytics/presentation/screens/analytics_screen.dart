import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_charts.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(travelStatisticsProvider);
    final isRefreshing = ref.watch(refreshStatisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Analytics'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isRefreshing ? Icons.hourglass_bottom : Icons.refresh),
            onPressed: isRefreshing
                ? null
                : () => ref
                    .read(refreshStatisticsProvider.notifier)
                    .refreshStatistics(),
            tooltip: 'Refresh Statistics',
          ),
        ],
      ),
      body: statisticsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Calculating travel statistics...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading analytics: ${error.toString()}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(travelStatisticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (statistics) => RefreshIndicator(
          onRefresh: () =>
              ref.read(refreshStatisticsProvider.notifier).refreshStatistics(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(context, statistics),
                const SizedBox(height: 24),
                _buildChartSection(context, statistics),
                const SizedBox(height: 24),
                _buildInsightsSection(context, statistics),
                const SizedBox(height: 24),
                _buildLastUpdated(context, statistics.lastUpdated),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, statistics) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Travel Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard(
              'Total Trips',
              statistics.totalTrips.toString(),
              Icons.flight,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Spent',
              currencyFormat.format(statistics.totalSpent),
              Icons.account_balance_wallet,
              Colors.green,
            ),
            _buildStatCard(
              'Travel Days',
              '${statistics.totalDays} days',
              Icons.calendar_today,
              Colors.orange,
            ),
            _buildStatCard(
              'Average Trip Cost',
              currencyFormat.format(statistics.averageTripCost),
              Icons.trending_up,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending Analysis',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: SpendingCategoryChart(
            spendingByCategory: statistics.spendingByCategory,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: MonthlySpendingChart(
            monthlySpending: statistics.monthlySpending,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: TripCountChart(
            monthlyTripCount: statistics.monthlyTripCount,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(BuildContext context, statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Travel Insights',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightRow(
                  'Favorite Month',
                  statistics.favoriteMonth,
                  Icons.star,
                ),
                const Divider(),
                _buildInsightRow(
                  'Most Expensive Destination',
                  statistics.mostExpensiveDestination,
                  Icons.location_on,
                ),
                const Divider(),
                _buildInsightRow(
                  'Average Trip Duration',
                  '${statistics.averageTripDuration.toStringAsFixed(1)} days',
                  Icons.schedule,
                ),
                if (statistics.topDestinations.isNotEmpty) ...[
                  const Divider(),
                  const Text(
                    'Top Destinations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...statistics.topDestinations.take(3).map(
                        (destination) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.place,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(destination),
                            ],
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLastUpdated(BuildContext context, DateTime lastUpdated) {
    final formatter = DateFormat('MMM d, y \'at\' h:mm a');
    return Center(
      child: Text(
        'Last updated: ${formatter.format(lastUpdated)}',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }
}
