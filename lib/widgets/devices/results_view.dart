import 'package:flutter/material.dart';
import 'devices_view.dart';
import 'device_components.dart';

class ResultsView extends StatelessWidget {
  final bool isSuccess;
  final Function(DeviceScreenState) onStateChange;

  const ResultsView({
    super.key,
    required this.isSuccess,
    required this.onStateChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                isSuccess 
                  ? 'assets/icons/device-icons/success.png' 
                  : 'assets/icons/device-icons/failed.png',
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              Text(
                isSuccess ? 'Successfully Connected' : 'Failed to Connect',
                style: const TextStyle(
                  fontFamily: 'HeaderFont',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                isSuccess 
                  ? 'Your EasyLens smart glasses are now active and providing real-time audio and haptic feedback.' 
                  : 'Check if your device is charged and within range, or try restarting the glasses.',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
        DeviceActionButton(
          label: isSuccess ? 'Finish Setup' : 'Retry Pairing',
          onPressed: () => onStateChange(DeviceScreenState.dashboard),
        ),
      ],
    ),
   );
  }
}
