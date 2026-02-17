import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../../../app/app_controller.dart';
import '../../../app/screens.dart';
import '../../../core/models/hydroponic/sensors_model.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/utils/vitality_utils.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';
import '../../insights/presentation/insights_state.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensors = ref.read(sensorsStreamProvider).valueOrNull;
      final settings = ref.read(settingsStreamProvider).valueOrNull;
      _checkAndFetchInsights(sensors, settings);
    });
  }

  void _checkAndFetchInsights(SensorsModel? sensors, SettingsModel? settings) {
    if (sensors == null || settings == null) return;

    final notifier = ref.read(insightsProvider.notifier);
    final appState = ref.read(appControllerProvider);

    if (notifier.shouldAutoRefresh(sensors, settings, appState.languageCode)) {
      notifier.fetchInsight(
        sensors: sensors,
        settings: settings,
        languageCode: appState.languageCode,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sensorsAsync = ref.watch(sensorsStreamProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final insightsState = ref.watch(insightsProvider);

    // Listen to sensors for auto-refresh logic
    ref.listen<AsyncValue<SensorsModel>>(sensorsStreamProvider, (prev, next) {
      next.whenData((sensors) {
        settingsAsync.whenData((settings) {
          _checkAndFetchInsights(sensors, settings);
        });
      });
    });

    // Also listen to settings to trigger initial fetch if sensors are already ready
    ref.listen<AsyncValue<SettingsModel>>(settingsStreamProvider, (prev, next) {
      next.whenData((settings) {
        sensorsAsync.whenData((sensors) {
          _checkAndFetchInsights(sensors, settings);
        });
      });
    });

    final sensors = sensorsAsync.valueOrNull;
    final settings = settingsAsync.valueOrNull;

    // Determine overall status
    SensorStatus overallStatus = SensorStatus.ok;
    IconData statusIcon = Icons.check_circle_rounded;

    if (sensors != null && settings != null) {
      final statuses = [
        VitalityUtils.getWaterLevelStatus(sensors.waterLevel),
        VitalityUtils.getTemperatureStatus(sensors.temperature, settings),
        VitalityUtils.getPhStatus(sensors.ph, settings),
        VitalityUtils.getEcStatus(sensors.ec, settings),
      ];

      if (statuses.contains(SensorStatus.critical)) {
        overallStatus = SensorStatus.critical;
      } else if (statuses.contains(SensorStatus.warning)) {
        overallStatus = SensorStatus.warning;
      }

      // Determine specific icon based on priority
      if (VitalityUtils.getWaterLevelStatus(sensors.waterLevel) ==
          SensorStatus.critical) {
        statusIcon = Icons.water_drop;
      } else if (VitalityUtils.getTemperatureStatus(
                sensors.temperature,
                settings,
              ) !=
              SensorStatus.ok &&
          VitalityUtils.getTemperatureStatus(sensors.temperature, settings) !=
              SensorStatus.unknown) {
        statusIcon = Icons.thermostat;
      } else if ((VitalityUtils.getPhStatus(sensors.ph, settings) !=
                  SensorStatus.ok &&
              VitalityUtils.getPhStatus(sensors.ph, settings) !=
                  SensorStatus.unknown) ||
          (VitalityUtils.getEcStatus(sensors.ec, settings) != SensorStatus.ok &&
              VitalityUtils.getEcStatus(sensors.ec, settings) !=
                  SensorStatus.unknown)) {
        statusIcon = Icons.science;
      } else if (overallStatus != SensorStatus.ok) {
        statusIcon = Icons.warning_rounded;
      }
    }

    final statusColor = VitalityUtils.getStatusColor(overallStatus);
    final systemStatusMessage = overallStatus == SensorStatus.critical
        ? AppLocalizations.of(context)!.systemCritical
        : overallStatus == SensorStatus.warning
        ? AppLocalizations.of(context)!.systemWarning
        : AppLocalizations.of(context)!.systemOptimal;

    final systemStatusDescription = overallStatus == SensorStatus.critical
        ? AppLocalizations.of(context)!.systemCriticalDescription
        : overallStatus == SensorStatus.warning
        ? AppLocalizations.of(context)!.systemWarningDescription
        : AppLocalizations.of(context)!.systemOptimalDescription;

    return AquaPageScaffold(
      includeBottomNav: false,
      currentScreen: widget.current,
      onNavigate: widget.onNavigate,
      child: Column(
        children: [
          AquaHeader(
            title: AppLocalizations.of(context)!.aiInsights,
            onBack: () => widget.onNavigate(AppScreen.more),
            rightAction: IconButton(
              icon: const AquaSymbol('sync', color: AquaColors.primary),
              onPressed: () {
                if (sensors != null && settings != null) {
                  ref
                      .read(insightsProvider.notifier)
                      .fetchInsight(
                        sensors: sensors,
                        settings: settings,
                        languageCode: appState.languageCode,
                      );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Status Hero Section
                _StatusHero(
                  status: overallStatus,
                  statusIcon: statusIcon,
                  title: systemStatusMessage,
                  description: systemStatusDescription,
                  color: statusColor,
                  isDark: isDark,
                ),
                const SizedBox(height: 32),

                // 2. Sensor Grid (2x2)
                if (sensors != null && settings != null)
                  _SensorGrid(
                    sensors: sensors,
                    settings: settings,
                    isDark: isDark,
                  ),
                const SizedBox(height: 32),

                // Error State
                if (insightsState.error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AquaColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AquaColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      insightsState.error!,
                      style: const TextStyle(color: AquaColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 3. Analysis Section
                _SectionHeader(
                  icon: 'analytics',
                  title: AppLocalizations.of(context)!.analysis,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _ContentCard(
                  content: insightsState.insight?.analysis,
                  isLoading: insightsState.isLoading,
                  isDark: isDark,
                ),
                const SizedBox(height: 32),

                // 4. Action Required Section
                _SectionHeader(
                  icon: 'error', // explicit error icon for Action Required
                  title: AppLocalizations.of(context)!.actionRequired,
                  color: AquaColors.critical,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _ContentCard(
                  content: insightsState.insight?.actionRequired,
                  isLoading: insightsState.isLoading,
                  isDark: isDark,
                  bulletPoints: true, // Use bullet point formatting
                ),
                const SizedBox(height: 32),

                // 5. Daily Tip Section
                _DailyTipCard(
                  content: insightsState.insight?.dailyTip,
                  isLoading: insightsState.isLoading,
                  isDark: isDark,
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

class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.status,
    required this.statusIcon,
    required this.title,
    required this.description,
    required this.color,
    required this.isDark,
  });

  final SensorStatus status;
  final IconData statusIcon;
  final String title;
  final String description;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Center(child: Icon(statusIcon, color: color, size: 40)),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 28, // Increased from 24
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            color: isDark ? AquaColors.slate400 : AquaColors.slate500,
            fontSize: 16, // Increased from 14
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SensorGrid extends StatelessWidget {
  const _SensorGrid({
    required this.sensors,
    required this.settings,
    required this.isDark,
  });

  final SensorsModel sensors;
  final SettingsModel settings;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SensorCard(
                label: AppLocalizations.of(context)!.phLevel,
                value: sensors.ph?.toStringAsFixed(1) ?? '--',
                unit: ' pH',
                status: VitalityUtils.getPhStatus(sensors.ph, settings),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SensorCard(
                label: AppLocalizations.of(context)!.ecLevel,
                value: sensors.ec?.toStringAsFixed(1) ?? '--',
                unit: ' µs',
                status: VitalityUtils.getEcStatus(sensors.ec, settings),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SensorCard(
                label: AppLocalizations.of(context)!.temperature,
                value: sensors.temperature?.toStringAsFixed(1) ?? '--',
                unit: '°C',
                status: VitalityUtils.getTemperatureStatus(
                  sensors.temperature,
                  settings,
                ),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SensorCard(
                label: AppLocalizations.of(context)!.waterLevel,
                value: '${sensors.waterLevel ?? '--'}',
                unit: '%',
                status: VitalityUtils.getWaterLevelStatus(sensors.waterLevel),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.label,
    required this.value,
    this.unit = '',
    required this.status,
    required this.isDark,
  });

  final String label;
  final String value;
  final String unit;
  final SensorStatus status;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = VitalityUtils.getStatusColor(status);
    final isCriticalOrWarning =
        status == SensorStatus.critical || status == SensorStatus.warning;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2C) : AquaColors.slate200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13, // Increased from 12
              fontWeight: FontWeight.w600,
              color: isDark ? AquaColors.slate400 : AquaColors.slate500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 28, // Increased from 24
                    fontWeight: FontWeight.bold,
                    color: isCriticalOrWarning
                        ? color
                        : (isDark ? Colors.white : AquaColors.slate900),
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontSize: 16, // Increased from 14
                    fontWeight: FontWeight.w500,
                    color: isDark ? AquaColors.slate500 : AquaColors.slate400,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.color,
    required this.isDark,
  });

  final String icon;
  final String title;
  final Color? color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // If it's a standard material icon name for now, but wrapper considers using AquaSymbol or Icon.
    // The design uses a small circle icon with text.
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (color ?? AquaColors.slate500).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon == 'analytics'
                ? Icons.analytics_outlined
                : icon == 'error'
                ? Icons.warning_amber_rounded
                : Icons.circle,
            size: 16,
            color: color ?? AquaColors.slate500,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14, // Increased from 12
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: isDark ? AquaColors.slate300 : AquaColors.slate600,
          ),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.content,
    required this.isLoading,
    required this.isDark,
    this.bulletPoints = false,
  });

  final String? content;
  final bool isLoading;
  final bool isDark;
  final bool bulletPoints;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _LoadingShimmer(isDark: isDark);
    }

    if (content == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AquaColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          AppLocalizations.of(context)!.waitingForInsights,
          style: TextStyle(
            color: isDark ? AquaColors.slate500 : AquaColors.slate400,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: bulletPoints
          ? _buildBulletPoints(content!)
          : Text(
              content!,
              style: TextStyle(
                fontSize: 16, // Increased from 15
                height: 1.6,
                color: isDark ? AquaColors.slate300 : AquaColors.slate700,
              ),
            ),
    );
  }

  Widget _buildBulletPoints(String text) {
    // Split by newlines and filter empty
    final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

    // Very basic heuristic to check if backend already sends bullets or not.
    // If not, we just treat each line as a bullet item.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final cleanLine = line.trim().replaceAll(RegExp(r'^[-*]\s*'), '');
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(Icons.circle, size: 6, color: AquaColors.critical),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cleanLine,
                  style: TextStyle(
                    fontSize: 16, // Increased from 15
                    height: 1.5,
                    color: isDark ? AquaColors.slate300 : AquaColors.slate700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({
    required this.content,
    required this.isLoading,
    required this.isDark,
  });

  final String? content;
  final bool isLoading;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F291E) // Darker green for dark mode
            : const Color(0xFFE8F5E9), // Light green for light mode
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AquaColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AquaColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'DAILY TIP',
                style: TextStyle(
                  fontSize: 14, // Increased from 12
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            _LoadingShimmer(isDark: isDark, baseColor: AquaColors.primary)
          else
            Text(
              content ?? 'Consistency is key to a healthy harvest.',
              style: TextStyle(
                fontSize: 16, // Increased from 15
                height: 1.6,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : AquaColors.slate900,
              ),
            ),
        ],
      ),
    );
  }
}

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer({required this.isDark, this.baseColor});
  final bool isDark;
  final Color? baseColor;

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line(width: double.infinity),
              const SizedBox(height: 8),
              _line(width: 200),
              const SizedBox(height: 8),
              _line(width: 150),
            ],
          ),
        );
      },
    );
  }

  Widget _line({required double width}) {
    final color =
        widget.baseColor ?? (widget.isDark ? Colors.white : Colors.black);
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
