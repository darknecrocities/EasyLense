import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Simulated camera preview widget.
///
/// Shows a dark gradient with scan-line animation when no camera is available.
class CameraPreviewWidget extends StatefulWidget {
  final bool isScanning;

  const CameraPreviewWidget({super.key, this.isScanning = false});

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scanAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scanController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF0D1117)],
        ),
        border: Border.all(
          color: AppConstants.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Stack(
          children: [
            // Grid overlay
            CustomPaint(
              size: const Size(double.infinity, 260),
              painter: _GridPainter(),
            ),

            // Scan line
            if (widget.isScanning)
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: _scanAnimation.value * 260,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppConstants.primaryBlue.withOpacity(0.8),
                            AppConstants.edgeModeCyan,
                            AppConstants.primaryBlue.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.edgeModeCyan.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Corner brackets
            ..._buildCornerBrackets(),

            // Center label
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isScanning ? Icons.radar : Icons.videocam_outlined,
                    color: AppConstants.primaryBlue.withOpacity(0.6),
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isScanning ? 'SCANNING...' : 'CAMERA SIMULATED',
                    style: TextStyle(
                      color: AppConstants.primaryBlue.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
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

  List<Widget> _buildCornerBrackets() {
    const size = 20.0;
    const thickness = 2.5;
    final color = AppConstants.primaryBlue.withOpacity(0.5);

    Widget bracket({
      required Alignment alignment,
      required BorderRadius radius,
      Border? border,
    }) {
      return Positioned.fill(
        child: Align(
          alignment: alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(border: border, borderRadius: radius),
          ),
        ),
      );
    }

    return [
      bracket(
        alignment: Alignment.topLeft,
        radius: const BorderRadius.only(topLeft: Radius.circular(4)),
        border: Border(
          top: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
        ),
      ),
      bracket(
        alignment: Alignment.topRight,
        radius: const BorderRadius.only(topRight: Radius.circular(4)),
        border: Border(
          top: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        ),
      ),
      bracket(
        alignment: Alignment.bottomLeft,
        radius: const BorderRadius.only(bottomLeft: Radius.circular(4)),
        border: Border(
          bottom: BorderSide(color: color, width: thickness),
          left: BorderSide(color: color, width: thickness),
        ),
      ),
      bracket(
        alignment: Alignment.bottomRight,
        radius: const BorderRadius.only(bottomRight: Radius.circular(4)),
        border: Border(
          bottom: BorderSide(color: color, width: thickness),
          right: BorderSide(color: color, width: thickness),
        ),
      ),
    ];
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppConstants.primaryBlue.withOpacity(0.06)
      ..strokeWidth = 0.5;

    const gridSize = 30.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
