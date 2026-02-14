import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment_config.dart';

class GroqService {
  final http.Client _client;
  final String _apiKey;

  GroqService({http.Client? client})
    : _client = client ?? http.Client(),
      _apiKey = EnvConfig.groqApiKey;

  Future<Map<String, dynamic>> sendRequest({
    required List<Map<String, dynamic>> messages,
    bool jsonMode = false,
    String model = "llama-3.3-70b-versatile",
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      };

      final body = {
        'model': model,
        'messages': messages,
        'temperature': 0.7,
        if (jsonMode) 'response_format': {'type': 'json_object'},
      };

      final response = await _client.post(
        Uri.parse(EnvConfig.groqBaseUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Groq API error ${response.statusCode}: ${errorBody['error']?['message'] ?? response.body}',
        );
      }

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      return responseBody;
    } catch (e) {
      throw Exception('Failed to perform Groq request: $e');
    }
  }

  // Deprecated: use sendRequest instead
  Future<Map<String, dynamic>> performRequest({
    required List<Map<String, dynamic>> messages,
    bool jsonMode = false,
    String model = "llama-3.3-70b-versatile",
  }) => sendRequest(messages: messages, jsonMode: jsonMode, model: model);
}
