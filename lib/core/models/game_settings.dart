/// Game settings model for different game modes and configurations
class GameSettings {
  final GameMode mode;
  final GridSize gridSize;
  final int? timeLimitSeconds; // For time attack mode
  final int? movesLimit; // For challenge mode

  const GameSettings({
    this.mode = GameMode.classic,
    this.gridSize = GridSize.size4x4,
    this.timeLimitSeconds,
    this.movesLimit,
  });

  GameSettings copyWith({
    GameMode? mode,
    GridSize? gridSize,
    int? timeLimitSeconds,
    int? movesLimit,
  }) {
    return GameSettings(
      mode: mode ?? this.mode,
      gridSize: gridSize ?? this.gridSize,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      movesLimit: movesLimit ?? this.movesLimit,
    );
  }

  int get gridDimension => gridSize.dimension;

  int get winningValue {
    switch (gridSize) {
      case GridSize.size3x3:
        return 512; // Easier to win on smaller grid
      case GridSize.size4x4:
        return 2048;
      case GridSize.size5x5:
        return 4096;
      case GridSize.size6x6:
        return 8192;
    }
  }

  String get modeDisplayName {
    switch (mode) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.timeAttack:
        return 'Time Attack';
      case GameMode.zen:
        return 'Zen Mode';
      case GameMode.challenge:
        return 'Challenge';
      case GameMode.daily:
        return 'Daily Challenge';
    }
  }

  String get gridDisplayName => '$gridDimension×$gridDimension';

  String get modeDescription {
    switch (mode) {
      case GameMode.classic:
        return 'The original 2048 experience';
      case GameMode.timeAttack:
        return 'Race against the clock!';
      case GameMode.zen:
        return 'Unlimited undos, no pressure';
      case GameMode.challenge:
        return 'Limited moves to reach the goal';
      case GameMode.daily:
        return 'New puzzle every day';
    }
  }
}

/// Available game modes
enum GameMode {
  classic, // Standard 2048 gameplay
  timeAttack, // Score as high as possible in limited time
  zen, // Unlimited undos, relaxing experience
  challenge, // Limited moves to reach a target
  daily, // Daily puzzle with the same seed for all users
}

/// Available grid sizes
enum GridSize {
  size3x3(3),
  size4x4(4),
  size5x5(5),
  size6x6(6);

  final int dimension;
  const GridSize(this.dimension);
}

/// Difficulty presets
class GamePresets {
  static const GameSettings easyClassic = GameSettings(
    mode: GameMode.classic,
    gridSize: GridSize.size4x4,
  );

  static const GameSettings hardClassic = GameSettings(
    mode: GameMode.classic,
    gridSize: GridSize.size3x3,
  );

  static const GameSettings timeAttack60 = GameSettings(
    mode: GameMode.timeAttack,
    gridSize: GridSize.size4x4,
    timeLimitSeconds: 60,
  );

  static const GameSettings timeAttack120 = GameSettings(
    mode: GameMode.timeAttack,
    gridSize: GridSize.size4x4,
    timeLimitSeconds: 120,
  );

  static const GameSettings timeAttack180 = GameSettings(
    mode: GameMode.timeAttack,
    gridSize: GridSize.size4x4,
    timeLimitSeconds: 180,
  );

  static const GameSettings zenMode = GameSettings(
    mode: GameMode.zen,
    gridSize: GridSize.size4x4,
  );

  static const GameSettings challenge50 = GameSettings(
    mode: GameMode.challenge,
    gridSize: GridSize.size4x4,
    movesLimit: 50,
  );

  static const GameSettings megaGrid = GameSettings(
    mode: GameMode.classic,
    gridSize: GridSize.size6x6,
  );
}
