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

  @override
  void initState() {
    super.initState();
    final requestedTab = ref.read(analyticsTabProvider);
    tab = requestedTab ?? widget.initialTab ?? 'pH Level';
    if (tab == 'Water Level') tab = 'pH Level';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsTabProvider.notifier).state = null;
    });
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

  // Generate spots from history map
  List<FlSpot> _getSpotsFromHistory(Map<int, double> history) {
    if (history.isEmpty) return [];

    final sortedKeys = history.keys.toList()..sort();
    return sortedKeys.map((timestamp) {
      return FlSpot(timestamp.toDouble(), history[timestamp]!);
    }).toList();
  }

  // Get X-Axis title based on timestamp and range
  String _getXAxisTitle(double value, AnalyticsTimeRange range) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    if (range == AnalyticsTimeRange.h24) {
      // Show time (HH:mm)
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      // Show date (MM/dd)
      return '${date.month}/${date.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sensorsAsync = ref.watch(sensorsStreamProvider);
    final sensors = sensorsAsync.valueOrNull;

    // Watch time range and history
    final timeRange = ref.watch(analyticsTimeRangeProvider);
    final historyAsync = ref.watch(analyticsHistoryProvider(tab));

    // Determine current value configuration
    double currentValue = 0.0;
    String unit = '';

    if (tab == 'pH Level') {
      currentValue = sensors?.ph ?? 7.0;
      unit = 'pH';
    } else if (tab == 'EC Level') {
      currentValue = sensors?.ec ?? 1.5;
      unit = 'mS/cm';
    } else if (tab == 'Temperature') {
      currentValue = sensors?.temperature ?? 24.0;
      unit = '°C';
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
                // Time Range Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AquaColors.surfaceDark
                        : AquaColors.slate200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: AnalyticsTimeRange.values.map((range) {
                      final selected = timeRange == range;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ref
                                    .read(analyticsTimeRangeProvider.notifier)
                                    .state =
                                range;
                          },
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
                                range.label,
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
                          // Trend Indicator (Static for now, could be calculated)
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
                                  'Stable',
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
                        child: historyAsync.when(
                          data: (history) {
                            if (history.isEmpty) {
                              return Center(
                                child: Text(
                                  'No data available for this period',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            }

                            final spots = _getSpotsFromHistory(history);
                            final minY = spots.map((e) => e.y).reduce(min);
                            final maxY = spots.map((e) => e.y).reduce(max);
                            // Add some padding
                            final rangeY = maxY - minY;
                            final padding = rangeY == 0 ? 1.0 : rangeY * 0.2;

                            return LineChart(
                              LineChartData(
                                minY: (minY - padding) < 0
                                    ? 0
                                    : (minY - padding),
                                maxY: maxY + padding,
                                borderData: FlBorderData(show: false),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: rangeY == 0
                                      ? 1
                                      : rangeY / 5,
                                  getDrawingHorizontalLine: (value) => FlLine(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.black12,
                                    strokeWidth: 1,
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        // Simple decimation to avoid overlapping
                                        // This basic logic displays a few labels based on index/interval
                                        // Since X is timestamp, we need to be careful.

                                        // TODO: Improve label distribution
                                        // For now, only show start, middle, end
                                        if (value == spots.first.x ||
                                            value == spots.last.x ||
                                            value ==
                                                spots[spots.length ~/ 2].x) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text(
                                              _getXAxisTitle(value, timeRange),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                ),
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
                                    spots: spots,
                                  ),
                                ],
                                lineTouchData: LineTouchData(
                                  touchTooltipData: LineTouchTooltipData(
                                    getTooltipColor: (touchedSpot) => isDark
                                        ? AquaColors.surfaceDark
                                        : Colors.white,
                                    tooltipBorderRadius: BorderRadius.circular(
                                      8,
                                    ),
                                    fitInsideHorizontally: true,
                                    fitInsideVertically: true,
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('Error loading chart')),
                        ),
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
