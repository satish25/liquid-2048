import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../shared/theme/app_theme.dart';

/// Animated tile widget with liquid glass aesthetic
/// Supports different grid sizes with adaptive font sizing
class GameTile extends StatefulWidget {
  final int value;
  final bool isNew;
  final bool isMerged;
  final double size;
  final int gridSize;

  const GameTile({
    super.key,
    required this.value,
    this.isNew = false,
    this.isMerged = false,
    required this.size,
    this.gridSize = 4,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _mergeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _mergeScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Appear animation for new tiles
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOutBack),
    );

    // Merge animation - bounce effect
    _mergeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _mergeScaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.2),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.2, end: 1.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(parent: _mergeController, curve: Curves.easeInOut),
        );

    if (widget.isNew) {
      _appearController.forward();
    } else {
      _appearController.value = 1.0;
    }

    if (widget.isMerged) {
      _mergeController.forward();
    }
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMerged && !oldWidget.isMerged) {
      _mergeController.forward(from: 0);
    }
    if (widget.isNew && !oldWidget.isNew) {
      _appearController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    _mergeController.dispose();
    super.dispose();
  }

  String _getDisplayText(int value) {
    // For larger grids or large numbers, use abbreviated format
    if (widget.gridSize >= 5 && value >= 1000) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(0)}M';
      }
      return '${value ~/ 1000}K';
    }
    if (value >= 10000) {
      return '${value ~/ 1000}K';
    }
    return value.toString();
  }

  double _getFontSize(int value) {
    final displayText = _getDisplayText(value);
    final length = displayText.length;

    // Adjust base font size based on grid size
    double baseFactor;
    switch (widget.gridSize) {
      case 3:
        baseFactor = 1.0;
        break;
      case 5:
        baseFactor = 0.85;
        break;
      case 6:
        baseFactor = 0.75;
        break;
      default: // 4x4
        baseFactor = 0.9;
    }

    double sizeFactor;
    if (length >= 4) {
      sizeFactor = 0.28;
    } else if (length >= 3) {
      sizeFactor = 0.33;
    } else if (length >= 2) {
      sizeFactor = 0.40;
    } else {
      sizeFactor = 0.48;
    }

    return widget.size * sizeFactor * baseFactor;
  }

  double _getBorderRadius() {
    // Smaller border radius for smaller tiles
    if (widget.gridSize >= 5) return 8;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = LiquidColors.getTileColor(widget.value);
    final borderColor = LiquidColors.getTileBorderColor(widget.value);
    final textColor = LiquidColors.getTileTextColor(widget.value);
    final borderRadius = _getBorderRadius();

    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _mergeScaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _mergeScaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: borderColor.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: -2,
                ),
                // Inner shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        backgroundColor,
                        backgroundColor.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: borderColor.withOpacity(0.6),
                      width: widget.gridSize >= 5 ? 1.5 : 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Glass reflection effect
                      Positioned(
                        top: 3,
                        left: 3,
                        right: widget.size * 0.3,
                        child: Container(
                          height: widget.size * 0.12,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(borderRadius - 2),
                              topRight: const Radius.circular(16),
                              bottomRight: const Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.35),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Value text
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _getDisplayText(widget.value),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                fontSize: _getFontSize(widget.value),
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
}

/// Empty tile placeholder with glass effect
class EmptyTile extends StatelessWidget {
  final double size;

  const EmptyTile({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size > 60 ? 12 : 8),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
    );
  }
}
