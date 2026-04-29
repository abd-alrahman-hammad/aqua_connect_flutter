
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class DeviceScanQrScreen extends ConsumerWidget {
  const DeviceScanQrScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? RayyanColors.backgroundDark
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: RayyanSymbol(
            'arrow_back_ios_new',
            color: isDark ? Colors.white : Colors.black87,
            size: 20,
          ),
          onPressed: () => onNavigate(AppScreen.qrInstructions),
        ),
        title: Text(
          'Connect Device',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: () => onNavigate(AppScreen.login), // Cancel
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Placeholder for Camera Feed
          Image.network(
            'https://images.unsplash.com/photo-1530836369250-ef71a3a5e4b8?q=80&w=2070&auto=format&fit=crop',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey.shade900),
          ),

          // Dark Overlay with Cutout (Simulated with simple dark overlay for now)
          Container(color: Colors.black.withValues(alpha: 0.6)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Toggle Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                'SCAN',
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: RayyanColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                onNavigate(AppScreen.deviceManualEntry),
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Text(
                                  'MANUAL',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Viewfinder Placeholder
                GestureDetector(
                  // Simulating scan failure or success
                  onDoubleTap: () => onNavigate(
                    AppScreen.login,
                  ), // Success -> go to dashboard/login
                  onTap: () => onNavigate(
                    AppScreen.deviceScanError,
                  ), // Tap simulates error for preview
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: RayyanColors.primary, width: 3),
                    ),
                    child: Center(
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1530836369250-ef71a3a5e4b8?q=80&w=2070',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Text
                Text(
                  'Scan the QR code',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0),
                  child: Text(
                    'Position the code within the frame for automatic detection.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Flashlight Button
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: RayyanColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.highlight_outlined,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
