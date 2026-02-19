import 'package:flutter_tts/flutter_tts.dart';

/// Text-to-Speech service supporting English and Filipino.
class TtsService {
  final FlutterTts _tts = FlutterTts();
  String _currentLanguage = 'en-US';
  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;
  String get currentLanguage => _currentLanguage;

  /// Initialise TTS engine with default settings.
  Future<void> init() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setLanguage(_currentLanguage);
  }

  /// Switch between English (en-US) and Filipino (fil-PH).
  Future<void> setLanguage(String langCode) async {
    if (langCode == 'en') {
      _currentLanguage = 'en-US';
    } else if (langCode == 'tl') {
      _currentLanguage = 'fil-PH';
    }
    await _tts.setLanguage(_currentLanguage);
  }

  /// Speak the given text aloud.
  Future<void> speak(String text) async {
    if (!_isEnabled) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  /// Stop any ongoing speech.
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Toggle TTS on or off.
  void setEnabled(bool value) {
    _isEnabled = value;
    if (!value) {
      _tts.stop();
    }
  }

  /// Clean up resources.
  void dispose() {
    _tts.stop();
  }
}
