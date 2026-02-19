import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/detection_card.dart';
import '../widgets/edge_mode_badge.dart';

/// Real-time detection screen with camera preview and detected object cards.
class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detection = context.watch<DetectionProvider>();
    final settings = context.watch<SettingsProvider>();
    final strings =
        AppConstants.i18n[settings.language] ?? AppConstants.i18n['en']!;

    return SafeArea(
      child: Column(
        children: [
          // Header with edge mode badge
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings['detection']!,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSizeTitle,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textWhite,
                  ),
                ),
                if (settings.edgeModeActive)
                  EdgeModeBadge(label: strings['edge_mode']),
              ],
            ),
          ),

          // Camera preview area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CameraPreviewWidget(isScanning: detection.isScanning),
          ),

          const SizedBox(height: 12),

          // Scan button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: detection.isScanning
                    ? null
                    : () => detection.scanEnvironment(),
                icon: Icon(
                  detection.isScanning ? Icons.hourglass_top : Icons.radar,
                  size: 22,
                ),
                label: Text(
                  detection.isScanning
                      ? strings['scanning']!
                      : strings['scan_environment']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Detection cards
          Expanded(
            child: detection.detections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: AppConstants.textSecondary.withOpacity(0.4),
                          size: 64,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          strings['no_detections']!,
                          style: TextStyle(
                            color: AppConstants.textSecondary.withOpacity(0.6),
                            fontSize: AppConstants.fontSizeBody,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: detection.detections.length,
                    itemBuilder: (context, index) {
                      return DetectionCard(object: detection.detections[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
