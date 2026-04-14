import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/detected_object.dart';
import '../services/ai_detection_service.dart';
import '../services/tts_service.dart';
import '../services/nlp_formatter.dart';
import '../services/hazard_mapper.dart';

/// Manages detection state, triggering scans and TTS announcements.
class DetectionProvider extends ChangeNotifier {
  final AiDetectionService _aiService = AiDetectionService();
  final TtsService ttsService = TtsService();
  final NlpFormatter _nlpFormatter = NlpFormatter();

  List<DetectedObject> _detections = [];
  bool _isScanning = false;
  String _lastInstruction = '';
  String _language = 'en';

  // Cumulative metrics
  int _totalScans = 0;
  int _totalObjects = 0;
  int _totalAlerts = 0;

  List<DetectedObject> get detections => _detections;
  bool get isScanning => _isScanning;
  String get lastInstruction => _lastInstruction;
  String get language => _language;
  int get totalScans => _totalScans;
  int get totalObjects => _totalObjects;
  int get totalAlerts => _totalAlerts;

  /// Initialise TTS on startup.
  Future<void> init() async {
    await ttsService.init();
    await _aiService.init();
    await HazardMapper.init(); // Load hazards mapping JSON
  }

  /// Set the language code and update TTS.
  Future<void> setLanguage(String langCode) async {
    _language = langCode;
    await ttsService.setLanguage(langCode);
    notifyListeners();
  }

  /// Perform a single detection scan.
  Future<void> scanEnvironment({CameraImage? cameraImage, int? sensorOrientation}) async {
    _isScanning = true;
    notifyListeners();

    try {
      _detections = await _aiService.detect(
        cameraImage: cameraImage, 
        sensorOrientation: sensorOrientation,
      );
      
      _totalScans += 1;
      _totalObjects += _detections.length;
      _totalAlerts += _detections.where((d) => d.riskLevel != RiskLevel.safe).length;

      // Generate the summary for UI, but don't speak automatically to reduce lag/noise
      final summary = _nlpFormatter.formatSummary(_detections, _language);
      _lastInstruction = summary;
      // await ttsService.speak(summary); // Disabled on user request to reduce lag
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
    _aiService.dispose();
    ttsService.dispose();
    super.dispose();
  }
}
