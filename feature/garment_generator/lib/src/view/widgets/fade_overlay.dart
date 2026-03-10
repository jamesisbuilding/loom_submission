import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class FadeOverlay extends StatelessWidget {
  final bool visible;
  final double fade; 
  const FadeOverlay({super.key, required this.visible, this.fade = 50});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: visible ? 1 : 0,
      child: Container(
        color: AppTheme.carbon.withValues(alpha: 0.3),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: fade, sigmaY: fade),
          child: const SizedBox(),
        ),
      ),
    );
  }
}
