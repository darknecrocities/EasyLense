import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import 'devices_view.dart'; // For the DeviceScreenState enum

class DashboardView extends StatelessWidget {
  final Function(DeviceScreenState) onStateChange;

  const DashboardView({
    super.key,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Add New Device Card
          GestureDetector(
            onTap: () {
              if (settings.isBleConnected) {
                onStateChange(DeviceScreenState.replacePrompt);
              } else {
                onStateChange(DeviceScreenState.searching);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF08209A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF08209A).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/app_icon_logo.png',
                      height: 28,
                      width: 28,
                      color: const Color(0xFF08209A),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Text(
                      'Add New Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'HeaderFont',
                      ),
                    ),
                  ),
                  const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),

          // Sample Device Card
          GestureDetector(
            onTap: () => onStateChange(DeviceScreenState.deviceSettings),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'EasyLens Model 1 : Active',
                        style: TextStyle(
                          fontFamily: 'DescriptionFont',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/icons/object-icon/glasses_main_icon.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
