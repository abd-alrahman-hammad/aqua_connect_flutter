import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/hydroponic/sensors_model.dart';
import '../../../core/models/hydroponic/settings_model.dart';
import '../../../core/utils/vitality_utils.dart';
import '../domain/ai_insight_model.dart';

import '../../../core/config/environment_config.dart';

const _groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';

// Free models available on Groq (pick one):
// - llama-3.3-70b-versatile   (best quality, still free)
// - llama3-8b-8192             (faster, lighter)
// - gemma2-9b-it               (Google Gemma, good alternative)
const _modelName = 'llama-3.3-70b-versatile';

final groqInsightsServiceProvider = Provider<GroqInsightsService>((ref) {
  return GroqInsightsService();
});

class GroqInsightsService {
  Future<AiInsightModel> generateInsight({
    required SensorsModel sensors,
    required SettingsModel settings,
    required String languageCode,
  }) async {
    final statusMessage = VitalityUtils.getVitalityMessage(sensors, settings);
    final waterStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getWaterLevelStatus(sensors.waterLevel),
    );
    final tempStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getTemperatureStatus(sensors.temperature, settings),
    );
    final phStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getPhStatus(sensors.ph, settings),
    );
    final ecStatus = VitalityUtils.getStatusLabel(
      VitalityUtils.getEcStatus(sensors.ec, settings),
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
      final response = await http.post(
        Uri.parse(_groqApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${EnvironmentConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a hydroponic system expert. Always respond with valid JSON only, no extra text.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'max_tokens': 500,
          // Force JSON output (supported by Groq)
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Groq API error ${response.statusCode}: ${errorBody['error']?['message'] ?? response.body}',
        );
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          responseBody['choices'][0]['message']['content'] as String;

      final cleanedJson = _cleanJson(content);
      return AiInsightModel.fromJson(_parseJson(cleanedJson));
    } on http.ClientException catch (e) {
      throw Exception('Network error: $e');
    } catch (e) {
      rethrow;
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
