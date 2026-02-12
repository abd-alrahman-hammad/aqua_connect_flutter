class EnvironmentConfig {
  static const String _groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  static String get groqApiKey {
    if (_groqApiKey.isEmpty) {
      throw Exception(
        'GROQ_API_KEY is not set. '
        'Please run with --dart-define=GROQ_API_KEY=YOUR_KEY',
      );
    }
    return _groqApiKey;
  }
}
