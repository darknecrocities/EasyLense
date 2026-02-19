import 'dart:math';
import 'package:flutter/material.dart';
import '../models/detected_object.dart';
import '../constants/app_constants.dart';

/// Simulated local AI inference service.
///
/// Returns randomised subsets of common urban objects with risk levels.
/// Designed to be swapped with a real TensorFlow Lite model later.
class AiDetectionService {
  final _random = Random();

  /// Available object definitions for mock detection.
  static const List<_MockObjectDef> _objectPool = [
    _MockObjectDef('Stairs', Icons.stairs, 0.5, 4.0),
    _MockObjectDef('Vehicle', Icons.directions_car, 1.0, 8.0),
    _MockObjectDef('Pedestrian', Icons.directions_walk, 0.3, 6.0),
    _MockObjectDef('Crosswalk', Icons.swap_calls, 1.0, 5.0),
    _MockObjectDef('Obstacle', Icons.warning_amber_rounded, 0.2, 3.0),
  ];

  /// Perform a simulated detection scan.
  ///
  /// Returns 1-4 random objects with varying distances and risk levels.
  /// Simulates ~200ms inference latency.
  Future<List<DetectedObject>> detect() async {
    // Simulate inference latency
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(100)));

    final count = 1 + _random.nextInt(4); // 1 to 4 objects
    final shuffled = List<_MockObjectDef>.from(_objectPool)..shuffle(_random);

    return shuffled.take(count).map((def) {
      final distance =
          def.minDist + _random.nextDouble() * (def.maxDist - def.minDist);
      final risk = _riskFromDistance(distance);

      return DetectedObject(
        name: def.name,
        distanceMeters: double.parse(distance.toStringAsFixed(1)),
        riskLevel: risk,
        icon: def.icon,
      );
    }).toList();
  }

  RiskLevel _riskFromDistance(double distance) {
    if (distance < 1.5) return RiskLevel.danger;
    if (distance < 3.5) return RiskLevel.warning;
    return RiskLevel.safe;
  }
}

class _MockObjectDef {
  final String name;
  final IconData icon;
  final double minDist;
  final double maxDist;

  const _MockObjectDef(this.name, this.icon, this.minDist, this.maxDist);
}
