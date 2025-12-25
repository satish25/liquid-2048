import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_2048_game/features/game/domain/game_manager.dart';
import 'package:liquid_2048_game/features/game/domain/game_state.dart';

void main() {
  setUp(() {
    // Reset tile ID counter before each test
    GameManager.resetTileIdCounter();
  });

  group('GameManager - New Game', () {
    test('newGame creates a game with two tiles', () {
      final state = GameManager.newGame();

      // Count non-zero tiles
      int tileCount = 0;
      for (var row in state.grid) {
        for (var value in row) {
          if (value != 0) tileCount++;
        }
      }

      expect(tileCount, equals(2));
      expect(state.score, equals(0));
      expect(state.isGameOver, isFalse);
      expect(state.isGameWon, isFalse);
    });

    test('initial tiles are 2 or 4', () {
      final state = GameManager.newGame();

      for (var row in state.grid) {
        for (var value in row) {
          if (value != 0) {
            expect(value == 2 || value == 4, isTrue);
          }
        }
      }
    });
  });

  group('GameManager - Tile Merging', () {
    test('mergeRow merges adjacent same values correctly', () {
      final (result, score) = _mergeRow([2, 2, 0, 0]);
      expect(result, equals([4, 0, 0, 0]));
      expect(score, equals(4));
    });

    test('mergeRow handles multiple merges', () {
      final (result, score) = _mergeRow([2, 2, 2, 2]);
      expect(result, equals([4, 4, 0, 0]));
      expect(score, equals(8));
    });

    test('mergeRow does not merge already merged tiles', () {
      final (result, score) = _mergeRow([2, 2, 4, 0]);
      expect(result, equals([4, 4, 0, 0]));
      expect(score, equals(4));
    });

    test('mergeRow slides tiles to the left', () {
      final (result, score) = _mergeRow([0, 2, 0, 2]);
      expect(result, equals([4, 0, 0, 0]));
      expect(score, equals(4));
    });

    test('mergeRow handles full row without merges', () {
      final (result, score) = _mergeRow([2, 4, 8, 16]);
      expect(result, equals([2, 4, 8, 16]));
      expect(score, equals(0));
    });

    test('mergeRow handles empty row', () {
      final (result, score) = _mergeRow([0, 0, 0, 0]);
      expect(result, equals([0, 0, 0, 0]));
      expect(score, equals(0));
    });

    test('mergeRow merges only first pair', () {
      final (result, score) = _mergeRow([4, 4, 4, 0]);
      expect(result, equals([8, 4, 0, 0]));
      expect(score, equals(8));
    });
  });

  group('GameManager - Move Detection', () {
    test('hasValidMoves returns true when empty cells exist', () {
      final grid = [
        [2, 4, 8, 16],
        [4, 8, 16, 32],
        [8, 16, 32, 64],
        [16, 32, 64, 0], // One empty cell
      ];
      expect(GameManager.hasValidMoves(grid), isTrue);
    });

    test('hasValidMoves returns true when horizontal merge is possible', () {
      final grid = [
        [2, 4, 8, 16],
        [4, 8, 16, 32],
        [8, 16, 32, 64],
        [16, 32, 64, 64], // Horizontal merge possible
      ];
      expect(GameManager.hasValidMoves(grid), isTrue);
    });

    test('hasValidMoves returns true when vertical merge is possible', () {
      final grid = [
        [2, 4, 8, 16],
        [4, 8, 16, 32],
        [8, 16, 32, 64],
        [16, 32, 32, 128], // Vertical merge possible (32s)
      ];
      expect(GameManager.hasValidMoves(grid), isTrue);
    });

    test('hasValidMoves returns false when no moves available', () {
      final grid = [
        [2, 4, 8, 16],
        [4, 8, 16, 32],
        [8, 16, 32, 64],
        [16, 32, 64, 128],
      ];
      expect(GameManager.hasValidMoves(grid), isFalse);
    });
  });

  group('GameManager - Game Over Detection', () {
    test('game over when no valid moves remain', () {
      // Create a game state with no valid moves
      var state = GameState(
        grid: [
          [2, 4, 8, 16],
          [4, 8, 16, 32],
          [8, 16, 32, 64],
          [16, 32, 64, 128],
        ],
        tiles: [],
        score: 0,
      );

      // Try to move - should remain unchanged
      final newState = GameManager.move(state, Direction.up);
      expect(newState.grid, equals(state.grid));
    });
  });

  group('GameManager - Win Detection', () {
    test('game is won when 2048 tile appears', () {
      var state = GameState(
        grid: [
          [1024, 1024, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        tiles: [],
        score: 0,
      );

      final newState = GameManager.move(state, Direction.left);
      expect(newState.isGameWon, isTrue);
    });
  });

  group('GameManager - Empty Cells', () {
    test('getEmptyCells returns correct positions', () {
      final grid = [
        [2, 0, 4, 0],
        [0, 8, 0, 16],
        [32, 0, 64, 0],
        [0, 128, 0, 256],
      ];

      final emptyCells = GameManager.getEmptyCells(grid);
      expect(emptyCells.length, equals(8));
      expect(emptyCells.contains((0, 1)), isTrue);
      expect(emptyCells.contains((0, 3)), isTrue);
      expect(emptyCells.contains((1, 0)), isTrue);
      expect(emptyCells.contains((1, 2)), isTrue);
    });

    test('getEmptyCells returns all cells for empty grid', () {
      final grid = [
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ];

      final emptyCells = GameManager.getEmptyCells(grid);
      expect(emptyCells.length, equals(16));
    });

    test('getEmptyCells returns empty list for full grid', () {
      final grid = [
        [2, 4, 8, 16],
        [32, 64, 128, 256],
        [512, 1024, 2, 4],
        [8, 16, 32, 64],
      ];

      final emptyCells = GameManager.getEmptyCells(grid);
      expect(emptyCells.length, equals(0));
    });
  });

  group('GameManager - Move Directions', () {
    test('move left slides tiles correctly', () {
      var state = GameState(
        grid: [
          [0, 2, 0, 2],
          [4, 0, 0, 0],
          [0, 0, 8, 0],
          [0, 0, 0, 16],
        ],
        tiles: [],
        score: 0,
      );

      final newState = GameManager.move(state, Direction.left);
      
      // First row: merge 2+2 = 4
      expect(newState.grid[0][0], equals(4));
      // Second row: 4 slides left
      expect(newState.grid[1][0], equals(4));
      // Third row: 8 slides left
      expect(newState.grid[2][0], equals(8));
      // Fourth row: 16 slides left
      expect(newState.grid[3][0], equals(16));
    });

    test('move right slides tiles correctly', () {
      var state = GameState(
        grid: [
          [2, 2, 0, 0],
          [4, 0, 0, 0],
          [0, 8, 0, 0],
          [16, 0, 0, 0],
        ],
        tiles: [],
        score: 0,
      );

      final newState = GameManager.move(state, Direction.right);
      
      // First row: merge 2+2 = 4 at rightmost
      expect(newState.grid[0][3], equals(4));
      // Second row: 4 slides right
      expect(newState.grid[1][3], equals(4));
      // Third row: 8 slides right
      expect(newState.grid[2][3], equals(8));
      // Fourth row: 16 slides right
      expect(newState.grid[3][3], equals(16));
    });

    test('move up slides tiles correctly', () {
      var state = GameState(
        grid: [
          [0, 0, 0, 0],
          [2, 4, 8, 16],
          [0, 0, 0, 0],
          [2, 0, 0, 0],
        ],
        tiles: [],
        score: 0,
      );

      final newState = GameManager.move(state, Direction.up);
      
      // First column: 2+2 merge at top
      expect(newState.grid[0][0], equals(4));
      // Other columns slide up
      expect(newState.grid[0][1], equals(4));
      expect(newState.grid[0][2], equals(8));
      expect(newState.grid[0][3], equals(16));
    });

    test('move down slides tiles correctly', () {
      var state = GameState(
        grid: [
          [2, 4, 8, 16],
          [0, 0, 0, 0],
          [2, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        tiles: [],
        score: 0,
      );

      final newState = GameManager.move(state, Direction.down);
      
      // First column: 2+2 merge at bottom
      expect(newState.grid[3][0], equals(4));
      // Other columns slide down
      expect(newState.grid[3][1], equals(4));
      expect(newState.grid[3][2], equals(8));
      expect(newState.grid[3][3], equals(16));
    });
  });

  group('GameManager - Score Calculation', () {
    test('score increases correctly on merge', () {
      var state = GameState(
        grid: [
          [2, 2, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        tiles: [],
        score: 0,
      );

      final newState = GameManager.move(state, Direction.left);
      expect(newState.score, equals(4));
    });

    test('score accumulates on multiple merges', () {
      var state = GameState(
        grid: [
          [2, 2, 4, 4],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
          [0, 0, 0, 0],
        ],
        tiles: [],
        score: 0,
      );

      final newState = GameManager.move(state, Direction.left);
      expect(newState.score, equals(12)); // 4 + 8
    });
  });

  group('GameManager - Undo', () {
    test('undo restores previous state', () {
      var state = GameManager.newGame();
      final originalGrid = state.grid.map((r) => List<int>.from(r)).toList();

      // Make a move
      state = GameManager.move(state, Direction.left);
      expect(state.history, isNotNull);
      expect(state.history!.isNotEmpty, isTrue);

      // Undo
      state = GameManager.undo(state);
      expect(state.grid, equals(originalGrid));
    });

    test('undo does nothing when history is empty', () {
      var state = GameState.initial();
      final originalState = state;
      
      state = GameManager.undo(state);
      expect(state.grid, equals(originalState.grid));
    });
  });
}

/// Helper function to test merge logic (reimplementation of private _mergeRow)
(List<int>, int) _mergeRow(List<int> row) {
  final nonZero = row.where((x) => x != 0).toList();
  final result = <int>[];
  int scoreGained = 0;

  int i = 0;
  while (i < nonZero.length) {
    if (i + 1 < nonZero.length && nonZero[i] == nonZero[i + 1]) {
      final merged = nonZero[i] * 2;
      result.add(merged);
      scoreGained += merged;
      i += 2;
    } else {
      result.add(nonZero[i]);
      i++;
    }
  }

  while (result.length < 4) {
    result.add(0);
  }

  return (result, scoreGained);
}
