import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'spotlight_target.dart';
import '../providers/detection_provider.dart';
import '../providers/gemini_provider.dart';

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
    // Simulate continuous environment analysis when the dashboard is open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSimulatedAnalysis();
    });
  }

  void _startSimulatedAnalysis() {
    // If we have a real camera controller and are on a native platform, 
    // we can attempt a high-frequency image stream for "Real-Time" vision.
    if (!kIsWeb && widget.cameraController != null && widget.cameraController!.value.isInitialized) {
      int lastProcessTime = 0;
      widget.cameraController!.startImageStream((image) {
        if (mounted) {
          final detectionProvider = context.read<DetectionProvider>();
          if (!detectionProvider.isScanning) {
            detectionProvider.scanEnvironment(cameraImage: image);
          }
        }
      });
      return;
    }

    // Fallback: Use the timer for Web or when no controller is present.
    _scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        final detectionProvider = context.read<DetectionProvider>();
        if (!detectionProvider.isScanning) {
          detectionProvider.scanEnvironment();
        }
      }
    });
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
    // Listen to detections
    final detectionState = context.watch<DetectionProvider>();
    final hasDetections = detectionState.detections.isNotEmpty;
    // Find highest risk detection for summary
    final topDetection = hasDetections ? detectionState.detections.first : null;

    final geminiState = context.watch<GeminiProvider>();
    // Inject camera controller just in time if required via provider
    if (widget.cameraController != null) {
      geminiState.setCameraController(widget.cameraController);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        children: [
          // 1. Hardware Status Card
          Container(
            key: widget.glassesCardKey,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isConnected ? 'EasyLens Model 1' : 'Phone Camera',
                  style: const TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                SpotlightTarget(
                  id: 'glasses_image',
                  child: Center(
                    key: widget.glassesImageKey,
                    child: Image.asset(
                      widget.isConnected 
                          ? 'assets/icons/object-icon/glasses_main_icon.png'
                          : 'assets/icons/object-icon/camera.png',
                      height: 90,
                      color: widget.isConnected ? null : const Color(0xFF08209A),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 2. Live Stream Card (Camera Feed)
          SpotlightTarget(
            id: 'scanning_card',
            child: Container(
              key: widget.scanningCardKey,
              width: double.infinity,
              height: 250, // Fixed height for the camera card
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    // Background Feed
                    Positioned.fill(
                      child: widget.cameraFeed != null 
                          ? widget.cameraFeed!
                          : Image.asset(
                              'assets/animation/Scanning.gif',
                              fit: BoxFit.cover,
                            ),
                    ),
                    // Detection Bounding Boxes Overlay
                    if (hasDetections)
                      Positioned.fill(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: detectionState.detections.map((d) {
                                if (d.boundingBox == null) return const SizedBox.shrink();
                                
                                final left = d.boundingBox!.left * constraints.maxWidth;
                                final top = d.boundingBox!.top * constraints.maxHeight;
                                final width = d.boundingBox!.width * constraints.maxWidth;
                                final height = d.boundingBox!.height * constraints.maxHeight;
                                
                                return Positioned(
                                  left: left,
                                  top: top,
                                  width: width,
                                  height: height,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: d.riskColor, 
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: d.riskColor,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          '${d.name.toUpperCase()} ${d.distanceLabel}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
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
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 3. Dynamic Hazard Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: hasDetections ? Colors.red : Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Hazard',
                      style: TextStyle(
                        fontFamily: 'HeaderFont',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasDetections ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasDetections ? topDetection!.icon : Icons.check_circle_outline,
                    color: hasDetections ? Colors.red : Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  hasDetections ? '${topDetection!.name} Detected' : 'Path Clear',
                  style: const TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasDetections 
                      ? 'Caution! ${topDetection!.name} detected ${topDetection.distanceMeters}m away.' 
                      : 'No hazards detected nearby.',
                  style: const TextStyle(
                    fontFamily: 'DescriptionFont',
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 4. Stats Row with 3 individual cards (Dynamic metrics from AI)
          SpotlightTarget(
            id: 'stats_row',
            child: Row(
              key: widget.statsRowKey,
              children: [
                Expanded(child: _buildStatItemCard('Objects', detectionState.totalObjects.toString())),
                const SizedBox(width: 12),
                Expanded(child: _buildStatItemCard('Scans', detectionState.totalScans.toString())),
                const SizedBox(width: 12),
                Expanded(child: _buildStatItemCard('Alerts', detectionState.totalAlerts.toString())),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 5. Stateful Enable Gemini Button
          SpotlightTarget(
            id: 'gemini_button',
            child: SizedBox(
              width: double.infinity,
              height: 56,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     if (geminiState.isListening) ...[
                       const SizedBox(
                         width: 20, 
                         height: 20, 
                         child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                       ),
                       const SizedBox(width: 12),
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
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      geminiState.isActive ? Icons.auto_awesome : Icons.auto_awesome_outlined, 
                      size: 20
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
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'HeaderFont',
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
