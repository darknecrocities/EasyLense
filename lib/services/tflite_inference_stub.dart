import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/detected_object.dart';

/// Web stub: returns mocked detections with random bounding boxes.
/// On the web platform TFLite C++ bindings cannot execute.
class TfliteInferenceService {
  final _random = Random();

  static const List<_Def> _pool = [
    _Def('Stairs', Icons.stairs, 0.5, 4.0, RiskLevel.warning),
    _Def('Vehicle', Icons.directions_car, 1.0, 8.0, RiskLevel.danger),
    _Def('Pedestrian', Icons.directions_walk, 0.3, 6.0, RiskLevel.warning),
    _Def('Crosswalk', Icons.swap_calls, 1.0, 5.0, RiskLevel.safe),
    _Def('Obstacle', Icons.warning_amber_rounded, 0.2, 3.0, RiskLevel.danger),
    _Def('Door', Icons.door_front_door, 1.0, 5.0, RiskLevel.safe),
    _Def('Chair', Icons.chair, 0.5, 4.0, RiskLevel.safe),
  ];

  Future<void> init() async {
    print('[Web] TFLite not supported in browser — mock inference active.');
  }

  Future<List<DetectedObject>> detect({CameraImage? cameraImage}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final count = _random.nextInt(4); // 0-3 objects
    final shuffled = List<_Def>.from(_pool)..shuffle(_random);
    return shuffled.take(count).map((d) {
      final dist = d.minDist + _random.nextDouble() * (d.maxDist - d.minDist);
      final w = 0.15 + _random.nextDouble() * 0.40;
      final h = 0.20 + _random.nextDouble() * 0.40;
      final l = _random.nextDouble() * (1.0 - w);
      final t = _random.nextDouble() * (1.0 - h);
      return DetectedObject(
        name: d.name,
        distanceMeters: double.parse(dist.toStringAsFixed(1)),
        riskLevel: d.riskLevel,
        icon: d.icon,
        boundingBox: Rect.fromLTWH(l, t, w, h),
      );
    }).toList();
  }

  void close() {
    // No-op for web stub.
  }
}

class _Def {
  final String name;
  final IconData icon;
  final double minDist;
  final double maxDist;
  final RiskLevel riskLevel;
  const _Def(this.name, this.icon, this.minDist, this.maxDist, this.riskLevel);
}
