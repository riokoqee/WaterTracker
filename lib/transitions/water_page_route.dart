import 'dart:math' as math;
import 'package:flutter/material.dart';
// ignore: unused_import
import '../theme/app_colors.dart';

class WaterPageRoute<T> extends PageRouteBuilder<T> {
  // ignore: use_super_parameters
  WaterPageRoute({
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 900),
    RouteSettings? settings,
  }) : super(
          pageBuilder: (ctx, a, sa) => builder(ctx),
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 400),
          settings: settings,
          transitionsBuilder: (context, animation, _, child) {
            // Безопасно ограничиваем t в [0, 1]
            final t = animation.value.clamp(0.0, 1.0);

            // Фазы
            double fill = (t <= .82) ? (t / .82) : 1.0;
            fill = Curves.easeInOutCubic.transform(fill.clamp(0.0, 1.0));

            double fadeIn = (t <= .50) ? 0 : ((t - .50) / .50);
            fadeIn = Curves.easeOut.transform(fadeIn.clamp(0.0, 1.0));

            double drain = (t <= .82) ? 0 : ((t - .82) / .18);
            drain = Curves.easeInOut.transform(drain.clamp(0.0, 1.0));

            final waterOpacity = (1.0 - drain).clamp(0.0, 1.0);
            final done = t >= 0.999;

            return Stack(
              children: [
                // Новый экран
                Opacity(opacity: fadeIn, child: child),

                // Вода
                if (!done && waterOpacity > 0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WaterFillPainter(
                        fill: fill,
                        drain: drain,
                        opacity: waterOpacity,
                      ),
                    ),
                  ),

                // Пузыри
                if (!done && waterOpacity > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: true,
                      child: CustomPaint(
                        painter: _BubblesPainter(
                          progress: t,
                          opacity: waterOpacity * 0.18,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}

class _WaterFillPainter extends CustomPainter {
  final double fill;
  final double drain;
  final double opacity;

  _WaterFillPainter({required this.fill, required this.drain, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final topY = size.height * (1.0 - fill);
    final bottomY = size.height * (1.0 - drain);

    if (bottomY <= topY || opacity <= 0) return;

    final rect = Rect.fromLTRB(0, topY, size.width, bottomY);

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1B6FA8), Color(0xFF56C3FF)],
      ).createShader(rect)
      ..colorFilter = ColorFilter.mode(
        Colors.white.withOpacity(opacity),
        BlendMode.modulate,
      );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _WaterFillPainter old) =>
      old.fill != fill || old.drain != drain || old.opacity != opacity;
}

class _BubblesPainter extends CustomPainter {
  final double progress;
  final double opacity;

  _BubblesPainter({required this.progress, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final rnd = math.Random(42);
    final paint = Paint()..color = Colors.white.withOpacity(opacity);

    for (int i = 0; i < 26; i++) {
      final baseX = rnd.nextDouble() * size.width;
      final baseY = rnd.nextDouble() * size.height;

      final y = baseY - progress * size.height * (0.35 + rnd.nextDouble() * 0.45);
      final x = baseX + math.sin((progress * 2 * math.pi) + i) * 10;

      if (y > 0) {
        final r = 2.0 + rnd.nextDouble() * 3.5;
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BubblesPainter old) =>
      old.progress != progress || old.opacity != opacity;
}
