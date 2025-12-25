import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/score_service.dart';
import '../../domain/game_state.dart';
import '../../domain/game_manager.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for ScoreService
final scoreServiceProvider = Provider<ScoreService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ScoreService(prefs);
});

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
  final authState = ref.watch(authStateProvider);
  return GameNotifier(ref, highScore, scoreService, authState.isGuest);
});

class GameNotifier extends StateNotifier<GameState> {
  final Ref _ref;
  final ScoreService _scoreService;
  final bool _isGuest;

  GameNotifier(this._ref, int highScore, this._scoreService, this._isGuest)
      : super(GameManager.newGame(highScore: highScore));

  void move(Direction direction) {
    final newState = GameManager.move(state, direction);
    if (newState != state) {
      state = newState;
      _ref.read(highScoreProvider.notifier).update(state.score);
    }
  }

  void restart() {
    GameManager.resetTileIdCounter();
    // Increment games played counter
    _scoreService.incrementGamesPlayed();
    state = GameManager.newGame(highScore: state.highScore);
  }

  void undo() {
    state = GameManager.undo(state);
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

  bool get canUndo => state.history != null && state.history!.isNotEmpty;
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
      final bestScore = await scoreService.syncOnLogin();
      ref.read(highScoreProvider.notifier).state;
    });
  }
  
  return;
});
