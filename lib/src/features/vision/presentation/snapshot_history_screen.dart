import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/models/db/detection_history_model.dart';
import '../data/detection_history_repository.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class SnapshotHistoryScreen extends ConsumerStatefulWidget {
  const SnapshotHistoryScreen({super.key});

  @override
  ConsumerState<SnapshotHistoryScreen> createState() => _SnapshotHistoryScreenState();
}

class _SnapshotHistoryScreenState extends ConsumerState<SnapshotHistoryScreen> {
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
          // Lists
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: ref.watch(detectionHistoryProvider).when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No history available yet'),
                          ),
                        ),
                      );
                    }
                    
                    // Filter the items based on status matching chips (e.g. status == 'Healthy')
                    final filteredItems = _selectedFilter == 'All' 
                        ? items 
                        : items.where((i) => i.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
                        
                    if (filteredItems.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No results for selected filter'),
                          ),
                        ),
                      );
                    }

                    // Group by formatted date
                    final Map<String, List<DetectionHistoryModel>> grouped = {};
                    for (var item in filteredItems) {
                      final dateStr = DateFormat('MMM d, yyyy').format(item.timestamp).toUpperCase();
                      grouped.putIfAbsent(dateStr, () => []).add(item);
                    }

                    final sliverChildren = <Widget>[];
                    grouped.forEach((dateString, dayItems) {
                      sliverChildren.add(_DateHeader(dateString));
                      sliverChildren.add(const SizedBox(height: 12));
                      for (var item in dayItems) {
                        sliverChildren.add(Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SnapshotItem(item: item),
                        ));
                      }
                      sliverChildren.add(const SizedBox(height: 12));
                    });
                    
                    sliverChildren.add(const SizedBox(height: 20));

                    return SliverList(
                      delegate: SliverChildListDelegate(sliverChildren),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  error: (err, stack) => SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Error: $err',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
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
  final DetectionHistoryModel item;

  const _SnapshotItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Status Color
    Color statusColor = RayyanColors.slate500;
    final lowerStatus = item.status.toLowerCase();
    if (lowerStatus.contains('health') || lowerStatus.contains('optimal')) {
      statusColor = RayyanColors.nature;
    } else if (lowerStatus.contains('warn')) {
      statusColor = RayyanColors.warning;
    } else if (lowerStatus.contains('critical') || lowerStatus.contains('danger') || lowerStatus.contains('disease')) {
      statusColor = RayyanColors.critical;
    }
    
    // Confidence Color
    final confStr = item.confidence.replaceAll('%', '');
    final confVal = int.tryParse(confStr) ?? 0;
    Color confColor = RayyanColors.critical;
    if (confVal >= 85) {
      confColor = RayyanColors.nature;
    } else if (confVal >= 60) {
      confColor = RayyanColors.warning;
    }

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
            // Image Cached
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: isDark ? RayyanColors.slate700 : RayyanColors.slate200,
                borderRadius: BorderRadius.circular(12),
                image: item.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(item.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (item.imageUrl.isEmpty)
                    const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                  // Confidence Badge Overlay
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: confColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.confidence,
                        style: const TextStyle(
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
                          item.title,
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
                        DateFormat('h:mm a').format(item.timestamp),
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
                    item.subtitle,
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
                          item.status.toUpperCase(),
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
                          item.description,
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
