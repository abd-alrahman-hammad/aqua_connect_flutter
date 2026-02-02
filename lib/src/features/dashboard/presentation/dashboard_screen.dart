import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AquaPageScaffold(
      currentScreen: current,
      onNavigate: onNavigate,
      child: Column(
        children: [
          _TopNav(onAlerts: () => onNavigate(AppScreen.alerts)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                _VitalityRing(isDark: isDark),
                const SizedBox(height: 24),
                Text(
                  'Your hydroponic system is performing optimally. All parameters within range.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AquaColors.slate400 : AquaColors.slate500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Real-time Sensors',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AquaColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LIVE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AquaColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _SensorCard(
                          width: cardWidth,
                          icon: 'water_ph',
                          value: '6.2',
                          label: 'pH Level',
                          status: 'OK',
                          color: AquaColors.primary,
                          bg: AquaColors.primary.withValues(alpha: 0.10),
                          onTap: () => onNavigate(AppScreen.monitoring),
                        ),
                        _SensorCard(
                          width: cardWidth,
                          icon: 'bolt',
                          value: '1.8',
                          label: 'EC (mS/cm)',
                          status: 'OK',
                          color: AquaColors.warning,
                          bg: AquaColors.warning.withValues(alpha: 0.10),
                          onTap: () => onNavigate(AppScreen.monitoring),
                        ),
                        _SensorCard(
                          width: cardWidth,
                          icon: 'device_thermostat',
                          value: '24°C',
                          label: 'Water Temp',
                          status: 'OK',
                          color: AquaColors.info,
                          bg: AquaColors.info.withValues(alpha: 0.10),
                          onTap: () => onNavigate(AppScreen.monitoring),
                        ),
                        _SensorCard(
                          width: cardWidth,
                          icon: 'waves',
                          value: '85%',
                          label: 'Reservoir',
                          status: 'OK',
                          color: const Color(0xFF3B82F6),
                          bg: const Color(0x1A3B82F6),
                          onTap: () => onNavigate(AppScreen.monitoring),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.onAlerts});
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? AquaColors.backgroundDark.withValues(alpha: 0.90)
        : AquaColors.backgroundLight.withValues(alpha: 0.90);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          decoration: BoxDecoration(
            color: bg,
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AquaColors.slate200,
              ),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AquaColors.primary,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: CachedNetworkImage(
                          imageUrl: 'https://picsum.photos/100',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WELCOME BACK,',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.3,
                                  color: isDark
                                      ? AquaColors.slate400
                                      : AquaColors.slate500,
                                ),
                          ),
                          Text(
                            'Grower Master',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: onAlerts,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AquaColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.10)
                              : AquaColors.slate200,
                        ),
                      ),
                      child: const Center(child: AquaSymbol('notifications')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VitalityRing extends StatelessWidget {
  const _VitalityRing({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final borderBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AquaColors.slate200.withValues(alpha: 0.4);

    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle outer ring
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 10, color: borderBg),
            ),
          ),
          // Progress arc with rounded cap, rotated so it starts at top
          Transform.rotate(
            angle: -0.75, // ~ -43°
            child: SizedBox(
              width: 240,
              height: 230,
              child: CircularProgressIndicator(
                value: 0.94,
                strokeWidth: 10,
                backgroundColor: Colors.transparent,
                color: AquaColors.nature,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          // Inner filled circle behind text
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? AquaColors.backgroundDark
                  : AquaColors.backgroundLight,
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withValues(alpha: 0.35),
              //     blurRadius: 24,
              //     offset: const Offset(0, 12),
              //   ),
              // ],
            ),
          ),
          // Center label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '94%',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'VITALITY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AquaColors.nature,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.2,
                  fontSize: 10,
                ),
              ),
            ],
          ),

          // Glowing progress dot sitting on the ring
        ],
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    required this.status,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  final double width;
  final String icon;
  final String value;
  final String label;
  final String status;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
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
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: AquaSymbol(icon, color: color)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AquaColors.nature.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AquaColors.nature,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AquaColors.slate400 : AquaColors.slate500,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
