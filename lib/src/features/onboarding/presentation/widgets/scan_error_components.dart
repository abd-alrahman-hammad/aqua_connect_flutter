import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/rayyan_colors.dart';

class ScanErrorBox extends StatelessWidget {
  const ScanErrorBox({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: RayyanColors.onboardError.withValues(alpha: 0.05),
              blurRadius: 40,
              spreadRadius: 10,
            ),
        ],
        border: Border.all(
          color: isDark
              ? RayyanColors.onboardError.withValues(alpha: 0.2)
              : RayyanColors.onboardErrorLight,
          width: 4,
        ),
      ),
      child: Column(
        children: [
          // QR Icon with Red X overlay
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 80,
                color: isDark ? Colors.white12 : Colors.grey.shade200,
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: RayyanColors.onboardError,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: RayyanColors.onboardError.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Invalid Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: RayyanColors.onboardErrorSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'INVALID QR CODE',
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: RayyanColors.onboardError,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanErrorTip extends StatelessWidget {
  const ScanErrorTip({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: RayyanColors.onboardCardLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.branding_watermark_outlined,
              color: RayyanColors.onboardTextDark,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check Label',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Look for the "Rayyan" logo on the silver rating plate.',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: isDark ? Colors.white54 : Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
