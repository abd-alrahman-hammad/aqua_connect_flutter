import 'package:flutter/material.dart';

import '../../../app/screens.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_bottom_nav.dart';
import '../../../core/widgets/rayyan_symbol.dart';
import 'snapshot_history_screen.dart';

class VisionScreen extends StatelessWidget {
  const VisionScreen({
    super.key,
    required this.current,
    required this.onNavigate,
  });

  final AppScreen current;
  final ValueChanged<AppScreen> onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? RayyanColors.backgroundDark
        : RayyanColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      // Custom Header to match exact design
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => onNavigate(AppScreen.dashboard),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: isDark
                                    ? Colors.white
                                    : RayyanColors.slate900,
                                size: 24,
                              ),
                            ),
                            Text(
                              'AI Plant Vision',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : RayyanColors.slate900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 24),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Image Area
                      const _CameraFeedSection(),

                      const SizedBox(height: 48),

                      const SizedBox(height: 24),

                      // Health Analysis
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _HealthAnalysisSection(),
                      ),

                      const SizedBox(height: 16),

                      // Detected Diseases
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _DetectedDiseasesSection(),
                      ),

                      const SizedBox(height: 16),

                      // Spot-by-Spot Analysis
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _SpotBySpotAnalysisSection(),
                      ),

                      const SizedBox(height: 16),

                      // Recommended Action
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _RecommendedActionSection(),
                      ),

                      const SizedBox(height: 32),

                      // Snapshot History
                      const _SnapshotHistorySection(),

                      // Spacing for bottom nav
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom Nav
          RayyanBottomNav(current: current, onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class _CameraFeedSection extends StatelessWidget {
  const _CameraFeedSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? RayyanColors.backgroundDark
        : RayyanColors.backgroundLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Image Container
          Container(
            height: 380,
            width: double.infinity,
            decoration: BoxDecoration(
              color: RayyanColors.slate900,
              borderRadius: BorderRadius.circular(24),
              // Subtly simulate a dark, grassy leafy background using gradients
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  RayyanColors.visionGradientTop,
                  RayyanColors.visionGradientMid,
                  RayyanColors.visionGradientBottom,
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Scan Line
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: RayyanColors.critical,
                      boxShadow: [
                        BoxShadow(
                          color: RayyanColors.critical.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // Target Spots S0, S4, S2 Top
                const Positioned(top: 80, left: 60, child: _TargetSpot('50')),
                const Positioned(top: 80, right: 60, child: _TargetSpot('52')),
                const Positioned(
                  top: 80,
                  left: 0,
                  right: 0,
                  child: Center(child: _TargetSpot('54')),
                ),

                // Target Spots S1, S3, S5 Bottom
                const Positioned(
                  bottom: 140,
                  left: 60,
                  child: _TargetSpot('51'),
                ),
                const Positioned(
                  bottom: 140,
                  right: 60,
                  child: _TargetSpot('55'),
                ),
                const Positioned(
                  bottom: 140,
                  left: 0,
                  right: 0,
                  child: Center(child: _TargetSpot('53')),
                ),

                // Live Analysis Indicator
                Positioned(
                  bottom: 24,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Camera Button Cutout Overlay
        ],
      ),
    );
  }
}

class _TargetSpot extends StatelessWidget {
  final String label;
  const _TargetSpot(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: RayyanColors.critical.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: RayyanColors.critical,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HealthAnalysisSection extends StatelessWidget {
  const _HealthAnalysisSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Health Analysis',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                fontSize: 18,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LAST SYNC',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: RayyanColors.slate400,
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '2025-03-11 18:16:26',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: RayyanColors.slate600,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Health Status Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? RayyanColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : RayyanColors.critical.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HEALTH STATUS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RayyanColors.slate400,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const RayyanSymbol(
                          'error',
                          color: RayyanColors.critical,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Critical',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: RayyanColors.critical,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Confidence Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? RayyanColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : RayyanColors.slate200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONFIDENCE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RayyanColors.slate400,
                        fontWeight: FontWeight.w800,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const RayyanSymbol(
                          'verified',
                          color: RayyanColors.rayyan,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '91%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetectedDiseasesSection extends StatelessWidget {
  const _DetectedDiseasesSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : RayyanColors.slate200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const RayyanSymbol(
                'coronavirus',
                color: RayyanColors.critical,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Detected Diseases',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Multiple diseased spots identified. High risk of spread. Intervention required immediately to save the crop.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: RayyanColors.slate500,
              height: 1.6,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotBySpotAnalysisSection extends StatelessWidget {
  const _SpotBySpotAnalysisSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : RayyanColors.slate200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const RayyanSymbol(
                'grid_view',
                color: RayyanColors.slate500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Spot-by-Spot Analysis',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SpotItem(
            id: 'S0',
            location: 'TOP LEFT',
            status: 'Diseased (مصاب)',
            confidence: '85%',
          ),
          const _SpotItem(
            id: 'S4',
            location: 'TOP CENTER',
            status: 'Diseased (مصاب)',
            confidence: '86%',
          ),
          const _SpotItem(
            id: 'S2',
            location: 'TOP RIGHT',
            status: 'Diseased (مصاب)',
            confidence: '90%',
          ),
          const _SpotItem(
            id: 'S1',
            location: 'BOTTOM LEFT',
            status: 'Diseased (مصاب)',
            confidence: '91%',
          ),
          const _SpotItem(
            id: 'S3',
            location: 'BOTTOM CENTER',
            status: 'Diseased (مصاب)',
            confidence: '87%',
          ),
          const _SpotItem(
            id: 'S5',
            location: 'BOTTOM RIGHT',
            status: 'Diseased (مصاب)',
            confidence: '86%',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SpotItem extends StatelessWidget {
  final String id;
  final String location;
  final String status;
  final String confidence;
  final bool isLast;

  const _SpotItem({
    required this.id,
    required this.location,
    required this.status,
    required this.confidence,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : const Color(0xFFF8FAFC), // Very light cool grey (slate50)
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                id,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: RayyanColors.slate400,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: RayyanColors.slate500,
                      fontWeight: FontWeight.w800,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: RayyanColors.critical,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: RayyanColors.rayyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                confidence,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: RayyanColors.rayyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedActionSection extends StatelessWidget {
  const _RecommendedActionSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? RayyanColors.critical.withValues(alpha: 0.1)
            : const Color(0xFFFEF2F2), // Light red bg
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RayyanColors.critical.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RayyanColors.critical,
              borderRadius: BorderRadius.circular(10), // Rounded square
              boxShadow: [
                BoxShadow(
                  color: RayyanColors.critical.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const RayyanSymbol('warning', color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Action',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: RayyanColors.critical,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Isolate affected plants immediately and apply organic fungicide. Check nutrient balance.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? RayyanColors.slate300
                        : RayyanColors.slate700,
                    height: 1.5,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'URGENCY:',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: RayyanColors.critical,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: RayyanColors.critical.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'High',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: RayyanColors.critical,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotHistorySection extends StatelessWidget {
  const _SnapshotHistorySection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Snapshot History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SnapshotHistoryScreen(),
                    ),
                  );
                },
                child: Text(
                  'View All',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: RayyanColors.nature,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 154,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            children: const [
              _SnapshotCard(
                imageColor: RayyanColors.visionHistoryHealthy1,
                date: 'Oct 24, 10:20 AM',
                status: 'Healthy',
                score: '92%',
                scoreColor: RayyanColors.nature,
              ),
              SizedBox(width: 16),
              _SnapshotCard(
                imageColor: RayyanColors.visionHistoryUnderwatered,
                date: 'Oct 23, 04:15 PM',
                status: 'Under-watered',
                score: '45%',
                scoreColor: RayyanColors.warning,
              ),
              SizedBox(width: 16),
              _SnapshotCard(
                imageColor: RayyanColors.visionHistoryHealthy2,
                date: 'Oct 15, 08:30 AM',
                status: 'Healthy',
                score: '90%',
                scoreColor: RayyanColors.nature,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final Color imageColor;
  final String date;
  final String status;
  final String score;
  final Color scoreColor;

  const _SnapshotCard({
    required this.imageColor,
    required this.date,
    required this.status,
    required this.score,
    required this.scoreColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 124,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : RayyanColors.slate200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                score,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            date,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 9,
              color: isDark ? Colors.white : RayyanColors.slate900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            status,
            style: theme.textTheme.bodySmall?.copyWith(
              color: RayyanColors.slate500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
