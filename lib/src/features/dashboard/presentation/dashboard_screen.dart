import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../../../app/screens.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/user_database_service.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/utils/value_formatter.dart';
import '../../../core/utils/vitality_utils.dart'; // [NEW]
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_sensor_card.dart';
import '../../../core/widgets/aqua_symbol.dart';
import '../../../core/models/hydroponic/sensors_model.dart'; // [NEW] - for type safety in builder
import '../../../core/models/hydroponic/settings_model.dart'; // [NEW]

import '../../alerts/application/sensor_monitor_service.dart'; // [NEW]
import '../../analytics/presentation/analytics_state.dart'; // [NEW]

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize sensor monitor service to ensure alerts are generated
    ref.watch(sensorMonitorServiceProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sensorsAsync = ref.watch(sensorsStreamProvider);
    final settingsAsync = ref.watch(settingsStreamProvider);
    final userAsync = ref.watch(realtimeUserProfileStreamProvider);
    final isConnected = ref.watch(systemStatusProvider);

    return AquaPageScaffold(
      currentScreen: current,
      onNavigate: onNavigate,
      child: Column(
        children: [
          _TopNav(
            onAlerts: () => onNavigate(AppScreen.alerts),
            user: userAsync.valueOrNull,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                _VitalityRing(
                  isDark: isDark,
                  sensors: sensorsAsync.valueOrNull,
                  settings: settingsAsync.valueOrNull,
                ),
                const SizedBox(height: 24),
                Text(
                  VitalityUtils.getVitalityMessage(
                    sensorsAsync.valueOrNull,
                    settingsAsync.valueOrNull,
                    AppLocalizations.of(context)!,
                    isSystemOnline: isConnected,
                  ),
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
                      AppLocalizations.of(context)!.realTimeSensors,
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
                        color: isConnected
                            ? AquaColors.success.withValues(alpha: 0.10)
                            : AquaColors.slate400.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected
                                  ? AquaColors.success
                                  : AquaColors.error,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected
                                ? AppLocalizations.of(context)!.online
                                : AppLocalizations.of(context)!.offline,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isConnected
                                      ? AquaColors.success
                                      : AquaColors.error,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 16) / 2;
                    final sensors = sensorsAsync.valueOrNull;
                    final settings = settingsAsync.valueOrNull;

                    // Calculate statuses
                    // Default to unknown if data is missing
                    final phStatus = settings != null
                        ? VitalityUtils.getPhStatus(sensors?.ph, settings)
                        : SensorStatus.unknown;
                    final ecStatus = settings != null
                        ? VitalityUtils.getEcStatus(sensors?.ec, settings)
                        : SensorStatus.unknown;
                    final tempStatus = settings != null
                        ? VitalityUtils.getTemperatureStatus(
                            sensors?.temperature,
                            settings,
                          )
                        : SensorStatus.unknown;
                    final waterStatus = VitalityUtils.getWaterLevelStatus(
                      sensors?.waterLevel,
                    );

                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        AquaSensorCard(
                          width: cardWidth,
                          icon: 'water_ph',
                          value: ValueFormatter.formatDouble(sensors?.ph),
                          label: AppLocalizations.of(context)!.phLevel,
                          badgeText: VitalityUtils.getStatusLabel(
                            phStatus,
                            AppLocalizations.of(context)!,
                          ),
                          statusColor: VitalityUtils.getStatusColor(phStatus),
                          iconColor: AquaColors.primary,
                          iconBg: AquaColors.primary.withValues(alpha: 0.10),
                          onTap: () {
                            ref.read(analyticsTabProvider.notifier).state =
                                'pH Level';
                            onNavigate(AppScreen.analytics);
                          },
                          labelUppercase: true,
                        ),
                        AquaSensorCard(
                          width: cardWidth,
                          icon: 'bolt',
                          value: ValueFormatter.formatDouble(sensors?.ec),
                          label: AppLocalizations.of(context)!.ecLevel,
                          badgeText: VitalityUtils.getStatusLabel(
                            ecStatus,
                            AppLocalizations.of(context)!,
                          ),
                          statusColor: VitalityUtils.getStatusColor(ecStatus),
                          iconColor: AquaColors.warning,
                          iconBg: AquaColors.warning.withValues(alpha: 0.10),
                          onTap: () {
                            ref.read(analyticsTabProvider.notifier).state =
                                'EC Level';
                            onNavigate(AppScreen.analytics);
                          },
                          labelUppercase: true,
                        ),
                        AquaSensorCard(
                          width: cardWidth,
                          icon: 'device_thermostat',
                          value: ValueFormatter.formatWithSuffix(
                            sensors?.temperature,
                            AppLocalizations.of(context)!.celsiusUnit,
                          ),
                          label: AppLocalizations.of(context)!.temperature,
                          badgeText: VitalityUtils.getStatusLabel(
                            tempStatus,
                            AppLocalizations.of(context)!,
                          ),
                          statusColor: VitalityUtils.getStatusColor(tempStatus),
                          iconColor: AquaColors.info,
                          iconBg: AquaColors.info.withValues(alpha: 0.10),
                          onTap: () {
                            ref.read(analyticsTabProvider.notifier).state =
                                'Temperature';
                            onNavigate(AppScreen.analytics);
                          },
                          labelUppercase: true,
                        ),
                        AquaSensorCard(
                          width: cardWidth,
                          icon: 'waves',
                          value: ValueFormatter.formatPercent(
                            sensors?.waterLevel,
                          ),
                          label: AppLocalizations.of(context)!.waterLevel,
                          badgeText: VitalityUtils.getStatusLabel(
                            waterStatus,
                            AppLocalizations.of(context)!,
                          ),
                          statusColor: VitalityUtils.getStatusColor(
                            waterStatus,
                          ),
                          iconColor: const Color(0xFF3B82F6),
                          iconBg: const Color(0x1A3B82F6),
                          onTap:
                              () {}, // Navigation removed as Monitoring screen is deleted
                          labelUppercase: true,
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
  const _TopNav({required this.onAlerts, this.user});

  final VoidCallback onAlerts;
  final UserModel? user;

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
                          imageUrl:
                              user?.photoUrl ??
                              'https://picsum.photos/100', // Fallback to placeholder
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.welcomeBack,
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
                            user?.displayName ?? 'User',
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
  const _VitalityRing({
    required this.isDark,
    required this.sensors,
    required this.settings,
  });

  final bool isDark;
  final SensorsModel? sensors;
  final SettingsModel? settings;

  @override
  Widget build(BuildContext context) {
    final borderBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : AquaColors.slate200.withValues(alpha: 0.4);

    // Calculate vitality score
    double progressValue = 0.0;
    if (sensors != null && settings != null) {
      progressValue = VitalityUtils.calculateVitality(sensors!, settings!);
    }

    final displayValue = '${(progressValue * 100).toInt()}%';

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
            angle: 0.15, // -90 degrees (start from top)
            child: SizedBox(
              width: 229,
              height: 229,
              child: CircularProgressIndicator(
                value: progressValue > 0 ? progressValue : null,
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
            ),
          ),
          // Center label
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayValue,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context)!.vitality,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AquaColors.nature,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.2,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
