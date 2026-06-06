import 'package:flutter/material.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../core/utils/password_validator.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = PasswordValidator.getStrength(password);
    
    Color color;
    String text;
    double fillPercentage;

    switch (strength) {
      case PasswordStrength.weak:
        color = Colors.red.shade400;
        text = AppLocalizations.of(context)!.passwordStrengthWeak;
        fillPercentage = 0.33;
        break;
      case PasswordStrength.medium:
        color = Colors.orange.shade400;
        text = AppLocalizations.of(context)!.passwordStrengthMedium;
        fillPercentage = 0.66;
        break;
      case PasswordStrength.strong:
        color = Colors.green.shade400;
        text = AppLocalizations.of(context)!.passwordStrengthStrong;
        fillPercentage = 1.0;
        break;
      case PasswordStrength.none:
        color = Colors.grey;
        text = '';
        fillPercentage = 0.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fillPercentage,
                  backgroundColor: color.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
