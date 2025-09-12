import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_planner/core/animation/app_animations.dart';
import 'package:travel_planner/widgets/animated_components.dart';

class EmptyStateWidget extends StatefulWidget {
  final String title;
  final String description;
  final String? lottieAsset;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Color? backgroundColor;
  final String emoji;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.lottieAsset,
    this.icon,
    this.actionText,
    this.onActionPressed,
    this.backgroundColor,
    this.emoji = '🌟',
  });

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: AppAnimations.bounceOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.gentle,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _bounceController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated illustration
              ScaleTransition(
                scale: _bounceAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: (widget.backgroundColor ??
                            Theme.of(context).primaryColor)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: widget.lottieAsset != null
                      ? Lottie.asset(
                          widget.lottieAsset!,
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Floating emoji animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 2),
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(
                                      0,
                                      -10 +
                                          (10 *
                                              (1 +
                                                  0.3 *
                                                      (value * 4 -
                                                          (value * 4)
                                                              .floor())))),
                                  child: Text(
                                    widget.emoji,
                                    style: const TextStyle(fontSize: 80),
                                  ),
                                );
                              },
                            ),
                            if (widget.icon != null)
                              Icon(
                                widget.icon,
                                size: 40,
                                color: widget.backgroundColor ??
                                    Theme.of(context).primaryColor,
                              ),
                          ],
                        ),
                ),
              ),

              // Animated title
              SlideInFromBottom(
                delay: const Duration(milliseconds: 400),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),

              const SizedBox(height: 16),

              // Animated description
              SlideInFromBottom(
                delay: const Duration(milliseconds: 600),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          height: 1.5,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Animated action button
              if (widget.actionText != null && widget.onActionPressed != null)
                BounceInScale(
                  delay: const Duration(milliseconds: 800),
                  child: PlayfulButton(
                    text: widget.actionText!,
                    onPressed: widget.onActionPressed,
                    backgroundColor: widget.backgroundColor ??
                        Theme.of(context).primaryColor,
                    icon: Icons.add_rounded,
                    size: const Size(180, 50),
                  ),
                ),

              const SizedBox(height: 16),

              // Helpful tips
              SlideInFromBottom(
                delay: const Duration(milliseconds: 1000),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tip: Tap the ✨ button to get started!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Specific empty state widgets for different sections
class TripsEmptyState extends StatelessWidget {
  final VoidCallback? onAddTrip;

  const TripsEmptyState({super.key, this.onAddTrip});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Trips Yet! ✈️',
      description:
          'Ready for an adventure? Create your first trip and start planning amazing memories!',
      lottieAsset: 'assets/lottie/empty_travel.json',
      emoji: '🧳',
      actionText: 'Create First Trip',
      onActionPressed: onAddTrip,
      backgroundColor: const Color(0xFF4F46E5),
    );
  }
}

class PackingEmptyState extends StatelessWidget {
  final VoidCallback? onAddItem;

  const PackingEmptyState({super.key, this.onAddItem});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Packing List is Empty! 🎒',
      description:
          'Don\'t forget anything important! Add items to your packing list.',
      emoji: '📋',
      actionText: 'Add First Item',
      onActionPressed: onAddItem,
      backgroundColor: const Color(0xFF06D6A0),
    );
  }
}

class ReviewsEmptyState extends StatelessWidget {
  final VoidCallback? onAddReview;

  const ReviewsEmptyState({super.key, this.onAddReview});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Reviews Yet! ⭐',
      description:
          'Share your experiences! Write a review about this amazing place.',
      emoji: '💭',
      actionText: 'Write First Review',
      onActionPressed: onAddReview,
      backgroundColor: const Color(0xFFFFB347),
    );
  }
}

class WeatherEmptyState extends StatelessWidget {
  final VoidCallback? onRefresh;

  const WeatherEmptyState({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Weather Not Available 🌤️',
      description:
          'We couldn\'t get weather information right now. Try refreshing!',
      emoji: '🔄',
      actionText: 'Refresh Weather',
      onActionPressed: onRefresh,
      backgroundColor: const Color(0xFF87CEEB),
    );
  }
}

class MapsEmptyState extends StatelessWidget {
  final VoidCallback? onEnableLocation;

  const MapsEmptyState({super.key, this.onEnableLocation});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Enable Location 📍',
      description:
          'Allow location access to see maps and find cool places near you!',
      emoji: '🗺️',
      actionText: 'Enable Location',
      onActionPressed: onEnableLocation,
      backgroundColor: const Color(0xFF98FB98),
    );
  }
}
