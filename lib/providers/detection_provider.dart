import 'package:flutter/material.dart';
import '../models/detected_object.dart';
import '../services/ai_detection_service.dart';
import '../services/tts_service.dart';
import '../services/nlp_formatter.dart';

/// Manages detection state, triggering scans and TTS announcements.
class DetectionProvider extends ChangeNotifier {
  final AiDetectionService _aiService = AiDetectionService();
  final TtsService ttsService = TtsService();
  final NlpFormatter _nlpFormatter = NlpFormatter();

  List<DetectedObject> _detections = [];
  bool _isScanning = false;
  String _lastInstruction = '';
  String _language = 'en';

  List<DetectedObject> get detections => _detections;
  bool get isScanning => _isScanning;
  String get lastInstruction => _lastInstruction;
  String get language => _language;

  /// Initialise TTS on startup.
  Future<void> init() async {
    await ttsService.init();
  }

  /// Set the language code and update TTS.
  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    await ttsService.setLanguage(langCode);
    notifyListeners();
  }

  /// Perform a single detection scan.
  Future<void> scanEnvironment() async {
    _isScanning = true;
    notifyListeners();

    try {
      _detections = await _aiService.detect();

      // Generate and speak the summary
      final summary = _nlpFormatter.formatSummary(_detections, _language);
      _lastInstruction = summary;
      await ttsService.speak(summary);
    } catch (e) {
      _detections = [];
      _lastInstruction = 'Scan failed';
    }

    _isScanning = false;
    notifyListeners();
  }

  /// Repeat the last spoken instruction.
  Future<void> repeatLastInstruction() async {
    if (_lastInstruction.isNotEmpty) {
      await ttsService.speak(_lastInstruction);
    }
  }

  /// Play emergency alert.
  Future<void> emergencyAlert(String message) async {
    await ttsService.speak(message);
  }

  /// Clear all detections.
  void clearDetections() {
    _detections = [];
    notifyListeners();
  }

  @override
  void dispose() {
    ttsService.dispose();
    super.dispose();
  }
}
