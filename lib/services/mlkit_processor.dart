import 'dart:ui';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:flutter/foundation.dart';

import '../constants/mlkit_label_map.dart';

/// Lightweight ML Kit result for internal pipeline use.
class MlKitDetection {
  final int? trackingId;
  final Rect boundingBox;
  final String? label;
  final double confidence;

  MlKitDetection({
    this.trackingId,
    required this.boundingBox,
    this.label,
    this.confidence = 0.0,
  });
}

/// Fully native Google ML Kit processor combining:
/// 1. Base Object Detection — bounding boxes + real-time tracking IDs
/// 2. Base Image Labeling — specific semantic labels (Computer, Chair, Dog, etc.)
class MlKitProcessor {
  ObjectDetector? _detector;
  ImageLabeler? _labeler;
  bool _isReady = false;

  // Cache the latest image labels to assign to detected objects smartly
  List<ImageLabel> _cachedLabels = [];
  int _frameCount = 0;

  Future<void> init() async {
    try {
      // 1. Base Object Detection for tight boxes + tracking (no custom model)
      final detectorOptions = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );
      _detector = ObjectDetector(options: detectorOptions);

      // 2. Base Image Labeling for specific semantic names
      final labelerOptions = ImageLabelerOptions(confidenceThreshold: 0.5);
      _labeler = ImageLabeler(options: labelerOptions);

      _isReady = true;
      print('[MLKit] Base Object Detector + Image Labeler initialized natively');
    } catch (e) {
      print('[MLKit] Init failed: $e');
      _isReady = false;
    }
  }

  /// Categorize semantic image labels to align with broad object detection classes.
  String? _matchSemanticLabelToCategory(String baseCategory, List<ImageLabel> semanticLabels, Set<String> usedLabels) {
    final lowerBase = baseCategory.toLowerCase();
    
    // Define category mappings for smart stock label pairing
    const Map<String, List<String>> categoryKeywords = {
      'food': ['food', 'fruit', 'vegetable', 'apple', 'banana', 'pizza', 'sandwich', 'bread', 'cookie', 'cake', 'meal', 'supper', 'lunch'],
      'fashion good': ['clothing', 'fashion', 'dress', 'shorts', 'jacket', 'coat', 'shoe', 'sneakers', 'hat', 'cap', 'beanie', 'scarf', 'jeans', 'denim', 'bag', 'handbag', 'glasses', 'sunglasses'],
      'home good': ['home', 'house', 'chair', 'couch', 'table', 'desk', 'bed', 'sink', 'drawer', 'cabinetry', 'shelf', 'computer', 'laptop', 'television', 'tv', 'refrigerator', 'microwave', 'cup', 'bottle', 'clock', 'book', 'telephone', 'mobile phone'],
      'plant': ['plant', 'flora', 'flower', 'flowerpot', 'garden', 'branch', 'twig', 'petal', 'tree', 'leaf', 'grass'],
      'place': ['building', 'room', 'bathroom', 'kitchen', 'bedroom', 'office', 'classroom', 'hallway'],
    };

    final keywords = categoryKeywords[lowerBase] ?? [];
    
    for (final labelObj in semanticLabels) {
      final labelText = labelObj.label.toLowerCase();
      if (usedLabels.contains(labelText)) continue;

      // Match if the label itself or any part matches the category keywords
      bool matches = keywords.any((kw) => labelText.contains(kw) || kw.contains(labelText));
      if (matches || lowerBase == 'object') {
        usedLabels.add(labelText);
        return labelObj.label;
      }
    }
    return null;
  }

  /// Process a CameraImage and return ML Kit detections with specific labels.
  Future<List<MlKitDetection>> process(CameraImage image, int sensorOrientation) async {
    if (!_isReady || _detector == null) return [];

    try {
      final inputImage = _convertCameraImage(image, sensorOrientation);
      if (inputImage == null) return [];

      // Run Object Detection on every frame (fast, needed for tracking)
      final objects = await _detector!.processImage(inputImage);

      // Run Image Labeling periodically to pull semantic labels from the visual scene
      _frameCount++;
      if (_labeler != null && _frameCount % 4 == 0) {
        final labelInput = _convertCameraImage(image, sensorOrientation);
        if (labelInput != null) {
          _cachedLabels = await _labeler!.processImage(labelInput);
        }
      }

      // Filter out overly generic, "global", or abstract scene labels we don't want
      final Set<String> ignoreLabels = {'place', 'musical instrument', 'event', 'leisure', 'sports', 'room', 'interior design'};
      
      final validSemanticLabels = _cachedLabels.where((l) {
        return !ignoreLabels.contains(l.label.toLowerCase()) && l.confidence > 0.45;
      }).toList();

      final Set<String> usedLabels = {};

      return objects.map((obj) {
        final bool isRotated = sensorOrientation == 90 || sensorOrientation == 270;
        final double portraitW = isRotated ? image.height.toDouble() : image.width.toDouble();
        final double portraitH = isRotated ? image.width.toDouble() : image.height.toDouble();

        final double nx = obj.boundingBox.left / portraitW;
        final double ny = obj.boundingBox.top / portraitH;
        final double nw = obj.boundingBox.width / portraitW;
        final double nh = obj.boundingBox.height / portraitH;

        // 1st Priority: Does Object Detector have a specific, useful classification?
        String baseLabelName = 'Object';
        double bestConf = 0.0;
        
        if (obj.labels.isNotEmpty) {
          final text = MlKitLabelMap.fromText(obj.labels.first.text);
          if (text.toLowerCase() != 'place') { 
            baseLabelName = text;
            bestConf = obj.labels.first.confidence;
          }
        }

        String finalDisplayLabel = baseLabelName;

        // 2nd Priority: Apply smart categorized semantic matching with stock image labeler results
        if (validSemanticLabels.isNotEmpty) {
          final matchedLabel = _matchSemanticLabelToCategory(baseLabelName, validSemanticLabels, usedLabels);
          if (matchedLabel != null) {
            final lowerMatched = matchedLabel.toLowerCase();
            if (lowerMatched == 'person' || lowerMatched == 'man' || lowerMatched == 'woman' || lowerMatched == 'child') {
              finalDisplayLabel = 'Person';
            } else if (baseLabelName == 'Object') {
              finalDisplayLabel = matchedLabel;
            } else {
              // E.g. "Home Good - Laptop"
              finalDisplayLabel = '$baseLabelName - $matchedLabel';
            }
            
            // Average confidences for stability
            final labelConf = validSemanticLabels.firstWhere((l) => l.label == matchedLabel).confidence;
            bestConf = bestConf > 0.0 ? (bestConf + labelConf) / 2.0 : labelConf;
          }
        }

        // Clean formatting
        finalDisplayLabel = finalDisplayLabel.isNotEmpty 
          ? finalDisplayLabel[0].toUpperCase() + finalDisplayLabel.substring(1)
          : 'Object';

        return MlKitDetection(
          trackingId: obj.trackingId,
          boundingBox: Rect.fromLTWH(
            nx.clamp(0.0, 1.0),
            ny.clamp(0.0, 1.0),
            nw.clamp(0.0, 1.0 - nx),
            nh.clamp(0.0, 1.0 - ny),
          ),
          label: finalDisplayLabel,
          confidence: bestConf,
        );
      }).toList();
    } catch (e) {
      print('[MLKit] Process error: $e');
      return [];
    }
  }

  /// Convert CameraImage to InputImage for ML Kit.
  InputImage? _convertCameraImage(CameraImage image, int sensorOrientation) {
    try {
      final Uint8List bytes = _yuvToNv21(image);
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: _rotationFromInt(sensorOrientation),
        format: InputImageFormat.nv21,
        bytesPerRow: image.width,
      );
      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      return null;
    }
  }

  Uint8List _yuvToNv21(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];
    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final numPixels = width * height;
    final nv21 = Uint8List(numPixels + (width * height ~/ 2));

    int idY = 0;
    for (int row = 0; row < height; row++) {
      nv21.setRange(idY, idY + width, yBuffer, row * yPlane.bytesPerRow);
      idY += width;
    }

    final int uvWidth = width ~/ 2;
    final int uvHeight = height ~/ 2;
    final int uPixelStride = uPlane.bytesPerPixel ?? 1;
    final int vPixelStride = vPlane.bytesPerPixel ?? 1;
    final int uRowStride = uPlane.bytesPerRow;
    final int vRowStride = vPlane.bytesPerRow;

    int idUV = numPixels;
    for (int row = 0; row < uvHeight; row++) {
      for (int col = 0; col < uvWidth; col++) {
        nv21[idUV++] = vBuffer[row * vRowStride + col * vPixelStride];
        nv21[idUV++] = uBuffer[row * uRowStride + col * uPixelStride];
      }
    }
    return nv21;
  }

  InputImageRotation _rotationFromInt(int rotation) {
    switch (rotation) {
      case 0: return InputImageRotation.rotation0deg;
      case 90: return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default: return InputImageRotation.rotation0deg;
    }
  }

  void close() {
    _detector?.close();
    _labeler?.close();
    _isReady = false;
  }
}
