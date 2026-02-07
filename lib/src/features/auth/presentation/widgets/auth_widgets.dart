import 'package:flutter/material.dart';

import '../../../../core/theme/aqua_colors.dart';
import '../../../../core/widgets/aqua_symbol.dart';

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

    final glowColor = AquaColors.primary.withOpacity(isDark ? 0.15 : 0.10);
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

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AquaColors.surfaceDark : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AquaColors.slate200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        // Removed fixed height to allow error text to show properly
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fill,
            errorText: errorText, // Inline error message
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.critical,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.critical,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthPasswordField extends StatelessWidget {
  const AuthPasswordField({
    super.key,
    required this.label,
    required this.hint,
    required this.visible,
    required this.onToggleVisibility,
    this.controller,
    this.errorText,
    this.onChanged,
  });

  final String label;
  final String hint;
  final bool visible;
  final VoidCallback onToggleVisibility;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AquaColors.surfaceDark : Colors.white;
    final border = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AquaColors.slate200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        // Removed fixed height to allow error text to show properly
        TextField(
          controller: controller,
          obscureText: !visible,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fill,
            errorText: errorText, // Inline error message
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.critical,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AquaColors.critical,
                width: 1.2,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: AquaSymbol(
                'visibility',
                color: isDark ? AquaColors.slate300 : AquaColors.slate400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AquaColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: AquaColors.primary.withValues(alpha: 0.30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        child: Text(label),
      ),
    );
  }
}

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
