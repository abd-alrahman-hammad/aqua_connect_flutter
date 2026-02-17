import 'dart:ui';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../core/services/groq_service.dart';
import '../../../core/models/hydroponic/sensors_model.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../../../core/utils/vitality_utils.dart';
import '../domain/ai_insight_model.dart';

final insightsRepositoryProvider = Provider<GroqInsightsService>((ref) {
  return GroqInsightsService(GroqService());
});

class GroqInsightsService {
  final GroqService _groqService;

  GroqInsightsService(this._groqService);

  Future<AiInsightModel> generateInsight({
    required SensorsModel sensors,
    required SettingsModel settings,
    required String languageCode,
  }) async {
    final loc = lookupAppLocalizations(Locale(languageCode.toLowerCase()));

    final statusMessage = VitalityUtils.getVitalityMessage(
      sensors,
      settings,
      loc,
    );
    final waterStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getWaterLevelStatus(sensors.waterLevel),
      loc,
    );
    final tempStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getTemperatureStatus(sensors.temperature, settings),
      loc,
    );
    final phStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getPhStatus(sensors.ph, settings),
      loc,
    );
    final ecStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getEcStatus(sensors.ec, settings),
      loc,
    );

    final prompt =
        '''
Analyze these hydroponic system readings and provide insights.

Context:
- System Status: $statusMessage
- Water Level: ${sensors.waterLevel ?? '--'}% ($waterStatus)
- Temperature: ${sensors.temperature ?? '--'}°C ($tempStatus) (Target: ${settings.tempLow}-${settings.tempHigh}°C)
- pH: ${sensors.ph ?? '--'} ($phStatus) (Target: ${settings.phLow}-${settings.phHigh})
- EC: ${sensors.ec ?? '--'} mS/cm ($ecStatus) (Target: ${settings.ecLow}-${settings.ecHigh} mS/cm)

Output the values of the JSON in ${languageCode == 'AR' ? 'Arabic' : 'English'} based on languageCode. 
Strictly keep the JSON keys (analysis, action_required, daily_tip) in English.
Return ONLY valid JSON with no extra text, no markdown, no code blocks.

JSON Schema:
{
  "analysis": "Brief analysis of current plant health and system status.",
  "action_required": "Specific actionable step to fix any issues or 'None' if optimal.",
  "daily_tip": "A general hydroponic tip relevant to current conditions."
}
''';

    try {
      final messages = [
        {
          'role': 'system',
          'content':
              'You are a hydroponic system expert. Always respond with valid JSON only, no extra text.',
        },
        {'role': 'user', 'content': prompt},
      ];

      final responseBody = await _groqService.sendRequest(
        messages: messages,
        jsonMode: true,
        model: "llama-3.3-70b-versatile",
      );

      final content =
          responseBody['choices'][0]['message']['content'] as String;

      final cleanedJson = _cleanJson(content);
      return AiInsightModel.fromJson(_parseJson(cleanedJson));
    } catch (e) {
      throw Exception('Failed to generate insights: $e');
    }
  }

  String _cleanJson(String raw) {
    var s = raw.trim();
    if (s.startsWith('```json')) {
      s = s.substring(7);
    } else if (s.startsWith('```')) {
      s = s.substring(3);
    }
    if (s.endsWith('```')) {
      s = s.substring(0, s.lastIndexOf('```'));
    }
    return s.trim();
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException(
        'Failed to parse AI response: $e\nResponse was: $jsonString',
      );
    }
  }
}
