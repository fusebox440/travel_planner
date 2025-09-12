import 'package:flutter/material.dart';
import 'package:travel_planner/core/animation/app_animations.dart';

/// Gamification system for Travel Planner app
/// Makes packing and travel planning fun with rewards and achievements

enum BadgeType {
  firstTrip,
  packingMaster,
  earlyBird,
  adventurer,
  reviewer,
  organizer,
  explorer,
  weatherWatcher,
}

class Badge {
  final BadgeType type;
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Badge({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  static Badge fromType(BadgeType type,
      {bool isUnlocked = false, DateTime? unlockedAt}) {
    switch (type) {
      case BadgeType.firstTrip:
        return Badge(
          type: type,
          title: 'First Adventure! 🌟',
          description: 'Created your very first trip',
          emoji: '✈️',
          color: const Color(0xFF4F46E5),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      case BadgeType.packingMaster:
        return Badge(
          type: type,
          title: 'Packing Master! 🎒',
          description: 'Completed 5 packing lists',
          emoji: '👑',
          color: const Color(0xFF06D6A0),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      case BadgeType.earlyBird:
        return Badge(
          type: type,
          title: 'Early Bird! 🐦',
          description: 'Planned a trip 30 days in advance',
          emoji: '⏰',
          color: const Color(0xFFFFB347),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      case BadgeType.adventurer:
        return Badge(
          type: type,
          title: 'World Adventurer! 🌍',
          description: 'Visited 10 different places',
          emoji: '🗺️',
          color: const Color(0xFFFF8A8A),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      case BadgeType.reviewer:
        return Badge(
          type: type,
          title: 'Review Star! ⭐',
          description: 'Written 10 place reviews',
          emoji: '📝',
          color: const Color(0xFFFFF176),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      case BadgeType.organizer:
        return Badge(
          type: type,
          title: 'Super Organizer! 📋',
          description: 'Used all app features in one trip',
          emoji: '🏆',
          color: const Color(0xFF87CEEB),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      case BadgeType.explorer:
        return Badge(
          type: type,
          title: 'Digital Explorer! 🔍',
          description: 'Used maps feature 50 times',
          emoji: '🧭',
          color: const Color(0xFF98FB98),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
      case BadgeType.weatherWatcher:
        return Badge(
          type: type,
          title: 'Weather Watcher! 🌤️',
          description: 'Checked weather 25 times',
          emoji: '☀️',
          color: const Color(0xFFDDA0DD),
          isUnlocked: isUnlocked,
          unlockedAt: unlockedAt,
        );
    }
  }
}

/// Animated badge widget that shows achievements
class BadgeWidget extends StatefulWidget {
  final Badge badge;
  final double size;
  final bool showAnimation;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.size = 60,
    this.showAnimation = true,
  });

  @override
  State<BadgeWidget> createState() => _BadgeWidgetState();
}

class _BadgeWidgetState extends State<BadgeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.bounceOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    if (widget.showAnimation && widget.badge.isUnlocked) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showBadgeDetails(context);
        if (widget.badge.isUnlocked) {
          _controller.forward(from: 0.8);
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: widget.badge.isUnlocked
                      ? widget.badge.color
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                  boxShadow: widget.badge.isUnlocked
                      ? [
                          BoxShadow(
                            color: widget.badge.color.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    widget.badge.emoji,
                    style: TextStyle(
                      fontSize: widget.size * 0.4,
                      color: widget.badge.isUnlocked ? null : Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBadgeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BadgeDetailDialog(badge: widget.badge),
    );
  }
}

/// Dialog showing badge details
class BadgeDetailDialog extends StatelessWidget {
  final Badge badge;

  const BadgeDetailDialog({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BadgeWidget(badge: badge, size: 100, showAnimation: false),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: badge.color,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (badge.isUnlocked && badge.unlockedAt != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: badge.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Unlocked ${_formatDate(badge.unlockedAt!)} 🎉',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: badge.color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'today';
    if (difference == 1) return 'yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) return '${(difference / 7).round()} weeks ago';
    return '${(difference / 30).round()} months ago';
  }
}

/// Progress tracking widget
class ProgressTracker extends StatefulWidget {
  final String title;
  final int current;
  final int target;
  final Color color;
  final String unit;
  final String emoji;

  const ProgressTracker({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.color,
    this.unit = '',
    this.emoji = '📊',
  });

  @override
  State<ProgressTracker> createState() => _ProgressTrackerState();
}

class _ProgressTrackerState extends State<ProgressTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.current / widget.target).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.playful,
    ));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(ProgressTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current != oldWidget.current) {
      _progressAnimation = Tween<double>(
        begin: (oldWidget.current / oldWidget.target).clamp(0.0, 1.0),
        end: (widget.current / widget.target).clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.playful,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.current >= widget.target;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              if (isComplete)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Complete! 🎉',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color,
                          widget.color.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Progress text
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final animatedCurrent =
                  (_progressAnimation.value * widget.target).round();
              return Text(
                '$animatedCurrent / ${widget.target} ${widget.unit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.w600,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Celebration animation when achievements are unlocked
class CelebrationOverlay extends StatefulWidget {
  final Widget child;
  final bool showCelebration;
  final VoidCallback? onCelebrationComplete;

  const CelebrationOverlay({
    super.key,
    required this.child,
    required this.showCelebration,
    this.onCelebrationComplete,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  List<AnimationController> _confettiControllers = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Create multiple confetti controllers
    for (int i = 0; i < 20; i++) {
      _confettiControllers.add(AnimationController(
        duration: Duration(milliseconds: 2000 + (i * 100)),
        vsync: this,
      ));
    }
  }

  @override
  void didUpdateWidget(CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showCelebration && !oldWidget.showCelebration) {
      _startCelebration();
    }
  }

  void _startCelebration() {
    // Start all confetti animations with slight delays
    for (int i = 0; i < _confettiControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 50), () {
        if (mounted) {
          _confettiControllers[i].forward();
        }
      });
    }

    _controller.forward().then((_) {
      if (widget.onCelebrationComplete != null) {
        widget.onCelebrationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _confettiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showCelebration)
          Positioned.fill(
            child: Stack(
              children: List.generate(20, (index) {
                return AnimatedBuilder(
                  animation: _confettiControllers[index],
                  builder: (context, child) {
                    final progress = _confettiControllers[index].value;
                    final colors = [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                      Colors.orange,
                    ];

                    return Positioned(
                      left:
                          (index % 5) * (MediaQuery.of(context).size.width / 5),
                      top:
                          -50 + (progress * MediaQuery.of(context).size.height),
                      child: Transform.rotate(
                        angle: progress * 6.28 * 3, // Multiple rotations
                        child: Opacity(
                          opacity: 1.0 - progress,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
      ],
    );
  }
}
