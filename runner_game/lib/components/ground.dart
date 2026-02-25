import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';

class Ground extends PositionComponent with HasGameRef<RunnerGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final groundY = gameRef.size.y * 0.75;
    position = Vector2(0, groundY);
    size = Vector2(gameRef.size.x, gameRef.size.y * 0.25);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Ground fill
    final groundPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      groundPaint,
    );

    // Grass on top
    final grassPaint = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, 8),
      grassPaint,
    );

    // Grass detail
    final grassDetailPaint = Paint()..color = const Color(0xFF4CAF50);
    for (double x = 0; x < size.x; x += 20) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, 10, 4),
        grassDetailPaint,
      );
    }

    // Ground texture dots
    final dotPaint = Paint()..color = const Color(0xFF795548);
    for (double x = 15; x < size.x; x += 40) {
      canvas.drawCircle(Offset(x, 25), 3, dotPaint);
    }
    for (double x = 35; x < size.x; x += 50) {
      canvas.drawCircle(Offset(x, 45), 2, dotPaint);
    }
  }
}
