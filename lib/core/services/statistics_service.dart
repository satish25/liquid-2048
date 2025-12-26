import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_settings.dart';
import '../models/game_statistics.dart';

/// Service for managing game statistics
class StatisticsService {
  final SharedPreferences _prefs;
  static const _statsKey = 'game_statistics';

  StatisticsService(this._prefs);

  /// Load statistics from storage
  GameStatistics loadStatistics() {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString == null) {
      return const GameStatistics();
    }
    try {
      final json = jsonDecode(jsonString);
      return GameStatistics.fromJson(json);
    } catch (e) {
      return const GameStatistics();
    }
  }

  /// Save statistics to storage
  Future<void> saveStatistics(GameStatistics stats) async {
    final jsonString = jsonEncode(stats.toJson());
    await _prefs.setString(_statsKey, jsonString);
  }

  /// Record a completed game
  Future<GameStatistics> recordGameCompleted({
    required int score,
    required int highestTile,
    required bool won,
    required int moves,
    required Duration playTime,
    required GameMode mode,
    required GridSize gridSize,
  }) async {
    var stats = loadStatistics();

    // Update recent scores (keep last 10)
    final newRecentScores = List<int>.from(stats.recentScores);
    newRecentScores.add(score);
    if (newRecentScores.length > 10) {
      newRecentScores.removeAt(0);
    }

    // Update high scores by mode
    final newModeScores = Map<String, int>.from(stats.highScoresByMode);
    final currentModeScore = newModeScores[mode.name] ?? 0;
    if (score > currentModeScore) {
      newModeScores[mode.name] = score;
    }

    // Update high scores by grid size
    final newGridScores = Map<String, int>.from(stats.highScoresByGridSize);
    final gridKey = '${gridSize.dimension}x${gridSize.dimension}';
    final currentGridScore = newGridScores[gridKey] ?? 0;
    if (score > currentGridScore) {
      newGridScores[gridKey] = score;
    }

    // Check for streak
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastPlayed = stats.lastPlayedDate;
    int newStreak = stats.currentStreak;

    if (lastPlayed != null) {
      final lastPlayedDay = DateTime(
        lastPlayed.year,
        lastPlayed.month,
        lastPlayed.day,
      );
      final daysDiff = today.difference(lastPlayedDay).inDays;

      if (daysDiff == 1) {
        // Consecutive day - increase streak
        newStreak = stats.currentStreak + 1;
      } else if (daysDiff > 1) {
        // Streak broken
        newStreak = 1;
      }
      // Same day - keep same streak
    } else {
      newStreak = 1;
    }

    stats = stats.copyWith(
      totalGamesPlayed: stats.totalGamesPlayed + 1,
      totalGamesWon: won ? stats.totalGamesWon + 1 : stats.totalGamesWon,
      highestScore: score > stats.highestScore ? score : stats.highestScore,
      highestTile: highestTile > stats.highestTile
          ? highestTile
          : stats.highestTile,
      totalMoves: stats.totalMoves + moves,
      totalTimePlayed: stats.totalTimePlayed + playTime,
      highScoresByMode: newModeScores,
      highScoresByGridSize: newGridScores,
      currentStreak: newStreak,
      bestStreak: newStreak > stats.bestStreak ? newStreak : stats.bestStreak,
      lastPlayedDate: now,
      recentScores: newRecentScores,
    );

    await saveStatistics(stats);
    return stats;
  }

  /// Record daily challenge completion
  Future<GameStatistics> recordDailyChallengeCompleted() async {
    var stats = loadStatistics();
    stats = stats.copyWith(
      dailyChallengesCompleted: stats.dailyChallengesCompleted + 1,
    );
    await saveStatistics(stats);
    return stats;
  }

  /// Reset all statistics
  Future<void> resetStatistics() async {
    await _prefs.remove(_statsKey);
  }
}
