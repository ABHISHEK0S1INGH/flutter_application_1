import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'controllers/gemini_controller.dart';
import 'controllers/speech_controller.dart';
import 'controllers/theme_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get controller instances using GetX dependency injection
    final GeminiController geminiController = Get.find<GeminiController>();
    final SpeechController speechController = Get.find<SpeechController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final TextEditingController textController = TextEditingController();
    final FocusNode focusNode = FocusNode();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gemini'),
        actions: [
          // Theme toggle button
          Obx(
            () => IconButton(
              icon: Icon(
                themeController.isDarkMode.value
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color:
                    themeController.isDarkMode.value
                        ? Colors.amber
                        : Colors.indigo,
              ),
              tooltip:
                  themeController.isDarkMode.value
                      ? 'Switch to Light Mode'
                      : 'Switch to Dark Mode',
              onPressed: themeController.toggleTheme,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => geminiController.resetChat(),
            tooltip: 'Clear conversation',
          ),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages area - using Obx for reactive UI updates
          Expanded(
            child: Obx(
              () =>
                  geminiController.messages.isEmpty
                      ? _buildWelcomeScreen(context, geminiController)
                      : _buildMessageList(geminiController),
            ),
          ),

          // Typing indicator
          Obx(
            () =>
                geminiController.isTyping.value
                    ? _buildTypingIndicator(context)
                    : const SizedBox.shrink(),
          ),

          // Input field
          _buildInputField(
            context,
            textController,
            focusNode,
            geminiController,
            speechController,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen(
    BuildContext context,
    GeminiController controller,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE8F0FE),
              child: Icon(
                Icons.auto_awesome,
                size: 40,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hello, I\'m Gemini',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'How can I help you today?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildSuggestionChips(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(
    BuildContext context,
    GeminiController controller,
  ) {
    final suggestions = [
      "Write a poem about the ocean",
      "Tell me about black holes",
      "Help me plan a trip to Tokyo",
      "Create a workout routine",
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children:
          suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              onPressed: () => controller.sendMessage(suggestion),
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMessageList(GeminiController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      reverse: true,
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message =
            controller.messages[controller.messages.length - 1 - index];
        return _ChatMessageWidget(message: message);
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 16,
            child: const Icon(
              Icons.auto_awesome,
              size: 18,
              color: Color(0xFF1A73E8),
            ),
          ),
          const SizedBox(width: 16),
          const _LoadingDots(),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context,
    TextEditingController textController,
    FocusNode focusNode,
    GeminiController geminiController,
    SpeechController speechController,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText:
                      speechController.isListening.value
                          ? 'Listening...'
                          : 'Message Gemini...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  suffixIcon: Obx(
                    () => IconButton(
                      icon: Icon(
                        speechController.isListening.value
                            ? Icons.mic
                            : Icons.mic_none,
                        color:
                            speechController.isListening.value
                                ? Theme.of(context).colorScheme.primary
                                : null,
                      ),
                      onPressed:
                          () => _handleVoiceInput(
                            context,
                            textController,
                            geminiController,
                            speechController,
                          ),
                    ),
                  ),
                ),
                onSubmitted: (text) {
                  geminiController.sendMessage(text);
                  textController.clear();
                  focusNode.requestFocus();
                },
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                geminiController.sendMessage(textController.text);
                textController.clear();
                focusNode.requestFocus();
              }
            },
            mini: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _handleVoiceInput(
    BuildContext context,
    TextEditingController textController,
    GeminiController geminiController,
    SpeechController speechController,
  ) async {
    bool success = await speechController.toggleListening();

    if (success && speechController.isListening.value) {
      _showVoiceInputDialog(
        context,
        textController,
        geminiController,
        speechController,
      );
    }
  }

  void _showVoiceInputDialog(
    BuildContext context,
    TextEditingController textController,
    GeminiController geminiController,
    SpeechController speechController,
  ) {
    Get.dialog(
      barrierDismissible: false,
      Obx(
        () => AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AvatarGlow(
                  animate: speechController.isListening.value,
                  glowColor: Theme.of(context).colorScheme.primary,
                  glowRadiusFactor: 0.7,
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    radius: 40,
                    child: Icon(
                      speechController.isListening.value
                          ? Icons.mic
                          : Icons.mic_none,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  speechController.isListening.value
                      ? 'Listening...'
                      : 'Voice input paused',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      speechController.recognizedText.value.isEmpty
                          ? 'Say something...'
                          : speechController.recognizedText.value,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            speechController.recognizedText.value.isEmpty
                                ? Theme.of(context).hintColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => speechController.clearRecognizedText(),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (speechController.isListening.value) {
                          await speechController.stopListening();
                        } else {
                          Get.back(); // Close dialog
                          if (speechController
                              .recognizedText
                              .value
                              .isNotEmpty) {
                            textController.text =
                                speechController.recognizedText.value;
                            geminiController.sendMessage(
                              speechController.recognizedText.value,
                            );
                            speechController.clearRecognizedText();
                          }
                        }
                      },
                      icon: Icon(
                        speechController.isListening.value
                            ? Icons.stop
                            : Icons.send,
                      ),
                      label: Text(
                        speechController.isListening.value ? 'Stop' : 'Send',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  _LoadingDotsState createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.33;
            final sinValue = ((_controller.value + delay) % 1.0) * 3.14;
            final size = 6.0 + 2.0 * (sinValue > 1.57 ? 1.0 : sin(sinValue));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

class _ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const _ChatMessageWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              radius: 18,
              child: const Icon(
                Icons.auto_awesome,
                size: 20,
                color: Color(0xFF1A73E8),
              ),
            ),
            const SizedBox(width: 8.0),
          ],
          if (message.isUser) const Spacer(),
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                // Change user message background to a darker blue for better visibility
                color:
                    message.isUser
                        ? const Color(
                          0xFF1A73E8,
                        ) // Darker blue color for user messages
                        : themeData.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child:
                  message.isUser
                      ? Text(
                        message.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w500, // Make text slightly bolder
                        ),
                      )
                      : MarkdownBody(
                        data: message.text,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                            color: themeData.colorScheme.onSurfaceVariant,
                          ),
                          code: TextStyle(
                            backgroundColor: themeData
                                .colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.5),
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: themeData.colorScheme.surfaceContainerHighest
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
            ),
          ),
          if (!message.isUser) const Spacer(),
          if (message.isUser) ...[
            const SizedBox(width: 8.0),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(
                0xFF1A73E8,
              ), // Match with the message bubble
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
