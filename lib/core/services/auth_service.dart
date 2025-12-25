import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:twitter_login/twitter_login.dart';

/// Authentication service for handling social logins
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // TODO: Replace with your actual API keys from respective developer consoles
  static const String _twitterApiKey = 'YOUR_TWITTER_API_KEY';
  static const String _twitterApiSecret = 'YOUR_TWITTER_API_SECRET';
  static const String _twitterRedirectUri = 'liquid2048://';

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

  /// Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In is not available on this device');
      }

      // Request credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create an OAuth credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Update display name if available
      if (appleCredential.givenName != null) {
        await userCredential.user?.updateDisplayName(
          '${appleCredential.givenName} ${appleCredential.familyName ?? ''}'
              .trim(),
        );
      }

      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }

  /// Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status != LoginStatus.success) {
        debugPrint('Facebook login failed: ${loginResult.status}');
        return null;
      }

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

      // Sign in to Firebase with the Facebook credential
      return await _auth.signInWithCredential(facebookAuthCredential);
    } catch (e) {
      debugPrint('Error signing in with Facebook: $e');
      rethrow;
    }
  }

  /// Sign in with X (Twitter)
  Future<UserCredential?> signInWithTwitter() async {
    try {
      // Create a TwitterLogin instance
      final twitterLogin = TwitterLogin(
        apiKey: _twitterApiKey,
        apiSecretKey: _twitterApiSecret,
        redirectURI: _twitterRedirectUri,
      );

      // Trigger the sign-in flow
      final authResult = await twitterLogin.login();

      if (authResult.status != TwitterLoginStatus.loggedIn) {
        debugPrint('Twitter login failed: ${authResult.status}');
        return null;
      }

      // Create a credential from the access token
      final twitterAuthCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      // Sign in to Firebase with the Twitter credential
      return await _auth.signInWithCredential(twitterAuthCredential);
    } catch (e) {
      debugPrint('Error signing in with Twitter: $e');
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

  /// Check if Firebase anonymous auth is available
  Future<bool> isAnonymousAuthAvailable() async {
    try {
      // Try to sign in anonymously and immediately sign out to test
      final result = await _auth.signInAnonymously();
      if (result.user != null) {
        // Anonymous auth works, sign out so user can choose
        await _auth.signOut();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      await GoogleSignIn().signOut();

      // Sign out from Facebook if signed in with Facebook
      await FacebookAuth.instance.logOut();

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

  /// Check if Apple Sign In is available
  Future<bool> isAppleSignInAvailable() async {
    if (kIsWeb) return false;
    if (!Platform.isIOS && !Platform.isMacOS) return false;
    return await SignInWithApple.isAvailable();
  }
}
