import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/screens.dart';
import '../../../core/services/auth_preferences_service.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String lang = 'EN';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AquaColors.backgroundDark : AquaColors.backgroundLight;

    return AquaPageScaffold(
      currentScreen: widget.current,
      onNavigate: widget.onNavigate,
      backgroundColor: bg,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.90),
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
                        const SizedBox(width: 8),
                        Text(
                          'System Settings',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => widget.onNavigate(AppScreen.profile),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AquaColors.primary.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: AquaSymbol(
                            'person',
                            color: AquaColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionLabel('Account'),
                _Card(
                  children: [
                    _MenuItem(
                      icon: 'lock',
                      title: 'Account Security',
                      subtitle: 'Change Password',
                      onTap: () => widget.onNavigate(AppScreen.accountSecurity),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: 'notifications',
                      title: 'Notification Settings',
                      subtitle: 'Alerts & Notifications',
                      onTap: () =>
                          widget.onNavigate(AppScreen.notificationSettings),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel('Hardware & IoT'),
                _Card(
                  children: [
                    _MenuItem(
                      icon: 'wifi',
                      title: 'WiFi Management',
                      subtitle: 'Run Connection Wizard',
                      onTap: () => widget.onNavigate(AppScreen.wifi),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: 'tune',
                      title: 'Operating Thresholds',
                      subtitle: 'Fan, Heater, pH pump, Feeding pump limits',
                      onTap: () => widget.onNavigate(AppScreen.thresholds),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: 'precision_manufacturing',
                      title: 'Sensor Calibration',
                      subtitle: 'pH, EC, and Temperature',
                      onTap: () =>
                          widget.onNavigate(AppScreen.sensorCalibration),
                    ),
                    _Divider(),
                    _MenuItem(
                      icon: 'update',
                      title: 'Firmware Update',
                      subtitleWidget: Text(
                        'Up to date: v2.4.1',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AquaColors.nature,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      onTap: () => widget.onNavigate(AppScreen.firmwareUpdate),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionLabel('App Preferences'),
                _Card(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _IconBox(
                                icon: 'language',
                                color: AquaColors.primary,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Language',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              setState(() => lang = lang == 'EN' ? 'AR' : 'EN');
                              widget.onToggleLanguage();
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AquaColors.surfaceDark
                                    : AquaColors.slate100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  _LangPill(
                                    label: 'EN',
                                    selected: lang == 'EN',
                                  ),
                                  _LangPill(
                                    label: 'AR',
                                    selected: lang == 'AR',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Divider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _IconBox(
                                icon: 'dark_mode',
                                color: AquaColors.primary,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Dark Mode',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: widget.onToggleTheme,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 48,
                              height: 28,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AquaColors.primary
                                    : AquaColors.slate300,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Align(
                                alignment: isDark
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  width: 20,
                                  height: 20,
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
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                InkWell(
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;
                        return AlertDialog(
                          backgroundColor: isDark
                              ? AquaColors.cardDark
                              : Colors.white,
                          title: Text(
                            'Sign Out',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                          ),
                          content: Text(
                            'Are you sure you want to sign out?',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: isDark
                                      ? AquaColors.slate400
                                      : AquaColors.slate600,
                                ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AquaColors.slate500,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Sign Out',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(
                                      color: AquaColors.critical,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    );

                    if (shouldLogout != true) return;

                    try {
                      if (context.mounted) {
                        await ref.read(authPreferencesServiceProvider).clear();
                        await ref.read(firebaseAuthServiceProvider).signOut();
                        widget.onNavigate(AppScreen.login);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing out: $e'),
                            backgroundColor: AquaColors.critical,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AquaColors.critical.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AquaColors.critical.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Sign Out',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AquaColors.critical,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Rayyan v2.4.1 Build 102',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AquaColors.slate400,
                      fontWeight: FontWeight.w800,
                    ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AquaColors.slate400,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AquaColors.slate200,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : AquaColors.slate100,
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});
  final String icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? AquaColors.surfaceDark : AquaColors.slate100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: AquaSymbol(icon, color: color)),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final Widget? subtitleWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _IconBox(icon: icon, color: AquaColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AquaColors.slate400
                            : AquaColors.slate500,
                      ),
                    ),
                  if (subtitleWidget != null) subtitleWidget!,
                ],
              ),
            ),
            const AquaSymbol('chevron_right', color: AquaColors.slate300),
          ],
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({required this.label, required this.selected});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? AquaColors.backgroundDark : Colors.white)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: selected ? AquaColors.primary : AquaColors.slate400,
          fontSize: 12,
        ),
      ),
    );
  }
}
