import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_header.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  Future<void> _launch(BuildContext context, String url, String copyText) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    await Clipboard.setData(ClipboardData(text: copyText));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied: $copyText'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: isDark
          ? RayyanColors.backgroundDark
          : RayyanColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            RayyanHeader(
              title: l10n.contactUsTitle,
              onBack: () => onNavigate(AppScreen.more),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.stillNeedHelp,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.specialistsAvailable,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: RayyanColors.slate500),
                    ),
                    const SizedBox(height: 24),
                    _ContactCard(
                      symbol: 'call',
                      title: l10n.callUs,
                      subtitle: '0786548862',
                      onTap: () => _launch(context, 'tel:0786548862', '0786548862'),
                    ),
                    _ContactCard(
                      symbol: 'mail',
                      title: l10n.emailSupport,
                      subtitle: 'rayyanapp26@gmail.com',
                      onTap: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'rayyanapp26@gmail.com',
                          queryParameters: {
                            'subject': 'Rayyan App Support',
                          },
                        );
                        try {
                          await launchUrl(uri);
                        } catch (_) {
                          if (context.mounted) {
                            await Clipboard.setData(
                              const ClipboardData(text: 'rayyanapp26@gmail.com'),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Copied: rayyanapp26@gmail.com'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    _ContactCard(
                      symbol: 'psychology',
                      title: l10n.agriculturalExpert,
                      subtitle: l10n.agriculturalExpertSub,
                      onTap: () => _launch(
                          context, 'https://wa.me/962786548862', '+962786548862'),
                    ),
                    _ContactCard(
                      symbol: 'forum',
                      title: l10n.whatsapp,
                      subtitle: l10n.whatsappSub,
                      onTap: () => _launch(
                          context, 'https://wa.me/962786548862', '+962786548862'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String symbol;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ContactCard({
    required this.symbol,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : RayyanColors.slate200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: RayyanColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: RayyanSymbol(
                    symbol,
                    color: RayyanColors.primary,
                  ),
                ),
              ),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: RayyanColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
