import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/aqua_colors.dart';
import '../../../core/widgets/aqua_header.dart';
import '../application/chat_provider.dart';
import '../domain/chat_message_model.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

    final chatState = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Auto-scroll on new messages
    ref.listen(chatProvider, (previous, next) {
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    });

    return Scaffold(
      backgroundColor: isDark
          ? AquaColors.backgroundDark
          : AquaColors.backgroundLight,
      // تمت إزالة SafeArea من هنا للسماح للخلفية بالوصول لأعلى الشاشة
      body: Column(
        children: [
          // تم تغليف الهيدر بحاوية للتحكم في الحافة العلوية (Notch)
          Container(
            color: isDark
                ? AquaColors.backgroundDark
                : AquaColors.backgroundLight,
            padding: EdgeInsets.only(
              // هذا السطر يضيف مسافة بمقدار ارتفاع شريط الحالة فقط
              top: MediaQuery.of(context).padding.top,
            ),
            child: AquaHeader(
              title: AppLocalizations.of(context)!.chatWithRayyan,
              onBack: () => Navigator.of(context).pop(),
            ),
          ),

          Expanded(
            child: chatState.messages.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.askMeAboutHydroponic,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AquaColors.slate500,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      final isUser = message.role == 'user';
                      return _MessageBubble(message: message, isUser: isUser);
                    },
                  ),
          ),

          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(color: AquaColors.primary),
            ),

          if (chatState.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(
                  context,
                )!.errorMessage(chatState.error.toString()),
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // استخدام SafeArea هنا فقط لحماية الجزء السفلي
          SafeArea(
            top: false, // لا نريد التأثير على الجزء العلوي مرة أخرى
            child: _ChatInput(
              controller: _controller,
              isLoading: chatState.isLoading,
              onSend: () {
                final text = _controller.text;
                if (text.trim().isNotEmpty) {
                  ref
                      .read(chatProvider.notifier)
                      .sendMessage(text, languageCode: languageCode);
                  _controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isUser});

  final ChatMessage message;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AquaColors.primary
              : (isDark ? AquaColors.cardDark : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AquaColors.slate200,
                ),
        ),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser
                ? Colors.white
                : (isDark ? Colors.white : AquaColors.slate900),
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AquaColors.backgroundDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AquaColors.slate200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isLoading,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeYourQuestion,
                filled: true,
                fillColor: isDark
                    ? AquaColors.surfaceDark
                    : AquaColors.slate100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: isLoading ? null : onSend,
            style: IconButton.styleFrom(
              backgroundColor: AquaColors.primary,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
