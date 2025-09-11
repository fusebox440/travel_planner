import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/design/app_typography.dart';
import 'package:travel_planner/widgets/responsive_scaffold.dart';
import 'dart:async';

final _timeProvider = StateProvider<DateTime>((ref) => DateTime.now().toUtc());

class WorldClockScreen extends ConsumerStatefulWidget {
  const WorldClockScreen({super.key});

  @override
  ConsumerState<WorldClockScreen> createState() => _WorldClockScreenState();
}

class _WorldClockScreenState extends ConsumerState<WorldClockScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      ref.read(_timeProvider.notifier).state = DateTime.now().toUtc();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final utcNow = ref.watch(_timeProvider);

    // Define some common timezones with their UTC offsets
    final timezones = {
      'New York': -5,
      'London': 0,
      'Paris': 1,
      'Dubai': 4,
      'Tokyo': 9,
      'Sydney': 10,
    };

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
      ),
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'World Time',
              style: AppTypography.title1,
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Colors.indigo,
                ),
                title: Text(
                  'UTC',
                  style: theme.textTheme.titleMedium,
                ),
                trailing: Text(
                  _formatTime(utcNow),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFeatures: const [
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: timezones.length,
                itemBuilder: (context, index) {
                  final city = timezones.keys.elementAt(index);
                  final offset = timezones[city]!;
                  final time = utcNow.add(Duration(hours: offset));
                  final isDaytime = time.hour >= 6 && time.hour < 18;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        isDaytime ? Icons.wb_sunny : Icons.nightlight_round,
                        color: isDaytime ? Colors.amber : Colors.indigo,
                      ),
                      title: Text(
                        city,
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        'UTC ${offset >= 0 ? "+$offset" : offset}',
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Text(
                        _formatTime(time),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
