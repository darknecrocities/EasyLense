import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';
import 'detection_screen.dart';
import 'navigation_assist_screen.dart';
import 'settings_screen.dart';

/// Home screen with bottom navigation bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DetectionScreen(),
    NavigationAssistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final strings =
        AppConstants.i18n[settings.language] ?? AppConstants.i18n['en']!;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppConstants.primaryBlue.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.radar, size: 28),
              label: strings['detection'],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.navigation, size: 28),
              label: strings['navigate'],
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings, size: 28),
              label: strings['settings'],
            ),
          ],
        ),
      ),
    );
  }
}
