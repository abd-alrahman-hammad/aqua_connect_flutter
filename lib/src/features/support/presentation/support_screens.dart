import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../../../core/widgets/aqua_page_scaffold.dart';
import '../../../core/widgets/aqua_symbol.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });
  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AquaPageScaffold(
      currentScreen: current,
      onNavigate: onNavigate,
      child: Column(
        children: [
          AquaHeader(
            title: 'Alerts & Notifications',
            onBack: () => onNavigate(AppScreen.dashboard),
            rightAction: IconButton(
              onPressed: () {},
              icon: const AquaSymbol('done_all'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: const [
                _AlertCard(
                  type: 'critical',
                  icon: 'water_drop',
                  title: 'Low pH Detected',
                  time: '2M AGO',
                  desc: 'Current pH: 4.2. Recommended: 5.5 - 6.5',
                ),
                SizedBox(height: 12),
                _AlertCard(
                  type: 'critical',
                  icon: 'settings_input_component',
                  title: 'Nutrient Pump Failure',
                  time: '1H AGO',
                  desc:
                      'Pump #3 is unresponsive. Check power supply immediately.',
                ),
                SizedBox(height: 24),
                _SectionLabel('Active Warnings'),
                SizedBox(height: 8),
                _AlertCard(
                  type: 'warning',
                  icon: 'eco',
                  title: 'Plant Disease Warning',
                  time: '15M AGO',
                  desc: 'Early signs of root rot detected in Zone B sensors.',
                ),
                SizedBox(height: 12),
                _AlertCard(
                  type: 'warning',
                  icon: 'light_mode',
                  title: 'Low Light Intensity',
                  time: '3H AGO',
                  desc: 'PAR levels below 400 μmol/m²/s in Sector 4.',
                ),
                SizedBox(height: 24),
                _SectionLabel('System Logs'),
                SizedBox(height: 8),
                _AlertCard(
                  type: 'info',
                  icon: 'history_edu',
                  title: 'Daily Summary Ready',
                  time: '8H AGO',
                  desc:
                      'Your daily yield prediction and nutrient log is now available.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, required this.onNavigate});
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AquaColors.backgroundDark
          : AquaColors.backgroundLight,
      body: Stack(
        children: [
          AquaPageScaffold(
            includeBottomNav: false,
            currentScreen: AppScreen.support,
            onNavigate: onNavigate,
            child: Column(
              children: [
                AquaHeader(
                  title: 'Support & Learning',
                  onBack: () => onNavigate(AppScreen.dashboard),
                  rightAction: IconButton(
                    onPressed: () {},
                    icon: const AquaSymbol('search'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Video Guides',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visual walkthroughs for your system',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AquaColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, i) {
                            final idx = i + 1;
                            return SizedBox(
                              width: 280,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl:
                                                'https://picsum.photos/300/170?random=$idx',
                                            fit: BoxFit.cover,
                                          ),
                                          Container(
                                            color: Colors.black.withValues(
                                              alpha: 0.30,
                                            ),
                                          ),
                                          Center(
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              decoration: const BoxDecoration(
                                                color: AquaColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: AquaSymbol(
                                                  'play_arrow',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.70,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                '5:20',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Setting up your Reservoir',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    'Automated nutrient mixing guide',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: AquaColors.slate500),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Frequently Asked Questions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        'How do I connect to Wi-Fi?',
                        'What is the ideal pH range?',
                        'How often should I change water?',
                      ].map((q) => _FaqTile(question: q)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Center(
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const AquaSymbol('smart_toy', color: Colors.white),
                    label: const Text('Chat with Aqua AI'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AquaColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question});
  final String question;
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : AquaColors.slate200,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => open = !open),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const AquaSymbol(
                      'expand_more',
                      color: AquaColors.slate400,
                    ),
                  ),
                ],
              ),
              if (open) ...[
                const SizedBox(height: 12),
                Divider(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AquaColors.slate100,
                  height: 1,
                ),
                const SizedBox(height: 12),
                Text(
                  'This is a detailed answer to the question. It provides helpful information to the user.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AquaColors.slate400 : AquaColors.slate500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AquaColors.slate400,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    ),
  );
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.type,
    required this.icon,
    required this.title,
    required this.time,
    required this.desc,
  });
  final String type;
  final String icon;
  final String title;
  final String time;
  final String desc;

  @override
  Widget build(BuildContext context) {
    Color border = AquaColors.info;
    Color iconColor = AquaColors.info;
    Color iconBg = AquaColors.info.withValues(alpha: 0.10);
    if (type == 'critical') {
      border = AquaColors.critical;
      iconColor = AquaColors.critical;
      iconBg = AquaColors.critical.withValues(alpha: 0.10);
    } else if (type == 'warning') {
      border = AquaColors.warning;
      iconColor = AquaColors.warning;
      iconBg = AquaColors.warning.withValues(alpha: 0.10);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AquaColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: border, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: AquaSymbol(icon, color: iconColor, size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AquaColors.slate400,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AquaColors.slate400
                              : AquaColors.slate500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (type == 'critical')
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'ADJUST PH',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AquaColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AquaColors.slate100,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: Text(
                          'DISMISS',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AquaColors.slate400,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
