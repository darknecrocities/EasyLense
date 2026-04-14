import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import '../common/spotlight_target.dart';
import '../../providers/detection_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/hazard_mapper.dart';
import '../../models/detected_object.dart';

class ScanningDashboardView extends StatefulWidget {
  final GlobalKey? glassesCardKey;
  final GlobalKey? glassesImageKey;
  final GlobalKey? scanningCardKey;
  final GlobalKey? statsRowKey;
  final GlobalKey? geminiButtonKey;
  
  final bool isConnected;
  final Widget? cameraFeed;
  final CameraController? cameraController;

  const ScanningDashboardView({
    super.key,
    this.glassesCardKey,
    this.glassesImageKey,
    this.scanningCardKey,
    this.statsRowKey,
    this.geminiButtonKey,
    this.isConnected = false,
    this.cameraFeed,
    this.cameraController,
  });

  @override
  State<ScanningDashboardView> createState() => _ScanningDashboardViewState();
}

class _ScanningDashboardViewState extends State<ScanningDashboardView> {
  bool _isGeminiEnabled = false;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSimulatedAnalysis();
    });
  }

  void _startSimulatedAnalysis() {
    if (!kIsWeb && widget.cameraController != null && widget.cameraController!.value.isInitialized) {
          widget.cameraController!.startImageStream((image) {
            if (mounted) {
              final detectionProvider = context.read<DetectionProvider>();
              if (!detectionProvider.isScanning) {
                // Pass the actual sensor orientation from the camera description
                final int sensorOrientation = widget.cameraController!.description.sensorOrientation;
                detectionProvider.scanEnvironment(
                  cameraImage: image,
                  sensorOrientation: sensorOrientation,
                );
              }
            }
          });
      return;
    }

    _scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final detectionProvider = context.read<DetectionProvider>();
        if (!detectionProvider.isScanning) {
          detectionProvider.scanEnvironment();
        }
      }
    });
  }

  void _openFullscreenCamera(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullscreenCameraOverlay(
            cameraFeed: widget.cameraFeed,
            cameraController: widget.cameraController,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    if (!kIsWeb && widget.cameraController != null && widget.cameraController!.value.isStreamingImages) {
      widget.cameraController!.stopImageStream();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detectionState = context.watch<DetectionProvider>();
    final hasDetections = detectionState.detections.isNotEmpty;
    final topDetection = hasDetections ? detectionState.detections.first : null;
    final geminiState = context.watch<GeminiProvider>();

    if (widget.cameraController != null) {
      geminiState.setCameraController(widget.cameraController);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      child: Column(
        children: [
          // 1. Hardware Status Card (Compact)
          Container(
            key: widget.glassesCardKey,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                SpotlightTarget(
                  id: 'glasses_image',
                  child: Image.asset(
                    widget.isConnected 
                        ? 'assets/icons/object-icon/glasses_main_icon.png'
                        : 'assets/icons/object-icon/camera.png',
                    key: widget.glassesImageKey,
                    height: 40,
                    color: widget.isConnected ? null : const Color(0xFF08209A),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.isConnected ? 'EasyLens Model 1' : 'Phone Camera',
                    style: const TextStyle(
                      fontFamily: 'HeaderFont',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontFamily: 'HeaderFont',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // 2. Live Stream Card — Tap to Fullscreen
          Expanded(
            flex: 5,
            child: SpotlightTarget(
              id: 'scanning_card',
              child: GestureDetector(
                onTap: () => _openFullscreenCamera(context),
                child: Container(
                  key: widget.scanningCardKey,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Camera Feed
                        Positioned.fill(
                          child: widget.cameraFeed != null 
                              ? widget.cameraFeed!
                              : Image.asset(
                                  'assets/animation/Scanning.gif',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        // Bounding Boxes
                        if (hasDetections)
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double previewAR = (widget.cameraController != null && widget.cameraController!.value.isInitialized)
                                    ? 1.0 / widget.cameraController!.value.aspectRatio 
                                    : 9 / 16; 
                                final double containerAR = constraints.maxWidth / constraints.maxHeight;

                                return Stack(
                                  children: detectionState.detections.map((d) {
                                    if (d.boundingBox == null) return const SizedBox.shrink();
                                    
                                    double left, top, width, height;
                                    
                                    // Calculate precise scaling to match the CameraPreview's "cover" behavior
                                    if (containerAR > previewAR) {
                                      // Container is wider than preview (Vertical cropping)
                                      final double scale = constraints.maxWidth / previewAR;
                                      final double vOffset = (scale - constraints.maxHeight) / 2;
                                      left = d.boundingBox!.left * constraints.maxWidth;
                                      top = (d.boundingBox!.top * scale) - vOffset;
                                      width = d.boundingBox!.width * constraints.maxWidth;
                                      height = d.boundingBox!.height * scale;
                                    } else {
                                      // Container is taller than preview (Horizontal cropping)
                                      final double scale = constraints.maxHeight * previewAR;
                                      final double hOffset = (scale - constraints.maxWidth) / 2;
                                      left = (d.boundingBox!.left * scale) - hOffset;
                                      top = d.boundingBox!.top * constraints.maxHeight;
                                      width = d.boundingBox!.width * scale;
                                      height = d.boundingBox!.height * constraints.maxHeight;
                                    }
                                    
                                    return Positioned(
                                      left: left, top: top, width: width, height: height,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: d.riskColor, width: 2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: d.riskColor,
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(4),
                                                bottomRight: Radius.circular(6),
                                              ),
                                            ),
                                            child: Text(
                                              d.name.toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'HeaderFont',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        // Object Counter (Lightweight — no BackdropFilter)
                        if (hasDetections)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6, height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00E676),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${detectionState.detections.length} Detected',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'HeaderFont',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // "Tap to expand" hint
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fullscreen, color: Colors.white70, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tap to expand',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'HeaderFont',
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),

          // 3. Hazard Card (Compact)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Hazard',
                        style: TextStyle(
                          fontFamily: 'HeaderFont',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          final hazard = HazardMapper.map(detectionState.detections);
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80, height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F9FF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: hazard.imagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          hazard.imagePath!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Icon(
                                            hazard.icon ?? Icons.warning_amber_rounded,
                                            color: const Color(0xFF08209A),
                                            size: 32,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        hazard.icon ?? Icons.warning_amber_rounded,
                                        color: const Color(0xFF08209A),
                                        size: 32,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hazard.title,
                                style: const TextStyle(
                                  fontFamily: 'HeaderFont',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hazard.description,
                                style: const TextStyle(
                                  fontFamily: 'DescriptionFont',
                                  fontSize: 11,
                                  color: Colors.black54,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // 4. Stats Row (Compact)
          SpotlightTarget(
            id: 'stats_row',
            child: Row(
              key: widget.statsRowKey,
              children: [
                Expanded(child: _buildStatItemCard('Objects', detectionState.totalObjects.toString())),
                const SizedBox(width: 8),
                Expanded(child: _buildStatItemCard('Scans', detectionState.totalScans.toString())),
                const SizedBox(width: 8),
                Expanded(child: _buildStatItemCard('Alerts', detectionState.totalAlerts.toString())),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // 5. Gemini Button (Compact)
          SpotlightTarget(
            id: 'gemini_button',
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                key: widget.geminiButtonKey,
                onPressed: () => geminiState.toggleGemini(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: geminiState.isActive ? const Color(0xFF08209A) : Colors.white,
                  foregroundColor: geminiState.isActive ? Colors.white : const Color(0xFF08209A),
                  side: BorderSide(
                    color: const Color(0xFF08209A), 
                    width: geminiState.isActive ? 0 : 2,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     if (geminiState.isListening) ...[
                       const SizedBox(
                         width: 18, height: 18, 
                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                       ),
                       const SizedBox(width: 10),
                     ],
                     Text(
                      geminiState.isProcessing 
                        ? 'Analyzing Scene...' 
                        : (geminiState.isListening 
                            ? 'Listening...' 
                            : (geminiState.isActive ? 'Disable Gemini' : 'Enable Gemini')),
                      style: const TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      geminiState.isActive ? Icons.auto_awesome : Icons.auto_awesome_outlined, 
                      size: 18
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'HeaderFont',
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'HeaderFont',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen Camera Overlay — Opens when user taps the livestream card.
class _FullscreenCameraOverlay extends StatelessWidget {
  final Widget? cameraFeed;
  final CameraController? cameraController;

  const _FullscreenCameraOverlay({
    this.cameraFeed,
    this.cameraController,
  });

  @override
  Widget build(BuildContext context) {
    final detectionState = context.watch<DetectionProvider>();
    final hasDetections = detectionState.detections.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fullscreen Camera
          Positioned.fill(
            child: cameraFeed != null
                ? cameraFeed!
                : Container(color: Colors.black),
          ),
          // Bounding Boxes
          if (hasDetections)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double previewAR = (cameraController != null && cameraController!.value.isInitialized)
                      ? 1.0 / cameraController!.value.aspectRatio 
                      : 9 / 16; 
                      
                  final double containerAR = constraints.maxWidth / constraints.maxHeight;

                  return Stack(
                    children: detectionState.detections.map((d) {
                      if (d.boundingBox == null) return const SizedBox.shrink();
                      
                      double left, top, width, height;
                      
                      if (containerAR > previewAR) {
                        final viewHeight = constraints.maxWidth / previewAR;
                        final verticalOffset = (viewHeight - constraints.maxHeight) / 2;
                        left = d.boundingBox!.left * constraints.maxWidth;
                        top = (d.boundingBox!.top * viewHeight) - verticalOffset;
                        width = d.boundingBox!.width * constraints.maxWidth;
                        height = d.boundingBox!.height * viewHeight;
                      } else {
                        final viewWidth = constraints.maxHeight * previewAR;
                        final horizontalOffset = (viewWidth - constraints.maxWidth) / 2;
                        left = (d.boundingBox!.left * viewWidth) - horizontalOffset;
                        top = d.boundingBox!.top * constraints.maxHeight;
                        width = d.boundingBox!.width * viewWidth;
                        height = d.boundingBox!.height * constraints.maxHeight;
                      }

                      return Positioned(
                        left: left, top: top, width: width, height: height,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: d.riskColor, width: 2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: d.riskColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomRight: Radius.circular(6),
                                ),
                              ),
                              child: Text(
                                '${d.name.toUpperCase()} ${d.distanceLabel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'HeaderFont',
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          // Object Counter
          if (hasDetections)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${detectionState.detections.length} Objects Detected',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'HeaderFont',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Close Button
          Positioned(
            top: 55,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

