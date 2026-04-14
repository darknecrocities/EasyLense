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
      final labelerOptions = ImageLabelerOptions(confidenceThreshold: 0.6);
      _labeler = ImageLabeler(options: labelerOptions);

      _isReady = true;
      print('[MLKit] Base Object Detector + Image Labeler initialized natively');
    } catch (e) {
      print('[MLKit] Init failed: $e');
      _isReady = false;
    }
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
      if (_labeler != null && _frameCount % 5 == 0) {
        final labelInput = _convertCameraImage(image, sensorOrientation);
        if (labelInput != null) {
          _cachedLabels = await _labeler!.processImage(labelInput);
        }
      }

      // Filter out overly generic, "global", or abstract scene labels we don't want
      final Set<String> ignoreLabels = {'place', 'musical instrument', 'event', 'leisure', 'sports', 'room'};
      
      final validSemanticLabels = _cachedLabels.where((l) {
        return !ignoreLabels.contains(l.label.toLowerCase());
      }).toList();

      // Counter to assign a unique semantic label to each distinct bounding box
      int semanticIndex = 0;

      return objects.map((obj) {
        // ML Kit ALREADY rotates bounding boxes to upright orientation
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
          // Object detector assigns basic categories: Home Good, Fashion Good, Food, Place, Plant
          final text = MlKitLabelMap.fromText(obj.labels.first.text);
          if (text.toLowerCase() != 'place') { // Remove 'Place' completely
            baseLabelName = text;
            bestConf = obj.labels.first.confidence;
          }
        }

        String finalDisplayLabel = baseLabelName;

        // 2nd Priority: Apply distinct specific Image Labeler tags to distinct objects
        if (validSemanticLabels.isNotEmpty) {
          final isGeneric = baseLabelName.toLowerCase() == 'home good' || 
                            baseLabelName.toLowerCase() == 'fashion good' ||
                            baseLabelName.toLowerCase() == 'food' ||
                            baseLabelName.toLowerCase() == 'plant' ||
                            baseLabelName == 'Object';
          
          if (isGeneric && semanticIndex < validSemanticLabels.length) {
            // Assign a UNIQUE specific label to this specific bounding box
            final specificLabel = validSemanticLabels[semanticIndex];
            semanticIndex++; // Increment so the next object gets the next label

            // Format: "Base Category - Specific Name" (e.g., "Home Good - Laptop")
            // Ensure Person is prioritized directly
            final sName = specificLabel.label;
            if (sName.toLowerCase() == 'person') {
              finalDisplayLabel = 'Person';
            } else {
              finalDisplayLabel = '$baseLabelName - $sName';
            }
            
            bestConf = specificLabel.confidence;
          }
        }

        // Final normalization to ensure capitalization is clean
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
