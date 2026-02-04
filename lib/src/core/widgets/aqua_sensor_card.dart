import 'package:flutter/material.dart';

import '../theme/aqua_colors.dart';
import 'aqua_symbol.dart';

/// Shared sensor/reading card widget used in Dashboard and Monitoring screens.
///
/// Displays an icon, value, label, and optional status badge in a styled card.
/// Supports optional tap handler (wraps in InkWell when provided).
class AquaSensorCard extends StatelessWidget {
  const AquaSensorCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.badgeText,
    this.badgeBg,
    this.badgeColor,
    this.statusColor,
    this.width,
    this.onTap,
    this.iconSize = 40,
    this.labelUppercase = false,
  });

  final String icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final String badgeText;
  final Color? badgeBg;
  final Color? badgeColor;
  final Color? statusColor;
  final double? width;
  final VoidCallback? onTap;
  final double iconSize;
  final bool labelUppercase;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveWidth =
        width ?? (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2;
    final effectiveBadgeColor = statusColor ?? badgeColor ?? AquaColors.nature;
    final effectiveBadgeBg =
        badgeBg ?? effectiveBadgeColor.withValues(alpha: 0.10);
    final displayLabel = labelUppercase ? label.toUpperCase() : label;

    final cardContent = Container(
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
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AquaSymbol(
                    icon,
                    color: iconColor,
                    size: iconSize > 36 ? 24 : 18,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: effectiveBadgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: effectiveBadgeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: iconSize > 36 ? 12 : 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            displayLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? AquaColors.slate400 : AquaColors.slate500,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: effectiveWidth,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: cardContent,
            )
          : cardContent,
    );
  }
}
