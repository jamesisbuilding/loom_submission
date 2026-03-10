
import 'package:design_system/src/widgets/images/shader_widget.dart';
import 'package:flutter/material.dart';

class GrainBackground extends StatelessWidget {
  const GrainBackground({
    super.key,
    this.opacity = 0.2,
  });

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: Opacity(
          opacity: opacity,
          child: const ShaderWidget(
            assetKey: 'packages/design_system/shaders/transparent_grain.frag',
          ),
        ),
      ),
    );
  }
}
