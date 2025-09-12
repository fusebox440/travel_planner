import 'package:flutter/material.dart';

/// A collection of animation utilities and constants for the Travel Planner app
/// Makes animations consistent and child-friendly throughout the app
class AppAnimations {
  AppAnimations._();

  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Curves
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve playful = Curves.elasticOut;
  static const Curve gentle = Curves.easeInOut;

  // Scale animations
  static const double scaleSmall = 0.8;
  static const double scaleNormal = 1.0;
  static const double scaleLarge = 1.2;
  static const double scaleExtraLarge = 1.5;
}

/// Animated container that responds to tap with playful scaling
class PlayfulTapContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;
  final double scaleDown;

  const PlayfulTapContainer({
    super.key,
    required this.child,
    this.onTap,
    this.duration = AppAnimations.fast,
    this.scaleDown = AppAnimations.scaleSmall,
  });

  @override
  State<PlayfulTapContainer> createState() => _PlayfulTapContainerState();
}

class _PlayfulTapContainerState extends State<PlayfulTapContainer>
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
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.gentle,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animated entrance for widgets - slides in from bottom with bounce
class SlideInFromBottom extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const SlideInFromBottom({
    super.key,
    required this.child,
    this.duration = AppAnimations.medium,
    this.delay = Duration.zero,
  });

  @override
  State<SlideInFromBottom> createState() => _SlideInFromBottomState();
}

class _SlideInFromBottomState extends State<SlideInFromBottom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.playful,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0),
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated scale entrance with bounce effect
class BounceInScale extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const BounceInScale({
    super.key,
    required this.child,
    this.duration = AppAnimations.slow,
    this.delay = Duration.zero,
  });

  @override
  State<BounceInScale> createState() => _BounceInScaleState();
}

class _BounceInScaleState extends State<BounceInScale>
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
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.bounceOut,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
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

/// Animated checkmark that grows and bounces when checked
class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double size;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size = 24.0,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward().then((_) {
          _controller.reverse();
        });
      }
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
        if (widget.onChanged != null) {
          widget.onChanged!(!widget.value);

          if (!widget.value) {
            _controller.forward().then((_) {
              _controller.reverse();
            });
          }
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
                  color: widget.value
                      ? (widget.activeColor ?? Theme.of(context).primaryColor)
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.value
                        ? (widget.activeColor ?? Theme.of(context).primaryColor)
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: widget.value
                    ? Icon(
                        Icons.check_rounded,
                        size: widget.size * 0.6,
                        color: widget.checkColor ?? Colors.white,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Floating hearts animation for celebration moments
class FloatingHearts extends StatefulWidget {
  final Duration duration;
  final int heartCount;

  const FloatingHearts({
    super.key,
    this.duration = const Duration(seconds: 3),
    this.heartCount = 6,
  });

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts>
    with TickerProviderStateMixin {
  List<AnimationController> _controllers = [];
  List<Animation<Offset>> _animations = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.heartCount; i++) {
      final controller = AnimationController(
        duration: widget.duration,
        vsync: this,
      );

      final animation = Tween<Offset>(
        begin: Offset(
          (i * 0.2) - 0.6, // Spread horizontally
          0.0,
        ),
        end: Offset(
          (i * 0.15) - 0.45,
          -1.5,
        ),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuart,
      ));

      _controllers.add(controller);
      _animations.add(animation);

      // Start each heart with a slight delay
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          controller.forward();
        }
      });
    }

    // Auto-dispose after animation
    Future.delayed(widget.duration + Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.heartCount, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return SlideTransition(
              position: _animations[index],
              child: Transform.scale(
                scale: 1.0 - _controllers[index].value * 0.3,
                child: Opacity(
                  opacity: 1.0 - _controllers[index].value,
                  child: const Text(
                    '💖',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Smooth page transition
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SmoothPageRoute({
    required this.child,
    this.duration = AppAnimations.medium,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween.chain(
              CurveTween(curve: AppAnimations.gentle),
            ));

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0),
            ));

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}
