import 'package:flutter/services.dart';

/// Service for haptic feedback
class HapticService {
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Haptic feedback for tile move
  static void onMove() {
    lightImpact();
  }

  /// Haptic feedback for tile merge
  static void onMerge() {
    mediumImpact();
  }

  /// Haptic feedback for game over
  static void onGameOver() {
    heavyImpact();
  }

  /// Haptic feedback for winning
  static void onWin() {
    heavyImpact();
  }

  /// Haptic feedback for button tap
  static void onButtonTap() {
    selectionClick();
  }
}

