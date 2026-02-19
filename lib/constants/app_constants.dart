import 'package:flutter/material.dart';

/// Centralised constants for the EasyLens app.
class AppConstants {
  AppConstants._();

  // ── Colours ──────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF1C2333);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color safeGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color dangerRed = Color(0xFFF44336);
  static const Color edgeModeCyan = Color(0xFF00E5FF);

  // ── Typography ───────────────────────────────────────────
  static const double fontSizeTitle = 28.0;
  static const double fontSizeHeading = 22.0;
  static const double fontSizeBody = 18.0;
  static const double fontSizeCaption = 14.0;
  static const double fontSizeButton = 20.0;

  // ── Layout ───────────────────────────────────────────────
  static const double buttonHeight = 80.0;
  static const double cardRadius = 16.0;
  static const double screenPadding = 20.0;

  // ── Mock Object Pool ─────────────────────────────────────
  static const List<String> mockObjectNames = [
    'Stairs',
    'Vehicle',
    'Pedestrian',
    'Crosswalk',
    'Obstacle',
  ];

  static const Map<String, IconData> objectIcons = {
    'Stairs': Icons.stairs,
    'Vehicle': Icons.directions_car,
    'Pedestrian': Icons.directions_walk,
    'Crosswalk': Icons.swap_calls,
    'Obstacle': Icons.warning_amber_rounded,
  };

  // ── i18n Strings ─────────────────────────────────────────
  static const Map<String, Map<String, String>> i18n = {
    'en': {
      'scan_environment': 'Scan Environment',
      'repeat_last': 'Repeat Last Instruction',
      'emergency_alert': 'Emergency Alert',
      'edge_mode': 'EDGE MODE ACTIVE',
      'detection': 'Detection',
      'navigate': 'Navigate',
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'filipino': 'Filipino',
      'ble_status': 'Smart Glasses',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'connect': 'Connect',
      'disconnect': 'Disconnect',
      'tts_enabled': 'Voice Feedback',
      'scanning': 'Scanning environment...',
      'no_detections': 'No hazards detected',
      'warning_prefix': 'Warning',
      'danger_prefix': 'Danger',
      'safe_prefix': 'Clear',
      'detected_ahead': 'detected ahead',
      'meters_ahead': 'metres ahead',
      'emergency_message': 'Emergency! Sending alert to emergency contacts!',
    },
    'tl': {
      'scan_environment': 'I-scan ang Paligid',
      'repeat_last': 'Ulitin ang Huling Tagubilin',
      'emergency_alert': 'Emergency Alert',
      'edge_mode': 'EDGE MODE AKTIBO',
      'detection': 'Deteksyon',
      'navigate': 'Nabigasyon',
      'settings': 'Mga Setting',
      'language': 'Wika',
      'english': 'Ingles',
      'filipino': 'Filipino',
      'ble_status': 'Smart Glasses',
      'connected': 'Konektado',
      'disconnected': 'Hindi Konektado',
      'connect': 'Ikonekta',
      'disconnect': 'Idiskonekta',
      'tts_enabled': 'Voice Feedback',
      'scanning': 'Ini-scan ang paligid...',
      'no_detections': 'Walang nakitang panganib',
      'warning_prefix': 'Babala',
      'danger_prefix': 'Panganib',
      'safe_prefix': 'Malinaw',
      'detected_ahead': 'nakita sa harap',
      'meters_ahead': 'metro sa harap',
      'emergency_message':
          'Emergency! Nagpapadala ng alerto sa mga emergency contact!',
    },
  };
}
