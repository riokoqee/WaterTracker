import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WaterLevelIndicator extends StatefulWidget {
  final double progress; // от 0.0 до 1.0
  final double size;
  final int goalMl;

  const WaterLevelIndicator({
    super.key,
    required this.progress,
    required this.goalMl,
    this.size = 200,
  });

  @override
  State<WaterLevelIndicator> createState() => _WaterLevelIndicatorState();
}

class _WaterLevelIndicatorState extends State<WaterLevelIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _levelController;
  late Animation<double> _levelAnimation;

  double _animatedProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // 🌊 контроллер волны
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 🩵 контроллер уровня
    _levelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _levelAnimation =
        Tween<double>(begin: 0, end: widget.progress).animate(CurvedAnimation(
      parent: _levelController,
      curve: Curves.easeInOut,
    ))
          ..addListener(() {
            setState(() {
              _animatedProgress = _levelAnimation.value;
            });
          });

    _levelController.forward();
  }

  @override
  void didUpdateWidget(covariant WaterLevelIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _levelAnimation = Tween<double>(
        begin: _animatedProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _levelController,
        curve: Curves.easeInOut,
      ))
        ..addListener(() {
          setState(() {
            _animatedProgress = _levelAnimation.value;
          });
        });
      _levelController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaterPainter(
              progress: _animatedProgress,
              phase: _waveController.value * 2 * math.pi,
              goalMl: widget.goalMl,
            ),
          );
        },
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final double progress;
  final double phase;
  final int goalMl;

  _WaterPainter({required this.progress, required this.phase, required this.goalMl});

  @override
  void paint(Canvas canvas, Size size) {
    final double waveHeight = 6;
    final double baseY = size.height * (1 - progress);

    final Path wavePath = Path();
    wavePath.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      double y = math.sin((x / size.width * 2 * math.pi) + phase) * waveHeight + baseY;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    final Path circlePath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ));

    // обрезаем круг
    canvas.clipPath(circlePath);

    // фон
    final Paint bgPaint = Paint()
      ..color = Colors.blue.shade50
      ..style = PaintingStyle.fill;
    canvas.drawPath(circlePath, bgPaint);

    // вода
    final Paint wavePaint = Paint()
      // ignore: deprecated_member_use
      ..color = AppColors.primary.withOpacity(0.75)
      ..style = PaintingStyle.fill;
    canvas.drawPath(wavePath, wavePaint);

    // контур
    final Paint borderPaint = Paint()
      // ignore: deprecated_member_use
      ..color = AppColors.primary.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawPath(circlePath, borderPaint);

    // текст
    final tp = TextPainter(
      text: TextSpan(
        text: "${(progress * 100).toInt()}%",
        style: const TextStyle(
          fontFamily: "MinecraftRus",
          fontSize: 24,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tp2 = TextPainter(
      text: TextSpan(
        text: "${(progress * goalMl).toInt()} мл из $goalMl мл",
        style: const TextStyle(
          fontFamily: "MinecraftRus",
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas,
        Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height));
    tp2.paint(canvas,
        Offset(size.width / 2 - tp2.width / 2, size.height / 2 + 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
