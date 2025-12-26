import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing daily challenges
class DailyChallengeService {
  final SharedPreferences _prefs;
  static const _completedKey = 'daily_challenge_completed';
  static const _lastDateKey = 'daily_challenge_last_date';
  static const _bestScoreKey = 'daily_challenge_best_score';

  DailyChallengeService(this._prefs);

  /// Get today's challenge seed (same for all users)
  int getTodaySeed() {
    final now = DateTime.now();
    // Create a unique seed based on the date
    return now.year * 10000 + now.month * 100 + now.day;
  }

  /// Get a random number generator seeded with today's date
  Random getTodayRandom() {
    return Random(getTodaySeed());
  }

  /// Check if today's challenge has been completed
  bool isTodayCompleted() {
    final lastDate = _prefs.getString(_lastDateKey);
    if (lastDate == null) return false;

    final today = _getTodayString();
    return lastDate == today;
  }

  /// Mark today's challenge as completed
  Future<void> completeToday(int score) async {
    final today = _getTodayString();
    await _prefs.setString(_lastDateKey, today);
    await _prefs.setBool(_completedKey, true);

    // Update best score if higher
    final bestScore = _prefs.getInt(_bestScoreKey) ?? 0;
    if (score > bestScore) {
      await _prefs.setInt(_bestScoreKey, score);
    }
  }

  /// Get best daily challenge score
  int getBestScore() {
    return _prefs.getInt(_bestScoreKey) ?? 0;
  }

  /// Get today's starting tiles (deterministic based on seed)
  List<(int row, int col, int value)> getTodayStartingTiles(int gridSize) {
    final random = getTodayRandom();
    final tiles = <(int row, int col, int value)>[];

    // Place 2-4 starting tiles based on difficulty
    final numTiles = 2 + random.nextInt(3); // 2-4 tiles
    final positions = <(int, int)>{};

    while (positions.length < numTiles) {
      final row = random.nextInt(gridSize);
      final col = random.nextInt(gridSize);
      positions.add((row, col));
    }

    for (final pos in positions) {
      final value = random.nextDouble() < 0.9 ? 2 : 4;
      tiles.add((pos.$1, pos.$2, value));
    }

    return tiles;
  }

  /// Get days until next challenge resets
  Duration getTimeUntilNextChallenge() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get the challenge number (days since a reference date)
  int getChallengeNumber() {
    final referenceDate = DateTime(2025, 1, 1);
    final now = DateTime.now();
    return now.difference(referenceDate).inDays + 1;
  }

  /// Get a difficulty modifier for today (varies day to day)
  double getTodayDifficultyModifier() {
    final random = getTodayRandom();
    // Returns a value between 0.8 and 1.2
    return 0.8 + (random.nextDouble() * 0.4);
  }
}
