import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class TextLogo extends StatelessWidget {
  final bool expanded; 
  const TextLogo({super.key, required this.expanded});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: !expanded ? 1 : 5,
      duration: animationDuration,
      curve: animationCurve,
      child: EpicycleText(text: 'RESTITCH'),
    );
  }
}
