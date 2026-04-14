import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'mlkit_processor.dart';
import '../models/detected_object.dart';

/// Manages the incoming camera stream and routes it through ML Kit.
class CameraStreamHandler {
  final MlKitProcessor _processor = MlKitProcessor();
  bool _isInit = false;

  Future<void> init() async {
    if (_isInit) return;
    await _processor.init();
    _isInit = true;
  }

  /// Processes a single frame and returns detections.
  Future<List<DetectedObject>> onFrame(CameraImage image, {int sensorOrientation = 90}) async {
    if (!_isInit) await init();
    final mlResults = await _processor.process(image, sensorOrientation);
    return mlResults.map<DetectedObject>((ml) {
      return DetectedObject(
        name: ml.label ?? 'Object',
        distanceMeters: 15.0,
        riskLevel: RiskLevel.safe,
        icon: Icons.visibility,
        boundingBox: ml.boundingBox,
        trackingId: ml.trackingId,
        confidence: ml.confidence,
        source: 'mlkit',
      );
    }).toList();
  }

  void dispose() {
    _processor.close();
    _isInit = false;
  }
}
