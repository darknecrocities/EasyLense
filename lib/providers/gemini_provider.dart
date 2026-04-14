import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/gemini_service.dart';
import '../services/tts_service.dart';

/// Manages the real-time interaction loop for the Gemini AI Assistant.
class GeminiProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final TtsService _ttsService = TtsService();
  final SpeechToText _speechToText = SpeechToText();

  bool _isActive = false;
  bool _isListening = false;
  bool _isProcessing = false;
  
  String _spokenText = '';

  bool get isActive => _isActive;
  bool get isListening => _isListening;
  bool get isProcessing => _isProcessing;
  String get spokenText => _spokenText;

  CameraController? _cameraController;
  Timer? _speechTimeoutTimer;

  bool _mounted = true;

  Future<void> init() async {
    _geminiService.init();
    await _ttsService.init();
    await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: (val) {
        if (_isActive && mountedCheck()) _startListening(); // Recover on silent errors
      },
    );
  }

  void setCameraController(CameraController? controller) {
    _cameraController = controller;
  }

  bool mountedCheck() {
    return _mounted;
  }

  @override
  void dispose() {
    _mounted = false;
    _speechTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> toggleGemini() async {
    _isActive = !_isActive;
    notifyListeners();

    if (_isActive) {
      _speechToText.stop();
      await _ttsService.speak('Gemini is active. What would you like to know?');
      // Briefly wait for TTS to finish before opening the mic
      await Future.delayed(const Duration(seconds: 3));
      if (_isActive) await _startListening();
    } else {
      await _speechToText.stop();
      _isListening = false;
      _isProcessing = false;
      notifyListeners();
      await _ttsService.speak('Gemini deactivated.');
    }
  }

  Future<void> _startListening() async {
    if (!_isActive || _isProcessing) return;
    
    _isListening = true;
    _spokenText = '';
    notifyListeners();

    _speechTimeoutTimer?.cancel();
    
    await _speechToText.listen(
      onResult: (result) {
        _spokenText = result.recognizedWords;
        if (result.finalResult && _isActive && !_isProcessing) {
          _processInteraction();
        }
      },
    );
  }

  void _onSpeechStatus(String status) {
    if (status == 'notListening') {
      if (_isListening && _spokenText.isNotEmpty && _isActive && !_isProcessing) {
        // Fallback trigger if result.finalResult wasn't raised
        _processInteraction();
      } else if (_isListening && _spokenText.isEmpty && _isActive && !_isProcessing) {
        // They didn't say anything, restart listening
        _startListening();
      }
    }
  }

  Future<void> _processInteraction() async {
    if (!_isActive || _isProcessing || _spokenText.isEmpty) return;

    _isProcessing = true;
    _isListening = false;
    notifyListeners();

    try {
      await _speechToText.stop();

      // 1. Take a picture
      if (_cameraController == null) throw Exception("Camera not connected");
      final imageFile = await _cameraController!.takePicture();
      final imageBytes = await imageFile.readAsBytes();

      // 2. Send to Gemini
      final response = await _geminiService.analyzeScene(imageBytes, _spokenText);

      // 3. Speak the results!
      await _ttsService.speak(response);
      
      // Wait for TTS to finish reading the answer (roughly based on length)
      await Future.delayed(Duration(seconds: (response.length / 15).ceil().clamp(2, 10)));

    } catch (e) {
      print("Gemini Conversation Error: $e");
      // Only speak a fallback if it wasn't a handled response already
      await _ttsService.speak("Oops, I encountered a connection issue. Let's try again in a moment.");
      await Future.delayed(const Duration(seconds: 3)); // Error cooldown
    } finally {
      if (_mounted) {
          _isProcessing = false;
          notifyListeners();
          
          // 4. Loop back to listening!
          if (_isActive) {
            // Briefly wait after any interaction (success or failure) to let user breathe
            await Future.delayed(const Duration(seconds: 1));
            await _startListening();
          }
      }
    }
  }
}
