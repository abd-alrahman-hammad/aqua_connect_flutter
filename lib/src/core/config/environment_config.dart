import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static String get groqApiKey {
    final key = dotenv.env['GROQ_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'GROQ_API_KEY not found in .env file. '
        'Please ensure assets/.env exists and has GROQ_API_KEY=...',
      );
    }
    return key;
  }
}
