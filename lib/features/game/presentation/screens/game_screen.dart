import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../shared/theme/app_theme.dart';
import '../providers/game_provider.dart';
import '../widgets/game_grid.dart';
import '../widgets/score_panel.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_overlay.dart';

/// Main game screen with the 2048 grid
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    // Add haptic feedback on game over or win
    ref.listen(gameProvider, (previous, next) {
      if (next.isGameOver && (previous == null || !previous.isGameOver)) {
        HapticFeedback.heavyImpact();
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
              // Background decorative elements
              _buildBackgroundDecorations(),
              // Main content
              isLandscape
                  ? _buildLandscapeLayout(context)
                  : _buildPortraitLayout(context),
              // Overlays
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
        // Top left glow
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
        // Bottom right glow
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

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        // Header with back button and title
        _buildHeader(context),
        const SizedBox(height: 24),
        // Score panel
        const ScorePanel(),
        const SizedBox(height: 24),
        // Game grid (centered and constrained)
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: const GameGrid(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Controls
        const GameControls(),
        const SizedBox(height: 24),
        // Instructions
        _buildInstructions(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        // Left panel with info and controls
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(context, compact: true),
              const SizedBox(height: 24),
              const ScorePanel(),
              const Spacer(),
              const GameControls(),
              const SizedBox(height: 24),
              _buildInstructions(),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Right panel with grid
        Expanded(
          flex: 1,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
                child: const GameGrid(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {bool compact = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 8 : 16,
      ),
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

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'Swipe to move tiles. Merge same numbers to reach 2048!',
        style: GoogleFonts.rajdhani(
          fontSize: 14,
          color: Colors.white38,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

