import 'package:flutter/material.dart';

/// Visual theme configuration for the game
class VisualTheme {
  final String id;
  final String name;
  final String description;
  final Color backgroundDark1;
  final Color backgroundDark2;
  final Color backgroundDark3;
  final Color accentPrimary;
  final Color accentSecondary;
  final Color accentTertiary;
  final Map<int, Color> tileColors;
  final bool isPremium;

  const VisualTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.backgroundDark1,
    required this.backgroundDark2,
    required this.backgroundDark3,
    required this.accentPrimary,
    required this.accentSecondary,
    required this.accentTertiary,
    required this.tileColors,
    this.isPremium = false,
  });

  Color getTileColor(int value) {
    if (tileColors.containsKey(value)) {
      return tileColors[value]!;
    }
    if (value > 2048) {
      return tileColors[2048] ?? accentPrimary;
    }
    return accentPrimary.withOpacity(0.6);
  }

  Color getTileTextColor(int value) {
    if (value <= 4) {
      return backgroundDark1;
    }
    return Colors.white;
  }

  LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundDark1, backgroundDark2, backgroundDark3],
    stops: const [0.0, 0.5, 1.0],
  );
}

/// Available visual themes
class VisualThemes {
  /// Liquid Neon - Original theme (Cyan/Pink)
  static const VisualTheme liquidNeon = VisualTheme(
    id: 'liquid_neon',
    name: 'Liquid Neon',
    description: 'Vibrant neon glow in the dark',
    backgroundDark1: Color(0xFF0D0D1A),
    backgroundDark2: Color(0xFF1A1A2E),
    backgroundDark3: Color(0xFF16213E),
    accentPrimary: Color(0xFF00F5FF), // Cyan
    accentSecondary: Color(0xFFFF006E), // Pink
    accentTertiary: Color(0xFF9D4EDD), // Purple
    tileColors: {
      2: Color(0xCC4CC9F0),
      4: Color(0xCC4895EF),
      8: Color(0xD97209B7),
      16: Color(0xD99D4EDD),
      32: Color(0xD9F72585),
      64: Color(0xD9FF006E),
      128: Color(0xE6FF6B35),
      256: Color(0xE6FFBE0B),
      512: Color(0xD939FF14),
      1024: Color(0xE600F5FF),
      2048: Color(0xF2FFD700),
    },
  );

  /// Aurora - Northern lights inspired (Green/Blue/Purple)
  static const VisualTheme aurora = VisualTheme(
    id: 'aurora',
    name: 'Aurora',
    description: 'Northern lights in motion',
    backgroundDark1: Color(0xFF0A1628),
    backgroundDark2: Color(0xFF0F2744),
    backgroundDark3: Color(0xFF1A3A5C),
    accentPrimary: Color(0xFF00FF87), // Mint green
    accentSecondary: Color(0xFF60EFFF), // Sky blue
    accentTertiary: Color(0xFFB388FF), // Lavender
    tileColors: {
      2: Color(0xCC60EFFF),
      4: Color(0xCC00D9FF),
      8: Color(0xD900FF87),
      16: Color(0xD950FF50),
      32: Color(0xD9B388FF),
      64: Color(0xD9D583FF),
      128: Color(0xE6FF83F5),
      256: Color(0xE6FFDD50),
      512: Color(0xD900FFD0),
      1024: Color(0xE660EFFF),
      2048: Color(0xF2FFFFFF),
    },
  );

  /// Sunset - Warm orange/red tones
  static const VisualTheme sunset = VisualTheme(
    id: 'sunset',
    name: 'Sunset',
    description: 'Warm golden hour vibes',
    backgroundDark1: Color(0xFF1A0A14),
    backgroundDark2: Color(0xFF2D1420),
    backgroundDark3: Color(0xFF3D1F2D),
    accentPrimary: Color(0xFFFF6B35), // Orange
    accentSecondary: Color(0xFFFF4081), // Pink
    accentTertiary: Color(0xFFFFAB40), // Amber
    tileColors: {
      2: Color(0xCCFFE082),
      4: Color(0xCCFFCA28),
      8: Color(0xD9FFAB40),
      16: Color(0xD9FF9100),
      32: Color(0xD9FF6B35),
      64: Color(0xD9FF5722),
      128: Color(0xE6FF4081),
      256: Color(0xE6F50057),
      512: Color(0xD9FF1744),
      1024: Color(0xE6FF6D00),
      2048: Color(0xF2FFD700),
    },
  );

  /// Ocean - Deep blue/teal tones
  static const VisualTheme ocean = VisualTheme(
    id: 'ocean',
    name: 'Ocean',
    description: 'Deep sea tranquility',
    backgroundDark1: Color(0xFF001F3D),
    backgroundDark2: Color(0xFF003366),
    backgroundDark3: Color(0xFF004080),
    accentPrimary: Color(0xFF00BCD4), // Teal
    accentSecondary: Color(0xFF26C6DA), // Cyan
    accentTertiary: Color(0xFF80DEEA), // Light cyan
    tileColors: {
      2: Color(0xCC80DEEA),
      4: Color(0xCC4DD0E1),
      8: Color(0xD926C6DA),
      16: Color(0xD900BCD4),
      32: Color(0xD900ACC1),
      64: Color(0xD90097A7),
      128: Color(0xE600838F),
      256: Color(0xE6006978),
      512: Color(0xD900E5FF),
      1024: Color(0xE618FFFF),
      2048: Color(0xF2FFFFFF),
    },
  );

  /// Monochrome - Elegant black and white
  static const VisualTheme monochrome = VisualTheme(
    id: 'monochrome',
    name: 'Monochrome',
    description: 'Elegant simplicity',
    backgroundDark1: Color(0xFF0A0A0A),
    backgroundDark2: Color(0xFF141414),
    backgroundDark3: Color(0xFF1E1E1E),
    accentPrimary: Color(0xFFFFFFFF),
    accentSecondary: Color(0xFFBDBDBD),
    accentTertiary: Color(0xFF757575),
    tileColors: {
      2: Color(0xCCE0E0E0),
      4: Color(0xCCBDBDBD),
      8: Color(0xD9A0A0A0),
      16: Color(0xD9888888),
      32: Color(0xD9707070),
      64: Color(0xD9585858),
      128: Color(0xE6F0F0F0),
      256: Color(0xE6F5F5F5),
      512: Color(0xD9FAFAFA),
      1024: Color(0xE6FFFFFF),
      2048: Color(0xF2FFD700), // Gold for 2048
    },
  );

  /// Nature - Forest/earth tones
  static const VisualTheme nature = VisualTheme(
    id: 'nature',
    name: 'Forest',
    description: 'Earth and greenery',
    backgroundDark1: Color(0xFF0A1F0A),
    backgroundDark2: Color(0xFF1A331A),
    backgroundDark3: Color(0xFF264726),
    accentPrimary: Color(0xFF4CAF50), // Green
    accentSecondary: Color(0xFF8BC34A), // Light green
    accentTertiary: Color(0xFFCDDC39), // Lime
    tileColors: {
      2: Color(0xCCC8E6C9),
      4: Color(0xCCA5D6A7),
      8: Color(0xD981C784),
      16: Color(0xD966BB6A),
      32: Color(0xD94CAF50),
      64: Color(0xD943A047),
      128: Color(0xE68BC34A),
      256: Color(0xE6CDDC39),
      512: Color(0xD9FFEB3B),
      1024: Color(0xE6FFC107),
      2048: Color(0xF2FFD700),
    },
  );

  static List<VisualTheme> get allThemes => [
    liquidNeon,
    aurora,
    sunset,
    ocean,
    monochrome,
    nature,
  ];

  static VisualTheme getById(String id) {
    return allThemes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => liquidNeon,
    );
  }
}
