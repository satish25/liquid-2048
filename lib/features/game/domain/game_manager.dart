import 'dart:math';

import '../../../core/models/game_settings.dart';
import 'game_state.dart';
import 'tile.dart';

/// Pure functions for game logic - can be tested independently from UI
/// Now supports multiple grid sizes and game modes
class GameManager {
  static const int defaultGridSize = 4;
  static const int defaultWinningValue = 2048;
  static int _tileIdCounter = 0;

  /// Generates a unique ID for a new tile
  static String _generateTileId() {
    return 'tile_${_tileIdCounter++}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Resets the tile ID counter (useful for testing)
  static void resetTileIdCounter() {
    _tileIdCounter = 0;
  }

  /// Creates a new game with two random tiles
  static GameState newGame({
    int highScore = 0,
    GameSettings settings = const GameSettings(),
    Random? random,
  }) {
    final gridSize = settings.gridDimension;
    final grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));

    var state = GameState(
      grid: grid,
      tiles: const [],
      score: 0,
      highScore: highScore,
      isGameOver: false,
      isGameWon: false,
      hasWonBefore: false,
      history: const [],
      gridSize: gridSize,
      gameMode: settings.mode,
      movesCount: 0,
      timeLimitSeconds: settings.timeLimitSeconds,
      movesLimit: settings.movesLimit,
    );

    state = addRandomTile(state, random: random);
    state = addRandomTile(state, random: random);
    return state;
  }

  /// Creates a new game for daily challenge with specific starting tiles
  static GameState newDailyChallenge({
    int highScore = 0,
    required List<(int row, int col, int value)> startingTiles,
    int gridSize = 4,
  }) {
    final grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));

    final tiles = <Tile>[];
    for (final (row, col, value) in startingTiles) {
      grid[row][col] = value;
      tiles.add(
        Tile(
          value: value,
          row: row,
          col: col,
          id: _generateTileId(),
          isNew: true,
        ),
      );
    }

    return GameState(
      grid: grid,
      tiles: tiles,
      score: 0,
      highScore: highScore,
      isGameOver: false,
      isGameWon: false,
      hasWonBefore: false,
      history: const [],
      gridSize: gridSize,
      gameMode: GameMode.daily,
      movesCount: 0,
    );
  }

  /// Gets all empty cell positions
  static List<(int, int)> getEmptyCells(List<List<int>> grid) {
    final gridSize = grid.length;
    final emptyCells = <(int, int)>[];
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) {
          emptyCells.add((row, col));
        }
      }
    }
    return emptyCells;
  }

  /// Adds a random tile (2 or 4) to an empty position
  static GameState addRandomTile(GameState state, {Random? random}) {
    final emptyCells = getEmptyCells(state.grid);
    if (emptyCells.isEmpty) return state;

    final rng = random ?? Random();
    final (row, col) = emptyCells[rng.nextInt(emptyCells.length)];
    final value = rng.nextDouble() < 0.9 ? 2 : 4;

    final newGrid = state.copyGrid();
    newGrid[row][col] = value;

    final newTile = Tile(
      value: value,
      row: row,
      col: col,
      id: _generateTileId(),
      isNew: true,
    );

    return state.copyWith(grid: newGrid, tiles: [...state.tiles, newTile]);
  }

  /// Moves tiles in the specified direction
  static GameState move(
    GameState state,
    Direction direction, {
    Random? random,
  }) {
    if (state.isGameOver) return state;

    // Check move limit for challenge mode
    if (state.gameMode == GameMode.challenge && state.movesLimit != null) {
      if (state.movesCount >= state.movesLimit!) {
        return state.copyWith(isGameOver: true);
      }
    }

    // Save current state for undo (before move)
    final previousStates = List<GameState>.from(state.history ?? []);

    GameState newState;
    int scoreGained = 0;

    switch (direction) {
      case Direction.up:
        (newState, scoreGained) = _moveUp(state);
        break;
      case Direction.down:
        (newState, scoreGained) = _moveDown(state);
        break;
      case Direction.left:
        (newState, scoreGained) = _moveLeft(state);
        break;
      case Direction.right:
        (newState, scoreGained) = _moveRight(state);
        break;
    }

    // Check if the grid changed
    bool gridChanged = false;
    final gridSize = state.gridSize;
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (state.grid[i][j] != newState.grid[i][j]) {
          gridChanged = true;
          break;
        }
      }
      if (gridChanged) break;
    }

    if (!gridChanged) return state;

    // Add a random tile after successful move
    newState = addRandomTile(newState, random: random);

    // Update score
    final newScore = state.score + scoreGained;
    final newHighScore = max(newScore, state.highScore);

    // Check for win condition based on grid size
    final winningValue = _getWinningValue(gridSize);
    bool hasWon = _checkWin(newState.grid, winningValue);
    bool showWin = hasWon && !state.hasWonBefore;

    // Check for game over
    bool isGameOver = !hasValidMoves(newState.grid);

    // Update history (limit to 10 for memory)
    previousStates.add(state.copyWith(history: null));
    if (previousStates.length > 10) {
      previousStates.removeAt(0);
    }

    // Increment moves count
    final newMovesCount = state.movesCount + 1;

    // Check if moves limit reached in challenge mode
    if (state.gameMode == GameMode.challenge && state.movesLimit != null) {
      if (newMovesCount >= state.movesLimit! && !hasWon) {
        isGameOver = true;
      }
    }

    return newState.copyWith(
      score: newScore,
      highScore: newHighScore,
      isGameOver: isGameOver,
      isGameWon: showWin,
      hasWonBefore: hasWon,
      history: previousStates,
      movesCount: newMovesCount,
    );
  }

  /// Get winning value based on grid size
  static int _getWinningValue(int gridSize) {
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

  /// Undoes the last move
  static GameState undo(GameState state) {
    final history = state.history;
    if (history == null || history.isEmpty) return state;

    final previousState = history.last;
    final newHistory = List<GameState>.from(history)..removeLast();

    return previousState.copyWith(
      highScore: state.highScore,
      history: newHistory,
      movesCount: max(0, state.movesCount - 1),
    );
  }

  /// Checks if the grid has any valid moves remaining
  static bool hasValidMoves(List<List<int>> grid) {
    final gridSize = grid.length;

    // Check for empty cells
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) return true;
      }
    }

    // Check for adjacent cells with same value
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final value = grid[row][col];
        // Check right
        if (col < gridSize - 1 && grid[row][col + 1] == value) return true;
        // Check down
        if (row < gridSize - 1 && grid[row + 1][col] == value) return true;
      }
    }

    return false;
  }

  /// Checks if the player has won (reached target value)
  static bool _checkWin(List<List<int>> grid, int targetValue) {
    final gridSize = grid.length;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] >= targetValue) return true;
      }
    }
    return false;
  }

  /// Gets the highest tile value in the grid
  static int getHighestTile(List<List<int>> grid) {
    int highest = 0;
    final gridSize = grid.length;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] > highest) {
          highest = grid[row][col];
        }
      }
    }
    return highest;
  }

  /// Moves and merges a single row/column to the left
  static (List<int>, int) _mergeRow(List<int> row) {
    final gridSize = row.length;
    // Remove zeros
    final nonZero = row.where((x) => x != 0).toList();
    final result = <int>[];
    int scoreGained = 0;

    int i = 0;
    while (i < nonZero.length) {
      if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
        // Merge tiles
        final merged = nonZero[i] * 2;
        result.add(merged);
        scoreGained += merged;
        i += 2;
      } else {
        result.add(nonZero[i]);
        i++;
      }
    }

    // Pad with zeros
    while (result.length < gridSize) {
      result.add(0);
    }

    return (result, scoreGained);
  }

  static (GameState, int) _moveLeft(GameState state) {
    final gridSize = state.gridSize;
    final newGrid = state.copyGrid();
    int totalScore = 0;
    final newTiles = <Tile>[];

    for (int row = 0; row < gridSize; row++) {
      final (mergedRow, score) = _mergeRow(newGrid[row]);
      newGrid[row] = mergedRow;
      totalScore += score;

      // Create tiles for non-zero values
      for (int col = 0; col < gridSize; col++) {
        if (mergedRow[col] != 0) {
          bool isMerged = false;
          final oldRow = state.grid[row];
          int oldValue = 0;
          for (int oldCol = 0; oldCol < gridSize; oldCol++) {
            if (oldRow[oldCol] == mergedRow[col] ~/ 2) {
              oldValue = oldRow[oldCol];
            }
          }
          if (score > 0 && mergedRow[col] == oldValue * 2) {
            isMerged = true;
          }

          newTiles.add(
            Tile(
              value: mergedRow[col],
              row: row,
              col: col,
              id: _generateTileId(),
              isMerged: isMerged,
            ),
          );
        }
      }
    }

    return (state.copyWith(grid: newGrid, tiles: newTiles), totalScore);
  }

  static (GameState, int) _moveRight(GameState state) {
    final gridSize = state.gridSize;
    final newGrid = state.copyGrid();
    int totalScore = 0;
    final newTiles = <Tile>[];

    for (int row = 0; row < gridSize; row++) {
      final reversed = newGrid[row].reversed.toList();
      final (mergedRow, score) = _mergeRow(reversed);
      newGrid[row] = mergedRow.reversed.toList();
      totalScore += score;

      for (int col = 0; col < gridSize; col++) {
        if (newGrid[row][col] != 0) {
          newTiles.add(
            Tile(
              value: newGrid[row][col],
              row: row,
              col: col,
              id: _generateTileId(),
            ),
          );
        }
      }
    }

    return (state.copyWith(grid: newGrid, tiles: newTiles), totalScore);
  }

  static (GameState, int) _moveUp(GameState state) {
    final gridSize = state.gridSize;
    final newGrid = state.copyGrid();
    int totalScore = 0;
    final newTiles = <Tile>[];

    for (int col = 0; col < gridSize; col++) {
      // Extract column
      final column = List.generate(gridSize, (row) => newGrid[row][col]);

      final (mergedColumn, score) = _mergeRow(column);
      totalScore += score;

      // Put back
      for (int row = 0; row < gridSize; row++) {
        newGrid[row][col] = mergedColumn[row];
        if (mergedColumn[row] != 0) {
          newTiles.add(
            Tile(
              value: mergedColumn[row],
              row: row,
              col: col,
              id: _generateTileId(),
            ),
          );
        }
      }
    }

    return (state.copyWith(grid: newGrid, tiles: newTiles), totalScore);
  }

  static (GameState, int) _moveDown(GameState state) {
    final gridSize = state.gridSize;
    final newGrid = state.copyGrid();
    int totalScore = 0;
    final newTiles = <Tile>[];

    for (int col = 0; col < gridSize; col++) {
      // Extract column reversed
      final column = List.generate(
        gridSize,
        (i) => newGrid[gridSize - 1 - i][col],
      );

      final (mergedColumn, score) = _mergeRow(column);
      totalScore += score;

      // Put back reversed
      for (int row = 0; row < gridSize; row++) {
        newGrid[row][col] = mergedColumn[gridSize - 1 - row];
        if (mergedColumn[gridSize - 1 - row] != 0) {
          newTiles.add(
            Tile(
              value: mergedColumn[gridSize - 1 - row],
              row: row,
              col: col,
              id: _generateTileId(),
            ),
          );
        }
      }
    }

    return (state.copyWith(grid: newGrid, tiles: newTiles), totalScore);
  }

  /// Continues the game after winning (doesn't show win overlay again)
  static GameState continueGame(GameState state) {
    return state.copyWith(isGameWon: false);
  }
}
