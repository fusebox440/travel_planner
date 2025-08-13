import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:travel_planner/core/theme/grey_mode_adjustments.dart';

class AnimatedStaggeredList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isGridView;

  const AnimatedStaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: isGridView
          ? GridView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
        ),
        itemBuilder: (context, index) {
          return _buildAnimatedItem(context, index, itemBuilder(context, index));
        },
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return _buildAnimatedItem(context, index, itemBuilder(context, index));
        },
      ),
    );
  }

  Widget _buildAnimatedItem(BuildContext context, int index, Widget child) {
    return AnimationConfiguration.staggeredList(
      position: index,
      // This is the integration point for the grey mode adjustment
      duration: MotionAdjuster.getDuration(context, const Duration(milliseconds: 400)),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: child,
        ),
      ),
    );
  }
}