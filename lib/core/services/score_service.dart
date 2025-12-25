import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user scores with cloud sync
class ScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs;

  static const String _localHighScoreKey = 'high_score';
  static const String _localGuestHighScoreKey = 'guest_high_score';
  static const String _usersCollection = 'users';
  static const String _highScoreField = 'highScore';
  static const String _lastUpdatedField = 'lastUpdated';
  static const String _gamesPlayedField = 'gamesPlayed';
  static const String _displayNameField = 'displayName';
  static const String _emailField = 'email';

  ScoreService(this._prefs);

  /// Get the current user's ID
  String? get _userId => _auth.currentUser?.uid;

  /// Check if user is logged in (not guest)
  bool get isLoggedIn => _auth.currentUser != null && !_auth.currentUser!.isAnonymous;

  /// Get user document reference
  DocumentReference? get _userDoc {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection(_usersCollection).doc(uid);
  }

  /// Get local high score (for guest or offline use)
  int getLocalHighScore() {
    return _prefs.getInt(_localHighScoreKey) ?? 0;
  }

  /// Get guest high score
  int getGuestHighScore() {
    return _prefs.getInt(_localGuestHighScoreKey) ?? 0;
  }

  /// Save high score locally
  Future<void> _saveLocalHighScore(int score) async {
    await _prefs.setInt(_localHighScoreKey, score);
  }

  /// Save guest high score locally
  Future<void> _saveGuestHighScore(int score) async {
    await _prefs.setInt(_localGuestHighScoreKey, score);
  }

  /// Get the best score (from cloud if logged in, local otherwise)
  Future<int> getBestScore({bool isGuest = false}) async {
    if (isGuest) {
      return getGuestHighScore();
    }

    // Try to get from cloud first
    try {
      final doc = _userDoc;
      if (doc != null) {
        final snapshot = await doc.get();
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          final cloudScore = data?[_highScoreField] as int? ?? 0;
          final localScore = getLocalHighScore();
          
          // Return the higher of cloud or local score
          final bestScore = cloudScore > localScore ? cloudScore : localScore;
          
          // Sync if local is higher
          if (localScore > cloudScore) {
            await _syncScoreToCloud(localScore);
          }
          
          return bestScore;
        }
      }
    } catch (e) {
      debugPrint('Error fetching cloud score: $e');
    }

    // Fallback to local score
    return getLocalHighScore();
  }

  /// Update high score (saves to both local and cloud)
  Future<void> updateHighScore(int score, {bool isGuest = false}) async {
    if (isGuest) {
      final currentBest = getGuestHighScore();
      if (score > currentBest) {
        await _saveGuestHighScore(score);
      }
      return;
    }

    final currentLocalBest = getLocalHighScore();
    
    // Save locally first
    if (score > currentLocalBest) {
      await _saveLocalHighScore(score);
    }

    // Sync to cloud if logged in
    if (_userId != null) {
      try {
        await _syncScoreToCloud(score);
      } catch (e) {
        debugPrint('Error syncing score to cloud: $e');
      }
    }
  }

  /// Sync score to cloud
  Future<void> _syncScoreToCloud(int score) async {
    final doc = _userDoc;
    if (doc == null) return;

    try {
      final snapshot = await doc.get();
      int currentCloudScore = 0;
      int currentGamesPlayed = 0;
      
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        currentCloudScore = data?[_highScoreField] as int? ?? 0;
        currentGamesPlayed = data?[_gamesPlayedField] as int? ?? 0;
      }

      // Only update if new score is higher
      if (score > currentCloudScore) {
        await doc.set({
          _highScoreField: score,
          _lastUpdatedField: FieldValue.serverTimestamp(),
          _gamesPlayedField: currentGamesPlayed,
          _displayNameField: _auth.currentUser?.displayName ?? 'Player',
          _emailField: _auth.currentUser?.email,
        }, SetOptions(merge: true));
        
        debugPrint('Score synced to cloud: $score');
      }
    } catch (e) {
      debugPrint('Error syncing score: $e');
      rethrow;
    }
  }

  /// Increment games played counter
  Future<void> incrementGamesPlayed() async {
    final doc = _userDoc;
    if (doc == null) return;

    try {
      await doc.set({
        _gamesPlayedField: FieldValue.increment(1),
        _lastUpdatedField: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error incrementing games played: $e');
    }
  }

  /// Sync local score to cloud on login
  Future<int> syncOnLogin() async {
    final localScore = getLocalHighScore();
    
    try {
      final doc = _userDoc;
      if (doc != null) {
        final snapshot = await doc.get();
        int cloudScore = 0;
        
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          cloudScore = data?[_highScoreField] as int? ?? 0;
        }

        // Use the higher score
        final bestScore = localScore > cloudScore ? localScore : cloudScore;
        
        // Update cloud with best score if local is higher
        if (localScore > cloudScore) {
          await doc.set({
            _highScoreField: localScore,
            _lastUpdatedField: FieldValue.serverTimestamp(),
            _displayNameField: _auth.currentUser?.displayName ?? 'Player',
            _emailField: _auth.currentUser?.email,
          }, SetOptions(merge: true));
        }
        
        // Update local with best score
        await _saveLocalHighScore(bestScore);
        
        debugPrint('Synced on login. Best score: $bestScore');
        return bestScore;
      }
    } catch (e) {
      debugPrint('Error syncing on login: $e');
    }
    
    return localScore;
  }

  /// Fetch cloud score on login (to restore user's best score)
  Future<int> fetchCloudScore() async {
    try {
      final doc = _userDoc;
      if (doc != null) {
        final snapshot = await doc.get();
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          final cloudScore = data?[_highScoreField] as int? ?? 0;
          
          // Update local score if cloud is higher
          final localScore = getLocalHighScore();
          if (cloudScore > localScore) {
            await _saveLocalHighScore(cloudScore);
          }
          
          return cloudScore;
        }
      }
    } catch (e) {
      debugPrint('Error fetching cloud score: $e');
    }
    
    return getLocalHighScore();
  }

  /// Clear local scores (for logout)
  Future<void> clearLocalScores() async {
    // Don't clear - keep local score for offline use
    // The score will be synced again on next login
    debugPrint('Logout - local score preserved for offline use');
  }

  /// Get leaderboard (top scores)
  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .orderBy(_highScoreField, descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'uid': doc.id,
          'displayName': data[_displayNameField] ?? 'Anonymous',
          'highScore': data[_highScoreField] ?? 0,
          'gamesPlayed': data[_gamesPlayedField] ?? 0,
        };
      }).toList();
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      return [];
    }
  }
}

