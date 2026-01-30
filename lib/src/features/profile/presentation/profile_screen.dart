import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
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
          AquaHeader(
            title: 'Farm Profile',
            onBack: () => onNavigate(AppScreen.settings),
            rightAction: const AquaSymbol('logout', color: AquaColors.critical),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AquaColors.cardDark : Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.20),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: 'https://picsum.photos/200',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AquaColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AquaColors.backgroundDark
                                : AquaColors.backgroundLight,
                            width: 4,
                          ),
                        ),
                        child: const AquaSymbol(
                          'verified',
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Alex Rivera',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'alex.rivera@aquaconnect.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AquaColors.slate400 : AquaColors.slate500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
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
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AquaColors.info.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: AquaSymbol(
                                'sync_alt',
                                color: AquaColors.info,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Sync',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Adjust pH based on local climate',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? AquaColors.slate400
                                          : AquaColors.slate500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 48,
                        height: 24,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AquaColors.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Align(
                          alignment: Alignment.centerRight,
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Devices',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const AquaSymbol(
                        'add_circle',
                        color: AquaColors.primary,
                      ),
                      label: Text(
                        'Add New',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AquaColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _DeviceRow(name: 'ESP32 - Hydro Tower 1', online: true),
                const SizedBox(height: 12),
                _DeviceRow(name: 'ESP32 - Seedling Tray', online: true),
                const SizedBox(height: 12),
                _DeviceRow(
                  name: 'Main Reservoir Hub',
                  online: false,
                  dashed: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({
    required this.name,
    required this.online,
    this.dashed = false,
  });

  final String name;
  final bool online;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dashed
            ? (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AquaColors.slate100)
            : (isDark ? AquaColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dashed
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : AquaColors.slate300)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AquaColors.slate200),
          style: dashed ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: online
                      ? AquaColors.primary.withValues(alpha: 0.05)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : AquaColors.slate200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AquaSymbol(
                    online ? 'memory' : 'cloud_off',
                    color: online ? AquaColors.primary : AquaColors.slate400,
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
                      color: dashed ? AquaColors.slate500 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: online
                              ? AquaColors.nature
                              : AquaColors.critical,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        online
                            ? 'Online • Signal Strong'
                            : 'Offline • No Signal',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: online
                              ? AquaColors.slate500
                              : AquaColors.critical,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              if (online && !dashed) ...[
                IconButton(
                  onPressed: () {},
                  icon: const AquaSymbol(
                    'settings',
                    color: AquaColors.slate400,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const AquaSymbol('edit', color: AquaColors.slate400),
                ),
              ] else
                IconButton(
                  onPressed: () {},
                  icon: const AquaSymbol('refresh', color: AquaColors.slate400),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
