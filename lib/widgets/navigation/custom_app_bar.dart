import 'dart:async';
import 'package:flutter/material.dart';
import '../common/spotlight_target.dart';
import 'package:provider/provider.dart';
import 'package:battery_plus/battery_plus.dart';
import '../../providers/settings_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  final GlobalKey? statusKey;
  final GlobalKey? batteryKey;
  final GlobalKey? menuKey;

  const CustomAppBar({
    super.key,
    required this.onMenuTap,
    this.statusKey,
    this.batteryKey,
    this.menuKey,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final Battery _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;
  StreamSubscription<BatteryState>? _batterySubscription;

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) {
      _getBatteryLevel();
      setState(() {
        _batteryState = state;
      });
    });
  }

  Future<void> _getBatteryLevel() async {
    final level = await _battery.batteryLevel;
    if (mounted) {
      setState(() {
        _batteryLevel = level;
      });
    }
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }

  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging) {
      return Icons.battery_charging_full_rounded;
    }
    if (_batteryLevel > 90) return Icons.battery_full_rounded;
    if (_batteryLevel > 80) return Icons.battery_6_bar_rounded;
    if (_batteryLevel > 60) return Icons.battery_5_bar_rounded;
    if (_batteryLevel > 40) return Icons.battery_4_bar_rounded;
    if (_batteryLevel > 20) return Icons.battery_3_bar_rounded;
    if (_batteryLevel > 10) return Icons.battery_2_bar_rounded;
    return Icons.battery_alert_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isConnected = settings.isBleConnected;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16, bottom: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF08209A),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Connection Status
          SpotlightTarget(
            id: 'app_status',
            child: Row(
              key: widget.statusKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isConnected ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isConnected ? const Color(0xFF4CAF50) : const Color(0xFFF44336)).withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isConnected ? 'Glasses' : 'No Connected',
                      style: const TextStyle(
                        fontFamily: 'HeaderFont',
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      isConnected ? 'Connected' : 'Device',
                      style: const TextStyle(
                        fontFamily: 'HeaderFont',
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Battery Status (Centered) - Now shows REAL cellphone battery level
          SpotlightTarget(
            id: 'app_battery',
            child: Row(
              key: widget.batteryKey,
              children: [
                RotatedBox(
                  quarterTurns: 1,
                  child: Icon(
                    _getBatteryIcon(),
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$_batteryLevel%',
                  style: const TextStyle(
                    fontFamily: 'HeaderFont',
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Hamburger Menu
          SpotlightTarget(
            id: 'app_menu',
            child: GestureDetector(
              key: widget.menuKey,
              onTap: widget.onMenuTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
