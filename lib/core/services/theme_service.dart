import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available accent color themes
enum AccentTheme {
  cyan('Cyan', Color(0xFF00F5FF)),
  pink('Pink', Color(0xFFFF006E)),
  purple('Purple', Color(0xFF9D4EDD)),
  green('Green', Color(0xFF39FF14)),
  orange('Orange', Color(0xFFFF6B35)),
  yellow('Gold', Color(0xFFFFD700));

  final String name;
  final Color color;

  const AccentTheme(this.name, this.color);
}

/// Provider for the current accent theme
final accentThemeProvider = StateNotifierProvider<AccentThemeNotifier, AccentTheme>((ref) {
  return AccentThemeNotifier();
});

class AccentThemeNotifier extends StateNotifier<AccentTheme> {
  static const _key = 'accent_theme';

  AccentThemeNotifier() : super(AccentTheme.cyan) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0;
    if (index >= 0 && index < AccentTheme.values.length) {
      state = AccentTheme.values[index];
    }
  }

  Future<void> setTheme(AccentTheme theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, theme.index);
  }
}

