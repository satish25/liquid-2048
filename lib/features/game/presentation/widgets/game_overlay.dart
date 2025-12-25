import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/liquid_glass_container.dart';
import '../providers/game_provider.dart';

/// Game over overlay
class GameOverOverlay extends ConsumerWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return _OverlayBase(
      title: 'GAME OVER',
      subtitle: 'Final Score: ${gameState.score}',
      accentColor: LiquidColors.neonPink,
      actions: [
        LiquidGlassButton(
          onPressed: () => ref.read(gameProvider.notifier).restart(),
          accentColor: LiquidColors.neonCyan,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'PLAY AGAIN',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiquidGlassButton(
          onPressed: () => _showShareModal(context, gameState.score),
          accentColor: LiquidColors.neonPurple,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'SHARE SCORE',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareModal(BuildContext context, int score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareScoreModal(score: score),
    );
  }
}

/// Share Score Modal with social media options
class ShareScoreModal extends StatelessWidget {
  final int score;

  const ShareScoreModal({super.key, required this.score});

  // App store links - Update these with your actual store URLs
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.liquid2048.game';
  static const String appStoreUrl =
      'https://apps.apple.com/app/liquid-2048/id123456789';
  static const String webUrl = 'https://liquid2048.web.app';

  String get _shareText => '''🎮 I just scored $score points in Liquid 2048! Can you beat my score? 🏆

📱 Download now:
▸ Android: $playStoreUrl
▸ iOS: $appStoreUrl
▸ Web: $webUrl

#Liquid2048 #2048Game #PuzzleGame''';

  String get _shareTextEncoded => Uri.encodeComponent(_shareText);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: LiquidGlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [LiquidColors.neonCyan, LiquidColors.neonPurple],
              ).createShader(bounds),
              child: Text(
                'SHARE YOUR SCORE',
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Score display
            Text(
              '$score points',
              style: GoogleFonts.rajdhani(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: LiquidColors.neonYellow,
              ),
            ),

            const SizedBox(height: 24),

            // Social media buttons grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _SocialShareButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: LiquidColors.neonCyan,
                  onTap: () => _shareNative(context),
                ),
                _SocialShareButton(
                  icon: Icons.copy,
                  label: 'Copy',
                  color: LiquidColors.neonPurple,
                  onTap: () => _copyToClipboard(context),
                ),
                _SocialShareButton(
                  customIcon: _buildXIcon(),
                  label: 'X',
                  color: Colors.black,
                  onTap: () => _shareToTwitter(context),
                ),
                _SocialShareButton(
                  customIcon: _buildFacebookIcon(),
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                  onTap: () => _shareToFacebook(context),
                ),
                _SocialShareButton(
                  icon: Icons.mail_outline,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  customIcon: _buildWhatsAppIcon(),
                  onTap: () => _shareToWhatsApp(context),
                ),
                _SocialShareButton(
                  icon: Icons.telegram,
                  label: 'Telegram',
                  color: const Color(0xFF0088CC),
                  onTap: () => _shareToTelegram(context),
                ),
                _SocialShareButton(
                  icon: Icons.link,
                  label: 'LinkedIn',
                  color: const Color(0xFF0A66C2),
                  onTap: () => _shareToLinkedIn(context),
                ),
                _SocialShareButton(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  color: LiquidColors.neonPink,
                  onTap: () => _shareViaEmail(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  color: Colors.white60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXIcon() {
    return const Text(
      '𝕏',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildFacebookIcon() {
    return const Text(
      'f',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildWhatsAppIcon() {
    return const Icon(Icons.chat_bubble, color: Colors.white, size: 22);
  }

  Future<void> _shareNative(BuildContext context) async {
    Navigator.pop(context);
    try {
      await Share.share(_shareText, subject: 'My Liquid 2048 Score!');
    } catch (e) {
      _showError(context, 'Could not share');
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    Navigator.pop(context);
    try {
      await Share.share(_shareText);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Score copied to clipboard!',
              style: GoogleFonts.rajdhani(fontSize: 16),
            ),
            backgroundColor: LiquidColors.neonGreen.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      _showError(context, 'Could not copy');
    }
  }

  Future<void> _shareToTwitter(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://twitter.com/intent/tweet?text=$_shareTextEncoded';
    await _launchUrl(context, url);
  }

  Future<void> _shareToFacebook(BuildContext context) async {
    Navigator.pop(context);
    final url =
        'https://www.facebook.com/sharer/sharer.php?quote=$_shareTextEncoded';
    await _launchUrl(context, url);
  }

  Future<void> _shareToWhatsApp(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://wa.me/?text=$_shareTextEncoded';
    await _launchUrl(context, url);
  }

  Future<void> _shareToTelegram(BuildContext context) async {
    Navigator.pop(context);
    final url = 'https://t.me/share/url?text=$_shareTextEncoded';
    await _launchUrl(context, url);
  }

  Future<void> _shareToLinkedIn(BuildContext context) async {
    Navigator.pop(context);
    final encodedUrl = Uri.encodeComponent(webUrl);
    final url =
        'https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl';
    await _launchUrl(context, url);
  }

  Future<void> _shareViaEmail(BuildContext context) async {
    Navigator.pop(context);
    final url =
        'mailto:?subject=My%20Liquid%202048%20Score!&body=$_shareTextEncoded';
    await _launchUrl(context, url);
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open link');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Could not share');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.rajdhani(fontSize: 16),
        ),
        backgroundColor: LiquidColors.neonPink.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Social share button widget
class _SocialShareButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialShareButton({
    this.icon,
    this.customIcon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: customIcon ??
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// Game won overlay
class GameWonOverlay extends ConsumerWidget {
  const GameWonOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return _OverlayBase(
      title: 'YOU WIN!',
      subtitle: 'Score: ${gameState.score}',
      accentColor: LiquidColors.neonYellow,
      showConfetti: true,
      actions: [
        LiquidGlassButton(
          onPressed: () => ref.read(gameProvider.notifier).continueGame(),
          accentColor: LiquidColors.neonGreen,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_forward_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'CONTINUE',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiquidGlassButton(
          onPressed: () => _showShareModal(context, gameState.score),
          accentColor: LiquidColors.neonPurple,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.share_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'SHARE SCORE',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LiquidGlassButton(
          onPressed: () => ref.read(gameProvider.notifier).restart(),
          accentColor: LiquidColors.neonCyan,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'NEW GAME',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showShareModal(BuildContext context, int score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareScoreModal(score: score),
    );
  }
}

class _OverlayBase extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color accentColor;
  final List<Widget> actions;
  final bool showConfetti;

  const _OverlayBase({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.actions,
    this.showConfetti = false,
  });

  @override
  State<_OverlayBase> createState() => _OverlayBaseState();
}

class _OverlayBaseState extends State<_OverlayBase>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10 * _fadeAnimation.value,
              sigmaY: 10 * _fadeAnimation.value,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: LiquidGlassContainer(
                    padding: const EdgeInsets.all(32),
                    borderColor: widget.accentColor.withOpacity(0.5),
                    shadows: [
                      BoxShadow(
                        color: widget.accentColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                    ],
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title with glow
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              widget.accentColor,
                              Colors.white,
                              widget.accentColor,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            widget.title,
                            style: GoogleFonts.orbitron(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          widget.subtitle,
                          style: GoogleFonts.rajdhani(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Actions
                        ...widget.actions,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
