import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';
import 'widgets/scan_error_components.dart';

class DeviceScanErrorScreen extends ConsumerWidget {
  const DeviceScanErrorScreen({super.key, required this.onNavigate});

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
          onPressed: () => onNavigate(AppScreen.deviceScanQr),
        ),
        title: Text(
          'Connect Device',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: ScanErrorBox(isDark: isDark),
          ),
          
          const SizedBox(height: 40),
          
          // Error Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
                children: const [
                  TextSpan(text: 'You are scanning the\n'),
                  TextSpan(
                    text: 'wrong ',
                    style: TextStyle(color: RayyanColors.onboardError),
                  ),
                  TextSpan(text: 'QR code'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Please scan the specific QR code located on the front of your Rayyan appliance or inside the user manual.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Check Label Tip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ScanErrorTip(isDark: isDark),
          ),
          
          const Spacer(),
          
          // Try Again Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => onNavigate(AppScreen.deviceScanQr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: RayyanColors.onboardSuccess,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_scanner, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'TRY AGAIN',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
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
