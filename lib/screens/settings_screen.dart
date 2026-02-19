import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/detection_provider.dart';
import '../providers/settings_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/edge_mode_badge.dart';

/// Settings screen with language toggle, BLE status, and TTS controls.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final detection = context.read<DetectionProvider>();
    final strings =
        AppConstants.i18n[settings.language] ?? AppConstants.i18n['en']!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              strings['settings']!,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeTitle,
                fontWeight: FontWeight.w800,
                color: AppConstants.textWhite,
              ),
            ),
            const SizedBox(height: 24),

            // Language selection
            _buildSectionCard(
              icon: Icons.language,
              title: strings['language']!,
              child: Row(
                children: [
                  Expanded(
                    child: _LanguageButton(
                      label: strings['english']!,
                      isSelected: settings.language == 'en',
                      onTap: () {
                        settings.setLanguage('en');
                        detection.setLanguage('en');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LanguageButton(
                      label: strings['filipino']!,
                      isSelected: settings.language == 'tl',
                      onTap: () {
                        settings.setLanguage('tl');
                        detection.setLanguage('tl');
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // BLE Connection
            _buildSectionCard(
              icon: Icons.bluetooth,
              title: strings['ble_status']!,
              child: Row(
                children: [
                  // Status dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: settings.isBleConnected
                          ? AppConstants.safeGreen
                          : AppConstants.dangerRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (settings.isBleConnected
                                      ? AppConstants.safeGreen
                                      : AppConstants.dangerRed)
                                  .withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.isBleConnected
                              ? settings.deviceName
                              : strings['disconnected']!,
                          style: const TextStyle(
                            color: AppConstants.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          settings.isBleConnected
                              ? strings['connected']!
                              : strings['disconnected']!,
                          style: const TextStyle(
                            color: AppConstants.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: settings.isConnecting
                          ? null
                          : () => settings.toggleBleConnection(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: settings.isBleConnected
                            ? AppConstants.dangerRed.withOpacity(0.2)
                            : AppConstants.primaryBlue,
                        foregroundColor: settings.isBleConnected
                            ? AppConstants.dangerRed
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        minimumSize: const Size(100, 44),
                      ),
                      child: settings.isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppConstants.textWhite,
                              ),
                            )
                          : Text(
                              settings.isBleConnected
                                  ? strings['disconnect']!
                                  : strings['connect']!,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Voice Feedback toggle
            _buildSectionCard(
              icon: Icons.record_voice_over,
              title: strings['tts_enabled']!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.ttsEnabled ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: settings.ttsEnabled
                          ? AppConstants.safeGreen
                          : AppConstants.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Switch(
                    value: settings.ttsEnabled,
                    onChanged: (value) {
                      settings.setTtsEnabled(value);
                      detection.ttsService.setEnabled(value);
                    },
                    activeColor: AppConstants.primaryBlue,
                    activeTrackColor: AppConstants.primaryBlue.withOpacity(0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Edge Mode indicator
            _buildSectionCard(
              icon: Icons.developer_board,
              title: 'Edge AI Processing',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Local inference active\nNo cloud dependency',
                    style: TextStyle(
                      color: AppConstants.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  EdgeModeBadge(label: strings['edge_mode']),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // App info
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.visibility,
                    color: AppConstants.primaryBlue.withOpacity(0.4),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'EasyLens v1.0.0',
                    style: TextStyle(
                      color: AppConstants.textSecondary.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: AppConstants.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppConstants.primaryBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppConstants.textWhite,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryBlue
              : AppConstants.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryBlue
                : AppConstants.textSecondary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppConstants.textSecondary,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
