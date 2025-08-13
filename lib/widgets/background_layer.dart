import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travel_planner/core/services/settings_service.dart';

/// A model to hold the state of a single animated blob.
class _Blob {
  double x;
  double y;
  double radius;
  double velocityX;
  double velocityY;
  final Color color;

  _Blob({
    required this.x,
    required this.y,
    required this.radius,
    required this.velocityX,
    required this.velocityY,
    required this.color,
  });

  void move(Size bounds) {
    x += velocityX;
    y += velocityY;

    if (x < 0 || x > bounds.width) {
      velocityX = -velocityX;
    }
    if (y < 0 || y > bounds.height) {
      velocityY = -velocityY;
    }
  }
}

/// A CustomPainter to draw the soft, blurred blobs.
class _BlobPainter extends CustomPainter {
  final List<_Blob> blobs;

  _BlobPainter({required this.blobs});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    for (final blob in blobs) {
      paint.color = blob.color;
      canvas.drawCircle(Offset(blob.x, blob.y), blob.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// A widget that provides a multi-layered, animated background.
class BackgroundLayer extends StatefulWidget {
  final Widget child;
  final bool isAnimationEnabled;

  const BackgroundLayer({
    super.key,
    required this.child,
    this.isAnimationEnabled = true,
  });

  @override
  State<BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends State<BackgroundLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Blob> _blobs;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(() {
      if (mounted) {
        setState(() {
          for (final blob in _blobs) {
            blob.move(context.size ?? Size.zero);
          }
        });
      }
    });

    _blobs = [];

    final batterySaverEnabled = SettingsService().getBatterySaver();
    if (widget.isAnimationEnabled && !batterySaverEnabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_blobs.isEmpty) {
      final theme = Theme.of(context);
      final size = MediaQuery.of(context).size;
      _blobs.addAll([
        _createRandomBlob(size, theme.colorScheme.primaryContainer),
        _createRandomBlob(size, theme.colorScheme.secondaryContainer),
        _createRandomBlob(size, theme.colorScheme.tertiaryContainer),
      ]);
    }
  }

  _Blob _createRandomBlob(Size size, Color color) {
    return _Blob(
      x: _random.nextDouble() * size.width,
      y: _random.nextDouble() * size.height,
      radius: _random.nextDouble() * 100 + 100,
      velocityX: _random.nextDouble() * 0.5 - 0.25,
      velocityY: _random.nextDouble() * 0.5 - 0.25,
      color: color.withOpacity(0.3),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final batterySaverEnabled = SettingsService().getBatterySaver();
    final showAnimations = widget.isAnimationEnabled && !batterySaverEnabled;

    return Stack(
      children: [
        // Layer 1: Gradient Base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.background,
              ],
            ),
          ),
        ),

        // Layer 2: Animated Blobs
        if (showAnimations)
          Positioned.fill(
            child: CustomPaint(
              painter: _BlobPainter(blobs: _blobs),
            ),
          ),

        // Layer 3: Noise Overlay (Optional)
        if (showAnimations)
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/noise.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),

        // Foreground Content
        widget.child,
      ],
    );
  }
}