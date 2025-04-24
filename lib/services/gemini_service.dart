import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Replace with your actual Gemini API key from https://makersuite.google.com/app/apikey
  static String apiKey = 'AIzaSyBS1JWdEsGJq_DNllQkDt065Mt_bmwc6nM';

  final GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiService()
    : _model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(
            HarmCategory.sexuallyExplicit,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.dangerousContent,
            HarmBlockThreshold.medium,
          ),
        ],
      );

  Future<String> sendMessage(String text) async {
    try {
      // Initialize chat session if not already done
      _chatSession ??= _model.startChat();

      // Send message and get response
      final response = await _chatSession!.sendMessage(Content.text(text));

      // Return the response text
      return response.text ?? 'No response generated';
    } catch (e) {
      // Basic error handling
      return 'Error: $e';
    }
  }

  // Reset the chat session
  void resetChat() {
    _chatSession = null;
  }
}
