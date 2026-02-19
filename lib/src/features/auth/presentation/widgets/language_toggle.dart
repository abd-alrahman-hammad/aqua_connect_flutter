import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/aqua_colors.dart';
import '../../../../core/localization/locale_provider.dart';

/// A pill-shaped EN / AR language toggle that uses [localeProvider]
/// to read and update the current locale.
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEnglish = locale.languageCode == 'en';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final trackColor = isDark ? AquaColors.cardDark : AquaColors.slate200;
    final inactiveTextColor = isDark
        ? AquaColors.slate400
        : AquaColors.slate500;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: 120,
        height: 42,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          children: [
            // Sliding indicator
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: isEnglish
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: 56,
                height: 34,
                decoration: BoxDecoration(
                  color: AquaColors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // Labels
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('en')),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isEnglish ? Colors.white : inactiveTextColor,
                        ),
                        child: const Text('EN'),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref
                        .read(localeProvider.notifier)
                        .setLocale(const Locale('ar')),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isEnglish ? inactiveTextColor : Colors.white,
                        ),
                        child: const Text('AR'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
