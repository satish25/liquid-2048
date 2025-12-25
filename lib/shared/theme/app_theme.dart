import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Liquid glass color palette
class LiquidColors {
  // Primary glass colors
  static const Color primaryGlass = Color(0x40FFFFFF);
  static const Color secondaryGlass = Color(0x20FFFFFF);
  static const Color darkGlass = Color(0x60000000);
  
  // Background gradients
  static const Color backgroundDark1 = Color(0xFF0D0D1A);
  static const Color backgroundDark2 = Color(0xFF1A1A2E);
  static const Color backgroundDark3 = Color(0xFF16213E);
  
  // Neon accent colors
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonOrange = Color(0xFFFF6B35);
  static const Color neonYellow = Color(0xFFFFE66D);
  static const Color neonBlue = Color(0xFF4CC9F0);
  
  // Tile colors based on value
  static Color getTileColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFF4CC9F0).withOpacity(0.8); // Cyan
      case 4:
        return const Color(0xFF4895EF).withOpacity(0.8); // Blue
      case 8:
        return const Color(0xFF7209B7).withOpacity(0.85); // Purple
      case 16:
        return const Color(0xFF9D4EDD).withOpacity(0.85); // Light Purple
      case 32:
        return const Color(0xFFF72585).withOpacity(0.85); // Pink
      case 64:
        return const Color(0xFFFF006E).withOpacity(0.85); // Hot Pink
      case 128:
        return const Color(0xFFFF6B35).withOpacity(0.9); // Orange
      case 256:
        return const Color(0xFFFFBE0B).withOpacity(0.9); // Yellow
      case 512:
        return const Color(0xFF39FF14).withOpacity(0.85); // Green
      case 1024:
        return const Color(0xFF00F5FF).withOpacity(0.9); // Bright Cyan
      case 2048:
        return const Color(0xFFFFD700).withOpacity(0.95); // Gold
      default:
        if (value > 2048) {
          return const Color(0xFFFFD700).withOpacity(0.95);
        }
        return const Color(0xFF4CC9F0).withOpacity(0.6);
    }
  }
  
  // Tile border glow color
  static Color getTileBorderColor(int value) {
    switch (value) {
      case 2:
        return neonCyan;
      case 4:
        return neonBlue;
      case 8:
      case 16:
        return neonPurple;
      case 32:
      case 64:
        return neonPink;
      case 128:
        return neonOrange;
      case 256:
        return neonYellow;
      case 512:
        return neonGreen;
      case 1024:
      case 2048:
        return neonYellow;
      default:
        return neonCyan;
    }
  }
  
  // Text color based on tile value
  static Color getTileTextColor(int value) {
    if (value <= 4) {
      return const Color(0xFF1A1A2E);
    }
    return Colors.white;
  }
}

/// App theme configuration
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: LiquidColors.backgroundDark1,
      colorScheme: const ColorScheme.dark(
        primary: LiquidColors.neonCyan,
        secondary: LiquidColors.neonPink,
        surface: LiquidColors.backgroundDark2,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 4,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 2,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.rajdhani(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: GoogleFonts.rajdhani(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
        bodyLarge: GoogleFonts.rajdhani(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: GoogleFonts.rajdhani(
          fontSize: 14,
          color: Colors.white70,
        ),
        labelLarge: GoogleFonts.orbitron(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LiquidColors.primaryGlass,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

