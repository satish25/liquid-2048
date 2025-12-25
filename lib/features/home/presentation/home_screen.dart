import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/liquid_glass_container.dart';
import '../../auth/presentation/login_screen.dart';
import '../../game/presentation/providers/game_provider.dart';
import '../../game/presentation/screens/game_screen.dart';

/// Home screen with title and play button
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
            // Animated background decorations
            _buildAnimatedBackground(),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // User profile bar
                  _buildUserProfileBar(authState),
                  // Scrollable content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo/Title
                            _buildTitle(),
                            const SizedBox(height: 48),
                            // Preview grid decoration
                            _buildPreviewGrid(),
                            const SizedBox(height: 48),
                            // High score display
                            if (highScore > 0) ...[
                              _buildHighScoreCard(highScore),
                              const SizedBox(height: 32),
                            ],
                            // Play button
                            _buildPlayButton(context),
                            const SizedBox(height: 24),
                            // How to play hint
                            _buildHowToPlay(),
                          ],
                        ),
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
          // Profile picture
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
          // User name
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
          // Settings/Menu button
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
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Profile info
            if (!isGuest && authState.user != null) ...[
              CircleAvatar(
                radius: 40,
                backgroundImage: authState.user!.photoURL != null
                    ? NetworkImage(authState.user!.photoURL!)
                    : null,
                backgroundColor: LiquidColors.neonCyan.withOpacity(0.2),
                child: authState.user!.photoURL == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: LiquidColors.neonCyan,
                      )
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
            // Menu options
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
        // Top glow
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
        // Bottom glow
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
        // Center purple glow
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
        // Main title with shader mask for gradient
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
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 12,
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
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 8,
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

  Widget _buildPreviewGrid() {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: 200,
        height: 200,
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _previewTile(2),
            _previewTile(0),
            _previewTile(4),
            _previewTile(0),
            _previewTile(0),
            _previewTile(8),
            _previewTile(0),
            _previewTile(2),
            _previewTile(16),
            _previewTile(0),
            _previewTile(32),
            _previewTile(0),
            _previewTile(0),
            _previewTile(64),
            _previewTile(0),
            _previewTile(128),
          ],
        ),
      ),
    );
  }

  Widget _previewTile(int value) {
    if (value == 0) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white.withOpacity(0.05),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LiquidColors.getTileColor(value),
            LiquidColors.getTileColor(value).withOpacity(0.6),
          ],
        ),
        border: Border.all(
          color: LiquidColors.getTileBorderColor(value).withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: LiquidColors.getTileBorderColor(value).withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          value.toString(),
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: LiquidColors.getTileTextColor(value),
          ),
        ),
      ),
    );
  }

  Widget _buildHighScoreCard(int highScore) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      borderColor: LiquidColors.neonYellow.withOpacity(0.4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            color: LiquidColors.neonYellow,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HIGH SCORE',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: LiquidColors.neonYellow,
                  letterSpacing: 2,
                ),
              ),
              Text(
                highScore.toString(),
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return LiquidGlassButton(
      onPressed: () => _startGame(context),
      accentColor: LiquidColors.neonCyan,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'PLAY',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ],
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
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: Colors.white60,
            ),
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
        border: Border.all(
          color: Colors.white24,
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white54,
        size: 16,
      ),
    );
  }

  void _startGame(BuildContext context) {
    // Reset the game before navigating
    ref.read(gameProvider.notifier).restart();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

/// Profile menu item widget
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: color.withOpacity(0.1),
    );
  }
}
