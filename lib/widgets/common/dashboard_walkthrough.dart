import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/walkthrough_service.dart';
import '../../services/spotlight_controller.dart';

class TutorialStep {
  final String title;
  final String description;
  final String? targetId; // Switched from GlobalKey to ID
  final String? assetPath; // For the logo in the welcome card

  TutorialStep({
    required this.title,
    required this.description,
    this.targetId,
    this.assetPath,
  });
}

class DashboardWalkthrough extends StatefulWidget {
  final Widget child;
  final List<TutorialStep> steps;
  final int currentIndex;
  final VoidCallback? onNext; // Callback to trigger index update from parent
  final VoidCallback onComplete;
  final Function(int index)? onStepChanged;

  const DashboardWalkthrough({
    super.key,
    required this.child,
    required this.steps,
    required this.currentIndex,
    required this.onComplete,
    this.onNext,
    this.onStepChanged,
  });

  @override
  State<DashboardWalkthrough> createState() => _DashboardWalkthroughState();
}

class _DashboardWalkthroughState extends State<DashboardWalkthrough> {
  bool _isVisible = true;
  late final SpotlightController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SpotlightController();
    _controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  // _waitForTarget is no longer needed with the self-reporting system
  // as the controller notifies us whenever a target reports in.


  void _nextStep() {
    if (widget.currentIndex < widget.steps.length - 1) {
      if (widget.onNext != null) {
        widget.onNext!();
      } else if (widget.onStepChanged != null) {
        widget.onStepChanged!(widget.currentIndex + 1);
      }
    } else {
      _finish();
    }
  }

  void _finish() {
    setState(() {
      _isVisible = false;
    });
    WalkthroughService.markDashboardTutorialComplete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return widget.child;

    final currentStep = widget.steps[widget.currentIndex];
    final targetRect = _controller.getTargetRect(currentStep.targetId);

    return Stack(
      children: [
        widget.child,

        // Spotlight Overlay
        if (_isVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Prevent taps reaching below
              child: AnimatedSpotlightOverlay(
                targetRect: targetRect,
              ),
            ),
          ),

        // Tutorial Card
        if (_isVisible) _buildTutorialCard(currentStep, targetRect),
      ],
    );
  }

  // Removed _getRectFromKey as it's replaced by the controller's lookup


  Widget _buildTutorialCard(TutorialStep step, Rect? targetRect) {
    bool isFirstStep = widget.currentIndex == 0;
    bool isLastStep = widget.currentIndex == widget.steps.length - 1;
    
    // Default to center for the welcome step or if no target is found
    Alignment alignment = Alignment.center;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 30);

    if (targetRect != null) {
      final screenHeight = MediaQuery.of(context).size.height;
      final targetCenterY = targetRect.center.dy;

      // If the spotlight is in the bottom half, push the card to the top
      if (targetCenterY > screenHeight / 2) {
        alignment = Alignment.topCenter;
        padding = const EdgeInsets.only(top: 80, left: 30, right: 30);
      } else {
        // Spotlight is in the top half, push card to the bottom
        alignment = Alignment.bottomCenter;
        padding = const EdgeInsets.only(bottom: 120, left: 30, right: 30);
      }
    }

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (step.assetPath != null) ...[
                    Image.asset(
                      step.assetPath!,
                      height: 85,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                  ],
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFDE7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    step.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'DescriptionFont',
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: isFirstStep 
                      ? MainAxisAlignment.spaceBetween 
                      : (isLastStep ? MainAxisAlignment.center : MainAxisAlignment.end),
                  children: [
                    if (isFirstStep)
                      TextButton(
                        onPressed: _finish,
                        child: const Text(
                          'Skip Tutorial',
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            color: Color(0xFF08209A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (isLastStep)
                      SizedBox(
                        width: 200,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _finish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF08209A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Go to Dashboard',
                            style: TextStyle(
                              fontFamily: 'HeaderFont',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _nextStep,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF08209A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}

/// A more robust, web-safe spotlight overlay that uses 4 positioned blocks
/// instead of complex Path operations that can fail in certain browsers.
class AnimatedSpotlightOverlay extends StatelessWidget {
  final Rect? targetRect;

  const AnimatedSpotlightOverlay({super.key, this.targetRect});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Rect?>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      tween: RectTween(
        begin: null,
        end: targetRect ?? Rect.zero,
      ),
      builder: (context, rect, _) {
        if (rect == null || rect.width <= 0) {
          // Full screen dimmed if no target reporting yet
          return Container(color: Colors.black.withOpacity(0.7));
        }

        final hole = rect.inflate(15);
        final color = Colors.black.withOpacity(0.7);

        return Stack(
          children: [
            // Top shroud
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: hole.top,
              child: Container(color: color),
            ),
            // Bottom shroud
            Positioned(
              top: hole.bottom,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(color: color),
            ),
            // Left shroud (constrained to hole height)
            Positioned(
              top: hole.top,
              left: 0,
              width: hole.left,
              height: hole.height,
              child: Container(color: color),
            ),
            // Right shroud (constrained to hole height)
            Positioned(
              top: hole.top,
              right: 0,
              left: hole.right,
              height: hole.height,
              child: Container(color: color),
            ),
            // Optional: Subtle white border around the clear spotlight hole
            Positioned.fromRect(
              rect: hole,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

