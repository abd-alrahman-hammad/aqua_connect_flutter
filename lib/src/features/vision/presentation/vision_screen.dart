import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../app/screens.dart';
import '../../../core/models/db/live_monitoring_model.dart';
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
          StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance.ref('LiveMonitoring/Plant_Master').onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: RayyanColors.rayyan),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}', style: theme.textTheme.bodyMedium),
                );
              }

              final data = snapshot.data?.snapshot.value;
              final model = data != null
                  ? LiveMonitoringModel.fromJson(data as Map<dynamic, dynamic>)
                  : const LiveMonitoringModel.initial();

              return CustomScrollView(
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
                                  AppLocalizations.of(context)!.visionTitle,
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
                          _CameraFeedSection(model: model),

                          const SizedBox(height: 48),

                          const SizedBox(height: 24),

                          // Health Analysis
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _HealthAnalysisSection(model: model),
                          ),

                          const SizedBox(height: 16),

                          // Detected Diseases
                          if (model.isCritical || model.isWarning) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _DetectedDiseasesSection(model: model),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Spot-by-Spot Analysis
                          if (model.hasSpots) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _SpotBySpotAnalysisSection(model: model),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Recommended Action
                          if (model.isCritical || model.isWarning) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: _RecommendedActionSection(model: model),
                            ),
                            const SizedBox(height: 32),
                          ],

                          // Snapshot History
                          const _SnapshotHistorySection(),

                          // Spacing for bottom nav
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom Nav
          RayyanBottomNav(current: current, onNavigate: onNavigate),
        ],
      ),
    );
  }
}

class _CameraFeedSection extends StatelessWidget {
  final LiveMonitoringModel model;
  const _CameraFeedSection({required this.model});

  @override
  Widget build(BuildContext context) {
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
              image: model.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(model.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              // Fallback gradient if there's no image
              gradient: model.imageUrl.isEmpty
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        RayyanColors.visionGradientTop,
                        RayyanColors.visionGradientMid,
                        RayyanColors.visionGradientBottom,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    )
                  : null,
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



class _HealthAnalysisSection extends StatelessWidget {
  final LiveMonitoringModel model;
  const _HealthAnalysisSection({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final statusColor = model.isCritical
        ? RayyanColors.critical
        : model.isWarning
            ? Colors.orange
            : RayyanColors.rayyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              l10n.visionHealthAnalysis,
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
                  l10n.visionLastSync,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: RayyanColors.slate400,
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  model.lastUpdate != null
                      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(model.lastUpdate!)
                      : l10n.visionNeverSync,
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
                        : statusColor.withValues(alpha: 0.15),
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
                      l10n.visionHealthStatus,
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
                        RayyanSymbol(
                          model.isCritical
                              ? 'error'
                              : model.isWarning
                                  ? 'warning'
                                  : 'check_circle',
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isArabic 
                                ? (model.statusAr.isNotEmpty ? model.statusAr : l10n.visionUnknown)
                                : (model.statusEn.isNotEmpty ? model.statusEn : l10n.visionUnknown),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
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
                      l10n.visionConfidence,
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
                          model.confidence,
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
  final LiveMonitoringModel model;
  const _DetectedDiseasesSection({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                l10n.visionDetectedDiseases,
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
            model.isCritical
                ? l10n.visionDiseaseCritical(model.totalSpots)
                : l10n.visionDiseaseWarning,
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
  final LiveMonitoringModel model;
  const _SpotBySpotAnalysisSection({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                l10n.visionSpotAnalysis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...model.spotsDetails.asMap().entries.map((entry) {
            final index = entry.key;
            final spot = entry.value;
            
            // Determine current language
            final isArabic = Localizations.localeOf(context).languageCode == 'ar';
            
            return _SpotItem(
              id: spot.spotId.replaceAll('spot_', 'SPOT '), // Clean up ID
              location: (isArabic && spot.locationAr.isNotEmpty 
                  ? spot.locationAr 
                  : spot.locationEn).toUpperCase(),
              status: isArabic && spot.statusAr.isNotEmpty 
                  ? spot.statusAr 
                  : spot.statusEn,
              confidence: spot.confidence,
              isLast: index == model.spotsDetails.length - 1,
            );
          }),
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
              width: 56, // Increased width to prevent text wrapping
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
  final LiveMonitoringModel model;
  const _RecommendedActionSection({required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.visionRecommendedAction,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: RayyanColors.critical,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.visionActionCritical,
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
                      l10n.visionUrgency,
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
                        model.isCritical ? l10n.visionUrgencyHigh : l10n.visionUrgencyModerate,
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
