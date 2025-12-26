import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/game_settings.dart';
import '../../../../core/models/game_statistics.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/daily_challenge_service.dart';
import '../../../../core/services/score_service.dart';
import '../../../../core/services/statistics_service.dart';
import '../../domain/game_manager.dart';
import '../../domain/game_state.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for ScoreService
final scoreServiceProvider = Provider<ScoreService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ScoreService(prefs);
});

/// Provider for StatisticsService
final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return StatisticsService(prefs);
});

/// Provider for DailyChallengeService
final dailyChallengeServiceProvider = Provider<DailyChallengeService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DailyChallengeService(prefs);
});

/// Provider for the current game settings
final gameSettingsProvider = StateProvider<GameSettings>((ref) {
  return const GameSettings();
});

/// Provider for game statistics
final gameStatisticsProvider =
    StateNotifierProvider<StatisticsNotifier, GameStatistics>((ref) {
      final service = ref.watch(statisticsServiceProvider);
      return StatisticsNotifier(service);
    });

class StatisticsNotifier extends StateNotifier<GameStatistics> {
  final StatisticsService _service;

  StatisticsNotifier(this._service) : super(const GameStatistics()) {
    _loadStats();
  }

  void _loadStats() {
    state = _service.loadStatistics();
  }

  Future<void> recordGame({
    required int score,
    required int highestTile,
    required bool won,
    required int moves,
    required Duration playTime,
    required GameMode mode,
    required GridSize gridSize,
  }) async {
    state = await _service.recordGameCompleted(
      score: score,
      highestTile: highestTile,
      won: won,
      moves: moves,
      playTime: playTime,
      mode: mode,
      gridSize: gridSize,
    );
  }

  Future<void> recordDailyCompleted() async {
    state = await _service.recordDailyChallengeCompleted();
  }

  void refresh() {
    _loadStats();
  }
}

/// Provider for the high score with cloud sync
final highScoreProvider = StateNotifierProvider<HighScoreNotifier, int>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final scoreService = ref.watch(scoreServiceProvider);
  final authState = ref.watch(authStateProvider);
  return HighScoreNotifier(prefs, scoreService, authState.isGuest);
});

class HighScoreNotifier extends StateNotifier<int> {
  final SharedPreferences _prefs;
  final ScoreService _scoreService;
  final bool _isGuest;
  static const _key = 'high_score';

  HighScoreNotifier(this._prefs, this._scoreService, this._isGuest)
    : super(_prefs.getInt(_key) ?? 0) {
    _loadScore();
  }

  Future<void> _loadScore() async {
    final score = await _scoreService.getBestScore(isGuest: _isGuest);
    if (score > state) {
      state = score;
    }
  }

  Future<void> update(int score) async {
    if (score > state) {
      state = score;
      _prefs.setInt(_key, score);

      // Sync to cloud
      await _scoreService.updateHighScore(score, isGuest: _isGuest);
    }
  }

  /// Force refresh from cloud (called after login)
  Future<void> refreshFromCloud() async {
    if (!_isGuest) {
      final cloudScore = await _scoreService.fetchCloudScore();
      if (cloudScore > state) {
        state = cloudScore;
        _prefs.setInt(_key, cloudScore);
      }
    }
  }

  /// Sync local score to cloud (called on login)
  Future<void> syncToCloud() async {
    if (!_isGuest) {
      final bestScore = await _scoreService.syncOnLogin();
      if (bestScore > state) {
        state = bestScore;
        _prefs.setInt(_key, bestScore);
      }
    }
  }
}

/// Main game state provider
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final highScore = ref.read(highScoreProvider);
  final scoreService = ref.read(scoreServiceProvider);
  final settings = ref.watch(gameSettingsProvider);
  return GameNotifier(ref, highScore, scoreService, settings);
});

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  // ignore: unused_field
  final ScoreService _scoreService;
  final GameSettings _settings;
  Timer? _gameTimer;
  DateTime? _gameStartTime;

  GameNotifier(this._ref, int highScore, this._scoreService, this._settings)
    : super(GameManager.newGame(highScore: highScore, settings: _settings)) {
    if (_settings.mode == GameMode.timeAttack) {
      _startTimer();
    }
    _gameStartTime = DateTime.now();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Handle time attack countdown
      if (state.timeLimitSeconds != null) {
        final elapsed = DateTime.now()
            .difference(_gameStartTime ?? DateTime.now())
            .inSeconds;
        if (elapsed >= state.timeLimitSeconds!) {
          // Time's up!
          state = state.copyWith(isGameOver: true);
          _gameTimer?.cancel();
          _recordGameEnd();
        }
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void move(Direction direction) {
    final newState = GameManager.move(state, direction);
    if (newState != state) {
      state = newState;
      _ref.read(highScoreProvider.notifier).update(state.score);

      if (state.isGameOver || state.isGameWon) {
        _recordGameEnd();
      }
    }
  }

  void _recordGameEnd() {
    final playTime = DateTime.now().difference(
      _gameStartTime ?? DateTime.now(),
    );
    final highestTile = GameManager.getHighestTile(state.grid);

    _ref
        .read(gameStatisticsProvider.notifier)
        .recordGame(
          score: state.score,
          highestTile: highestTile,
          won: state.isGameWon,
          moves: state.movesCount,
          playTime: playTime,
          mode: state.gameMode,
          gridSize: GridSize.values.firstWhere(
            (g) => g.dimension == state.gridSize,
            orElse: () => GridSize.size4x4,
          ),
        );
  }

  void restart() {
    _gameTimer?.cancel();
    GameManager.resetTileIdCounter();
    _scoreService.incrementGamesPlayed();
    state = GameManager.newGame(
      highScore: state.highScore,
      settings: _settings,
    );
    _gameStartTime = DateTime.now();

    if (_settings.mode == GameMode.timeAttack) {
      _startTimer();
    }
  }

  void startNewGame(GameSettings settings) {
    _gameTimer?.cancel();
    GameManager.resetTileIdCounter();
    _scoreService.incrementGamesPlayed();
    state = GameManager.newGame(highScore: state.highScore, settings: settings);
    _gameStartTime = DateTime.now();

    if (settings.mode == GameMode.timeAttack) {
      _startTimer();
    }
  }

  void startDailyChallenge(List<(int, int, int)> startingTiles) {
    _gameTimer?.cancel();
    GameManager.resetTileIdCounter();
    state = GameManager.newDailyChallenge(
      highScore: state.highScore,
      startingTiles: startingTiles,
      gridSize: 4,
    );
    _gameStartTime = DateTime.now();
  }

  void undo() {
    // In Zen mode, always allow undo
    // In other modes, check if history is available
    if (state.gameMode == GameMode.zen ||
        (state.history?.isNotEmpty ?? false)) {
      state = GameManager.undo(state);
    }
  }

  void continueGame() {
    state = GameManager.continueGame(state);
  }

  /// Update high score from cloud sync
  void updateHighScore(int newHighScore) {
    if (newHighScore > state.highScore) {
      state = state.copyWith(highScore: newHighScore);
    }
  }

  bool get canUndo {
    if (state.gameMode == GameMode.zen) {
      return state.history != null && state.history!.isNotEmpty;
    }
    return state.history != null && state.history!.isNotEmpty;
  }

  /// Get elapsed time for time attack mode
  int getElapsedSeconds() {
    if (_gameStartTime == null) return 0;
    return DateTime.now().difference(_gameStartTime!).inSeconds;
  }

  /// Get remaining time for time attack mode
  int? getRemainingSeconds() {
    if (state.timeLimitSeconds == null) return null;
    final elapsed = getElapsedSeconds();
    return (state.timeLimitSeconds! - elapsed).clamp(
      0,
      state.timeLimitSeconds!,
    );
  }
}

/// Provider for checking if undo is available
final canUndoProvider = Provider<bool>((ref) {
  final gameState = ref.watch(gameProvider);
  return gameState.history != null && gameState.history!.isNotEmpty;
});

/// Provider to sync scores on auth state change
final scoreSyncProvider = Provider<void>((ref) {
  final authState = ref.watch(authStateProvider);
  final scoreService = ref.read(scoreServiceProvider);

  // When user logs in, sync their score
  if (authState.status == AuthStatus.authenticated && !authState.isGuest) {
    Future.microtask(() async {
      await scoreService.syncOnLogin();
      ref.read(highScoreProvider.notifier).refreshFromCloud();
    });
  }

  return;
});

/// Provider for current visual theme
final currentThemeIdProvider = StateProvider<String>((ref) {
  return 'liquid_neon';
});
