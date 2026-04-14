import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/detected_object.dart';
import '../constants/app_constants.dart';

// Conditional platform import:
// On Web → tflite_inference_stub.dart (pure Dart mock, no FFI)
// On Android/iOS → tflite_inference_native.dart (real TFLite interpreter)
import 'tflite_inference_stub.dart'
    if (dart.library.io) 'tflite_inference_native.dart';

/// Coordinator service that delegates to the correct platform inference engine.
class AiDetectionService {
  static const String mobileNetModelPath = 'assets/models/mobilenet_v2_quantized.tflite';
  static const String geminiModel        = 'gemini-3.1-flash-lite-preview';

  final _engine = TfliteInferenceService();

  Future<void> init() => _engine.init();

  Future<List<DetectedObject>> detect({CameraImage? cameraImage, int? sensorOrientation}) => 
      _engine.detect(cameraImage: cameraImage, sensorOrientation: sensorOrientation);

  Future<void> dispose() async {
    // Both native and stub engines should implement close/cleanup logic if needed.
    // In our case, the native engine uses .close() on the interpreter.
    try {
      if (identical(_engine.runtimeType, TfliteInferenceService)) {
        (_engine as dynamic).close();
      }
    } catch (_) {}
  }
}
