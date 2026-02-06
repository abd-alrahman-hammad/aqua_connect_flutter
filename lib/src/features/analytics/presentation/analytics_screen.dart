import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/screens.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/utils/value_formatter.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

import 'analytics_state.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
    this.initialTab,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;
  final String? initialTab;

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late String tab;
  int activeBar = 3; // Default to a middle bar

  @override
  void initState() {
    super.initState();
    // Check provider for requested tab, otherwise use initialTab or default
    final requestedTab = ref.read(analyticsTabProvider);

    // Default to 'pH Level' if no initial tab or if it was 'Water Level' (which is removed)
    tab = requestedTab ?? widget.initialTab ?? 'pH Level';
    if (tab == 'Water Level') tab = 'pH Level';

    // Clear the provider after reading it so subsequent navigations (e.g. from menu) don't get stuck
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsTabProvider.notifier).state = null;
    });
  }

  // Helper to generate simulated history data based on current value
  // logic: create a curve that ends at the current value
  List<FlSpot> _generateSpots(double currentValue, double variance) {
    final random = Random(42); // Fixed seed for consistent "history"
    final spots = <FlSpot>[];
    for (int i = 0; i <= 6; i++) {
      // Generate a value that is within +/- variance of the current value
      // The last point (i=6) should be exactly the current value
      double value;
      if (i == 6) {
        value = currentValue;
      } else {
        final noise = (random.nextDouble() - 0.5) * 2 * variance;
        value = currentValue + noise;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  Color _getTabColor(String tab) {
    switch (tab) {
      case 'pH Level':
        return AquaColors.primary;
      case 'EC Level':
        return AquaColors.warning;
      case 'Temperature':
        return AquaColors.info;
      default:
        return AquaColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sensorsAsync = ref.watch(sensorsStreamProvider);
    final sensors = sensorsAsync.valueOrNull;

    // Determine current value and configuration based on selected tab
    double currentValue = 0.0;
    String unit = '';
    double variance = 1.0;

    // Only 'EC Level', 'pH Level', 'Temperature' are allowed
    if (tab == 'pH Level') {
      currentValue = sensors?.ph ?? 7.0;
      unit = 'pH';
      variance = 0.5;
    } else if (tab == 'EC Level') {
      currentValue = sensors?.ec ?? 1.5;
      unit = 'mS/cm';
      variance = 0.3;
    } else if (tab == 'Temperature') {
      currentValue = sensors?.temperature ?? 24.0;
      unit = '°C';
      variance = 2.0;
    }

    final chartColor = _getTabColor(tab);

    return AquaPageScaffold(
      currentScreen: widget.current,
      onNavigate: widget.onNavigate,
      child: Column(
        children: [
          AquaHeader(
            title: 'Historical Analytics',
            onBack: () => widget.onNavigate(AppScreen.dashboard),
          ),
          // Tabs
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AquaColors.slate200,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                // Removed 'Water Level' as requested
                children: ['pH Level', 'EC Level', 'Temperature'].map((t) {
                  final active = tab == t;
                  return InkWell(
                    onTap: () => setState(() => tab = t),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 16, 24, 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: active ? chartColor : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        t,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: active
                              ? chartColor
                              : (isDark
                                    ? AquaColors.slate400
                                    : AquaColors.slate500),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              children: [
                // Time Range Toggle - Removed 'ALL'
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AquaColors.surfaceDark
                        : AquaColors.slate200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['24H', '7D', '30D'].asMap().entries.map((e) {
                      final selected = e.key == 0; // Default to 24H
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                ? (isDark
                                      ? AquaColors.backgroundDark
                                      : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.10,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              e.value,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? AquaColors.primary
                                        : AquaColors.slate500,
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Chart Card
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$tab (Live)',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AquaColors.slate400
                                          : AquaColors.slate500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ValueFormatter.formatDouble(currentValue)} $unit',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: chartColor,
                                    ),
                              ),
                            ],
                          ),
                          // Simulated trend indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AquaColors.nature.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AquaSymbol(
                                  'trending_up',
                                  size: 16,
                                  color: AquaColors.nature,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Stable', // Simplified for now
                                  style: Theme.of(context).textTheme.labelMedium
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
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            minY: (currentValue - variance * 2) < 0
                                ? 0
                                : (currentValue - variance * 2),
                            maxY: currentValue + variance * 2,
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: variance,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: isDark ? Colors.white10 : Colors.black12,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: const FlTitlesData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                color: chartColor,
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      chartColor.withValues(alpha: 0.30),
                                      chartColor.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                                spots: _generateSpots(currentValue, variance),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpot) => isDark
                                    ? AquaColors.surfaceDark
                                    : Colors.white,
                                tooltipBorderRadius: BorderRadius.circular(8),
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // X-Axis Labels (Simulated 24H)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            '00:00',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            '04:00',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            '08:00',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            '12:00',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            '16:00',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            '20:00',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            'Now',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Key Insights',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _InsightRow(
                  bg: AquaColors.primary.withValues(alpha: 0.05),
                  border: AquaColors.primary.withValues(alpha: 0.10),
                  iconBg: AquaColors.primary,
                  icon: 'lightbulb',
                  title: 'System Optimal',
                  subtitle:
                      '$tab is within the healthy range for this growth stage.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: child,
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color bg;
  final Color border;
  final Color iconBg;
  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Center(child: AquaSymbol(icon, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AquaColors.slate400 : AquaColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          const AquaSymbol('chevron_right', color: AquaColors.slate400),
        ],
      ),
    );
  }
}
