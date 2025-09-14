import 'package:flutter/material.dart';

/// Animated page wrapper with consistent transitions
class AnimatedPage extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimationType animationType;

  const AnimatedPage({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.animationType = AnimationType.fadeSlide,
  });

  @override
  Widget build(BuildContext context) {
    switch (animationType) {
      case AnimationType.fade:
        return _FadeAnimation(
          duration: duration,
          curve: curve,
          child: child,
        );
      case AnimationType.slide:
        return _SlideAnimation(
          duration: duration,
          curve: curve,
          child: child,
        );
      case AnimationType.fadeSlide:
        return _FadeSlideAnimation(
          duration: duration,
          curve: curve,
          child: child,
        );
      case AnimationType.scale:
        return _ScaleAnimation(
          duration: duration,
          curve: curve,
          child: child,
        );
    }
  }
}

enum AnimationType {
  fade,
  slide,
  fadeSlide,
  scale,
}

class _FadeAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _FadeAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<_FadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: widget.child,
    );
  }
}

class _SlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _SlideAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<_SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

class _FadeSlideAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _FadeSlideAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_FadeSlideAnimation> createState() => _FadeSlideAnimationState();
}

class _FadeSlideAnimationState extends State<_FadeSlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class _ScaleAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const _ScaleAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<_ScaleAnimation> createState() => _ScaleAnimationState();
}

class _ScaleAnimationState extends State<_ScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
