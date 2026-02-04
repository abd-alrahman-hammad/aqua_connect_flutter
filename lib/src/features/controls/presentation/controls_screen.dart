import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/screens.dart';
import '../../../core/services/hydroponic_database_service.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/utils/value_formatter.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class ControlsScreen extends ConsumerStatefulWidget {
  const ControlsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  ConsumerState<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends ConsumerState<ControlsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controlsAsync = ref.watch(controlsStreamProvider);
    final dbService = ref.read(hydroponicDatabaseServiceProvider);

    final isLoading = controlsAsync.isLoading || controlsAsync.hasError;
    final autoMode = controlsAsync.valueOrNull?.autoMode ?? false;
    final ledLight = controlsAsync.valueOrNull?.ledLight ?? false;
    final isManualMode = !autoMode;

    return AquaPageScaffold(
      currentScreen: widget.current,
      onNavigate: widget.onNavigate,
      child: Column(
        children: [
          AquaHeader(
            title: 'Smart Controls',
            onBack: () => widget.onNavigate(AppScreen.dashboard),
            rightAction: InkWell(
              onTap: () => widget.onNavigate(AppScreen.wifi),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AquaColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: AquaSymbol('wifi', color: AquaColors.primary),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'System Operation Mode'.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? AquaColors.slate400 : AquaColors.slate500,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AquaColors.surfaceDark
                          : AquaColors.slate200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _ModeButton(
                          label: 'Smart Auto',
                          active: autoMode,
                          isLoading: isLoading,
                          onTap: () => dbService.toggleAutoMode(true),
                        ),
                        _ModeButton(
                          label: 'Manual Override',
                          active: isManualMode,
                          isLoading: isLoading,
                          onTap: () => dbService.toggleAutoMode(false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hardware Modules',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
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
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AquaColors.nature,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'System Healthy',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AquaColors.nature,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _ModuleCard(
                        title: 'Water Pump',
                        sub: '2.4L/m',
                        icon: 'water_drop',
                        active: controlsAsync.valueOrNull?.waterPump ?? false,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.toggleWaterPump(value),
                      ),
                      _ModuleCard(
                        title: 'Ventilation Fan',
                        icon: 'mode_fan',
                        active: controlsAsync.valueOrNull?.fan ?? false,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.toggleFan(value),
                      ),
                      _ModuleCard(
                        title: 'Raise EC',
                        sub: 'Nutrient Pump',
                        icon: 'science',
                        active: controlsAsync.valueOrNull?.pumpEcUp ?? false,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.togglePumpEcUp(value),
                      ),
                      _ModuleCard(
                        title: 'Lower EC',
                        sub: 'Dilution Valve',
                        icon: 'opacity',
                        active: controlsAsync.valueOrNull?.pumpEcDown ?? false,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.togglePumpEcDown(value),
                      ),
                      _ModuleCard(
                        title: 'Raise pH',
                        sub: 'Base Doser',
                        icon: 'keyboard_arrow_up',
                        active: controlsAsync.valueOrNull?.pumpPhUp ?? false,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.togglePumpPhUp(value),
                      ),
                      _ModuleCard(
                        title: 'Lower pH',
                        sub: 'Acid Doser',
                        icon: 'keyboard_arrow_down',
                        active: controlsAsync.valueOrNull?.pumpPhDown ?? false,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.togglePumpPhDown(value),
                      ),
                      _ModuleCard(
                        title: 'UV Purifier',
                        icon: 'flare',
                        // Maps to ledLight as requested (UV Board)
                        active: ledLight,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.toggleLedLight(value),
                      ),
                      _ModuleCard(
                        title: 'Heat Gen',
                        sub: '24.5°C',
                        icon: 'thermostat',
                        active: controlsAsync.valueOrNull?.heater ?? false,
                        isEnabled: isManualMode && !isLoading,
                        onToggle: (value) => dbService.toggleHeater(value),
                      ),
                      // LED Light card removed as it is now UV Purifier
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isManualMode)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AquaColors.warning.withValues(alpha: 0.10),
                        border: Border.all(
                          color: AquaColors.warning.withValues(alpha: 0.20),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AquaSymbol(
                            'warning',
                            color: AquaColors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Manual override is active. You control all modules at your own risk. Switch to Smart Auto for system-managed operation.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AquaColors.warning.withValues(
                                      alpha: 0.80,
                                    ),
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AquaColors.primary.withValues(alpha: 0.10),
                        border: Border.all(
                          color: AquaColors.primary.withValues(alpha: 0.20),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AquaSymbol('info', color: AquaColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Smart Auto mode: System controls all modules automatically. Switch to Manual Override to take control.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AquaColors.primary.withValues(
                                      alpha: 0.90,
                                    ),
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.active,
    required this.isLoading,
    required this.onTap,
  });
  final String label;
  final bool active;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? (isDark ? AquaColors.primary : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isLoading && active
                ? Text(
                    ValueFormatter.nullPlaceholder,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AquaColors.slate900,
                    ),
                  )
                : Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: active
                          ? (isDark ? Colors.white : AquaColors.slate900)
                          : AquaColors.slate500,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    this.sub,
    required this.icon,
    required this.active,
    required this.isEnabled,
    required this.onToggle,
  });

  final String title;
  final String? sub;
  final String icon;
  final bool active;
  final bool isEnabled;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = active
        ? (isDark ? AquaColors.surfaceDark : Colors.white)
        : (isDark ? AquaColors.cardDark : Colors.white);
    final borderColor = active
        ? AquaColors.primary
        : (isDark ? Colors.white.withValues(alpha: 0.05) : AquaColors.slate200);
    final status = active ? 'ACTIVE' : 'OFF';

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 16) / 2,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: InkWell(
          onTap: isEnabled ? () => onToggle(!active) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AquaColors.primary.withValues(alpha: 0.30),
                        blurRadius: 20,
                      ),
                    ]
                  : [
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
                        color: active
                            ? AquaColors.primary.withValues(alpha: 0.20)
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AquaColors.slate100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: AquaSymbol(
                          icon,
                          color: active
                              ? AquaColors.primary
                              : AquaColors.slate400,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: isEnabled ? () => onToggle(!active) : null,
                      child: Container(
                        width: 40,
                        height: 24,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: active
                              ? AquaColors.primary
                              : (isDark
                                    ? AquaColors.slate700
                                    : AquaColors.slate300),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Align(
                          alignment: active
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      status.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: active
                            ? AquaColors.primary
                            : AquaColors.slate400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (sub != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• $sub',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AquaColors.slate400,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
