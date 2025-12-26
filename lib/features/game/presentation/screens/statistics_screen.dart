import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/game_statistics.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/liquid_glass_container.dart';
import '../providers/game_provider.dart';

/// Screen displaying comprehensive game statistics
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gameStatisticsProvider);

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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewCards(stats),
                      const SizedBox(height: 24),
                      _buildSectionTitle('ACHIEVEMENTS'),
                      const SizedBox(height: 12),
                      _buildAchievementCards(stats),
                      const SizedBox(height: 24),
                      _buildSectionTitle('RECORDS BY MODE'),
                      const SizedBox(height: 12),
                      _buildModeRecords(stats),
                      const SizedBox(height: 24),
                      _buildSectionTitle('RECORDS BY GRID'),
                      const SizedBox(height: 12),
                      _buildGridRecords(stats),
                      const SizedBox(height: 24),
                      _buildSectionTitle('RECENT SCORES'),
                      const SizedBox(height: 12),
                      _buildRecentScores(stats),
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

  Widget _buildHeader(BuildContext context) {
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
            'STATISTICS',
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

  Widget _buildOverviewCards(GameStatistics stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.sports_esports_rounded,
                label: 'Games Played',
                value: stats.totalGamesPlayed.toString(),
                color: LiquidColors.neonCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events_rounded,
                label: 'Games Won',
                value: stats.totalGamesWon.toString(),
                color: LiquidColors.neonYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.percent_rounded,
                label: 'Win Rate',
                value: '${stats.winRate.toStringAsFixed(1)}%',
                color: LiquidColors.neonGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.timer_rounded,
                label: 'Time Played',
                value: stats.formattedTimePlayed,
                color: LiquidColors.neonPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.rajdhani(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCards(GameStatistics stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.leaderboard_rounded,
                title: 'Best Score',
                value: stats.highestScore.toString(),
                color: LiquidColors.neonYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.grid_on_rounded,
                title: 'Highest Tile',
                value: stats.highestTile.toString(),
                color: LiquidColors.neonOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Current Streak',
                value: '${stats.currentStreak} days',
                color: LiquidColors.neonPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.whatshot_rounded,
                title: 'Best Streak',
                value: '${stats.bestStreak} days',
                color: LiquidColors.neonCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.swipe_rounded,
                title: 'Total Moves',
                value: _formatNumber(stats.totalMoves),
                color: LiquidColors.neonPurple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                icon: Icons.calendar_month_rounded,
                title: 'Daily Challenges',
                value: stats.dailyChallengesCompleted.toString(),
                color: LiquidColors.neonGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeRecords(GameStatistics stats) {
    final modes = {
      'classic': ('Classic', LiquidColors.neonCyan),
      'timeAttack': ('Time Attack', LiquidColors.neonOrange),
      'zen': ('Zen', LiquidColors.neonGreen),
      'challenge': ('Challenge', LiquidColors.neonPink),
      'daily': ('Daily', LiquidColors.neonYellow),
    };

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: modes.entries.map((entry) {
          final score = stats.highScoresByMode[entry.key] ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.value.$2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  entry.value.$1,
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  score > 0 ? score.toString() : '-',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: score > 0 ? entry.value.$2 : Colors.white24,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGridRecords(GameStatistics stats) {
    final grids = ['3x3', '4x4', '5x5', '6x6'];

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: grids.map((grid) {
          final score = stats.highScoresByGridSize[grid] ?? 0;
          return Column(
            children: [
              Text(
                grid,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  color: LiquidColors.neonPurple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                score > 0 ? score.toString() : '-',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: score > 0 ? Colors.white : Colors.white24,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentScores(GameStatistics stats) {
    if (stats.recentScores.isEmpty) {
      return LiquidGlassContainer(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No games played yet',
            style: GoogleFonts.rajdhani(fontSize: 16, color: Colors.white38),
          ),
        ),
      );
    }

    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: stats.recentScores.reversed.toList().asMap().entries.map((
          entry,
        ) {
          final index = entry.key;
          final score = entry.value;
          final isLatest = index == 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isLatest
                        ? LiquidColors.neonCyan.withOpacity(0.2)
                        : Colors.white.withOpacity(0.05),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        color: isLatest
                            ? LiquidColors.neonCyan
                            : Colors.white38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: LiquidColors.neonCyan.withOpacity(0.2),
                    ),
                    child: Text(
                      'LATEST',
                      style: GoogleFonts.orbitron(
                        fontSize: 8,
                        color: LiquidColors.neonCyan,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  score.toString(),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                    color: isLatest ? Colors.white : Colors.white54,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
