import 'package:flutter/foundation.dart';
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

  const GameState({
    required this.grid,
    required this.tiles,
    this.score = 0,
    this.highScore = 0,
    this.isGameOver = false,
    this.isGameWon = false,
    this.hasWonBefore = false,
    this.history,
  });

  /// Creates the initial game state
  factory GameState.initial() {
    return const GameState(
      grid: [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      tiles: [],
      score: 0,
      isGameOver: false,
      isGameWon: false,
      history: [],
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
    );
  }

  /// Deep copy the grid
  List<List<int>> copyGrid() {
    return grid.map((row) => List<int>.from(row)).toList();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        listEquals(other.grid, grid) &&
        listEquals(other.tiles, tiles) &&
        other.score == score &&
        other.isGameOver == isGameOver &&
        other.isGameWon == isGameWon;
  }

  @override
  int get hashCode => Object.hash(
        grid,
        tiles,
        score,
        isGameOver,
        isGameWon,
      );
}

/// Direction for tile movement
enum Direction { up, down, left, right }

