import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'pairing_view.dart';
import 'results_view.dart';
import 'settings_view.dart';

enum DeviceScreenState {
  dashboard,
  searching,
  replacePrompt,
  connecting,
  pairedSuccess,
  pairingFailed,
  deviceSettings
}

class DevicesView extends StatefulWidget {
  const DevicesView({super.key});

  @override
  State<DevicesView> createState() => _DevicesViewState();
}

class _DevicesViewState extends State<DevicesView> {
  DeviceScreenState _currentState = DeviceScreenState.dashboard;

  void _setState(DeviceScreenState state) {
    setState(() {
      _currentState = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_currentState != DeviceScreenState.deviceSettings) ...[
            _buildHeader(),
            const SizedBox(height: 10),
            _buildSubtitle(),
            const SizedBox(height: 30),
          ],
          Expanded(
            child: _buildCurrentStateView(),
          ),
          const SizedBox(height: 80), // Space for navbar
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title = 'Connected Devices';
    if (_currentState == DeviceScreenState.searching) title = 'Adding Device';
    if (_currentState == DeviceScreenState.replacePrompt) title = 'Replace Connected Device?';
    if (_currentState == DeviceScreenState.connecting) title = 'Connecting...';
    if (_currentState == DeviceScreenState.pairedSuccess) title = 'Connection Success!';
    if (_currentState == DeviceScreenState.pairingFailed) title = 'Connection Failed';

    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'HeaderFont',
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0D1724),
      ),
    );
  }

  Widget _buildSubtitle() {
    String subtitle = 'Manage your smart glasses and accessories. Tap the model to configure';
    if (_currentState == DeviceScreenState.searching) {
      subtitle = 'Ensure your smart glasses are turned on and nearby to connect.';
    } else if (_currentState == DeviceScreenState.replacePrompt) {
      subtitle = 'You currently have an active pair of smart glasses connected to EasyLens.';
    } else if (_currentState == DeviceScreenState.connecting) {
      subtitle = 'Establishing secure link with your EasyLens glasses...';
    } else if (_currentState == DeviceScreenState.pairedSuccess) {
      subtitle = 'Your smart glasses are now successfully paired and ready to use.';
    } else if (_currentState == DeviceScreenState.pairingFailed) {
      subtitle = 'Unable to establish a connection. Please try again or check your settings.';
    }

    return Text(
      subtitle,
      style: const TextStyle(
        fontFamily: 'DescriptionFont',
        fontSize: 16,
        color: Colors.black54,
        height: 1.4,
      ),
    );
  }

  Widget _buildCurrentStateView() {
    switch (_currentState) {
      case DeviceScreenState.dashboard:
        return DashboardView(onStateChange: _setState);
      case DeviceScreenState.searching:
      case DeviceScreenState.connecting:
        return PairingView(state: _currentState, onStateChange: _setState);
      case DeviceScreenState.replacePrompt:
        return _buildReplacePrompt();
      case DeviceScreenState.pairedSuccess:
        return ResultsView(isSuccess: true, onStateChange: _setState);
      case DeviceScreenState.pairingFailed:
        return ResultsView(isSuccess: false, onStateChange: _setState);
      case DeviceScreenState.deviceSettings:
        return SettingsView(onStateChange: _setState);
    }
  }

  Widget _buildReplacePrompt() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
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
              Image.asset(
                'assets/icons/device-icons/disconnect.png',
                height: 140,
                color: const Color(0xFF08209A),
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              const Text(
                'Disconnect current glasses?',
                style: TextStyle(
                  fontFamily: 'HeaderFont',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'To pair a new device, we need to disconnect your current one first. Would you like to proceed with pairing the new glasses?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DescriptionFont',
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => _setState(DeviceScreenState.searching),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF08209A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              elevation: 0,
            ),
            child: const Text(
              'Disconnect & Pair New',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton(
            onPressed: () => _setState(DeviceScreenState.dashboard),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: const Color(0xFF08209A), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text(
              'Keep Current Device',
              style: TextStyle(
                color: Color(0xFF08209A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
