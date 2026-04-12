import 'package:flutter/material.dart';

/// A singleton controller that tracks the global rects of active spotlight targets.
/// This decentralizes the coordinate hunting and lets widgets report their own positions.
class SpotlightController extends ChangeNotifier {
  static final SpotlightController _instance = SpotlightController._internal();
  factory SpotlightController() => _instance;
  SpotlightController._internal();

  final Map<String, Rect> _targets = {};

  void updateTarget(String id, Rect rect) {
    if (_targets[id] == rect) return;
    _targets[id] = rect;
    notifyListeners();
  }

  Rect? getTargetRect(String? id) {
    if (id == null) return null;
    return _targets[id];
  }

  void removeTarget(String id) {
    if (_targets.containsKey(id)) {
      _targets.remove(id);
      notifyListeners();
    }
  }
}
