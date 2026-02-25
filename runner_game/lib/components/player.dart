import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game/runner_game.dart';

class Player extends PositionComponent
    with HasGameRef<RunnerGame>, CollisionCallbacks {
  // Physics
  double _velocityY = 0;
  final double _gravity = 1200;
  final double _jumpForce = -550;
  bool _isOnGround = true;
  late double _groundY;

  // Movement
  double _velocityX = 0;
  final double _moveSpeed = 250;
  bool _isMovingRight = false;
  bool _isMovingLeft = false;
  bool _facingRight = true;

  // Animation
  double _runAnimTimer = 0;
  int _runFrame = 0;
  final double _runAnimSpeed = 0.12; // seconds per frame

  // Visual
  static const double playerWidth = 44;
  static const double playerHeight = 64;

  Player() : super(size: Vector2(playerWidth, playerHeight));

  // Track which keys are pressed
  final Set<LogicalKeyboardKey> _keysPressed = {};

  void setMovingRight(bool move) {
    _isMovingRight = move;
    if (move) _facingRight = true;
  }

  void setMovingLeft(bool move) {
    _isMovingLeft = move;
    if (move) _facingRight = false;
  }

  void onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _keysPressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }

    setMovingRight(
      _keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          _keysPressed.contains(LogicalKeyboardKey.keyD),
    );
    setMovingLeft(
      _keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          _keysPressed.contains(LogicalKeyboardKey.keyA),
    );

    // Jump with up arrow, W or space
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.keyW ||
          event.logicalKey == LogicalKeyboardKey.space) {
        jump();
      }
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _groundY = gameRef.size.y * 0.75 - playerHeight;
    // Start at center of screen
    position = Vector2(gameRef.size.x / 2 - playerWidth / 2, _groundY);

    // Add hitbox for collision
    add(
      RectangleHitbox(
        size: Vector2(playerWidth - 10, playerHeight - 6),
        position: Vector2(5, 3),
      ),
    );
  }

  void jump() {
    if (_isOnGround) {
      _velocityY = _jumpForce;
      _isOnGround = false;
    }
  }

  bool get isMoving => _isMovingRight || _isMovingLeft;

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGameOver) return;

    // Horizontal movement
    _velocityX = 0;
    if (_isMovingRight) {
      _velocityX = _moveSpeed;
      _facingRight = true;
    }
    if (_isMovingLeft) {
      _velocityX = -_moveSpeed;
      _facingRight = false;
    }

    position.x += _velocityX * dt;

    // Clamp to screen bounds
    position.x = position.x.clamp(0, gameRef.size.x - playerWidth);

    // Apply gravity
    _velocityY += _gravity * dt;
    position.y += _velocityY * dt;

    // Check ground collision
    if (position.y >= _groundY) {
      position.y = _groundY;
      _velocityY = 0;
      _isOnGround = true;
    }

    // Running animation timer
    if (isMoving && _isOnGround) {
      _runAnimTimer += dt;
      if (_runAnimTimer >= _runAnimSpeed) {
        _runAnimTimer = 0;
        _runFrame = (_runFrame + 1) % 4;
      }
    } else if (!isMoving) {
      _runFrame = 0;
      _runAnimTimer = 0;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Flip canvas if facing left
    if (!_facingRight) {
      canvas.save();
      canvas.translate(playerWidth, 0);
      canvas.scale(-1, 1);
    }

    // Shadow
    final shadowPaint = Paint()..color = Colors.black.withOpacity(0.15);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(playerWidth / 2, playerHeight - 2),
        width: 36,
        height: 8,
      ),
      shadowPaint,
    );

    // Body (shirt)
    final bodyPaint = Paint()..color = const Color(0xFF2196F3);
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 16, 24, 28),
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Shirt stripe detail
    final stripePaint = Paint()..color = const Color(0xFF1976D2);
    canvas.drawRect(Rect.fromLTWH(10, 28, 24, 3), stripePaint);

    // Head
    final headPaint = Paint()..color = const Color(0xFFFFCC80);
    canvas.drawCircle(const Offset(22, 12), 11, headPaint);

    // Hair
    final hairPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawArc(const Rect.fromLTWH(11, 1, 22, 18), pi, pi, true, hairPaint);

    // Eye
    final eyePaint = Paint()..color = const Color(0xFF333333);
    canvas.drawCircle(const Offset(27, 10), 2.2, eyePaint);
    // Eye highlight
    final eyeHighlight = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(27.8, 9.2), 0.8, eyeHighlight);

    // Mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFFE57373)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    if (isMoving) {
      // Open mouth when running
      canvas.drawArc(
        const Rect.fromLTWH(24, 13, 6, 4),
        0,
        pi,
        false,
        mouthPaint,
      );
    } else {
      // Smile when idle
      canvas.drawArc(
        const Rect.fromLTWH(24, 14, 5, 3),
        0.1,
        pi * 0.8,
        false,
        mouthPaint,
      );
    }

    // Legs with running animation
    final legPaint = Paint()
      ..color = const Color(0xFF333333)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Shoes paint
    final shoePaint = Paint()..color = const Color(0xFFFF5722);

    if (!_isOnGround) {
      // Jumping - legs tucked
      canvas.drawLine(const Offset(16, 44), const Offset(13, 52), legPaint);
      canvas.drawLine(const Offset(28, 44), const Offset(31, 52), legPaint);
      canvas.drawCircle(const Offset(13, 52), 3, shoePaint);
      canvas.drawCircle(const Offset(31, 52), 3, shoePaint);
    } else if (isMoving) {
      // Running animation - 4 frames
      final legPositions = _getRunningLegPositions();
      // Left leg
      canvas.drawLine(
        const Offset(16, 44),
        Offset(16 + legPositions[0], 44 + legPositions[1]),
        legPaint,
      );
      canvas.drawCircle(
        Offset(16 + legPositions[0], 44 + legPositions[1]),
        3,
        shoePaint,
      );
      // Right leg
      canvas.drawLine(
        const Offset(28, 44),
        Offset(28 + legPositions[2], 44 + legPositions[3]),
        legPaint,
      );
      canvas.drawCircle(
        Offset(28 + legPositions[2], 44 + legPositions[3]),
        3,
        shoePaint,
      );
    } else {
      // Standing idle
      canvas.drawLine(const Offset(16, 44), const Offset(14, 58), legPaint);
      canvas.drawLine(const Offset(28, 44), const Offset(30, 58), legPaint);
      canvas.drawCircle(const Offset(14, 58), 3, shoePaint);
      canvas.drawCircle(const Offset(30, 58), 3, shoePaint);
    }

    // Arms with animation
    final armPaint = Paint()
      ..color = const Color(0xFFFFCC80)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (isMoving && _isOnGround) {
      // Swinging arms while running
      final armSwing = sin(_runFrame * pi / 2) * 6;
      canvas.drawLine(const Offset(10, 22), Offset(4 - armSwing, 34), armPaint);
      canvas.drawLine(
        const Offset(34, 22),
        Offset(40 + armSwing, 32),
        armPaint,
      );
    } else {
      // Idle arms
      canvas.drawLine(const Offset(10, 22), const Offset(4, 34), armPaint);
      canvas.drawLine(const Offset(34, 22), const Offset(40, 32), armPaint);
    }

    if (!_facingRight) {
      canvas.restore();
    }
  }

  List<double> _getRunningLegPositions() {
    // Returns [leftLegDX, leftLegDY, rightLegDX, rightLegDY]
    switch (_runFrame) {
      case 0:
        return [-6, 14, 8, 12];
      case 1:
        return [-2, 16, 4, 10];
      case 2:
        return [8, 12, -6, 14];
      case 3:
        return [4, 10, -2, 16];
      default:
        return [0, 14, 0, 14];
    }
  }
}
