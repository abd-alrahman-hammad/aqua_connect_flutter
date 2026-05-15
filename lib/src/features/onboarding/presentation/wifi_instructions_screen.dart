import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class WifiInstructionsScreen extends ConsumerWidget {
  const WifiInstructionsScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? RayyanColors.backgroundDark : RayyanColors.onboardBackgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: RayyanSymbol('arrow_back_ios_new', color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => onNavigate(AppScreen.deviceList),
        ),
        title: Text(
          'Get ready! 1/2',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87, size: 20),
            onPressed: () => onNavigate(AppScreen.deviceList), // Cancel onboarding, go to list
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          
          // Floating Illustration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SizedBox(
              width: double.infinity,
              height: 280,
              child: Center(
                child: ColorFiltered(
                  colorFilter: isDark
                      ? const ColorFilter.matrix([
                          0, 0, 0, 0, 255,
                          0, 0, 0, 0, 255,
                          0, 0, 0, 0, 255,
                          -0.3917, -0.3917, -0.3917, 1, 0,
                        ])
                      : const ColorFilter.matrix([
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0,
                          -0.3917, -0.3917, -0.3917, 1, 0,
                        ]),
                  child: Image.asset(
                    'assets/images/onboarding/wifi_instructions.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            'Connect to Grow',
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'To properly add your appliance, make sure you are connected to a home network.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.6,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => onNavigate(AppScreen.qrInstructions),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RayyanColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'OK, NEXT',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
