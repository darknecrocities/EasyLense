import 'package:flutter/material.dart';

class DeviceActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutline;
  final bool isRed;

  const DeviceActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isOutline = false,
    this.isRed = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRed ? Colors.redAccent : const Color(0xFF08209A);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: isOutline
            ? OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
      ),
    );
  }
}

class DeviceInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const DeviceInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'DescriptionFont',
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'DescriptionFont',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class DeviceStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showBar;
  final double progress; // 0.0 to 1.0

  const DeviceStatRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showBar = false,
    this.progress = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.black54, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DescriptionFont',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'DescriptionFont',
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        if (showBar) ...[
          const SizedBox(height: 12),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
