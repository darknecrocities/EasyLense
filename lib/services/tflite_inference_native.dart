import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/detected_object.dart';

/// Native mobile implementation using SSD Object Detection.
/// This engine produces moving bounding boxes for 80-90 common objects.
class TfliteInferenceService {
  static const String _modelPath = 'assets/models/ssd_mobilenet_v2_quantized.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isReady = false;

  Future<void> init() async {
    try {
      final options = InterpreterOptions()..threads = 4; // Multi-threaded inference
      _interpreter = await Interpreter.fromAsset(_modelPath, options: options);
      final raw = await rootBundle.loadString(_labelsPath);
      _labels = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
      _isReady = true;
      print('[Native] SSD Engine ready with 4 threads. Labels: ${_labels.length}');
    } catch (e) {
      print('[Native] SSD Detection init failed: $e');
      _isReady = false;
    }
  }

  Future<List<DetectedObject>> detect({CameraImage? cameraImage}) async {
    if (!_isReady || _interpreter == null || cameraImage == null) {
      return [];
    }
    try {
      // 1. Convert YUV CameraImage → 300x300 RGB byte list (SSD Standard)
      const int targetSize = 300;
      final input = await compute(_convertYUV420ToRGB, {
        'y': cameraImage.planes[0].bytes,
        'u': cameraImage.planes[1].bytes,
        'v': cameraImage.planes[2].bytes,
        'width': cameraImage.width,
        'height': cameraImage.height,
        'yRowStride': cameraImage.planes[0].bytesPerRow,
        'uvRowStride': cameraImage.planes[1].bytesPerRow,
        'uvPixelStride': cameraImage.planes[1].bytesPerPixel ?? 1,
        'targetW': targetSize,
        'targetH': targetSize,
      });

      if (input == null) return [];

      // 2. Prepare SSD Output Tensors (Multi-Output)
      // SSD Mobilenet V2 quant outputs 4 tensors:
      // Index 0: Locations [1, 10, 4]
      // Index 1: Classes [1, 10]
      // Index 2: Scores [1, 10]
      // Index 3: Num Detections [1]
      
      final Map<int, Object> outputMap = {
        0: List.filled(1 * 20 * 4, 0.0).reshape([1, 20, 4]),
        1: List.filled(1 * 20, 0.0).reshape([1, 20]),
        2: List.filled(1 * 20, 0.0).reshape([1, 20]),
        3: List.filled(1, 0.0).reshape([1]),
      };

      // 3. Run inference
      _interpreter!.runForMultipleInputs([input.reshape([1, targetSize, targetSize, 3])], outputMap);

      // 4. Parse Results
      final locations = (outputMap[0] as List<dynamic>)[0] as List<dynamic>;
      final classes = (outputMap[1] as List<dynamic>)[0] as List<dynamic>;
      final scores = (outputMap[2] as List<dynamic>)[0] as List<dynamic>;
      final int count = ((outputMap[3] as List<dynamic>)[0] as double).toInt();

      final List<DetectedObject> results = [];
      for (int i = 0; i < min(count, 20); i++) {
        final double score = (scores[i] as num).toDouble();
        if (score < 0.45) continue; // High confidence threshold for stability

        final int classIdx = (classes[i] as num).toInt();
        if (classIdx >= _labels.length || _labels[classIdx] == '???') continue;

        final String label = _labels[classIdx];
        
        // Locations in SSD are [ymin, xmin, ymax, xmax]
        final List<dynamic> box = locations[i] as List<dynamic>;
        final double ymin = (box[0] as num).toDouble();
        final double xmin = (box[1] as num).toDouble();
        final double ymax = (box[2] as num).toDouble();
        final double xmax = (box[3] as num).toDouble();

        results.add(
          DetectedObject(
            name: label[0].toUpperCase() + label.substring(1),
            distanceMeters: double.parse(((1.0 - score) * 10.0 + 0.5).toStringAsFixed(1)),
            riskLevel: score > 0.8 ? RiskLevel.safe : RiskLevel.warning,
            icon: _iconFor(label),
            boundingBox: Rect.fromLTRB(xmin, ymin, xmax, ymax), // Normalized coordinates
          ),
        );
      }

      return results;
    } catch (e) {
      // If we hit a dimension mismatch, it's likely because the user hasn't 
      // replaced the Classifier model with an SSD model yet.
      print('[Native] Detection failure: $e');
      return [];
    }
  }

  void close() {
    _interpreter?.close();
    _isReady = false;
  }

  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('car') || l.contains('truck') || l.contains('bus') || l.contains('motorcycle')) return Icons.directions_car;
    if (l.contains('person')) return Icons.directions_walk;
    if (l.contains('chair') || l.contains('bench') || l.contains('couch')) return Icons.chair;
    if (l.contains('stair')) return Icons.stairs;
    if (l.contains('bicycle') || l.contains('bike')) return Icons.pedal_bike;
    if (l.contains('door')) return Icons.door_front_door;
    if (l.contains('traffic light')) return Icons.traffic;
    if (l.contains('keyboard') || l.contains('laptop') || l.contains('mouse') || l.contains('tv')) return Icons.devices;
    if (l.contains('bottle') || l.contains('cup') || l.contains('wine glass')) return Icons.local_drink;
    return Icons.warning_amber_rounded;
  }
}

/// Dynamic top-level function for compute() isolate processing.
Uint8List? _convertYUV420ToRGB(Map<String, dynamic> data) {
  try {
    final Uint8List yPlane = data['y'];
    final Uint8List uPlane = data['u'];
    final Uint8List vPlane = data['v'];
    final int width = data['width'];
    final int height = data['height'];
    final int yRowStride = data['yRowStride'];
    final int uvRowStride = data['uvRowStride'];
    final int uvPixelStride = data['uvPixelStride'];
    final int targetW = data['targetW'];
    final int targetH = data['targetH'];

    final rgb = Uint8List(targetW * targetH * 3);
    int idx = 0;

    for (int y = 0; y < targetH; y++) {
      for (int x = 0; x < targetW; x++) {
        final srcX = (x * width / targetW).floor();
        final srcY = (y * height / targetH).floor();

        final yv = yPlane[srcY * yRowStride + srcX];
        final uvIdx = (srcY ~/ 2) * uvRowStride + (srcX ~/ 2) * uvPixelStride;
        final u = uPlane[uvIdx] - 128;
        final v = vPlane[uvIdx] - 128;

        rgb[idx++] = (yv + 1.370705 * v).clamp(0, 255).toInt();
        rgb[idx++] = (yv - 0.698001 * v - 0.337633 * u).clamp(0, 255).toInt();
        rgb[idx++] = (yv + 1.732446 * u).clamp(0, 255).toInt();
      }
    }
    return rgb;
  } catch (e) {
    return null;
  }
}
