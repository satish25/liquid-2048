import 'package:flutter/foundation.dart';

import '../../../core/models/game_settings.dart';
import 'tile.dart';

/// Represents the complete game state
@immutable
class GameState {
  final List<List<int>> grid;
  final List<Tile> tiles;
  final int score;
  final int highScore;
  final bool isGameOver;
  final bool isGameWon;
  final bool hasWonBefore;
  final List<GameState>? history;
  final int gridSize;
  final GameMode gameMode;
  final int movesCount;
  final int? timeLimitSeconds;
  final int? movesLimit;
  final DateTime? startTime;

  const GameState({
    required this.grid,
    required this.tiles,
    this.score = 0,
    this.highScore = 0,
    this.isGameOver = false,
    this.isGameWon = false,
    this.hasWonBefore = false,
    this.history,
    this.gridSize = 4,
    this.gameMode = GameMode.classic,
    this.movesCount = 0,
    this.timeLimitSeconds,
    this.movesLimit,
    this.startTime,
  });

  /// Creates the initial game state
  factory GameState.initial({int gridSize = 4}) {
    final grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    return GameState(
      grid: grid,
      tiles: const [],
      score: 0,
      isGameOver: false,
      isGameWon: false,
      history: const [],
      gridSize: gridSize,
    );
  }

  GameState copyWith({
    List<List<int>>? grid,
    List<Tile>? tiles,
    int? score,
    int? highScore,
    bool? isGameOver,
    bool? isGameWon,
    bool? hasWonBefore,
    List<GameState>? history,
    int? gridSize,
    GameMode? gameMode,
    int? movesCount,
    int? timeLimitSeconds,
    int? movesLimit,
    DateTime? startTime,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      tiles: tiles ?? this.tiles,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      isGameOver: isGameOver ?? this.isGameOver,
      isGameWon: isGameWon ?? this.isGameWon,
      hasWonBefore: hasWonBefore ?? this.hasWonBefore,
      history: history ?? this.history,
      gridSize: gridSize ?? this.gridSize,
      gameMode: gameMode ?? this.gameMode,
      movesCount: movesCount ?? this.movesCount,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      movesLimit: movesLimit ?? this.movesLimit,
      startTime: startTime ?? this.startTime,
    );
  }

  /// Deep copy the grid
  List<List<int>> copyGrid() {
    return grid.map((row) => List<int>.from(row)).toList();
  }

  /// Check if this is Zen mode (unlimited undos)
  bool get isZenMode => gameMode == GameMode.zen;

  /// Check if this is a timed mode
  bool get isTimedMode => gameMode == GameMode.timeAttack;

  /// Check if this is challenge mode with limited moves
  bool get hasMovesLimit => movesLimit != null && movesLimit! > 0;

  /// Get remaining moves in challenge mode
  int? get remainingMoves =>
      movesLimit != null ? movesLimit! - movesCount : null;

  /// Get the winning value based on grid size
  int get winningValue {
    switch (gridSize) {
      case 3:
        return 512;
      case 5:
        return 4096;
      case 6:
        return 8192;
      default:
        return 2048;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        listEquals(other.grid, grid) &&
        listEquals(other.tiles, tiles) &&
        other.score == score &&
        other.isGameOver == isGameOver &&
        other.isGameWon == isGameWon &&
        other.gridSize == gridSize &&
        other.gameMode == gameMode;
  }

  @override
  int get hashCode => Object.hash(
    grid,
    tiles,
    score,
    isGameOver,
    isGameWon,
    gridSize,
    gameMode,
  );
}

/// Direction for tile movement
enum Direction { up, down, left, right }
