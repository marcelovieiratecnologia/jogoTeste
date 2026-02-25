import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/player.dart';
import '../components/ground.dart';
import '../components/obstacle.dart';
import '../components/background.dart';

class RunnerGame extends FlameGame
    with TapCallbacks, HasCollisionDetection, KeyboardEvents {
  final VoidCallback onGameOver;
  final ValueChanged<int> onScoreUpdate;

  RunnerGame({required this.onGameOver, required this.onScoreUpdate});

  Player player = Player();
  late Ground ground;
  late Background background;

  final Random _random = Random();
  double _obstacleTimer = 0;
  double _obstacleInterval = 1.8; // seconds between obstacles
  double _gameSpeed = 300; // pixels per second
  int _score = 0;
  double _scoreTimer = 0;
  bool _isGameOver = false;
  bool _hasStarted = false;
  double _speedIncreaseTimer = 0;

  double get gameSpeed => _gameSpeed;
  bool get isGameOver => _isGameOver;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Sky blue

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background
    background = Background();
    add(background);

    // Add ground
    ground = Ground();
    add(ground);

    // Add player
    add(player);
  }

  void startGame() {
    _hasStarted = true;
    _isGameOver = false;
    _score = 0;
    _obstacleTimer = 0;
    _gameSpeed = 300;
    _obstacleInterval = 1.8;
    _scoreTimer = 0;
    _speedIncreaseTimer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!_hasStarted || _isGameOver) return;

    // Score timer
    _scoreTimer += dt;
    if (_scoreTimer >= 0.1) {
      _score++;
      _scoreTimer = 0;
      onScoreUpdate(_score);
    }

    // Increase speed over time
    _speedIncreaseTimer += dt;
    if (_speedIncreaseTimer >= 5) {
      _gameSpeed += 20;
      if (_obstacleInterval > 0.8) {
        _obstacleInterval -= 0.05;
      }
      _speedIncreaseTimer = 0;
    }

    // Spawn obstacles
    _obstacleTimer += dt;
    if (_obstacleTimer >= _obstacleInterval) {
      _obstacleTimer = 0;
      _spawnObstacle();
    }
  }

  void _spawnObstacle() {
    final groundY = size.y * 0.75;

    // Randomly choose obstacle size
    final heightOptions = [40.0, 55.0, 70.0];
    final widthOptions = [30.0, 40.0, 25.0];
    final index = _random.nextInt(heightOptions.length);
    final obstacleHeight = heightOptions[index];
    final obstacleWidth = widthOptions[index];

    final obstacle = Obstacle(
      obstacleSize: Vector2(obstacleWidth, obstacleHeight),
      groundY: groundY,
      gameSpeedGetter: () => _gameSpeed,
      onPlayerHit: gameOver,
    );

    add(obstacle);
  }

  void gameOver() {
    if (_isGameOver) return;
    _isGameOver = true;
    onGameOver();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_hasStarted || _isGameOver) return;
    player.jump();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!_hasStarted || _isGameOver) return KeyEventResult.ignored;
    player.onKeyEvent(event);
    return KeyEventResult.handled;
  }
}
