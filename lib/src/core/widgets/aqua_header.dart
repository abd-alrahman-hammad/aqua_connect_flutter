import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/aqua_colors.dart';
import 'aqua_symbol.dart';

class AquaHeader extends StatelessWidget {
  const AquaHeader({
    super.key,
    required this.title,
    this.onBack,
    this.rightAction,
    this.forceDarkText = false,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? rightAction;

  /// For screens that sit on pure black (Vision feed), match white header content.
  final bool forceDarkText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark
        ? AquaColors.backgroundDark.withValues(alpha: 0.80)
        : Colors.white.withValues(alpha: 0.80);
    final border = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AquaColors.slate200;
    final textColor = forceDarkText ? Colors.white : null;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: bg,
            border: Border(bottom: BorderSide(color: border)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: onBack == null
                          ? null
                          : IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: onBack,
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: Colors.transparent,
                              ),
                              icon: AquaSymbol(
                                'arrow_back_ios_new',
                                color: textColor,
                              ),
                            ),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: rightAction,
                      ),
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
