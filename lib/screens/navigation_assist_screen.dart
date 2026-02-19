import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/accessible_button.dart';

/// Navigation assist screen with large accessible action buttons.
class NavigationAssistScreen extends StatefulWidget {
  const NavigationAssistScreen({super.key});

  @override
  State<NavigationAssistScreen> createState() => _NavigationAssistScreenState();
}

class _NavigationAssistScreenState extends State<NavigationAssistScreen> {
  bool _showEmergency = false;

  @override
  Widget build(BuildContext context) {
    final detection = context.watch<DetectionProvider>();
    final settings = context.watch<SettingsProvider>();
    final strings =
        AppConstants.i18n[settings.language] ?? AppConstants.i18n['en']!;

    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.navigation,
                      color: AppConstants.primaryBlue,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      strings['navigate']!,
                      style: const TextStyle(
                        fontSize: AppConstants.fontSizeTitle,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textWhite,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Status indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.cardDark,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  border: Border.all(
                    color: AppConstants.primaryBlue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: detection.detections.isEmpty
                            ? AppConstants.safeGreen
                            : AppConstants.warningYellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (detection.detections.isEmpty
                                        ? AppConstants.safeGreen
                                        : AppConstants.warningYellow)
                                    .withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        detection.lastInstruction.isEmpty
                            ? strings['no_detections']!
                            : detection.lastInstruction,
                        style: const TextStyle(
                          color: AppConstants.textWhite,
                          fontSize: 15,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action buttons
              AccessibleButton(
                label: strings['scan_environment']!,
                icon: Icons.radar,
                onPressed: () => detection.scanEnvironment(),
                color: AppConstants.primaryBlue,
              ),

              AccessibleButton(
                label: strings['repeat_last']!,
                icon: Icons.replay,
                onPressed: () => detection.repeatLastInstruction(),
                color: const Color(0xFF7C4DFF),
              ),

              AccessibleButton(
                label: strings['emergency_alert']!,
                icon: Icons.emergency,
                onPressed: () => _triggerEmergency(detection, strings),
                color: AppConstants.dangerRed,
              ),

              const SizedBox(height: 24),
              const Spacer(),
            ],
          ),
        ),

        // Emergency flash overlay
        if (_showEmergency)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showEmergency = false),
              child: AnimatedOpacity(
                opacity: _showEmergency ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: AppConstants.dangerRed.withOpacity(0.85),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emergency, color: Colors.white, size: 80),
                        SizedBox(height: 20),
                        Text(
                          'EMERGENCY ALERT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Tap anywhere to dismiss',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _triggerEmergency(
    DetectionProvider detection,
    Map<String, String> strings,
  ) {
    HapticFeedback.vibrate();
    setState(() => _showEmergency = true);
    detection.emergencyAlert(strings['emergency_message']!);

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showEmergency = false);
    });
  }
}
