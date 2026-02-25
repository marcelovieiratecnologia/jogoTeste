import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game/runner_game.dart';
import 'player.dart';

class Obstacle extends PositionComponent
    with HasGameRef<RunnerGame>, CollisionCallbacks {
  final Vector2 obstacleSize;
  final double groundY;
  final double Function() gameSpeedGetter;
  final VoidCallback onPlayerHit;

  Obstacle({
    required this.obstacleSize,
    required this.groundY,
    required this.gameSpeedGetter,
    required this.onPlayerHit,
  }) : super(size: obstacleSize);

  final bool _scored = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Position at right edge, on the ground
    position = Vector2(
      gameRef.size.x + 50,
      groundY - obstacleSize.y,
    );

    // Add hitbox for collision
    add(RectangleHitbox(
      size: Vector2(obstacleSize.x - 6, obstacleSize.y - 4),
      position: Vector2(3, 2),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGameOver) return;

    // Move to the left
    position.x -= gameSpeedGetter() * dt;

    // Remove when off-screen
    if (position.x < -obstacleSize.x - 20) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) {
      onPlayerHit();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Cactus-style obstacle
    final trunkPaint = Paint()..color = const Color(0xFF2E7D32);

    // Main trunk
    final trunkWidth = obstacleSize.x * 0.4;
    final trunkX = (obstacleSize.x - trunkWidth) / 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(trunkX, 0, trunkWidth, obstacleSize.y),
        const Radius.circular(3),
      ),
      trunkPaint,
    );

    // Left arm
    if (obstacleSize.y > 45) {
      final armPaint = Paint()..color = const Color(0xFF388E3C);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              0, obstacleSize.y * 0.3, trunkX + 2, obstacleSize.x * 0.3),
          const Radius.circular(3),
        ),
        armPaint,
      );
      // Left arm vertical part
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, obstacleSize.y * 0.15, obstacleSize.x * 0.25,
              obstacleSize.y * 0.2),
          const Radius.circular(3),
        ),
        armPaint,
      );
    }

    // Right arm
    if (obstacleSize.y > 55) {
      final armPaint = Paint()..color = const Color(0xFF388E3C);
      final rightX = trunkX + trunkWidth - 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rightX, obstacleSize.y * 0.45, obstacleSize.x - rightX,
              obstacleSize.x * 0.3),
          const Radius.circular(3),
        ),
        armPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(obstacleSize.x * 0.7, obstacleSize.y * 0.25,
              obstacleSize.x * 0.25, obstacleSize.y * 0.25),
          const Radius.circular(3),
        ),
        armPaint,
      );
    }

    // Spikes / dots for texture
    final spikePaint = Paint()..color = const Color(0xFF1B5E20);
    canvas.drawCircle(
      Offset(obstacleSize.x / 2, obstacleSize.y * 0.15),
      2,
      spikePaint,
    );
    canvas.drawCircle(
      Offset(obstacleSize.x / 2, obstacleSize.y * 0.5),
      2,
      spikePaint,
    );
  }
}
