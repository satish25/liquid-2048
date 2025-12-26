import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/liquid_glass_container.dart';
import '../../auth/presentation/login_screen.dart';
import '../../game/presentation/providers/game_provider.dart';
import '../../game/presentation/screens/game_screen.dart';
import '../../game/presentation/screens/mode_selection_screen.dart';
import '../../game/presentation/screens/statistics_screen.dart';
import '../../game/presentation/screens/theme_selection_screen.dart';

/// Home screen with title, game modes, and navigation
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highScore = ref.watch(highScoreProvider);
    final authState = ref.watch(authStateProvider);
    final stats = ref.watch(gameStatisticsProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LiquidColors.backgroundDark1,
              LiquidColors.backgroundDark2,
              LiquidColors.backgroundDark3,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildUserProfileBar(authState),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildTitle(),
                          const SizedBox(height: 32),
                          _buildQuickStats(highScore, stats),
                          const SizedBox(height: 32),
                          _buildQuickPlayButton(),
                          const SizedBox(height: 16),
                          _buildGameModeButton(),
                          const SizedBox(height: 32),
                          _buildFeatureGrid(),
                          const SizedBox(height: 24),
                          _buildHowToPlay(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileBar(AuthState authState) {
    final user = authState.user;
    final isGuest = user?.isAnonymous ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showProfileMenu(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: LiquidColors.neonCyan.withOpacity(0.5),
                  width: 2,
                ),
                image: user?.photoURL != null
                    ? DecorationImage(
                        image: NetworkImage(user!.photoURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user?.photoURL == null
                  ? Icon(
                      isGuest ? Icons.person_outline : Icons.person,
                      color: LiquidColors.neonCyan,
                      size: 24,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? 'Guest' : (user?.displayName ?? 'Player'),
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isGuest && user?.email != null)
                  Text(
                    user!.email!,
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          LiquidGlassIconButton(
            icon: Icons.more_vert_rounded,
            onPressed: () => _showProfileMenu(context),
            size: 40,
            color: LiquidColors.neonPurple,
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authState = ref.read(authStateProvider);
    final isGuest = authState.user?.isAnonymous ?? true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LiquidGlassContainer(
        borderRadius: 24,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            if (!isGuest && authState.user != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundImage: authState.user!.photoURL != null
                    ? NetworkImage(authState.user!.photoURL!)
                    : null,
                backgroundColor: LiquidColors.neonCyan.withOpacity(0.2),
                child: authState.user!.photoURL == null
                    ? Icon(Icons.person, size: 40, color: LiquidColors.neonCyan)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                authState.user!.displayName ?? 'Player',
                style: GoogleFonts.rajdhani(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (authState.user!.email != null)
                Text(
                  authState.user!.email!,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),
              const SizedBox(height: 24),
            ],
            if (isGuest)
              _ProfileMenuItem(
                icon: Icons.login_rounded,
                label: 'Sign In',
                color: LiquidColors.neonCyan,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authStateProvider.notifier).signOut();
                },
              ),
            _ProfileMenuItem(
              icon: Icons.logout_rounded,
              label: isGuest ? 'Exit Guest Mode' : 'Sign Out',
              color: LiquidColors.neonPink,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Positioned(
              top: -150 + (10 * _pulseAnimation.value),
              left: -50,
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        LiquidColors.neonCyan.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: -100 - (10 * _pulseAnimation.value),
              right: -100,
              child: Opacity(
                opacity: 0.3,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        LiquidColors.neonPink.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: MediaQuery.of(context).size.width * 0.3,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  LiquidColors.neonPurple.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              LiquidColors.neonCyan,
              LiquidColors.neonPurple,
              LiquidColors.neonPink,
            ],
          ).createShader(bounds),
          child: Text(
            'LIQUID',
            style: GoogleFonts.orbitron(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 10,
              height: 1,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Text(
                '2048',
                style: GoogleFonts.orbitron(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 6,
                  height: 1,
                  shadows: [
                    Shadow(
                      color: LiquidColors.neonCyan.withOpacity(0.8),
                      blurRadius: 20,
                    ),
                    Shadow(
                      color: LiquidColors.neonPink.withOpacity(0.5),
                      blurRadius: 40,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickStats(int highScore, stats) {
    return Row(
      children: [
        Expanded(
          child: LiquidGlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: LiquidColors.neonYellow.withOpacity(0.4),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: LiquidColors.neonYellow,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  highScore.toString(),
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Best Score',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LiquidGlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: LiquidColors.neonCyan.withOpacity(0.4),
            child: Column(
              children: [
                Icon(
                  Icons.sports_esports_rounded,
                  color: LiquidColors.neonCyan,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  stats.totalGamesPlayed.toString(),
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Games Played',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LiquidGlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: LiquidColors.neonPink.withOpacity(0.4),
            child: Column(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: LiquidColors.neonPink,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.currentStreak}',
                  style: GoogleFonts.orbitron(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Day Streak',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPlayButton() {
    return SizedBox(
      width: double.infinity,
      child: LiquidGlassButton(
        onPressed: () => _startQuickGame(context),
        accentColor: LiquidColors.neonCyan,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Text(
              'QUICK PLAY',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeButton() {
    return SizedBox(
      width: double.infinity,
      child: LiquidGlassButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ModeSelectionScreen()),
        ),
        accentColor: LiquidColors.neonPurple,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              'GAME MODES',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.bar_chart_rounded,
                title: 'Statistics',
                color: LiquidColors.neonGreen,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.palette_rounded,
                title: 'Themes',
                color: LiquidColors.neonOrange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSelectionScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(20),
        borderColor: color.withOpacity(0.3),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowToPlay() {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      backgroundColor: Colors.white.withOpacity(0.03),
      child: Column(
        children: [
          Text(
            'HOW TO PLAY',
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: LiquidColors.neonCyan,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Swipe to move all tiles. When two tiles with the same number touch, they merge into one!',
            style: GoogleFonts.rajdhani(fontSize: 14, color: Colors.white60),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _directionIcon(Icons.arrow_upward_rounded),
              _directionIcon(Icons.arrow_downward_rounded),
              _directionIcon(Icons.arrow_back_rounded),
              _directionIcon(Icons.arrow_forward_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _directionIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Icon(icon, color: Colors.white54, size: 16),
    );
  }

  void _startQuickGame(BuildContext context) {
    ref.read(gameProvider.notifier).restart();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: color.withOpacity(0.1),
    );
  }
}
