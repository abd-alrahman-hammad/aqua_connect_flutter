import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/services/auth_preferences_service.dart';
import '../../../core/services/firebase_auth_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNavigation() async {
    final prefsService = ref.read(authPreferencesServiceProvider);
    final authService = ref.read(firebaseAuthServiceProvider);

    final rememberMe = await prefsService.getRememberMe();

    if (!rememberMe) {
      await authService.signOut();
      widget.onNavigate(AppScreen.login);
      return;
    }

    final user = authService.currentUser;

    if (user == null) {
      widget.onNavigate(AppScreen.login);
      return;
    }

    if (!user.emailVerified) {
      await authService.signOut();
      widget.onNavigate(AppScreen.login);
      return;
    }

    widget.onNavigate(AppScreen.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    // الاعتماد على Theme.of لضمان التوافق مع الثيم
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AquaColors.backgroundDark
        : AquaColors.backgroundLight;

    final textColor = isDark ? Colors.white : AquaColors.slate900;

    final subTitleColor = isDark ? AquaColors.slate300 : AquaColors.slate500;

    final trackColor = isDark
        ? AquaColors.slate700.withValues(alpha: 0.3)
        : AquaColors.slate200;

    return Scaffold(
      backgroundColor: backgroundColor,
      // AppBar وهمي لضبط Status Bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          _buildBackgroundBlobs(isDark),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            _buildLogo(isDark),

                            const SizedBox(height: 32),

                            Text(
                              'Rayyan',
                              style: GoogleFonts.manrope(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: textColor,
                                letterSpacing: -1.0,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'Smart Hydroponics Management',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: subTitleColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    _buildProgressBar(trackColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AquaColors.primary.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        isDark ? 'assets/logo/logo.png' : 'assets/logo/logo.png',
        fit: BoxFit.contain,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Image.asset('assets/logo/logo.png', fit: BoxFit.contain);
        },
      ),
    );
  }

  Widget _buildProgressBar(Color trackColor) {
    return SizedBox(
      width: 180,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 3),
        curve: Curves.easeInOutQuart,
        onEnd: _handleNavigation,
        builder: (context, value, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: trackColor,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AquaColors.primary,
              ),
              minHeight: 4,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundBlobs(bool isDark) {
    final primaryBlobColor = AquaColors.primary.withValues(
      alpha: isDark ? 0.08 : 0.05,
    );
    final aquaBlobColor = AquaColors.aqua.withValues(
      alpha: isDark ? 0.08 : 0.05,
    );

    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -80,
          child: _buildBlob(primaryBlobColor, 350),
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: _buildBlob(aquaBlobColor, 350),
        ),
      ],
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
        ),
      ),
    );
  }
}
