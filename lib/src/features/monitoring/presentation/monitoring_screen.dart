import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  String range = '24h';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AquaPageScaffold(
      currentScreen: widget.current,
      onNavigate: widget.onNavigate,
      child: Column(
        children: [
          AquaHeader(
            title: 'Real-time Monitoring',
            onBack: () => widget.onNavigate(AppScreen.dashboard),
            rightAction: const AquaSymbol('sync', color: AquaColors.primary),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AquaColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                  child: Row(
                    children: ['24h', '7d', '30d'].map((r) {
                      final active = range == r;
                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => range = r),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: active
                                  ? AquaColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                r.toUpperCase(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: active
                                          ? Colors.white
                                          : (isDark
                                                ? AquaColors.slate400
                                                : AquaColors.slate500),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AquaColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AquaColors.slate200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Current pH & EC',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? AquaColors.slate400
                                            : AquaColors.slate500,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AquaColors.primary,
                                        ),
                                    children: [
                                      const TextSpan(text: '6.2'),
                                      TextSpan(
                                        text: '  Stable',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AquaColors.nature,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '● pH Level',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AquaColors.info,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '● EC Level',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AquaColors.nature,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 256,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: 6,
                              minY: 1.0,
                              maxY: 7.0,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1.0,
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      const labels = [
                                        '08:00',
                                        '10:00',
                                        '12:00',
                                        '14:00',
                                        '16:00',
                                        '18:00',
                                        '20:00',
                                      ];
                                      final idx = value.round();
                                      if (idx < 0 || idx >= labels.length)
                                        return const SizedBox.shrink();
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          labels[idx],
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: AquaColors.slate400,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  color: const Color(0xFF00B0F0),
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(
                                          0xFF00B0F0,
                                        ).withValues(alpha: 0.30),
                                        const Color(
                                          0xFF00B0F0,
                                        ).withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                  spots: const [
                                    FlSpot(0, 5.8),
                                    FlSpot(1, 6.0),
                                    FlSpot(2, 6.2),
                                    FlSpot(3, 6.1),
                                    FlSpot(4, 6.3),
                                    FlSpot(5, 6.4),
                                    FlSpot(6, 6.2),
                                  ],
                                ),
                                LineChartBarData(
                                  isCurved: true,
                                  color: const Color(0xFF0BDA57),
                                  barWidth: 3,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(
                                          0xFF0BDA57,
                                        ).withValues(alpha: 0.30),
                                        const Color(
                                          0xFF0BDA57,
                                        ).withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                  spots: const [
                                    FlSpot(0, 1.2),
                                    FlSpot(1, 1.4),
                                    FlSpot(2, 1.8),
                                    FlSpot(3, 1.6),
                                    FlSpot(4, 1.5),
                                    FlSpot(5, 1.7),
                                    FlSpot(6, 1.8),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Readings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigate(AppScreen.analytics),
                      style: TextButton.styleFrom(
                        foregroundColor: AquaColors.primary,
                      ),
                      child: const Text('View History'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _ReadingCard(
                      icon: 'water_ph',
                      iconBg: Color(0x1A7AC043),
                      iconColor: AquaColors.primary,
                      badgeText: 'OPTIMAL',
                      badgeBg: Color(0x1A7AC043),
                      badgeColor: AquaColors.nature,
                      value: '6.2 pH',
                      label: 'Acidity Level',
                    ),
                    _ReadingCard(
                      icon: 'bolt',
                      iconBg: Color(0x1AFFA500),
                      iconColor: AquaColors.warning,
                      badgeText: 'CAUTION',
                      badgeBg: Color(0x1AFFA500),
                      badgeColor: AquaColors.warning,
                      value: '1.8 EC',
                      label: 'Conductivity',
                    ),
                    _ReadingCard(
                      icon: 'device_thermostat',
                      iconBg: Color(0x1AF97316),
                      iconColor: Color(0xFFF97316),
                      badgeText: 'OPTIMAL',
                      badgeBg: Color(0x1A7AC043),
                      badgeColor: AquaColors.nature,
                      value: '24.5°C',
                      label: 'Water Temp',
                    ),
                    _ReadingCard(
                      icon: 'humidity_percentage',
                      iconBg: Color(0x1A3B82F6),
                      iconColor: Color(0xFF3B82F6),
                      badgeText: 'OPTIMAL',
                      badgeBg: Color(0x1A7AC043),
                      badgeColor: AquaColors.nature,
                      value: '72%',
                      label: 'Air Humidity',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AquaColors.primary.withValues(alpha: 0.20),
                        Colors.transparent,
                      ],
                    ),
                    border: Border(
                      left: BorderSide(color: AquaColors.primary, width: 4),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AquaColors.primary.withValues(alpha: 0.20),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: AquaSymbol('info', color: AquaColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nutrient Check Recommended',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'EC level is slightly rising above target. Check reservoir dilution.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AquaColors.slate300
                                        : AquaColors.slate600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const AquaSymbol(
                        'chevron_right',
                        color: AquaColors.slate400,
                      ),
                    ],
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

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeColor,
    required this.value,
    required this.label,
  });

  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String badgeText;
  final Color badgeBg;
  final Color badgeColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;
    return SizedBox(
      width: width,
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: AquaSymbol(icon, size: 18, color: iconColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? AquaColors.slate400 : AquaColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
