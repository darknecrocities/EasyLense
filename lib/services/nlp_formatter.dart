import '../models/detected_object.dart';
import '../constants/app_constants.dart';

/// Formats detected objects into natural-language alerts
/// in the selected locale (English or Filipino).
class NlpFormatter {
  /// Format a single detected object into a spoken alert.
  String formatAlert(DetectedObject obj, String langCode) {
    final strings = AppConstants.i18n[langCode] ?? AppConstants.i18n['en']!;

    String prefix;
    switch (obj.riskLevel) {
      case RiskLevel.danger:
        prefix = strings['danger_prefix']!;
        break;
      case RiskLevel.warning:
        prefix = strings['warning_prefix']!;
        break;
      case RiskLevel.safe:
        prefix = strings['safe_prefix']!;
        break;
    }

    if (langCode == 'tl') {
      return '$prefix — May ${obj.name.toLowerCase()}, '
          '${obj.distanceLabel} ${strings['meters_ahead']}';
    }

    return '$prefix — ${obj.name} detected, '
        '${obj.distanceLabel} ${strings['meters_ahead']}';
  }

  /// Format all detected objects into a combined spoken summary.
  String formatSummary(List<DetectedObject> objects, String langCode) {
    if (objects.isEmpty) {
      final strings = AppConstants.i18n[langCode] ?? AppConstants.i18n['en']!;
      return strings['no_detections']!;
    }

    // Sort by risk level (danger first) then by distance (nearest first)
    final sorted = List<DetectedObject>.from(objects)
      ..sort((a, b) {
        final riskCmp = b.riskLevel.index.compareTo(a.riskLevel.index);
        if (riskCmp != 0) return riskCmp;
        return a.distanceMeters.compareTo(b.distanceMeters);
      });

    return sorted.map((obj) => formatAlert(obj, langCode)).join('. ');
  }
}
