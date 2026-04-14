import 'package:camera/camera.dart';

/// Drops all frames except the latest, enforcing a minimum interval.
/// This prevents queue buildup and ensures we always process the freshest data.
class FrameThrottler {
  final int minIntervalMs;
  int _lastProcessedTime = 0;
  bool _isProcessing = false;

  FrameThrottler({this.minIntervalMs = 100}); // ~10 FPS

  /// Returns the frame if it should be processed, null if it should be dropped.
  CameraImage? shouldProcess(CameraImage frame) {
    if (_isProcessing) return null; // Drop: previous frame still being processed

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastProcessedTime < minIntervalMs) return null; // Drop: too soon

    _lastProcessedTime = now;
    return frame;
  }

  void markProcessing() => _isProcessing = true;
  void markDone() => _isProcessing = false;
}
