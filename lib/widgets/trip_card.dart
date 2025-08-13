import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_planner/core/theme/grey_mode_adjustments.dart';
import 'package:travel_planner/src/models/trip.dart';
import 'package:travel_planner/widgets/skeletons.dart';

enum TripCardSize { compact, large }

class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const PressableCard({super.key, required this.child, this.onTap});

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class TripCard extends StatelessWidget {
  final Trip trip;
  final TripCardSize size;
  final VoidCallback onTap;

  const TripCard({
    super.key,
    required this.trip,
    required this.onTap,
    this.size = TripCardSize.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final totalDays = trip.endDate.difference(trip.startDate).inDays + 1;
    final totalActivities =
    trip.days.fold<int>(0, (prev, day) => prev + day.activities.length);

    final coverImage = trip.imageUrl ?? 'https://placehold.co/600x400/0D47A1/FFFFFF/png?text=Trip';

    final cardContent = Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size == TripCardSize.large ? 200 : 120,
            width: double.infinity,
            child: GreyModeFilter(
              child: CachedNetworkImage(
                imageUrl: coverImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => const TripCardSkeleton(),
                errorWidget: (context, url, error) =>
                const Center(child: Icon(Icons.error)),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.title,
                      style: size == TripCardSize.large
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _LocationChip(location: trip.locationName),
                        _SummaryBadge(
                            label: '$totalDays Days', icon: Icons.calendar_today),
                        _SummaryBadge(
                            label: '$totalActivities Activities',
                            icon: Icons.local_activity),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label:
      'Trip to ${trip.locationName}, titled ${trip.title}, from ${dateFormat.format(trip.startDate)} to ${dateFormat.format(trip.endDate)}.',
      button: true,
      child: PressableCard(
        onTap: onTap,
        child: cardContent,
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String location;
  const _LocationChip({required this.location});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(Icons.location_on,
          size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
      label: Text(location),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SummaryBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon,
          size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}