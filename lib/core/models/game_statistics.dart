/// Comprehensive game statistics for tracking player progress
class GameStatistics {
  final int totalGamesPlayed;
  final int totalGamesWon;
  final int highestScore;
  final int highestTile;
  final int totalMoves;
  final Duration totalTimePlayed;
  final Map<String, int> highScoresByMode;
  final Map<String, int> highScoresByGridSize;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastPlayedDate;
  final int dailyChallengesCompleted;
  final List<int> recentScores; // Last 10 scores

  const GameStatistics({
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
    this.highestScore = 0,
    this.highestTile = 0,
    this.totalMoves = 0,
    this.totalTimePlayed = Duration.zero,
    this.highScoresByMode = const {},
    this.highScoresByGridSize = const {},
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastPlayedDate,
    this.dailyChallengesCompleted = 0,
    this.recentScores = const [],
  });

  double get winRate {
    if (totalGamesPlayed == 0) return 0.0;
    return (totalGamesWon / totalGamesPlayed) * 100;
  }

  double get averageScore {
    if (recentScores.isEmpty) return 0.0;
    return recentScores.reduce((a, b) => a + b) / recentScores.length;
  }

  String get formattedTimePlayed {
    final hours = totalTimePlayed.inHours;
    final minutes = totalTimePlayed.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  GameStatistics copyWith({
    int? totalGamesPlayed,
    int? totalGamesWon,
    int? highestScore,
    int? highestTile,
    int? totalMoves,
    Duration? totalTimePlayed,
    Map<String, int>? highScoresByMode,
    Map<String, int>? highScoresByGridSize,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastPlayedDate,
    int? dailyChallengesCompleted,
    List<int>? recentScores,
  }) {
    return GameStatistics(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalGamesWon: totalGamesWon ?? this.totalGamesWon,
      highestScore: highestScore ?? this.highestScore,
      highestTile: highestTile ?? this.highestTile,
      totalMoves: totalMoves ?? this.totalMoves,
      totalTimePlayed: totalTimePlayed ?? this.totalTimePlayed,
      highScoresByMode: highScoresByMode ?? this.highScoresByMode,
      highScoresByGridSize: highScoresByGridSize ?? this.highScoresByGridSize,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      dailyChallengesCompleted:
          dailyChallengesCompleted ?? this.dailyChallengesCompleted,
      recentScores: recentScores ?? this.recentScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalGamesWon': totalGamesWon,
      'highestScore': highestScore,
      'highestTile': highestTile,
      'totalMoves': totalMoves,
      'totalTimePlayed': totalTimePlayed.inSeconds,
      'highScoresByMode': highScoresByMode,
      'highScoresByGridSize': highScoresByGridSize,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'dailyChallengesCompleted': dailyChallengesCompleted,
      'recentScores': recentScores,
    };
  }

  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalGamesWon: json['totalGamesWon'] ?? 0,
      highestScore: json['highestScore'] ?? 0,
      highestTile: json['highestTile'] ?? 0,
      totalMoves: json['totalMoves'] ?? 0,
      totalTimePlayed: Duration(seconds: json['totalTimePlayed'] ?? 0),
      highScoresByMode: Map<String, int>.from(json['highScoresByMode'] ?? {}),
      highScoresByGridSize: Map<String, int>.from(
        json['highScoresByGridSize'] ?? {},
      ),
      currentStreak: json['currentStreak'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
      dailyChallengesCompleted: json['dailyChallengesCompleted'] ?? 0,
      recentScores: List<int>.from(json['recentScores'] ?? []),
    );
  }
}
