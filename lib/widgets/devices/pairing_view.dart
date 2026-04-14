import 'package:flutter/material.dart';
import 'devices_view.dart';
import 'device_components.dart';

class PairingView extends StatelessWidget {
  final DeviceScreenState state;
  final Function(DeviceScreenState) onStateChange;

  const PairingView({
    super.key,
    required this.state,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    if (state == DeviceScreenState.searching) {
      return SingleChildScrollView(child: _buildSearching());
    } else {
      return SingleChildScrollView(child: _buildConnecting());
    }
  }

  Widget _buildSearching() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onStateChange(DeviceScreenState.connecting),
          child: Container(
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
                  'assets/animation/Connecting.gif',
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Searching for Glasses...',
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Ensure your EasyLens glasses are turned on, fully charged, and placed near your phone.',
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
        ),
        const SizedBox(height: 30),
        DeviceActionButton(
          label: 'Cancel Search',
          onPressed: () => onStateChange(DeviceScreenState.dashboard),
          isOutline: true,
        ),
      ],
    );
  }

  Widget _buildConnecting() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => onStateChange(DeviceScreenState.pairedSuccess),
          onLongPress: () => onStateChange(DeviceScreenState.pairingFailed),
          child: Container(
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
                  'assets/animation/Loading.gif',
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Connecting to Device...',
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Establishing a secure bridge between your phone and smart glasses.',
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
        ),
        const SizedBox(height: 30),
        DeviceActionButton(
          label: 'Cancel Connection',
          onPressed: () => onStateChange(DeviceScreenState.dashboard),
          isOutline: true,
        ),
      ],
    );
  }
}
