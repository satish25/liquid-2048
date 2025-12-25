import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

/// Key for persisting guest mode
const String _guestModeKey = 'is_guest_mode';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for current user
final currentUserProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider for auth state
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(ref);
});

/// Auth state enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Auth state class
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isGuest;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isGuest = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
    bool? isGuest,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

/// Auth state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  late final AuthService _authService;
  SharedPreferences? _prefs;

  AuthStateNotifier(this._ref) : super(const AuthState()) {
    _authService = _ref.read(authServiceProvider);
    _init();
  }

  Future<void> _init() async {
    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
    
    // Check if user was previously logged in as guest
    final wasGuest = _prefs?.getBool(_guestModeKey) ?? false;
    
    // Check current Firebase auth state
    final currentUser = _authService.currentUser;
    
    if (currentUser != null) {
      // User is logged in with Firebase (Google, Apple, Anonymous)
      state = AuthState(
        status: AuthStatus.authenticated,
        user: currentUser,
        isGuest: currentUser.isAnonymous,
      );
    } else if (wasGuest) {
      // User was logged in as local guest - restore that state
      state = const AuthState(
        status: AuthStatus.authenticated,
        isGuest: true,
      );
    } else {
      // No previous session - show login screen
      state = const AuthState(
        status: AuthStatus.unauthenticated,
      );
    }
    
    // Listen for future auth state changes
    _authService.authStateChanges.listen((user) {
      // Don't overwrite local guest mode state
      if (state.isGuest && user == null) {
        return;
      }
      
      if (user != null) {
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          isGuest: user.isAnonymous,
        );
      } else if (!state.isGuest) {
        // Only set to unauthenticated if not in local guest mode
        state = const AuthState(
          status: AuthStatus.unauthenticated,
        );
      }
    });
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        // Clear guest mode flag when signing in with Google
        await _prefs?.setBool(_guestModeKey, false);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getReadableError(e.toString()),
      );
    }
  }

  Future<void> signInWithApple() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _authService.signInWithApple();
      if (result == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      } else {
        // Clear guest mode flag when signing in with Apple
        await _prefs?.setBool(_guestModeKey, false);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getReadableError(e.toString()),
      );
    }
  }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _authService.signInWithFacebook();
      if (result == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getReadableError(e.toString()),
      );
    }
  }

  Future<void> signInWithTwitter() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final result = await _authService.signInWithTwitter();
      if (result == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getReadableError(e.toString()),
      );
    }
  }

  Future<void> signInAsGuest() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Try Firebase anonymous auth first
      final result = await _authService.signInAnonymously();
      if (result != null) {
        // Save guest mode preference
        await _prefs?.setBool(_guestModeKey, true);
      }
    } catch (e) {
      // If Firebase anonymous auth fails, use local guest mode
      // This allows users to play without Firebase auth configured
      debugPrint('Firebase anonymous auth failed, using local guest mode: $e');
      
      // Persist local guest mode
      await _prefs?.setBool(_guestModeKey, true);
      
      state = const AuthState(
        status: AuthStatus.authenticated,
        isGuest: true,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Clear guest mode preference
      await _prefs?.setBool(_guestModeKey, false);
      
      // If it's a local guest, just reset the state
      if (state.isGuest && state.user == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      
      // Sign out from Firebase
      await _authService.signOut();
      
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _getReadableError(e.toString()),
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Convert technical error messages to user-friendly ones
  String _getReadableError(String error) {
    if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('cancelled') || error.contains('canceled')) {
      return 'Sign in was cancelled.';
    } else if (error.contains('credential')) {
      return 'Invalid credentials. Please try again.';
    } else if (error.contains('disabled')) {
      return 'This account has been disabled.';
    } else if (error.contains('not-found')) {
      return 'Account not found.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }
    return 'Sign in failed. Please try again.';
  }
}
