import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/game_settings.dart';
import '../../../../core/services/daily_challenge_service.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/liquid_glass_container.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

/// Screen for selecting game mode, grid size, and other options
class ModeSelectionScreen extends ConsumerStatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  ConsumerState<ModeSelectionScreen> createState() =>
      _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends ConsumerState<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  GameMode _selectedMode = GameMode.classic;
  GridSize _selectedGridSize = GridSize.size4x4;
  int _selectedTimeLimit = 120; // seconds

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('GAME MODE'),
                      const SizedBox(height: 12),
                      _buildModeSelector(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('GRID SIZE'),
                      const SizedBox(height: 12),
                      _buildGridSizeSelector(),
                      if (_selectedMode == GameMode.timeAttack) ...[
                        const SizedBox(height: 32),
                        _buildSectionTitle('TIME LIMIT'),
                        const SizedBox(height: 12),
                        _buildTimeLimitSelector(),
                      ],
                      const SizedBox(height: 40),
                      _buildDailyChallenge(),
                      const SizedBox(height: 24),
                      _buildStartButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: LiquidColors.neonCyan,
            ),
          ),
          const Spacer(),
          Text(
            'SELECT MODE',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: LiquidColors.neonCyan,
        letterSpacing: 3,
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      children: [
        _buildModeCard(
          mode: GameMode.classic,
          icon: Icons.grid_4x4_rounded,
          title: 'Classic',
          description: 'The original 2048 experience',
          color: LiquidColors.neonCyan,
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          mode: GameMode.timeAttack,
          icon: Icons.timer_rounded,
          title: 'Time Attack',
          description: 'Race against the clock!',
          color: LiquidColors.neonOrange,
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          mode: GameMode.zen,
          icon: Icons.spa_rounded,
          title: 'Zen Mode',
          description: 'Unlimited undos, no pressure',
          color: LiquidColors.neonGreen,
        ),
        const SizedBox(height: 12),
        _buildModeCard(
          mode: GameMode.challenge,
          icon: Icons.emoji_events_rounded,
          title: 'Challenge',
          description: 'Limited moves to reach the goal',
          color: LiquidColors.neonPink,
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required GameMode mode,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? color.withOpacity(0.15)
              : Colors.white.withOpacity(0.03),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20)]
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(isSelected ? 0.3 : 0.1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.rajdhani(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    description,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSizeSelector() {
    return Row(
      children: GridSize.values.map((size) {
        final isSelected = _selectedGridSize == size;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedGridSize = size),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: size != GridSize.size6x6 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? LiquidColors.neonPurple
                      : Colors.white.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected
                    ? LiquidColors.neonPurple.withOpacity(0.15)
                    : Colors.white.withOpacity(0.03),
              ),
              child: Column(
                children: [
                  Text(
                    '${size.dimension}×${size.dimension}',
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? LiquidColors.neonPurple
                          : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getGridDifficulty(size),
                    style: GoogleFonts.rajdhani(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getGridDifficulty(GridSize size) {
    switch (size) {
      case GridSize.size3x3:
        return 'HARD';
      case GridSize.size4x4:
        return 'CLASSIC';
      case GridSize.size5x5:
        return 'MEDIUM';
      case GridSize.size6x6:
        return 'EASY';
    }
  }

  Widget _buildTimeLimitSelector() {
    final times = [60, 120, 180, 300];
    return Row(
      children: times.map((seconds) {
        final isSelected = _selectedTimeLimit == seconds;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTimeLimit = seconds),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: seconds != 300 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? LiquidColors.neonOrange
                      : Colors.white.withOpacity(0.1),
                  width: isSelected ? 2 : 1,
                ),
                color: isSelected
                    ? LiquidColors.neonOrange.withOpacity(0.15)
                    : Colors.white.withOpacity(0.03),
              ),
              child: Text(
                _formatTime(seconds),
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? LiquidColors.neonOrange : Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) return '${minutes}m';
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildDailyChallenge() {
    final dailyService = ref.read(dailyChallengeServiceProvider);
    final isCompleted = dailyService.isTodayCompleted();
    final challengeNumber = dailyService.getChallengeNumber();
    final timeUntilNext = dailyService.getTimeUntilNextChallenge();

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(20),
      borderColor: LiquidColors.neonYellow.withOpacity(0.5),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: LiquidColors.neonYellow.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: LiquidColors.neonYellow,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY CHALLENGE #$challengeNumber',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: LiquidColors.neonYellow,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Completed! Next in ${_formatDuration(timeUntilNext)}'
                          : 'Same puzzle for everyone today!',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: LiquidGlassButton(
              onPressed: isCompleted
                  ? () {}
                  : () => _startDailyChallenge(dailyService),
              accentColor: isCompleted ? Colors.grey : LiquidColors.neonYellow,
              child: Text(
                isCompleted ? 'COMPLETED ✓' : 'PLAY DAILY',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  void _startDailyChallenge(DailyChallengeService dailyService) {
    final startingTiles = dailyService.getTodayStartingTiles(4);

    ref.read(gameSettingsProvider.notifier).state = const GameSettings(
      mode: GameMode.daily,
      gridSize: GridSize.size4x4,
    );

    ref.read(gameProvider.notifier).startDailyChallenge(startingTiles);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: LiquidGlassButton(
        onPressed: _startGame,
        accentColor: LiquidColors.neonCyan,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Text(
              'START GAME',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    final settings = GameSettings(
      mode: _selectedMode,
      gridSize: _selectedGridSize,
      timeLimitSeconds: _selectedMode == GameMode.timeAttack
          ? _selectedTimeLimit
          : null,
      movesLimit: _selectedMode == GameMode.challenge ? 50 : null,
    );

    ref.read(gameSettingsProvider.notifier).state = settings;
    ref.read(gameProvider.notifier).startNewGame(settings);

    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
  }
}
