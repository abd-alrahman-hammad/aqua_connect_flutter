import 'package:flutter/material.dart';

import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class SnapshotHistoryScreen extends StatefulWidget {
  const SnapshotHistoryScreen({super.key});

  @override
  State<SnapshotHistoryScreen> createState() => _SnapshotHistoryScreenState();
}

class _SnapshotHistoryScreenState extends State<SnapshotHistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark
        ? RayyanColors.backgroundDark
        : RayyanColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : RayyanColors.slate900,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Snapshot History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : RayyanColors.slate900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: RayyanSymbol(
              'calendar_month',
              color: isDark ? RayyanColors.slate400 : RayyanColors.slate600,
              size: 24,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? RayyanColors.surfaceDark
                          : RayyanColors.slate100.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        RayyanSymbol(
                          'search',
                          color: RayyanColors.slate500,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search lettuce snapshots...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: RayyanColors.slate500,
                                fontSize: 14,
                              ),
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white : RayyanColors.slate900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedFilter == 'All',
                        onTap: () => setState(() => _selectedFilter = 'All'),
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: 'Healthy',
                        icon: 'check_circle',
                        iconColor: RayyanColors.nature,
                        isSelected: _selectedFilter == 'Healthy',
                        onTap: () => setState(() => _selectedFilter = 'Healthy'),
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: 'Warning',
                        icon: 'warning',
                        iconColor: RayyanColors.warning,
                        isSelected: _selectedFilter == 'Warning',
                        onTap: () => setState(() => _selectedFilter = 'Warning'),
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: 'Critical',
                        icon: 'error',
                        iconColor: RayyanColors.critical,
                        isSelected: _selectedFilter == 'Critical',
                        onTap: () => setState(() => _selectedFilter = 'Critical'),
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 16),
                  child: Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : RayyanColors.slate200.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Lists
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _DateHeader('TODAY, OCT 24'),
                const SizedBox(height: 12),
                const _SnapshotItem(
                  imageColor: RayyanColors.visionHistoryHealthy1,
                  score: '98%',
                  title: 'Butterhead Lettuce',
                  subtitle: 'Main Reservoir • System A',
                  time: '14:30',
                  status: 'HEALTHY',
                  statusColor: RayyanColors.nature,
                  description: 'No action needed',
                ),
                const SizedBox(height: 12),
                const _SnapshotItem(
                  imageColor: RayyanColors.visionHistoryUnderwatered,
                  score: '95%',
                  title: 'Romaine Lettuce',
                  subtitle: 'Nursery Rack • Tier 2',
                  time: '11:15',
                  status: 'HEALTHY',
                  statusColor: RayyanColors.nature,
                  description: 'Optimal growth',
                ),
                
                const SizedBox(height: 24),
                _DateHeader('YESTERDAY, OCT 23'),
                const SizedBox(height: 12),
                const _SnapshotItem(
                  imageColor: RayyanColors.visionGradientTop,
                  score: '82%',
                  title: 'Red Leaf Lettuce',
                  subtitle: 'Vertical Wall • Section 4',
                  time: '16:45',
                  status: 'WARNING',
                  statusColor: RayyanColors.warning,
                  description: 'Slight tip burn',
                ),
                const SizedBox(height: 12),
                const _SnapshotItem(
                  imageColor: RayyanColors.visionHistoryHealthy2,
                  score: '65%',
                  title: 'Butterhead Lettuce',
                  subtitle: 'Main Reservoir • Tray 12',
                  time: '08:30',
                  status: 'CRITICAL',
                  statusColor: RayyanColors.critical,
                  description: 'Temp stress detected',
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? icon;
  final Color? iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Custom color for the "All" chip as seen in mock (an orange/reddish hue)
    const orangeColor = Color(0xFFF05D23);

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isSelected && icon == null) {
      // "All" active state
      bgColor = orangeColor;
      borderColor = orangeColor;
      textColor = Colors.white;
    } else if (isSelected) {
      // other active states (though mockup doesn't show them active, assume logic if needed)
      bgColor = isDark ? RayyanColors.surfaceDark : Colors.white;
      borderColor = iconColor ?? RayyanColors.slate300;
      textColor = isDark ? Colors.white : RayyanColors.slate900;
    } else {
      // Inactive
      bgColor = isDark ? RayyanColors.surfaceDark : Colors.white;
      borderColor = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : RayyanColors.slate200;
      textColor = isDark ? RayyanColors.slate300 : RayyanColors.slate700;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              RayyanSymbol(
                icon!,
                color: iconColor ?? textColor,
                size: 16,
                fill: 1,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;

  const _DateHeader(this.date);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      date,
      style: theme.textTheme.labelSmall?.copyWith(
        color: isDark ? RayyanColors.slate400 : RayyanColors.slate500,
        fontWeight: FontWeight.w900,
        fontSize: 11,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SnapshotItem extends StatelessWidget {
  final Color imageColor;
  final String score;
  final String title;
  final String subtitle;
  final String time;
  final String status;
  final Color statusColor;
  final String description;

  const _SnapshotItem({
    required this.imageColor,
    required this.score,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? RayyanColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : RayyanColors.slate200.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Placeholder
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: imageColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  score,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: isDark ? Colors.white : RayyanColors.slate900,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark ? RayyanColors.slate400 : RayyanColors.slate400,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: RayyanColors.slate500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: RayyanColors.slate400,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
