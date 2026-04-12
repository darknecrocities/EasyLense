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
      print("Gemini API Error: $e");
      return "There was an error connecting to the AI assistant.";
    }
  }
}
