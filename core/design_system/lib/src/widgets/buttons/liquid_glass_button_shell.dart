import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class LiquidGlassButtonShell extends StatelessWidget {
  const LiquidGlassButtonShell({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: LiquidGlassSettings(
        thickness: 20,
        blur: 10,
        glassColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.1),
      ),
      child: LiquidGlass(
        shape: LiquidRoundedSuperellipse(borderRadius: borderRadius),
        child: child,
      ),
    );
  }
}

