import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/hydroponic/sensors_model.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../../../core/utils/vitality_utils.dart';
import '../data/groq_insights_service.dart'; // ✅ Changed from gemini_insights_service
import '../domain/ai_insight_model.dart';

class InsightsState {
  final AiInsightModel? insight;
  final bool isLoading;
  final String? error;
  final SensorsModel? lastAnalyzedSensors;
  final DateTime? lastFetchTime;
  final String? lastOverallStatus;

  const InsightsState({
    this.insight,
    this.isLoading = false,
    this.error,
    this.lastAnalyzedSensors,
    this.lastFetchTime,
    this.lastOverallStatus,
  });

  InsightsState copyWith({
    AiInsightModel? insight,
    bool? isLoading,
    String? error,
    SensorsModel? lastAnalyzedSensors,
    DateTime? lastFetchTime,
    String? lastOverallStatus,
  }) {
    return InsightsState(
      insight: insight ?? this.insight,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastAnalyzedSensors: lastAnalyzedSensors ?? this.lastAnalyzedSensors,
      lastFetchTime: lastFetchTime ?? this.lastFetchTime,
      lastOverallStatus: lastOverallStatus ?? this.lastOverallStatus,
    );
  }
}

final insightsProvider = StateNotifierProvider<InsightsNotifier, InsightsState>(
  (ref) {
    final service = ref.watch(groqInsightsServiceProvider); // ✅ Changed
    return InsightsNotifier(service);
  },
);

class InsightsNotifier extends StateNotifier<InsightsState> {
  final GroqInsightsService _service; // ✅ Changed type

  InsightsNotifier(this._service) : super(const InsightsState());

  Future<void> fetchInsight({
    required SensorsModel sensors,
    required SettingsModel settings,
    required String languageCode,
  }) async {
    if (state.isLoading) return;

    final currentStatus = VitalityUtils.getVitalityMessage(sensors, settings);

    state = state.copyWith(isLoading: true, error: null);

    try {
      final insight = await _service.generateInsight(
        sensors: sensors,
        settings: settings,
        languageCode: languageCode,
      );

      state = state.copyWith(
        insight: insight,
        isLoading: false,
        lastAnalyzedSensors: sensors,
        lastFetchTime: DateTime.now(),
        lastOverallStatus: currentStatus,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: $e',
        lastFetchTime: DateTime.now(),
        lastAnalyzedSensors: sensors,
      );
    }
  }

  bool shouldAutoRefresh(SensorsModel current, SettingsModel settings) {
    if (state.lastFetchTime == null || state.lastAnalyzedSensors == null) {
      return true; // First load
    }

    final timeDiff = DateTime.now().difference(state.lastFetchTime!);
    final currentStatus = VitalityUtils.getVitalityMessage(current, settings);

    if (timeDiff.inMinutes < 5) {
      if (currentStatus != state.lastOverallStatus) return true;
      return false;
    }

    final last = state.lastAnalyzedSensors!;

    if (((current.ph ?? 0) - (last.ph ?? 0)).abs() > 0.3) return true;
    if (((current.temperature ?? 0) - (last.temperature ?? 0)).abs() > 2.0)
      return true;
    if (((current.ec ?? 0) - (last.ec ?? 0)).abs() > 0.3) return true;
    if (((current.waterLevel ?? 0) - (last.waterLevel ?? 0)).abs() > 10)
      return true;

    return false;
  }
}
