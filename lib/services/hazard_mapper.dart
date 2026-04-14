import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/detected_object.dart';

class HazardInfo {
  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;
  final Color color;

  const HazardInfo({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
    this.color = const Color(0xFFFFC107),
  });
}

class HazardMapper {
  static Map<String, dynamic>? _config;
  static const String _configPath = 'assets/models/hazards_config.json';

  /// Loads the hazard configuration from JSON.
  static Future<void> init() async {
    try {
      final String response = await rootBundle.loadString(_configPath);
      _config = json.decode(response);
      print('[HazardMapper] Configuration loaded successfully.');
    } catch (e) {
      print('[HazardMapper] Failed to load config: $e');
    }
  }

  /// Maps a list of detected objects to a dominant HazardInfo state.
  static HazardInfo map(List<DetectedObject> detections) {
    if (_config == null) {
       return _fallbackMapping(detections);
    }

    if (detections.isEmpty) {
      final clear = _config!['clear'];
      return HazardInfo(
        title: clear['title'],
        description: clear['description'],
        imagePath: clear['imagePath'],
        icon: _getIcon(clear['icon']),
        color: const Color(0xFF4CAF50),
      );
    }

    final topDetection = detections.first;
    final name = topDetection.name.toLowerCase();

    // Search for a matching mapping in the JSON
    final List<dynamic> mappings = _config!['mappings'];
    for (var mapping in mappings) {
      final List<dynamic> labels = mapping['labels'];
      if (labels.any((l) => name.contains(l.toLowerCase()))) {
        return HazardInfo(
          title: mapping['title'],
          description: mapping['description'],
          imagePath: mapping['imagePath'],
          icon: _getIcon(mapping['icon']),
          color: mapping['title'] == 'STOP!' ? const Color(0xFFF44336) : const Color(0xFFFFC107),
        );
      }
    }

    // Default Fallback
    return HazardInfo(
      title: 'Hazard',
      description: 'Obstacle approaching. Proceed slowly.',
      icon: topDetection.icon,
    );
  }

  static HazardInfo _fallbackMapping(List<DetectedObject> detections) {
     if (detections.isEmpty) {
      return const HazardInfo(
        title: 'Path Clear',
        description: 'No hazards detected nearby.',
        icon: Icons.check_circle_outline,
        color: Color(0xFF4CAF50),
      );
    }
    final top = detections.first;
    return HazardInfo(
      title: 'Hazard',
      description: 'Obstacle detected ${top.distanceMeters}m away.',
      icon: top.icon,
    );
  }

  static IconData _getIcon(String? name) {
    switch (name) {
      case 'check_circle_outline': return Icons.check_circle_outline;
      case 'directions_car': return Icons.directions_car;
      case 'directions_walk': return Icons.directions_walk;
      case 'front_hand': return Icons.front_hand;
      case 'stairs': return Icons.stairs;
      case 'category': return Icons.category;
      case 'warning': return Icons.warning;
      case 'brightness_4': return Icons.brightness_4;
      case 'pause_circle_filled': return Icons.pause_circle_filled;
      default: return Icons.warning_amber_rounded;
    }
  }
}
