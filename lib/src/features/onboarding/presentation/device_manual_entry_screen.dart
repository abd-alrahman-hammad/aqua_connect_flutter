import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';
import 'widgets/manual_input_dot.dart';

class DeviceManualEntryScreen extends ConsumerWidget {
  const DeviceManualEntryScreen({super.key, required this.onNavigate});

  final void Function(AppScreen) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? RayyanColors.backgroundDark
          : RayyanColors.onboardBackgroundLight,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: () => onNavigate(AppScreen.login),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Toggle Buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? RayyanColors.cardDark
                                    : RayyanColors.onboardCardLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          onNavigate(AppScreen.deviceScanQr),
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Text(
                                            'SCAN',
                                            style: GoogleFonts.manrope(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.white54
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? RayyanColors.surfaceDark
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          if (!isDark)
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'MANUAL',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: RayyanColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              'Enter the number of your\nappliance.',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              'Please type the 12-character serial code found on the sticker of your hydroponic unit.',
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Where can I find the serial number?',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: RayyanColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: RayyanColors.primary,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 48),

                          // 12 Input Dots Placeholder
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    6,
                                    (index) => ManualInputDot(isDark: isDark),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    6,
                                    (index) => ManualInputDot(isDark: isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Bottom Button
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 24.0,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () =>
                                    onNavigate(AppScreen.dashboard),
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
                                      'CONFIRM',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
