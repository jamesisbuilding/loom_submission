import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class LoadingTextLogo extends StatelessWidget {
  const LoadingTextLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: Transform.scale(
        scale: 0.72,
        child: const EpicycleText(text: 'LOADING'),
      ),
    );
  }
}

