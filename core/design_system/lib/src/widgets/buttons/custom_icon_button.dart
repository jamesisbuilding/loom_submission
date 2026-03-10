
import 'package:design_system/src/utils/animated_press_mixin.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatefulWidget {
  final int delay;
  final VoidCallback onTap;
  final Widget icon;
  const CustomIconButton({
    super.key,
    this.delay = 100,
    required this.onTap,
    required this.icon,
  });

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton>
    with AnimatedPressMixin {
  @override
  int get animateInDelay => widget.delay;

  @override
  double get pressedScale => 0.9;

  @override
  void onPressComplete() => widget.onTap();
  @override
  Widget build(BuildContext context) {
    return buildPressable(child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: widget.icon,
    ));
  }
}