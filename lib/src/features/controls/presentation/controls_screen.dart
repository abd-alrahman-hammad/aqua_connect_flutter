import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class ControlsScreen extends StatefulWidget {
  const ControlsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  State<ControlsScreen> createState() => _ControlsScreenState();
}

class _ControlsScreenState extends State<ControlsScreen> {
  String mode = 'manual';
  final Map<String, bool> moduleStates = {
    'Irrigation Pump': true,
    'Ventilation Fan': false,
    'Raise EC': true,
    'Lower EC': false,
    'Raise pH': false,
    'Lower pH': true,
    'UV Purifier': false,
    'Heat Gen': true,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        active: mode == 'auto',
                        onTap: () => setState(() => mode = 'auto'),
                      ),
                      _ModeButton(
                        label: 'Manual Override',
                        active: mode == 'manual',
                        onTap: () => setState(() => mode = 'manual'),
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
                      title: 'Irrigation Pump',
                      sub: '2.4L/m',
                      icon: 'water_drop',
                      active: moduleStates['Irrigation Pump']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) => setState(
                        () => moduleStates['Irrigation Pump'] = value,
                      ),
                    ),
                    _ModuleCard(
                      title: 'Ventilation Fan',
                      icon: 'mode_fan',
                      active: moduleStates['Ventilation Fan']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) => setState(
                        () => moduleStates['Ventilation Fan'] = value,
                      ),
                    ),
                    _ModuleCard(
                      title: 'Raise EC',
                      sub: 'Nutrient Pump',
                      icon: 'science',
                      active: moduleStates['Raise EC']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) =>
                          setState(() => moduleStates['Raise EC'] = value),
                    ),
                    _ModuleCard(
                      title: 'Lower EC',
                      sub: 'Dilution Valve',
                      icon: 'opacity',
                      active: moduleStates['Lower EC']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) =>
                          setState(() => moduleStates['Lower EC'] = value),
                    ),
                    _ModuleCard(
                      title: 'Raise pH',
                      sub: 'Base Doser',
                      icon: 'keyboard_arrow_up',
                      active: moduleStates['Raise pH']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) =>
                          setState(() => moduleStates['Raise pH'] = value),
                    ),
                    _ModuleCard(
                      title: 'Lower pH',
                      sub: 'Acid Doser',
                      icon: 'keyboard_arrow_down',
                      active: moduleStates['Lower pH']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) =>
                          setState(() => moduleStates['Lower pH'] = value),
                    ),
                    _ModuleCard(
                      title: 'UV Purifier',
                      icon: 'flare',
                      active: moduleStates['UV Purifier']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) =>
                          setState(() => moduleStates['UV Purifier'] = value),
                    ),
                    _ModuleCard(
                      title: 'Heat Gen',
                      sub: '24.5°C',
                      icon: 'thermostat',
                      active: moduleStates['Heat Gen']!,
                      isEnabled: mode == 'manual',
                      onToggle: (value) =>
                          setState(() => moduleStates['Heat Gen'] = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (mode == 'manual')
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
                        const AquaSymbol('warning', color: AquaColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Manual override is active. Smart nutrient balancing is paused to allow for user adjustment.',
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
                  ),
              ],
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
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: InkWell(
        onTap: onTap,
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
            child: Text(
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
  final Function(bool) onToggle;

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
                      color: active ? AquaColors.primary : AquaColors.slate400,
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
