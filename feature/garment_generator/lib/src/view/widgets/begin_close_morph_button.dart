import 'package:flutter/material.dart';
import 'package:design_system/design_system.dart';

class BeginCloseMorphButton extends StatefulWidget {
  const BeginCloseMorphButton({
    super.key,
    required this.expanded,
    required this.onBegin,
    required this.onClose,
    this.bottom = 40,
  });

  final bool expanded;
  final VoidCallback onBegin;
  final VoidCallback onClose;
  final double bottom;

  static const _duration = Duration(milliseconds: 250);
  static const _curve = Cubic(0.175, 0.885, 0.32, 1.1);

  @override
  State<BeginCloseMorphButton> createState() => _BeginCloseMorphButtonState();
}

class _BeginCloseMorphButtonState extends State<BeginCloseMorphButton>
    with AnimatedPressMixin {
  @override
  void onPressComplete() {
    if (widget.expanded) {
      widget.onClose();
    } else {
      widget.onBegin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10);
    final border =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.20);

    final width = widget.expanded ? 50.0 : 300.0;
    final height = widget.expanded ? 50.0 : 60.0;
    final radiusValue = 50.0;
    final borderRadius = BorderRadius.circular(radiusValue);

    return Positioned(
      bottom: widget.bottom,
      child: buildPressable(
        child: LiquidGlassButtonShell(
          borderRadius: radiusValue,
          child: AnimatedContainer(
            duration: BeginCloseMorphButton._duration,
            curve: BeginCloseMorphButton._curve,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border, width: 0.5),
              borderRadius: borderRadius,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: BeginCloseMorphButton._duration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: widget.expanded
                    ? const Icon(
                        Icons.close,
                        key: ValueKey('close'),
                        color: Colors.white,
                      )
                    : Text(
                        'START RESTITCHING',
                        key: const ValueKey('begin'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

