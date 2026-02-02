import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AquaPageScaffold(
      currentScreen: current,
      onNavigate: onNavigate,
      child: Column(
        children: [
          const AquaHeader(title: 'Menu'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _MenuCard(
                      title: 'Analytics',
                      subtitle: 'History & Trends',
                      icon: 'monitoring',
                      color: AquaColors.info,
                      bg: AquaColors.info.withValues(alpha: 0.10),
                      onTap: () => onNavigate(AppScreen.analytics),
                    ),
                    _MenuCard(
                      title: 'AI Insights',
                      subtitle: 'Growth Predictions',
                      icon: 'psychology',
                      color: const Color(0xFF8B5CF6),
                      bg: const Color(0x1A8B5CF6),
                      onTap: () => onNavigate(AppScreen.insights),
                    ),
                    _MenuCard(
                      title: 'Monitoring',
                      subtitle: 'Real-time Sensors',
                      icon: 'speed',
                      color: AquaColors.warning,
                      bg: AquaColors.warning.withValues(alpha: 0.10),
                      onTap: () => onNavigate(AppScreen.monitoring),
                    ),
                    _MenuCard(
                      title: 'Support',
                      subtitle: 'Help & Guides',
                      icon: 'help',
                      color: AquaColors.nature,
                      bg: AquaColors.nature.withValues(alpha: 0.10),
                      onTap: () => onNavigate(AppScreen.support),
                    ),
                    _MenuCard(
                      title: 'Profile',
                      subtitle: 'User & Farm',
                      icon: 'person',
                      color: const Color(0xFFEC4899),
                      bg: const Color(0x1AEC4899),
                      onTap: () => onNavigate(AppScreen.profile),
                    ),
                  ],
                ),
                const SizedBox(height: 300),
                
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = (MediaQuery.of(context).size.width - 16 * 2 - 16) / 2;
    return SizedBox(
      width: width,
      height: 128,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AquaColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AquaColors.slate200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -24,
                right: -24,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: AquaSymbol(icon, color: color, size: 24),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AquaColors.slate400
                              : AquaColors.slate500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Positioned(
                bottom: 8,
                right: 8,
                child: AquaSymbol('arrow_forward', color: AquaColors.slate300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
