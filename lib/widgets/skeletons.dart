import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:travel_planner/core/services/settings_service.dart';

/// A wrapper that conditionally applies a shimmer effect.
/// It respects the user's choice for reduced motion.
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  const ShimmerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = SettingsService().getReducedMotion();
    if (reduceMotion) {
      return child; // Return the plain skeleton if motion is off
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}

/// The basic building block for all skeletons: a simple grey container.
class Skeleton extends StatelessWidget {
  final double? height;
  final double? width;
  const Skeleton({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
    );
  }
}

/// A skeleton placeholder that mimics the layout of a TripCard.
class TripCardSkeleton extends StatelessWidget {
  const TripCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerWrapper(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(height: 120, width: double.infinity),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 200, height: 24),
                  SizedBox(height: 8),
                  Skeleton(width: 100, height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A skeleton placeholder for a single activity item in a list.
class ActivityItemSkeleton extends StatelessWidget {
  const ActivityItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerWrapper(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Skeleton(width: 50, height: 50),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: double.infinity, height: 16),
                  SizedBox(height: 8),
                  Skeleton(width: 100, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A skeleton placeholder for the map preview in the detail header.
class MapPlaceholderSkeleton extends StatelessWidget {
  const MapPlaceholderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerWrapper(
      child: Skeleton(
        height: 150,
        width: double.infinity,
      ),
    );
  }
}