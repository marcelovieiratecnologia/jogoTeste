import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/runner_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  runApp(const RunnerApp());
}

class RunnerApp extends StatelessWidget {
  const RunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Runner Game',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late RunnerGame _game;
  bool _isGameOver = false;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = RunnerGame(
      onGameOver: _handleGameOver,
      onScoreUpdate: _handleScoreUpdate,
    );
  }

  int _score = 0;

  void _handleGameOver() {
    setState(() {
      _isGameOver = true;
    });
  }

  void _handleScoreUpdate(int score) {
    setState(() {
      _score = score;
    });
  }

  void _startGame() {
    setState(() {
      _hasStarted = true;
      _isGameOver = false;
      _score = 0;
    });
    _initGame();
    _game.startGame();
  }

  void _restartGame() {
    _startGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game Canvas
          GameWidget(game: _game),

          // HUD Controles (Apenas quando o jogo está rodando)
          if (_hasStarted && !_isGameOver) ..._buildControls(),

          // Score display
          if (_hasStarted && !_isGameOver)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Score: $_score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

          // Start Screen overlay
          if (!_hasStarted)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🏃 Runner Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Use onscreen buttons to move and jump!',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _startGame,
                      child: const Text(
                        'START',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Game Over overlay
          if (_isGameOver)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'GAME OVER',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Score: $_score',
                      style: const TextStyle(color: Colors.white, fontSize: 28),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _restartGame,
                      child: const Text(
                        'PLAY AGAIN',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildControls() {
    return [
      // Left button
      Positioned(
        bottom: 30,
        left: 30,
        child: _ControlButton(
          icon: Icons.arrow_back,
          onTapDown: () => _game.player.setMovingLeft(true),
          onTapUp: () => _game.player.setMovingLeft(false),
        ),
      ),
      // Right button
      Positioned(
        bottom: 30,
        left: 120,
        child: _ControlButton(
          icon: Icons.arrow_forward,
          onTapDown: () => _game.player.setMovingRight(true),
          onTapUp: () => _game.player.setMovingRight(false),
        ),
      ),
      // Jump button
      Positioned(
        bottom: 30,
        right: 30,
        child: _ControlButton(
          icon: Icons.arrow_upward,
          size: 70,
          onTapDown: () => _game.player.jump(),
          onTapUp: () {},
        ),
      ),
    ];
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTapDown,
    required this.onTapUp,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 2),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.6),
      ),
    );
  }
}
