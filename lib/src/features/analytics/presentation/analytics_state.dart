import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/hydroponic_database_service.dart';

/// Provider to store the initial tab for the Analytics Screen.
/// Used when navigating from Dashboard to a specific sensor chart.
final analyticsTabProvider = StateProvider<String?>((ref) => null);

/// Enum defining the available time ranges for analytics
enum AnalyticsTimeRange {
  h24('24H', Duration(hours: 24)),
  d7('7D', Duration(days: 7)),
  d30('30D', Duration(days: 30));

  final String label;
  final Duration duration;
  const AnalyticsTimeRange(this.label, this.duration);
}

/// Provider to track the currently selected time range
final analyticsTimeRangeProvider = StateProvider<AnalyticsTimeRange>((ref) {
  return AnalyticsTimeRange.h24;
});

/// Parameters for fetching history data
class HistoryParams {
  final String sensorType;
  final AnalyticsTimeRange range;

  HistoryParams(this.sensorType, this.range);

  @override
  bool operator ==(Object other) =>
      other is HistoryParams &&
      other.sensorType == sensorType &&
      other.range == range;

  @override
  int get hashCode => Object.hash(sensorType, range);
}

/// Future provider to fetch history data based on sensor type and selected range
final analyticsHistoryProvider = FutureProvider.family<Map<int, double>, String>((
  ref,
  sensorType,
) async {
  final range = ref.watch(analyticsTimeRangeProvider);
  final dbService = ref.watch(hydroponicDatabaseServiceProvider);

  // If we are in 24H mode, we might want to prioritize recent data or use a different strategy,
  // but for now, we use the same getSensorHistory method.
  return dbService.getSensorHistory(sensorType, range.duration);
});
