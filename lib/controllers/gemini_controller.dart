import 'package:get/get.dart';
import '../services/gemini_service.dart';

class GeminiController extends GetxController {
  final GeminiService _geminiService = GeminiService();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isListening = false.obs;
  final RxString recognizedText = ''.obs;

  // Send message to Gemini API
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(text: text, isUser: true));
    isTyping.value = true;

    try {
      // Get response from Gemini API
      final response = await _geminiService.sendMessage(text);

      isTyping.value = false;
      messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      isTyping.value = false;
      messages.add(
        ChatMessage(
          text: "Sorry, I encountered an error: ${e.toString()}",
          isUser: false,
        ),
      );
    }
  }

  // Reset the chat
  void resetChat() {
    messages.clear();
    _geminiService.resetChat();
  }

  // Update recognized text from speech recognition
  void updateRecognizedText(String text) {
    recognizedText.value = text;
  }

  // Set listening state
  void setListening(bool listening) {
    isListening.value = listening;
  }
}

// Chat message data model
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessage({required this.text, required this.isUser, this.isError = false});
}
