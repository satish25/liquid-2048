import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service for handling social logins
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // iOS Client ID from GoogleService-Info.plist
  static const String _iosClientId =
      '1092240937434-jh4mooq6obeqshbpfiugf0h5i5ehoqfh.apps.googleusercontent.com';

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Configure GoogleSignIn with iOS client ID
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: !kIsWeb && Platform.isIOS ? _iosClientId : null,
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign in anonymously (for guest mode)
  /// Falls back to local guest mode if Firebase anonymous auth fails
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      // If anonymous sign-in fails, we'll handle guest mode locally
      // through the auth state notifier
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      await GoogleSignIn().signOut();

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }
}
