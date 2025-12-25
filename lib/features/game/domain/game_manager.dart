import 'dart:math';
import 'game_state.dart';
import 'tile.dart';

/// Pure functions for game logic - can be tested independently from UI
class GameManager {
  static const int gridSize = 4;
  static const int winningValue = 2048;
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
  static GameState newGame({int highScore = 0}) {
    var state = GameState.initial().copyWith(highScore: highScore, history: []);
    state = addRandomTile(state);
    state = addRandomTile(state);
    return state;
  }

  /// Gets all empty cell positions
  static List<(int, int)> getEmptyCells(List<List<int>> grid) {
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
  static GameState addRandomTile(GameState state) {
    final emptyCells = getEmptyCells(state.grid);
    if (emptyCells.isEmpty) return state;

    final random = Random();
    final (row, col) = emptyCells[random.nextInt(emptyCells.length)];
    final value = random.nextDouble() < 0.9 ? 2 : 4;

    final newGrid = state.copyGrid();
    newGrid[row][col] = value;

    final newTile = Tile(
      value: value,
      row: row,
      col: col,
      id: _generateTileId(),
      isNew: true,
    );

    return state.copyWith(
      grid: newGrid,
      tiles: [...state.tiles, newTile],
    );
  }

  /// Moves tiles in the specified direction
  static GameState move(GameState state, Direction direction) {
    if (state.isGameOver) return state;

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
    newState = addRandomTile(newState);

    // Update score
    final newScore = state.score + scoreGained;
    final newHighScore = max(newScore, state.highScore);

    // Check for win condition
    bool hasWon = _checkWin(newState.grid);
    bool showWin = hasWon && !state.hasWonBefore;

    // Check for game over
    bool isGameOver = !hasValidMoves(newState.grid);

    // Update history
    previousStates.add(state.copyWith(history: null));
    if (previousStates.length > 10) {
      previousStates.removeAt(0);
    }

    return newState.copyWith(
      score: newScore,
      highScore: newHighScore,
      isGameOver: isGameOver,
      isGameWon: showWin,
      hasWonBefore: hasWon,
      history: previousStates,
    );
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
    );
  }

  /// Checks if the grid has any valid moves remaining
  static bool hasValidMoves(List<List<int>> grid) {
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

  /// Checks if the player has won (reached 2048)
  static bool _checkWin(List<List<int>> grid) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] >= winningValue) return true;
      }
    }
    return false;
  }

  /// Moves and merges a single row/column to the left
  static (List<int>, int) _mergeRow(List<int> row) {
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
          // Check if this is a merged tile
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

          newTiles.add(Tile(
            value: mergedRow[col],
            row: row,
            col: col,
            id: _generateTileId(),
            isMerged: isMerged,
          ));
        }
      }
    }

    return (
      state.copyWith(grid: newGrid, tiles: newTiles),
      totalScore,
    );
  }

  static (GameState, int) _moveRight(GameState state) {
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
          newTiles.add(Tile(
            value: newGrid[row][col],
            row: row,
            col: col,
            id: _generateTileId(),
          ));
        }
      }
    }

    return (
      state.copyWith(grid: newGrid, tiles: newTiles),
      totalScore,
    );
  }

  static (GameState, int) _moveUp(GameState state) {
    final newGrid = state.copyGrid();
    int totalScore = 0;
    final newTiles = <Tile>[];

    for (int col = 0; col < gridSize; col++) {
      // Extract column
      final column = [
        newGrid[0][col],
        newGrid[1][col],
        newGrid[2][col],
        newGrid[3][col],
      ];

      final (mergedColumn, score) = _mergeRow(column);
      totalScore += score;

      // Put back
      for (int row = 0; row < gridSize; row++) {
        newGrid[row][col] = mergedColumn[row];
        if (mergedColumn[row] != 0) {
          newTiles.add(Tile(
            value: mergedColumn[row],
            row: row,
            col: col,
            id: _generateTileId(),
          ));
        }
      }
    }

    return (
      state.copyWith(grid: newGrid, tiles: newTiles),
      totalScore,
    );
  }

  static (GameState, int) _moveDown(GameState state) {
    final newGrid = state.copyGrid();
    int totalScore = 0;
    final newTiles = <Tile>[];

    for (int col = 0; col < gridSize; col++) {
      // Extract column reversed
      final column = [
        newGrid[3][col],
        newGrid[2][col],
        newGrid[1][col],
        newGrid[0][col],
      ];

      final (mergedColumn, score) = _mergeRow(column);
      totalScore += score;

      // Put back reversed
      for (int row = 0; row < gridSize; row++) {
        newGrid[row][col] = mergedColumn[3 - row];
        if (mergedColumn[3 - row] != 0) {
          newTiles.add(Tile(
            value: mergedColumn[3 - row],
            row: row,
            col: col,
            id: _generateTileId(),
          ));
        }
      }
    }

    return (
      state.copyWith(grid: newGrid, tiles: newTiles),
      totalScore,
    );
  }

  /// Continues the game after winning (doesn't show win overlay again)
  static GameState continueGame(GameState state) {
    return state.copyWith(isGameWon: false);
  }
}

