import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../core/models/db/detection_history_model.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class DetectionDetailsScreen extends StatelessWidget {
  final DetectionHistoryModel item;

  const DetectionDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    // Evaluate colors and localized status
    Color statusColor = RayyanColors.slate500;
    String translatedStatus = item.status;
    final lowerStatus = item.status.toLowerCase();
    
    if (lowerStatus.contains('health') || lowerStatus.contains('optimal')) {
      statusColor = RayyanColors.nature;
      translatedStatus = l10n.visionHealthy;
    } else if (lowerStatus.contains('warn')) {
      statusColor = RayyanColors.warning;
      translatedStatus = l10n.visionWarning;
    } else if (lowerStatus.contains('critical') || lowerStatus.contains('danger') || lowerStatus.contains('disease')) {
      statusColor = RayyanColors.critical;
      translatedStatus = l10n.visionCritical;
    }

    final confStr = item.confidence.replaceAll('%', '');
    final confVal = int.tryParse(confStr) ?? 0;
    Color confColor = RayyanColors.critical;
    if (confVal >= 85) {
      confColor = RayyanColors.nature;
    } else if (confVal >= 60) {
      confColor = RayyanColors.warning;
    }

    return Scaffold(
      backgroundColor: isDark ? RayyanColors.backgroundDark : RayyanColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: RayyanSymbol(
            'arrow_back_ios_new',
            color: isDark ? Colors.white : RayyanColors.slate900,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : RayyanColors.slate900,
        ),
        title: Text(
          l10n.detectionDetailsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : RayyanColors.slate900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Image
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: isDark ? RayyanColors.slate700 : RayyanColors.slate200,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: item.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(item.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.imageUrl.isEmpty
                   ? const Center(child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey))
                   : null,
              ),
              const SizedBox(height: 24),

              // Health Analysis Section
              _buildHealthAnalysisSection(context, theme, isDark, statusColor, confColor, lowerStatus, translatedStatus, l10n),
              const SizedBox(height: 16),

              // Detected Diseases & Spots Analysis
              if (item.totalSpots > 0) ...[
                _DetectedDiseasesSection(item: item),
                const SizedBox(height: 16),
                _SpotBySpotAnalysisSection(item: item),
              ],
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthAnalysisSection(BuildContext context, ThemeData theme, bool isDark, Color statusColor, Color confColor, String lowerStatus, String translatedStatus, AppLocalizations l10n) {
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
                  l10n.visionLastSync.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: RayyanColors.slate400,
                    fontWeight: FontWeight.w800,
                    fontSize: 8,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(item.timestamp),
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
                      l10n.visionHealthStatus.toUpperCase(),
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
                          _getSymbolName(lowerStatus),
                          color: statusColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            translatedStatus.toUpperCase(),
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
                      l10n.visionConfidence.toUpperCase(),
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
                          item.confidence,
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

  String _getSymbolName(String lowerStatus) {
    if (lowerStatus.contains('health') || lowerStatus.contains('optimal')) return 'check_circle';
    if (lowerStatus.contains('warn')) return 'warning';
    return 'error';
  }
}

class _DetectedDiseasesSection extends StatelessWidget {
  final DetectionHistoryModel item;
  const _DetectedDiseasesSection({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    final isCritical = item.status.toLowerCase() == 'critical' || item.status == 'حرج';

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
            isCritical
                ? l10n.visionDiseaseCritical(item.totalSpots)
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
  final DetectionHistoryModel item;
  const _SpotBySpotAnalysisSection({required this.item});

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
          ...item.spotsDetails.asMap().entries.map((entry) {
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
              isLast: index == item.spotsDetails.length - 1,
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
              : const Color(0xFFF8FAFC), // Very light cool grey
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
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
