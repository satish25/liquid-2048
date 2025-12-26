import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/game_settings.dart';
import '../../../../shared/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_overlay.dart';
import '../widgets/score_panel.dart';

/// Main game screen with the 2048 grid
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  void _startTimerIfNeeded() {
    final settings = ref.read(gameSettingsProvider);
    if (settings.mode == GameMode.timeAttack) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _elapsedSeconds++;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final settings = ref.watch(gameSettingsProvider);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    // Add haptic feedback on game over or win
    ref.listen(gameProvider, (previous, next) {
      if (next.isGameOver && (previous == null || !previous.isGameOver)) {
        HapticFeedback.heavyImpact();
        _timer?.cancel();
      }
      if (next.isGameWon && (previous == null || !previous.isGameWon)) {
        HapticFeedback.heavyImpact();
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LiquidColors.backgroundDark1,
              LiquidColors.backgroundDark2,
              LiquidColors.backgroundDark3,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _buildBackgroundDecorations(),
              isLandscape
                  ? _buildLandscapeLayout(context, settings)
                  : _buildPortraitLayout(context, settings),
              if (gameState.isGameOver) const GameOverOverlay(),
              if (gameState.isGameWon) const GameWonOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  LiquidColors.neonCyan.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  LiquidColors.neonPink.withOpacity(0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(BuildContext context, GameSettings settings) {
    return Column(
      children: [
        _buildHeader(context, settings),
        const SizedBox(height: 16),
        _buildGameModeIndicator(settings),
        const SizedBox(height: 16),
        const ScorePanel(),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: const GameGrid(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const GameControls(),
        const SizedBox(height: 16),
        _buildInstructions(settings),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, GameSettings settings) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(context, settings, compact: true),
              const SizedBox(height: 16),
              _buildGameModeIndicator(settings),
              const SizedBox(height: 16),
              const ScorePanel(),
              const Spacer(),
              const GameControls(),
              const SizedBox(height: 16),
              _buildInstructions(settings),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 500,
                ),
                child: const GameGrid(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    GameSettings settings, {
    bool compact = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 8 : 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: LiquidColors.neonCyan,
            ),
          ),
          if (!compact) const Spacer(),
          Text(
            'LIQUID 2048',
            style: GoogleFonts.orbitron(
              fontSize: compact ? 18 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: LiquidColors.neonCyan.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          if (!compact) const Spacer(),
          if (!compact) const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGameModeIndicator(GameSettings settings) {
    final gameState = ref.watch(gameProvider);

    Color modeColor;
    IconData modeIcon;
    String modeText;
    String? extraInfo;

    switch (settings.mode) {
      case GameMode.classic:
        modeColor = LiquidColors.neonCyan;
        modeIcon = Icons.grid_4x4_rounded;
        modeText = 'CLASSIC';
        break;
      case GameMode.timeAttack:
        modeColor = LiquidColors.neonOrange;
        modeIcon = Icons.timer_rounded;
        modeText = 'TIME ATTACK';
        final remaining = (settings.timeLimitSeconds ?? 120) - _elapsedSeconds;
        extraInfo = _formatTime(
          remaining.clamp(0, settings.timeLimitSeconds ?? 120),
        );
        break;
      case GameMode.zen:
        modeColor = LiquidColors.neonGreen;
        modeIcon = Icons.spa_rounded;
        modeText = 'ZEN MODE';
        break;
      case GameMode.challenge:
        modeColor = LiquidColors.neonPink;
        modeIcon = Icons.emoji_events_rounded;
        modeText = 'CHALLENGE';
        extraInfo = '${gameState.remainingMoves ?? 0} moves left';
        break;
      case GameMode.daily:
        modeColor = LiquidColors.neonYellow;
        modeIcon = Icons.calendar_today_rounded;
        modeText = 'DAILY CHALLENGE';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: modeColor.withOpacity(0.15),
              border: Border.all(color: modeColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(modeIcon, color: modeColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  modeText,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: modeColor,
                    letterSpacing: 1,
                  ),
                ),
                if (extraInfo != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 16,
                    color: modeColor.withOpacity(0.3),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    extraInfo,
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: LiquidColors.neonPurple.withOpacity(0.15),
              border: Border.all(
                color: LiquidColors.neonPurple.withOpacity(0.5),
              ),
            ),
            child: Text(
              '${settings.gridSize.dimension}×${settings.gridSize.dimension}',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: LiquidColors.neonPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildInstructions(GameSettings settings) {
    String instruction;
    switch (settings.mode) {
      case GameMode.zen:
        instruction = 'Unlimited undos available. Play at your own pace!';
        break;
      case GameMode.timeAttack:
        instruction = 'Score as high as you can before time runs out!';
        break;
      case GameMode.challenge:
        instruction =
            'Reach ${settings.gridSize == GridSize.size4x4 ? '2048' : settings.winningValue} within the move limit!';
        break;
      case GameMode.daily:
        instruction = 'Complete today\'s puzzle. Same challenge for everyone!';
        break;
      default:
        instruction =
            'Swipe to move tiles. Merge same numbers to reach ${settings.winningValue}!';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        instruction,
        style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white38),
        textAlign: TextAlign.center,
      ),
    );
  }
}
