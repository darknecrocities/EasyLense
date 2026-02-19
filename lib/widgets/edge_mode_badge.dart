import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Pulsing "EDGE MODE ACTIVE" badge with glow animation.
class EdgeModeBadge extends StatefulWidget {
  final String? label;

  const EdgeModeBadge({super.key, this.label});

  @override
  State<EdgeModeBadge> createState() => _EdgeModeBadgeState();
}

class _EdgeModeBadgeState extends State<EdgeModeBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.label ?? 'EDGE MODE ACTIVE';

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppConstants.edgeModeCyan.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppConstants.edgeModeCyan.withOpacity(
                _glowAnimation.value,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConstants.edgeModeCyan.withOpacity(
                  _glowAnimation.value * 0.3,
                ),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppConstants.edgeModeCyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.edgeModeCyan.withOpacity(
                        _glowAnimation.value,
                      ),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: AppConstants.edgeModeCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
