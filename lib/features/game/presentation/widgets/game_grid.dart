import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/game_state.dart';
import '../providers/game_provider.dart';
import 'game_tile.dart';

/// The main game grid with swipe gestures
class GameGrid extends ConsumerStatefulWidget {
  const GameGrid({super.key});

  @override
  ConsumerState<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends ConsumerState<GameGrid> {
  static const int gridSize = 4;
  static const double gridPadding = 8.0;
  static const double tileSpacing = 8.0;

  Offset? _startPosition;
  bool _isSwiping = false;

  void _onPanStart(DragStartDetails details) {
    _startPosition = details.localPosition;
    _isSwiping = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isSwiping || _startPosition == null) return;

    final delta = details.localPosition - _startPosition!;
    final threshold = 20.0;

    if (delta.distance > threshold) {
      Direction? direction;

      if (delta.dx.abs() > delta.dy.abs()) {
        // Horizontal swipe
        direction = delta.dx > 0 ? Direction.right : Direction.left;
      } else {
        // Vertical swipe
        direction = delta.dy > 0 ? Direction.down : Direction.up;
      }

      _isSwiping = false;
      ref.read(gameProvider.notifier).move(direction);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isSwiping = false;
    _startPosition = null;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate tile size based on available space
        final availableSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final gridSizeWithPadding = availableSize - (gridPadding * 2);
        final tileSize = (gridSizeWithPadding - (tileSpacing * (gridSize - 1))) / gridSize;

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            width: availableSize,
            height: availableSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: LiquidColors.neonCyan.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(gridPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LiquidColors.darkGlass,
                        LiquidColors.darkGlass.withOpacity(0.4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background grid (empty tiles)
                      _buildEmptyGrid(tileSize),
                      // Actual tiles
                      ..._buildTiles(gameState, tileSize),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyGrid(double tileSize) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(gridSize, (row) {
        return Padding(
          padding: EdgeInsets.only(bottom: row < gridSize - 1 ? tileSpacing : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(gridSize, (col) {
              return Padding(
                padding: EdgeInsets.only(right: col < gridSize - 1 ? tileSpacing : 0),
                child: EmptyTile(size: tileSize),
              );
            }),
          ),
        );
      }),
    );
  }

  List<Widget> _buildTiles(GameState gameState, double tileSize) {
    final tiles = <Widget>[];

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final value = gameState.grid[row][col];
        if (value != 0) {
          final tile = gameState.tiles.firstWhere(
            (t) => t.row == row && t.col == col,
            orElse: () => throw StateError('Tile not found at ($row, $col)'),
          );

          final left = col * (tileSize + tileSpacing);
          final top = row * (tileSize + tileSpacing);

          tiles.add(
            AnimatedPositioned(
              key: ValueKey(tile.id),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              left: left,
              top: top,
              child: GameTile(
                value: value,
                isNew: tile.isNew,
                isMerged: tile.isMerged,
                size: tileSize,
              ),
            ),
          );
        }
      }
    }

    return tiles;
  }
}

