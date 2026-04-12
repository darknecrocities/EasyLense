import 'package:shared_preferences/shared_preferences.dart';

class WalkthroughService {
  static const String _keyShowDashboardTutorial = 'show_dashboard_tutorial_v1';

  static Future<bool> shouldShowDashboardTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to true if not found
    return prefs.getBool(_keyShowDashboardTutorial) ?? true;
  }

  static Future<void> markDashboardTutorialComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowDashboardTutorial, false);
  }

  /// Reset for debugging if needed
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyShowDashboardTutorial);
  }
}
