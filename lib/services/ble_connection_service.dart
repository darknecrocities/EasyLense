import 'dart:async';

/// Simulated BLE connection manager for smart glasses.
///
/// Provides mock connect/disconnect functionality with realistic delays.
/// Designed to be swapped with a real Flutter BLE library later.
class BleConnectionService {
  bool _isConnected = false;
  String _deviceName = 'EasyLens Glasses v1';

  bool get isConnected => _isConnected;
  String get deviceName => _deviceName;

  /// Simulate connecting to the smart glasses.
  Future<bool> connect() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    _isConnected = true;
    _deviceName = 'EasyLens Glasses v1';
    return true;
  }

  /// Simulate disconnecting from the smart glasses.
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = false;
  }

  /// Simulate sending data to glasses.
  Future<void> sendCommand(String command) async {
    if (!_isConnected) return;
    await Future.delayed(const Duration(milliseconds: 100));
    // In a real implementation, this would write to a BLE characteristic
  }
}
