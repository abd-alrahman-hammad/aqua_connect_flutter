import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../l10n/generated/app_localizations.dart';

import '../../../core/models/db/detection_history_model.dart';
import '../data/detection_history_repository.dart';
import 'detection_details_screen.dart';
import '../../../core/theme/rayyan_colors.dart';
import '../../../core/widgets/rayyan_symbol.dart';

class SnapshotHistoryScreen extends ConsumerStatefulWidget {
  const SnapshotHistoryScreen({super.key});

  @override
  ConsumerState<SnapshotHistoryScreen> createState() => _SnapshotHistoryScreenState();
}

class _SnapshotHistoryScreenState extends ConsumerState<SnapshotHistoryScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
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
          icon: RayyanSymbol(
            'arrow_back_ios_new',
            color: isDark ? Colors.white : RayyanColors.slate900,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.snapshotHistoryTitle,
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
              color: _selectedDate != null 
                  ? RayyanColors.rayyan 
                  : (isDark ? RayyanColors.slate400 : RayyanColors.slate600),
              size: 24,
            ),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: isDark
                          ? const ColorScheme.dark(
                              primary: RayyanColors.rayyan,
                              onPrimary: Colors.white,
                              surface: RayyanColors.surfaceDark,
                              onSurface: Colors.white,
                            )
                          : const ColorScheme.light(
                              primary: RayyanColors.rayyan,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: RayyanColors.slate900,
                            ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              } else {
                // If they cancel out, we can choose to clear it or keep it
                // Let's keep it to clear it when tapping again:
                setState(() {
                  _selectedDate = null;
                });
              }
            },
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
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: l10n.snapshotSearchHint,
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
                        label: l10n.snapshotFilterAll,
                        isSelected: _selectedFilter == 'All',
                        onTap: () => setState(() => _selectedFilter = 'All'),
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: l10n.snapshotFilterHealthy,
                        icon: 'check_circle',
                        iconColor: RayyanColors.nature,
                        isSelected: _selectedFilter == 'Healthy',
                        onTap: () => setState(() => _selectedFilter = 'Healthy'),
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: l10n.snapshotFilterWarning,
                        icon: 'warning',
                        iconColor: RayyanColors.warning,
                        isSelected: _selectedFilter == 'Warning',
                        onTap: () => setState(() => _selectedFilter = 'Warning'),
                      ),
                      const SizedBox(width: 12),
                      _FilterChip(
                        label: l10n.snapshotFilterCritical,
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
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(l10n.snapshotNoHistory),
                          ),
                        ),
                      );
                    }
                    
                    // Filter the items based on status matching chips (e.g. status == 'Healthy')
                    var filteredItems = _selectedFilter == 'All' 
                        ? items 
                        : items.where((i) => i.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();

                    // Apply text search
                    if (_searchQuery.isNotEmpty) {
                      filteredItems = filteredItems.where((i) => 
                        i.title.toLowerCase().contains(_searchQuery) ||
                        i.subtitle.toLowerCase().contains(_searchQuery) ||
                        i.description.toLowerCase().contains(_searchQuery)
                      ).toList();
                    }

                    // Apply date filter
                    if (_selectedDate != null) {
                      filteredItems = filteredItems.where((i) {
                        return i.timestamp.year == _selectedDate!.year &&
                               i.timestamp.month == _selectedDate!.month &&
                               i.timestamp.day == _selectedDate!.day;
                      }).toList();
                    }
                        
                    if (filteredItems.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(l10n.snapshotNoResults),
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
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetectionDetailsScreen(item: item),
                                ),
                              );
                            },
                            child: _SnapshotItem(item: item),
                          ),
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
                          l10n.snapshotError(err.toString()),
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
    final l10n = AppLocalizations.of(context)!;
    
    // Status Color
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
                        DateFormat('h:mm a', l10n.localeName).format(item.timestamp),
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
                    l10n.visionSpotsDetected(item.totalSpots),
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
                          translatedStatus.toUpperCase(),
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
                          _localizedDescription(item.description, l10n),
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

  String _localizedDescription(String description, AppLocalizations l10n) {
    switch (description) {
      case 'Action requires attention':
        return l10n.visionActionRequiresAttention;
      case 'Optimal growth':
        return l10n.visionOptimalGrowth;
      default:
        return description;
    }
  }
}
