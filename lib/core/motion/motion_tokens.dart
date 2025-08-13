import 'package:flutter/material.dart';

/// A centralized class for all motion and animation constants.
class MotionTokens {
  MotionTokens._();

  //============================================================================
  // D U R A T I O N S
  //============================================================================

  /// 150ms. Use for fast, subtle animations like button presses.
  static const Duration fast = Duration(milliseconds: 150);

  /// 300ms. Standard duration for most screen transitions and component animations.
  static const Duration medium = Duration(milliseconds: 300);

  /// 500ms. Use for slow, deliberate animations, like a bottom sheet appearing.
  static const Duration slow = Duration(milliseconds: 500);

  //============================================================================
  // C U R V E S
  //============================================================================

  /// A curve that snaps back slightly, good for overshooting animations.
  static const Curve easeInOutBack = Curves.easeInOutBack;

  /// A curve that starts fast and slows down, good for elements entering the screen.
  static const Curve decelerate = Curves.decelerate;
}

//==============================================================================
// M O T I O N   A W A R E   W I D G E T
//==============================================================================

///
/// A wrapper widget that makes its child react to user interactions
/// with scale and opacity animations.
///
/// ---
/// ### How to use:
/// ```dart
/// MotionAware(
///   onTap: () => print('Tapped!'),
///   child: YourWidget(),
/// )
/// ```
///
class MotionAware extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MotionAware({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<MotionAware> createState() => _MotionAwareState();
}

class _MotionAwareState extends State<MotionAware>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.fast,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.decelerate),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.decelerate),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent details) => _controller.forward();
  void _onExit(PointerEvent details) => _controller.reverse();
  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}