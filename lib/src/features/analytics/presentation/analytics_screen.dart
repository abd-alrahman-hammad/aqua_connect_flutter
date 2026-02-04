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

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String tab = 'Water';
  int activeBar = 5;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sensorsAsync = ref.watch(sensorsStreamProvider);
    final waterLevel = sensorsAsync.valueOrNull?.waterLevel;
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
                children: ['Water level', 'EC Level', 'pH Level', 'Temperature']
                    .map((t) {
                      final active = tab == t;
                      return InkWell(
                        onTap: () => setState(() => tab = t),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 16, 24, 12),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: active
                                    ? AquaColors.primary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Text(
                            t,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: active
                                      ? AquaColors.primary
                                      : (isDark
                                            ? AquaColors.slate400
                                            : AquaColors.slate500),
                                ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              children: [
                // Toggle row (static like web; second selected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AquaColors.surfaceDark
                        : AquaColors.slate200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['24H', '7D', '30D', 'ALL'].asMap().entries.map((
                      e,
                    ) {
                      final selected = e.key == 1;
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
                                'Water Level (Live)',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AquaColors.slate400
                                          : AquaColors.slate500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ValueFormatter.formatPercent(waterLevel),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AquaColors.critical.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const AquaSymbol(
                                  'trending_down',
                                  size: 16,
                                  color: AquaColors.critical,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '-5.2%',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: AquaColors.critical,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(show: false),
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
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
                                  FlSpot(0, 40),
                                  FlSpot(1, 70),
                                  FlSpot(2, 50),
                                  FlSpot(3, 90),
                                  FlSpot(4, 60),
                                  FlSpot(5, 30),
                                  FlSpot(6, 80),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                                'Growth Efficiency',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: isDark
                                          ? AquaColors.slate400
                                          : AquaColors.slate500,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ValueFormatter.formatPercent(waterLevel),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
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
                                  '+12%',
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
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(7, (i) {
                              final v = [
                                45,
                                60,
                                35,
                                70,
                                50,
                                85,
                                65,
                              ][i].toDouble();
                              final isActive = i == activeBar;
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: v,
                                    width: 14,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                    color: isActive
                                        ? const Color(0xFF4E9B1A)
                                        : const Color(0x334E9B1A),
                                  ),
                                ],
                              );
                            }),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchCallback: (event, resp) {
                                if (event.isInterestedForInteractions &&
                                    resp?.spot != null) {
                                  setState(
                                    () => activeBar =
                                        resp!.spot!.touchedBarGroupIndex,
                                  );
                                }
                              },
                            ),
                          ),
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
                  title: 'Optimize Nutrient Mix',
                  subtitle: 'Watering at 6 AM saved 15% resources this week.',
                ),
                const SizedBox(height: 12),
                _InsightRow(
                  bg: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AquaColors.slate100,
                  border: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : AquaColors.slate200,
                  iconBg: AquaColors.warning,
                  icon: 'warning',
                  title: 'pH Variance Detected',
                  subtitle: 'Slight spike on Wednesday due to heatwave.',
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
