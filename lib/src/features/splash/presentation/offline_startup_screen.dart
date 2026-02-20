import 'dart:async';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';

/// Full-screen offline screen shown at startup when Remember Me is enabled
/// but no internet connection is available.
///
/// This screen is **not** part of the [AppScreen] enum and does not modify
/// [_AppRoot]. It receives the same [onNavigate] callback from SplashScreen
/// so it can re-enter the normal navigation flow when connectivity is restored.
class OfflineStartupScreen extends StatefulWidget {
  const OfflineStartupScreen({super.key, required this.onNavigate});

  /// Callback to navigate back into the normal app flow.
  final void Function(AppScreen) onNavigate;

  @override
  State<OfflineStartupScreen> createState() => _OfflineStartupScreenState();
}

class _OfflineStartupScreenState extends State<OfflineStartupScreen>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the plant icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for connectivity changes
    _subscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasInternet = results.any((r) => r != ConnectivityResult.none);
    if (hasInternet && mounted && !_navigating) {
      _navigating = true;
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    // Pop this route (back to _AppRoot showing splash underneath),
    // then immediately trigger the state-machine navigation to dashboard.
    Navigator.of(context).pop();
    widget.onNavigate(AppScreen.dashboard);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    final backgroundColor = isDark
        ? AquaColors.backgroundDark
        : AquaColors.backgroundLight;
    final textColor = isDark ? Colors.white : AquaColors.slate900;
    final subTextColor = isDark ? AquaColors.slate300 : AquaColors.slate500;

    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false, // Prevent back navigation to splash
      child: Scaffold(
        backgroundColor: backgroundColor,
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
                      // Pulsing plant icon
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AquaColors.primary.withValues(
                              alpha: isDark ? 0.15 : 0.1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.wifi_off_rounded,
                              size: 52,
                              color: isDark
                                  ? AquaColors.slate300
                                  : AquaColors.slate500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        l10n.offlineStartupTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Message
                      Text(
                        l10n.offlineStartupMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: subTextColor,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Subtle loading indicator
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AquaColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Background blobs (same pattern as SplashScreen) ───

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
