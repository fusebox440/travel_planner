import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_planner/core/gamification/gamification.dart'
    as gamification;
import 'package:travel_planner/core/gamification/gamification_provider.dart';
import 'package:travel_planner/core/animation/app_animations.dart';

/// Screen showing all badges and achievements
class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBadges = ref.watch(allBadgesProvider);
    final userLevel = ref.watch(userLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements 🏆'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Level Card
            _UserLevelCard(
              level: userLevel['level'],
              title: userLevel['title'],
              score: userLevel['score'],
              progress: userLevel['progress'],
            ),

            const SizedBox(height: 24),

            // Badges Grid
            Text(
              'Your Badges',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badge = allBadges[index];
                return _BadgeCard(badge: badge, index: index);
              },
            ),

            const SizedBox(height: 24),

            // Progress Section
            Text(
              'Your Progress',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            _ProgressSection(),
          ],
        ),
      ),
    );
  }
}

class _UserLevelCard extends StatelessWidget {
  final int level;
  final String title;
  final int score;
  final double progress;

  const _UserLevelCard({
    required this.level,
    required this.title,
    required this.score,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'L$level',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '$score points',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (level < 5) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress to Level ${level + 1}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 6,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final gamification.Badge badge;
  final int index;

  const _BadgeCard({required this.badge, required this.index});

  @override
  Widget build(BuildContext context) {
    return SlideInFromBottom(
      delay: Duration(milliseconds: index * 100),
      child: Container(
        decoration: BoxDecoration(
          color: badge.isUnlocked
              ? badge.color.withOpacity(0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.isUnlocked
                ? badge.color.withOpacity(0.3)
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gamification.BadgeWidget(
              badge: badge,
              size: 50,
              showAnimation: false,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                badge.title.split('!')[0], // Remove emoji from title
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: badge.isUnlocked ? badge.color : Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gamificationProvider);

    final progressItems = [
      {
        'title': 'Trips Created',
        'current': state.progressCounters['trips_created'] ?? 0,
        'target': 10,
        'color': const Color(0xFF4F46E5),
        'emoji': '✈️',
        'unit': 'trips',
      },
      {
        'title': 'Packing Lists',
        'current': state.progressCounters['packing_lists_completed'] ?? 0,
        'target': 5,
        'color': const Color(0xFF06D6A0),
        'emoji': '🎒',
        'unit': 'lists',
      },
      {
        'title': 'Reviews Written',
        'current': state.progressCounters['reviews_written'] ?? 0,
        'target': 10,
        'color': const Color(0xFFFFF176),
        'emoji': '⭐',
        'unit': 'reviews',
      },
      {
        'title': 'Weather Checks',
        'current': state.progressCounters['weather_checked'] ?? 0,
        'target': 25,
        'color': const Color(0xFFDDA0DD),
        'emoji': '🌤️',
        'unit': 'checks',
      },
      {
        'title': 'Maps Used',
        'current': state.progressCounters['maps_used'] ?? 0,
        'target': 50,
        'color': const Color(0xFF98FB98),
        'emoji': '🗺️',
        'unit': 'times',
      },
      {
        'title': 'Places Visited',
        'current': state.progressCounters['places_visited'] ?? 0,
        'target': 10,
        'color': const Color(0xFFFF8A8A),
        'emoji': '🌍',
        'unit': 'places',
      },
    ];

    return Column(
      children: progressItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: gamification.ProgressTracker(
            title: item['title'] as String,
            current: item['current'] as int,
            target: item['target'] as int,
            color: item['color'] as Color,
            emoji: item['emoji'] as String,
            unit: item['unit'] as String,
          ),
        );
      }).toList(),
    );
  }
}

/// Widget to show quick achievement summary
class AchievementSummary extends ConsumerWidget {
  const AchievementSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedCount = ref.watch(unlockedBadgesCountProvider);
    final userLevel = ref.watch(userLevelProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'L${userLevel['level']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userLevel['title'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  '$unlockedCount/${gamification.BadgeType.values.length} badges earned • ${userLevel['score']} points',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BadgesScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
