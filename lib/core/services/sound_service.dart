import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for sound service
final soundServiceProvider = Provider<SoundService>((ref) => SoundService());

/// Provider for sound enabled state
final soundEnabledProvider = StateProvider<bool>((ref) => true);

/// Service for playing game sounds
class SoundService {
  final AudioPlayer _movePlayer = AudioPlayer();
  final AudioPlayer _mergePlayer = AudioPlayer();
  final AudioPlayer _gameOverPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();

  SoundService() {
    // Pre-configure players for low latency
    _movePlayer.setReleaseMode(ReleaseMode.stop);
    _mergePlayer.setReleaseMode(ReleaseMode.stop);
    _gameOverPlayer.setReleaseMode(ReleaseMode.stop);
    _winPlayer.setReleaseMode(ReleaseMode.stop);
  }

  /// Play move sound
  Future<void> playMove() async {
    // Sound files would be added in assets/sounds/
    // await _movePlayer.play(AssetSource('sounds/move.mp3'));
  }

  /// Play merge sound
  Future<void> playMerge() async {
    // await _mergePlayer.play(AssetSource('sounds/merge.mp3'));
  }

  /// Play game over sound
  Future<void> playGameOver() async {
    // await _gameOverPlayer.play(AssetSource('sounds/game_over.mp3'));
  }

  /// Play win sound
  Future<void> playWin() async {
    // await _winPlayer.play(AssetSource('sounds/win.mp3'));
  }

  /// Dispose all players
  void dispose() {
    _movePlayer.dispose();
    _mergePlayer.dispose();
    _gameOverPlayer.dispose();
    _winPlayer.dispose();
  }
}

