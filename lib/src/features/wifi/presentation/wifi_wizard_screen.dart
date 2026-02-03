import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_symbol.dart';

class WiFiWizardScreen extends StatelessWidget {
  const WiFiWizardScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AquaColors.backgroundDark
          : AquaColors.backgroundLight,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AquaColors.backgroundDark : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AquaColors.slate200,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => onNavigate(AppScreen.controls),
                    icon: const AquaSymbol(
                      'close',
                      color: AquaColors.primary,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'WiFi Setup',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Help',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AquaColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: isDark ? AquaColors.backgroundDark : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _StepPill(active: true, label: 'Discover'),
                SizedBox(width: 12),
                _StepPill(active: true, label: 'Network'),
                SizedBox(width: 12),
                _StepPill(active: false, label: 'Finish'),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Network',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scanning for nearby networks. Select your 2.4GHz home network.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AquaColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AquaColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AquaColors.primary.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AquaColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Scanning for ESP32 module...',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AquaColors.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              '75%',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AquaColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 6,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : AquaColors.slate200,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: 0.75,
                                child: Container(color: AquaColors.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Available Networks'.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AquaColors.slate400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _NetworkTile(
                    name: 'FarmHouse_Main_2G',
                    type: 'WPA2 Protected',
                    locked: true,
                    active: true,
                  ),
                  const SizedBox(height: 12),
                  const _NetworkTile(
                    name: 'Guest_Network',
                    type: 'Open Network',
                    locked: false,
                  ),
                  const SizedBox(height: 12),
                  const _NetworkTile(
                    name: 'Aqua_Lab_Extender',
                    type: 'WPA3 Protected',
                    locked: true,
                  ),
                  const SizedBox(height: 12),
                  const _NetworkTile(
                    name: 'Neighbor_Hub',
                    type: 'Secured',
                    locked: true,
                    dim: true,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const AquaSymbol(
                      'refresh',
                      color: AquaColors.primary,
                    ),
                    label: Text(
                      'Rescan for Networks',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AquaColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              color: isDark ? AquaColors.cardDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AquaColors.slate200,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onNavigate(AppScreen.controls),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AquaColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Connect to FarmHouse_Main_2G'),
                          SizedBox(width: 8),
                          AquaSymbol('arrow_forward', color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rayyan IoT v2.4.0'.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AquaColors.slate400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({required this.active, required this.label});
  final bool active;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AquaColors.primary : AquaColors.slate200,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: active ? AquaColors.primary : AquaColors.slate400,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _NetworkTile extends StatelessWidget {
  const _NetworkTile({
    required this.name,
    required this.type,
    required this.locked,
    this.active = false,
    this.dim = false,
  });
  final String name;
  final String type;
  final bool locked;
  final bool active;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = active
        ? (isDark ? AquaColors.surfaceDark : Colors.white)
        : (isDark ? AquaColors.cardDark : Colors.white);
    final border = active
        ? AquaColors.primary
        : (isDark ? Colors.white.withValues(alpha: 0.05) : AquaColors.slate200);
    return Opacity(
      opacity: dim ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AquaColors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                      locked ? 'wifi_lock' : 'wifi',
                      color: active ? AquaColors.primary : AquaColors.slate400,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AquaColors.slate500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                const AquaSymbol(
                  'signal_wifi_4_bar',
                  color: AquaColors.slate400,
                ),
                if (active) ...[
                  const SizedBox(width: 8),
                  const AquaSymbol('check_circle', color: AquaColors.primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
