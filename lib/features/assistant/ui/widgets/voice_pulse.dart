import 'package:flutter/material.dart';

class VoicePulse extends StatefulWidget {
  const VoicePulse({super.key});

  @override
  VoicePulseState createState() => VoicePulseState();
}

class VoicePulseState extends State<VoicePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            return Container(
              width: 24.0 + (index * 8.0),
              height: 24.0 + (index * 8.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(
                  (1 - _controller.value - (index * 0.2)).clamp(0.0, 1.0),
                ),
              ),
            );
          }).reversed.toList(),
        );
      },
    );
  }
}
