import 'package:flutter/material.dart';
import 'devices_view.dart';
import 'device_components.dart';

class SettingsView extends StatelessWidget {
  final Function(DeviceScreenState) onStateChange;

  const SettingsView({
    super.key,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => onStateChange(DeviceScreenState.dashboard),
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF08209A), size: 28),
              ),
              const Expanded(
                child: Text(
                  'Device Settings',
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D1724),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 48),
            child: Text(
              'Manage your smart glass.',
              style: TextStyle(fontFamily: 'DescriptionFont', fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 30),

          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'EasyLens Model 1: Active',
                  style: TextStyle(fontFamily: 'DescriptionFont', fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Image.asset('assets/icons/object-icon/glasses_main_icon.png', height: 100, fit: BoxFit.contain),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Status Indicators (Battery, Quality, Wifi, Sync)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: const Column(
              children: [
                DeviceStatRow(
                  icon: Icons.battery_charging_full_rounded,
                  label: 'Battery Level',
                  value: '85%',
                  showBar: true,
                  progress: 0.85,
                ),
                Divider(height: 30, color: Colors.black12),
                DeviceStatRow(
                  icon: Icons.wifi_tethering_rounded,
                  label: 'Connection Quality',
                  value: 'Excellent',
                ),
                Divider(height: 30, color: Colors.black12),
                DeviceStatRow(
                  icon: Icons.wifi_rounded,
                  label: 'Wifi',
                  value: 'Connected',
                ),
                Divider(height: 30, color: Colors.black12),
                DeviceStatRow(
                  icon: Icons.sync_rounded,
                  label: 'Last Sync',
                  value: '2 minutes ago',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Toggles Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assistant View (Live Camera)',
                        style: TextStyle(fontFamily: 'HeaderFont', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Allow Object Bound Boxes',
                        style: TextStyle(fontFamily: 'DescriptionFont', fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: true, 
                  onChanged: (v) {}, 
                  activeColor: const Color(0xFF08209A),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Information',
                  style: TextStyle(fontFamily: 'HeaderFont', fontSize: 18, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 20),
                DeviceInfoRow(label: 'Firmware Version', value: '2.4.1'),
                SizedBox(height: 12),
                DeviceInfoRow(label: 'Serial Number', value: 'EL-X2026-4892'),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Action Buttons
          DeviceActionButton(label: 'Pause Camera', onPressed: () {}, isOutline: false),
          DeviceActionButton(label: 'Camera Test', onPressed: () {}, isOutline: true),
          DeviceActionButton(label: 'Update Firmware', onPressed: () {}, isOutline: false),
          DeviceActionButton(label: 'Disconnect Device', onPressed: () {}, isOutline: true, isRed: false),
          DeviceActionButton(label: 'Reset Device', onPressed: () {}, isOutline: false),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
