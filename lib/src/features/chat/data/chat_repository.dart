import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/groq_service.dart';
import '../domain/chat_message_model.dart';

// Provider for the ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  // We can inject GroqService if we make it a provider,
  // or just instantiate it here since it's a simple service.
  // For better testability, making GroqService a provider is better,
  // but following the plan's simplicity:
  return ChatRepository(GroqService());
});

class ChatRepository {
  final GroqService _groqService;

  ChatRepository(this._groqService);

  Future<ChatMessage> sendMessage({
    required List<ChatMessage> history,
    required String message,
    required String languageCode, // 'ar' or 'en'
  }) async {
    final systemPrompt = _getSystemPrompt(languageCode);

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => m.toJson()),
      {'role': 'user', 'content': message},
    ];

    try {
      final responseBody = await _groqService.sendRequest(messages: messages);

      final content =
          responseBody['choices'][0]['message']['content'] as String;

      return ChatMessage(
        role: 'assistant',
        content: content,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  String _getSystemPrompt(String languageCode) {
    if (languageCode.toLowerCase() == 'ar') {
      return "أنت مساعد ذكي لتطبيق زراعة مائية يسمى ريان. مهمتك الإجابة فقط عن أسئلة الزراعة المائية أو الزراعة. إذا سُئلت عن أي موضوع آخر فاعتذر بلطف وارفض الإجابة.";
    } else {
      return "You are a smart assistant for a hydroponic app named Rayyan. You must only answer agriculture or hydroponic-related questions. If asked about anything else, politely apologize and refuse.";
    }
  }
}
