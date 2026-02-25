import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';

class Background extends PositionComponent with HasGameRef<RunnerGame> {
  final List<_Cloud> _clouds = [];
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;

    // Create some initial clouds
    for (int i = 0; i < 5; i++) {
      _clouds.add(_Cloud(
        x: _random.nextDouble() * size.x,
        y: 30 + _random.nextDouble() * (size.y * 0.3),
        width: 60 + _random.nextDouble() * 80,
        speed: 20 + _random.nextDouble() * 30,
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    for (final cloud in _clouds) {
      cloud.x -= cloud.speed * dt;
      if (cloud.x < -cloud.width) {
        cloud.x = size.x + 20;
        cloud.y = 30 + _random.nextDouble() * (size.y * 0.3);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw clouds
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.8);
    final cloudShadowPaint = Paint()..color = Colors.white.withOpacity(0.5);

    for (final cloud in _clouds) {
      // Cloud shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cloud.x + 2, cloud.y + 4),
          width: cloud.width,
          height: cloud.width * 0.4,
        ),
        cloudShadowPaint,
      );
      // Cloud main body
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cloud.x, cloud.y),
          width: cloud.width,
          height: cloud.width * 0.4,
        ),
        cloudPaint,
      );
      // Cloud bumps
      canvas.drawCircle(
        Offset(cloud.x - cloud.width * 0.2, cloud.y - 5),
        cloud.width * 0.18,
        cloudPaint,
      );
      canvas.drawCircle(
        Offset(cloud.x + cloud.width * 0.15, cloud.y - 8),
        cloud.width * 0.22,
        cloudPaint,
      );
    }

    // Sun
    final sunPaint = Paint()..color = const Color(0xFFFFF176);
    canvas.drawCircle(Offset(size.x - 60, 50), 30, sunPaint);

    final sunGlow = Paint()
      ..color = const Color(0xFFFFF176).withOpacity(0.3);
    canvas.drawCircle(Offset(size.x - 60, 50), 45, sunGlow);
  }
}

class _Cloud {
  double x;
  double y;
  double width;
  double speed;

  _Cloud({
    required this.x,
    required this.y,
    required this.width,
    required this.speed,
  });
}
