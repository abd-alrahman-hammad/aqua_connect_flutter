import 'package:flutter/material.dart';
import '../../../../core/theme/aqua_colors.dart';

class SwitchPill extends StatelessWidget {
  const SwitchPill({super.key, required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackOff = isDark ? AquaColors.slate700 : AquaColors.slate200;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 40,
      height: 24,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: value ? AquaColors.primary : trackOff,
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
