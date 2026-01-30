import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/screens.dart';
import '../theme/aqua_colors.dart';
import 'aqua_symbol.dart';

class AquaBottomNav extends StatelessWidget {
  const AquaBottomNav({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? const Color(0xCC1E291D)
        : Colors.white.withValues(alpha: 0.80);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.20);

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      screen: AppScreen.dashboard,
                      current: current,
                      icon: 'grid_view',
                      label: 'Home',
                      onTap: () => onNavigate(AppScreen.dashboard),
                    ),
                    _NavItem(
                      screen: AppScreen.controls,
                      current: current,
                      icon: 'settings_input_component',
                      label: 'Controls',
                      onTap: () => onNavigate(AppScreen.controls),
                    ),
                    _NavItem(
                      screen: AppScreen.vision,
                      current: current,
                      icon: 'filter_center_focus',
                      label: 'Vision',
                      onTap: () => onNavigate(AppScreen.vision),
                    ),
                    _NavItem(
                      screen: AppScreen.more,
                      current: current,
                      icon: 'apps',
                      label: 'More',
                      onTap: () => onNavigate(AppScreen.more),
                    ),
                    _NavItem(
                      screen: AppScreen.settings,
                      current: current,
                      icon: 'settings',
                      label: 'Settings',
                      onTap: () => onNavigate(AppScreen.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.screen,
    required this.current,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final AppScreen screen;
  final AppScreen current;
  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = current == screen;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inactive = isDark ? AquaColors.slate500 : AquaColors.slate400;
    final active = AquaColors.aqua;

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: isActive ? 1.10 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: AquaSymbol(
                      icon,
                      size: 26,
                      color: isActive ? active : inactive,
                      fill: isActive ? 1 : 1,
                      weight: isActive ? 500 : 400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isActive
                          ? active
                          : inactive.withValues(alpha: 0.80),
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
          if (isActive)
            Positioned(
              bottom: 6,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AquaColors.aqua,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
