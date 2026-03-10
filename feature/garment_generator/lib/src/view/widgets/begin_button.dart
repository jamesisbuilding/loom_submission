import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class BeginButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;
  const BeginButton({super.key, required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: animationDuration,
      bottom: !visible ? -100 : 40,
      curve: animationCurve,
      child: MainButton(onTap: () => onTap(), label: 'Start Restitching'),
    );
  }
}
