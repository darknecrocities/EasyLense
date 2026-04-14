import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Service to handle interaction with Google's Gemini SDK.
class GeminiService {
  late final GenerativeModel _model;
  bool _isInit = false;

  /// Initializes the model using the GEMINI key from .env
  void init() {
    if (_isInit) return;
    
    final apiKey = dotenv.env['GEMINI'];
    if (apiKey == null || apiKey.isEmpty) {
      print('WARNING: GEMINI API key not found in .env');
      return;
    }

    _model = GenerativeModel(
      // Using the exact model you requested
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: apiKey,
    );
    _isInit = true;
  }

  /// Sends the photo and the user's spoken prompt to Gemini,
  /// requesting a short, helpful breakdown for a visually impaired user.
  Future<String> analyzeScene(Uint8List imageBytes, String userPrompt) async {
    if (!_isInit) {
      return "Gemini service is not initialized. Please check your API key.";
    }

    int retries = 0;
    const maxRetries = 3;
    
    while (retries <= maxRetries) {
      try {
        final textPart = TextPart(
          "You are an AI assistant for a visually impaired user. "
          "The user asked: '$userPrompt'. "
          "Based on the attached image from their smart glasses, provide a "
          "very concise, direct, and helpful answer. Keep it under 2 sentences.",
        );
        final imagePart = DataPart('image/jpeg', imageBytes);

        final response = await _model.generateContent([
          Content.multi([textPart, imagePart])
        ]);

        return response.text ?? "I'm sorry, I couldn't process the image right now.";
      } catch (e) {
        final errorStr = e.toString();
        
        // Check for 503 - Service Unavailable (High Demand)
        if (errorStr.contains('503') || errorStr.contains('high demand')) {
          if (retries < maxRetries) {
            retries++;
            // Exponential backoff: 1s, 2s, 4s...
            final delay = Duration(seconds: (1 << (retries - 1)));
            print("[Gemini] Server Busy (503). Retrying in ${delay.inSeconds}s... (Attempt $retries)");
            await Future.delayed(delay);
            continue;
          }
          return "The AI assistant is temporarily very busy due to high demand. Please try again in a few moments.";
        }

        print("Gemini API Error: $e");
        return "There was an error connecting to the AI assistant.";
      }
    }
    return "There was an error connecting to the AI assistant.";
  }
}
