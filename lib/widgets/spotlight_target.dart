import 'package:flutter/material.dart';
import '../services/spotlight_controller.dart';

/// A wrapper widget that automatically reports its global position to the [SpotlightController].
/// Wrapped widgets will 'self-report' their Rect whenever they are laid out or scrolled.
class SpotlightTarget extends StatefulWidget {
  final String id;
  final Widget child;

  const SpotlightTarget({
    super.key,
    required this.id,
    required this.child,
  });

  @override
  State<SpotlightTarget> createState() => _SpotlightTargetState();
}

class _SpotlightTargetState extends State<SpotlightTarget> {
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _reportPosition();
  }

  void _reportPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final RenderBox? box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        final Offset offset = box.localToGlobal(Offset.zero);
        final Rect rect = offset & box.size;
        SpotlightController().updateTarget(widget.id, rect);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder ensures we re-report if the parent layout changes
    return LayoutBuilder(
      builder: (context, constraints) {
        _reportPosition();
        return Container(
          key: _key,
          child: widget.child,
        );
      },
    );
  }
}
