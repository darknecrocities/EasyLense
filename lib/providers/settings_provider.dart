import 'package:flutter/material.dart';
import '../services/ble_connection_service.dart';

/// Manages app-wide settings: language, BLE, edge mode, TTS toggle.
class SettingsProvider extends ChangeNotifier {
  final BleConnectionService _bleService = BleConnectionService();

  String _language = 'en'; // 'en' or 'tl'
  bool _edgeModeActive = true; // Always on in this version
  bool _ttsEnabled = true;
  bool _isConnecting = false;

  String get language => _language;
  bool get edgeModeActive => _edgeModeActive;
  bool get ttsEnabled => _ttsEnabled;
  bool get isConnecting => _isConnecting;
  bool get isBleConnected => _bleService.isConnected;
  String get deviceName => _bleService.deviceName;

  void setLanguage(String langCode) {
    _language = langCode;
    notifyListeners();
  }

  void setTtsEnabled(bool value) {
    _ttsEnabled = value;
    notifyListeners();
  }

  Future<void> toggleBleConnection() async {
    _isConnecting = true;
    notifyListeners();

    if (_bleService.isConnected) {
      await _bleService.disconnect();
    } else {
      await _bleService.connect();
    }

    _isConnecting = false;
    notifyListeners();
  }
}
