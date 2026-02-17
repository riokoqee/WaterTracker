import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedWave extends StatefulWidget {
  final Color color;
  final double height;
  final double offset;

  const AnimatedWave({
    super.key,
    required this.color,
    this.height = 100,
    this.offset = 0,
  });

  @override
  State<AnimatedWave> createState() => _AnimatedWaveState();
}

class _AnimatedWaveState extends State<AnimatedWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ClipPath(
          clipper: _WaveClipper(_controller.value * 2 * math.pi, widget.offset),
          child: Container(
            height: widget.height,
            // ignore: deprecated_member_use
            color: widget.color.withOpacity(0.9),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double phase;
  final double offset;
  _WaveClipper(this.phase, this.offset);

  @override
  Path getClip(Size size) {
    final path = Path();
    final waveHeight = 12.0;
    path.lineTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      double y = math.sin((x / size.width * 2 * math.pi) + phase + offset) *
              waveHeight +
          size.height / 1.3;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => true;
}
