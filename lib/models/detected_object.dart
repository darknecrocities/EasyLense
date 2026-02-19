import 'package:flutter/material.dart';

/// Risk level for a detected object.
enum RiskLevel { safe, warning, danger }

/// Represents an object detected by the AI inference engine.
class DetectedObject {
  final String name;
  final double distanceMeters;
  final RiskLevel riskLevel;
  final IconData icon;

  const DetectedObject({
    required this.name,
    required this.distanceMeters,
    required this.riskLevel,
    required this.icon,
  });

  /// Human-readable risk label.
  String get riskLabel {
    switch (riskLevel) {
      case RiskLevel.safe:
        return 'Safe';
      case RiskLevel.warning:
        return 'Warning';
      case RiskLevel.danger:
        return 'Danger';
    }
  }

  /// Colour corresponding to the risk level.
  Color get riskColor {
    switch (riskLevel) {
      case RiskLevel.safe:
        return const Color(0xFF4CAF50);
      case RiskLevel.warning:
        return const Color(0xFFFFC107);
      case RiskLevel.danger:
        return const Color(0xFFF44336);
    }
  }

  /// Distance formatted as a short string.
  String get distanceLabel => '${distanceMeters.toStringAsFixed(1)} m';
}
