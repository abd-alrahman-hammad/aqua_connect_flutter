import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const AquaConnectApp());
}

class AquaConnectApp extends StatelessWidget {
  const AquaConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aqua Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Setting the font globally to Manrope
        textTheme: GoogleFonts.manropeTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // Define colors from the CSS config
  static const Color primaryColor = Color(0xFF7AC144); // Green
  static const Color aquaBlue = Color(0xFF0099DB);     // Blue
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF1A1A1A);
  static const Color progressTrackColor = Color(0xFFF0F0F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          // 1. Background Blurred Blobs
          _buildBackgroundBlobs(),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Top Spacer
                  const SizedBox(height: 48),

                  // Center Content (Logo + Title)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Composition
                        _buildLogo(),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          'Aqua Connect',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 36,
                            fontWeight: FontWeight.w800, // ExtraBold
                            color: textColor,
                            height: 1.1,
                            letterSpacing: -0.5, // tight tracking
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Content (Subtitle + Progress)
                  SizedBox(
                    width: 320, // max-w-xs equivalent
                    child: Column(
                      children: [
                        Text(
                          'Smart Farming, Simplified',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.6),
                            letterSpacing: 0.5, // tracking-wide
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Custom Progress Bar
                        Container(
                          height: 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: progressTrackColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.45, // 45% width
                            child: Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48), // Padding bottom
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    // Scaling the logo slightly to match "scale-110" from CSS
    return Transform.scale(
      scale: 1.1,
      child: SizedBox(
        width: 160,
        height: 160,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main Water Drop
            const Icon(
              Icons.water_drop, // standard filled icon
              size: 100,
              color: aquaBlue,
            ),
            
            // Eco Leaf (Bottom Left, Rotated)
            Positioned(
              bottom: 30, // Adjusting visual alignment
              left: 30,
              child: Transform.rotate(
                angle: 45 * (math.pi / 180), // 45 degrees
                child: const Icon(
                  Icons.eco,
                  size: 60,
                  color: primaryColor,
                ),
              ),
            ),

            // RSS Feed (Right side)
            const Positioned(
              right: 20, 
              // The CSS had a translation, we adjust via Positioned
              child: Opacity(
                opacity: 0.8,
                child: Icon(
                  Icons.rss_feed,
                  size: 36, // text-4xl equivalent
                  color: aquaBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        // Top Left Blob (Aqua Blue)
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 256, // w-64
            height: 256, // h-64
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: aquaBlue.withOpacity(0.05), // bg-aqua-blue/5
              boxShadow: [
                BoxShadow(
                  color: aquaBlue.withOpacity(0.05),
                  blurRadius: 100, // blur-3xl
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        // Bottom Right Blob (Primary/Green)
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.05), // bg-primary/5
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.05),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}