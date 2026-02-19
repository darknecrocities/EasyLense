import 'package:flutter/material.dart';
import '../models/detected_object.dart';
import '../constants/app_constants.dart';

/// Card displaying a detected object with risk-coloured accent.
class DetectionCard extends StatelessWidget {
  final DetectedObject object;

  const DetectionCard({super.key, required this.object});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.cardDark,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: object.riskColor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: object.riskColor.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Risk-coloured icon circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: object.riskColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(object.icon, color: object.riskColor, size: 30),
            ),
            const SizedBox(width: 16),

            // Object info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    object.name,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeBody,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    object.distanceLabel,
                    style: const TextStyle(
                      fontSize: AppConstants.fontSizeCaption,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Risk badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: object.riskColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: object.riskColor.withOpacity(0.6),
                  width: 1,
                ),
              ),
              child: Text(
                object.riskLabel,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeCaption,
                  fontWeight: FontWeight.w800,
                  color: object.riskColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
