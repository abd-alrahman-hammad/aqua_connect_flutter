import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_bottom_nav.dart';
import '../../../core/widgets/rayyan_header.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class VisionScreen extends StatelessWidget {
  const VisionScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              // camera feed area
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                    // Header overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: RayyanHeader(
                        title: 'Plant Health AI Vision',
                        onBack: () => onNavigate(AppScreen.dashboard),

                        forceDarkText: false,
                      ),
                    ),
                    // Bounding box
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.20,
                      top: MediaQuery.of(context).size.height * 0.25,
                      width: MediaQuery.of(context).size.width * 0.60,
                      height: MediaQuery.of(context).size.height * 0.40,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: RayyanColors.info,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: RayyanColors.info.withValues(
                                    alpha: 0.40,
                                  ),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 0,
                            top: -28,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: const BoxDecoration(
                                color: RayyanColors.info,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Plant ID: HC-042'.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Floating badges
                    Positioned(
                      top: 100,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: RayyanColors.nature.withValues(
                                alpha: 0.90,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const RayyanSymbol(
                                  'check_circle',
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status: Healthy'.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.60),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const RayyanSymbol(
                                  'analytics',
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Confidence: 98.4%'.toUpperCase(),
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // bottom sheet content
              Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? RayyanColors.cardDark
                      : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: const [
                        _InfoTile(
                          label: 'Health Index',
                          value: 'Excellent',
                          valueColor: RayyanColors.nature,
                        ),
                        _InfoTile(
                          label: 'Detection',
                          value: 'AI Active',
                          valueColor: RayyanColors.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
          // bottom nav dock
          RayyanBottomNav(current: current, onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });
  final String label;
  final String value;
  final Color valueColor;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = (MediaQuery.of(context).size.width - 24 * 2 - 16) / 2;
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? RayyanColors.surfaceDark
              : RayyanColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : RayyanColors.slate200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: RayyanColors.slate400,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
