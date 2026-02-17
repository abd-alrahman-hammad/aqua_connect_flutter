import 'package:flutter/material.dart';
import '../../../../core/theme/aqua_colors.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconSize,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final double iconSize;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glowColor = AquaColors.primary.withValues(
      alpha: isDark ? 0.15 : 0.10,
    );
    final borderColor = Colors.transparent;

    return Column(
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor,
              width: 0,
              style: BorderStyle.none,
            ),
            boxShadow: compact
                ? null
                : [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
          ),
          child: Center(
            child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : AquaColors.slate900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? AquaColors.slate400 : AquaColors.slate500,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        if (!compact) const SizedBox(height: 32),
      ],
    );
  }
}
