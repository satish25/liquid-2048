import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/liquid_glass_container.dart';
import '../../home/presentation/home_screen.dart';

/// Login screen with social authentication options
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final size = MediaQuery.of(context).size;

    // Listen for auth state changes
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: LiquidColors.neonPink.withOpacity(0.8),
          ),
        );
        ref.read(authStateProvider.notifier).clearError();
      }
    });

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.08),
                        // Logo/Title
                        _buildTitle(),
                        const SizedBox(height: 40),
                        // Welcome text
                        _buildWelcomeText(),
                        const SizedBox(height: 48),
                        // Login options
                        _buildLoginOptions(authState),
                        const SizedBox(height: 32),
                        // Guest mode
                        _buildGuestOption(authState),
                        const SizedBox(height: 24),
                        // Terms text
                        _buildTermsText(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Loading overlay
            if (authState.status == AuthStatus.loading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        // Top glow
        Positioned(
          top: -100,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  LiquidColors.neonCyan.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom glow
        Positioned(
          bottom: -100,
          right: -50,
          child: Container(
            width: 350,
            height: 350,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  LiquidColors.neonPurple.withOpacity(0.15),
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
        // App icon representation
        LiquidGlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Icon(
            Icons.grid_4x4_rounded,
            size: 48,
            color: LiquidColors.neonCyan,
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              LiquidColors.neonCyan,
              LiquidColors.neonPurple,
            ],
          ).createShader(bounds),
          child: Text(
            'LIQUID 2048',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome',
          style: GoogleFonts.rajdhani(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to save your progress\nand compete on leaderboards',
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            color: Colors.white60,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginOptions(AuthState authState) {
    return LiquidGlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Google Sign In
          _SocialLoginButton(
            onPressed: () =>
                ref.read(authStateProvider.notifier).signInWithGoogle(),
            icon: _buildGoogleIcon(),
            label: 'Continue with Google',
            backgroundColor: Colors.white,
            textColor: Colors.black87,
          ),

          // Apple Sign In (iOS/macOS only)
          if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) ...[
            const SizedBox(height: 16),
            _SocialLoginButton(
              onPressed: () =>
                  ref.read(authStateProvider.notifier).signInWithApple(),
              icon: const Icon(Icons.apple, color: Colors.white, size: 24),
              label: 'Continue with Apple',
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  Widget _buildGuestOption(AuthState authState) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  color: Colors.white38,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: Colors.white24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LiquidGlassButton(
          onPressed: () =>
              ref.read(authStateProvider.notifier).signInAsGuest(),
          accentColor: LiquidColors.neonPurple,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                'Play as Guest',
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Text(
            'By continuing, you agree to our ',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
          GestureDetector(
            onTap: () => _showTermsOfService(context),
            child: Text(
              'Terms of Service',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: LiquidColors.neonCyan,
                decoration: TextDecoration.underline,
                decorationColor: LiquidColors.neonCyan,
              ),
            ),
          ),
          Text(
            ' and ',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
          GestureDetector(
            onTap: () => _showPrivacyPolicy(context),
            child: Text(
              'Privacy Policy',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: LiquidColors.neonCyan,
                decoration: TextDecoration.underline,
                decorationColor: LiquidColors.neonCyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _LegalDocumentDialog(
        title: 'Terms of Service',
        content: _termsOfServiceContent,
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _LegalDocumentDialog(
        title: 'Privacy Policy',
        content: _privacyPolicyContent,
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: LiquidGlassContainer(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: LiquidColors.neonCyan,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Signing in...',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Social login button widget
class _SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google logo painter
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -0.5,
      1.5,
      true,
      paint,
    );

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      1.0,
      1.0,
      true,
      paint,
    );

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      2.0,
      1.0,
      true,
      paint,
    );

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      3.0,
      1.0,
      true,
      paint,
    );

    // White center
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35,
      paint,
    );

    // Blue bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.35,
        size.width * 0.5,
        size.height * 0.3,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Legal Document Dialog Widget
class _LegalDocumentDialog extends StatelessWidget {
  final String title;
  final String content;

  const _LegalDocumentDialog({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              LiquidColors.backgroundDark1.withOpacity(0.95),
              LiquidColors.backgroundDark2.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: LiquidColors.neonCyan.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: LiquidColors.neonCyan.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    title.contains('Privacy')
                        ? Icons.privacy_tip_outlined
                        : Icons.description_outlined,
                    color: LiquidColors.neonCyan,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white54),
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Text(
                  content,
                  style: GoogleFonts.rajdhani(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LiquidColors.neonCyan.withOpacity(0.2),
                    foregroundColor: LiquidColors.neonCyan,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: LiquidColors.neonCyan.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Text(
                    'I Understand',
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Terms of Service Content
const String _termsOfServiceContent = '''
TERMS OF SERVICE

Last Updated: December 2024

Welcome to Liquid 2048! These Terms of Service ("Terms") govern your use of the Liquid 2048 mobile application and website (the "Service").

1. ACCEPTANCE OF TERMS

By accessing or using Liquid 2048, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use the Service.

2. DESCRIPTION OF SERVICE

Liquid 2048 is a puzzle game application that allows users to:
• Play the classic 2048 number puzzle game
• Track high scores and game progress
• Share scores on social media
• Compete on leaderboards (when signed in)

3. USER ACCOUNTS

3.1 Account Creation
You may use Liquid 2048 as a guest or create an account using social login providers (Google, Apple, Facebook, X/Twitter).

3.2 Account Responsibility
You are responsible for maintaining the confidentiality of your account and for all activities under your account.

3.3 Account Termination
We reserve the right to suspend or terminate your account if you violate these Terms.

4. USER CONDUCT

You agree NOT to:
• Use the Service for any illegal purpose
• Attempt to gain unauthorized access to the Service
• Interfere with or disrupt the Service
• Use automated systems to access the Service
• Impersonate any person or entity

5. INTELLECTUAL PROPERTY

5.1 Our Content
All content, features, and functionality of Liquid 2048 are owned by us and protected by copyright, trademark, and other intellectual property laws.

5.2 Your Content
When you share scores or other content through the Service, you grant us a non-exclusive license to use that content for promotional purposes.

6. PRIVACY

Your use of the Service is also governed by our Privacy Policy, which is incorporated into these Terms by reference.

7. DISCLAIMERS

THE SERVICE IS PROVIDED "AS IS" WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED.

8. LIMITATION OF LIABILITY

WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING FROM YOUR USE OF THE SERVICE.

9. CHANGES TO TERMS

We may modify these Terms at any time. Continued use of the Service after changes constitutes acceptance of the modified Terms.

10. CONTACT US

If you have questions about these Terms, please contact us at:
satishkumara225@gmail.com

Thank you for using Liquid 2048!
''';

/// Privacy Policy Content
const String _privacyPolicyContent = '''
PRIVACY POLICY

Last Updated: December 2024

Liquid 2048 ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information.

1. INFORMATION WE COLLECT

1.1 Information You Provide
• Account information (name, email) when using social login
• Game scores and progress data

1.2 Automatically Collected Information
• Device information (type, operating system)
• Game usage statistics
• Performance and crash data

1.3 Information from Third Parties
When you sign in with Google, Apple, Facebook, or X/Twitter, we receive basic profile information as authorized by you.

2. HOW WE USE YOUR INFORMATION

We use your information to:
• Provide and maintain the game service
• Save and sync your game progress
• Display leaderboards
• Improve the game experience
• Send important updates (with your consent)
• Analyze usage patterns to improve the app

3. DATA STORAGE AND SECURITY

3.1 Cloud Storage
Your game data is stored securely using Firebase services provided by Google. Data is encrypted in transit and at rest.

3.2 Local Storage
Some data is stored locally on your device for offline functionality.

3.3 Data Retention
We retain your data for as long as your account is active. You may request deletion at any time.

4. SHARING YOUR INFORMATION

We do NOT sell your personal information. We may share data with:
• Service providers (Firebase, analytics)
• When required by law
• With your explicit consent

5. YOUR RIGHTS

You have the right to:
• Access your personal data
• Correct inaccurate data
• Delete your data
• Export your data
• Opt-out of analytics

6. CHILDREN'S PRIVACY

Liquid 2048 is suitable for all ages. We do not knowingly collect personal information from children under 13 without parental consent.

7. THIRD-PARTY SERVICES

We use the following third-party services:
• Firebase (Google) - Authentication & Database
• Google Analytics - Usage statistics
• Social login providers - Authentication

Each service has its own privacy policy.

8. COOKIES AND TRACKING

We use minimal tracking for:
• Essential functionality
• Analytics (can be disabled)
• Remembering preferences

9. INTERNATIONAL DATA TRANSFERS

Your data may be processed in countries outside your residence. We ensure appropriate safeguards are in place.

10. CHANGES TO THIS POLICY

We may update this Privacy Policy periodically. We will notify you of significant changes through the app.

11. CONTACT US

For privacy-related questions or requests:
Email: satishkumara225@gmail.com

12. YOUR CONSENT

By using Liquid 2048, you consent to this Privacy Policy.

Thank you for trusting Liquid 2048 with your information!
''';
