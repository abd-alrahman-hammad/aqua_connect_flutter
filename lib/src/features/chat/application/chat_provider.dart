import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/chat_message_model.dart';
import '../data/chat_repository.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatState({required this.messages, this.isLoading = false, this.error});

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final String
  _languageCode; // In a real app this might come from a settings provider

  ChatNotifier(this._repository, this._languageCode)
    : super(ChatState(messages: []));

  Future<void> sendMessage(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;

    final lang = languageCode ?? _languageCode;

    final userMessage = ChatMessage(
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    // Optimistically add user message
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final response = await _repository.sendMessage(
        history: state.messages.sublist(0, state.messages.length - 1),
        message: text,
        languageCode: lang,
      );

      state = state.copyWith(
        messages: [...state.messages, response],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// We need a provider that somehow knows the language code.
// For now, we'll default to 'en' or try to read it if possible,
// but since the requirement is "The assistant can remain stateless...",
// we'll assume we can pass it or read it from a global setting.
// The prompt says: "The system text should automatically change based on the application language (Arabic or English)"
// This implies we need access to the locale.

final chatProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>((
  ref,
) {
  final repository = ref.watch(chatRepositoryProvider);
  // Ideally verify referencing localization/settings provider.
  // For this implementation, I will default to 'en' but provide a way to set it,
  // or assume the UI will handle it?
  // Let's check existing code for language settings.
  // I saw 'SettingsModel' in 'groq_insights_service.dart'.
  // I will check if there is a 'settingsProvider' I can watch.

  // For now, hardcode to 'en' as default, but in the ChatScreen we can initialize/update it.
  // Better yet, I'll check for a settings provider in a moment.
  return ChatNotifier(repository, 'en');
});
