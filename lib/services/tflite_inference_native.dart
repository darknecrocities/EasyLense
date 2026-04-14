import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/detected_object.dart';
import 'mlkit_processor.dart';

/// Native mobile implementation using the Native Google ML Kit Custom Model Pipeline.
class TfliteInferenceService {
  final MlKitProcessor _processor = MlKitProcessor();

  Future<void> init() async {
    await _processor.init();
  }

  Future<List<DetectedObject>> detect({CameraImage? cameraImage, int? sensorOrientation}) async {
    if (cameraImage == null) return [];
    
    // 1. Process with Native ML Kit
    final mlResults = await _processor.process(cameraImage, sensorOrientation ?? 90);
    
    // 2. Map to DetectedObject for the UI
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

  void close() {
    _processor.close();
  }
}
