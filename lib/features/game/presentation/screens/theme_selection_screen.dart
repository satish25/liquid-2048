import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/visual_theme.dart';
import '../../../../shared/theme/app_theme.dart';
import '../providers/game_provider.dart';

/// Screen for selecting visual themes
class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeId = ref.watch(currentThemeIdProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LiquidColors.backgroundDark1,
              LiquidColors.backgroundDark2,
              LiquidColors.backgroundDark3,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: VisualThemes.allThemes.length,
                  itemBuilder: (context, index) {
                    final theme = VisualThemes.allThemes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildThemeCard(
                        context,
                        ref,
                        theme,
                        isSelected: theme.id == currentThemeId,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: LiquidColors.neonCyan,
            ),
          ),
          const Spacer(),
          Text(
            'THEMES',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    WidgetRef ref,
    VisualTheme theme, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(currentThemeIdProvider.notifier).state = theme.id;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.accentPrimary
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.accentPrimary.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Theme preview
              Container(
                height: 140,
                decoration: BoxDecoration(gradient: theme.backgroundGradient),
                child: Stack(
                  children: [
                    // Accent glow decorations
                    Positioned(
                      top: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.accentPrimary.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              theme.accentSecondary.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Sample tiles
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSampleTile(theme, 2),
                          const SizedBox(width: 8),
                          _buildSampleTile(theme, 8),
                          const SizedBox(width: 8),
                          _buildSampleTile(theme, 32),
                          const SizedBox(width: 8),
                          _buildSampleTile(theme, 2048),
                        ],
                      ),
                    ),
                    // Selected checkmark
                    if (isSelected)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.accentPrimary,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Theme info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.name,
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.description,
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Color swatches
                    Row(
                      children: [
                        _buildColorSwatch(theme.accentPrimary),
                        const SizedBox(width: 4),
                        _buildColorSwatch(theme.accentSecondary),
                        const SizedBox(width: 4),
                        _buildColorSwatch(theme.accentTertiary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleTile(VisualTheme theme, int value) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.getTileColor(value),
        boxShadow: [
          BoxShadow(
            color: theme.getTileColor(value).withOpacity(0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: GoogleFonts.orbitron(
            fontSize: value > 999 ? 10 : 14,
            fontWeight: FontWeight.bold,
            color: theme.getTileTextColor(value),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwatch(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
    );
  }
}
