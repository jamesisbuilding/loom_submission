import 'dart:ui';

import 'package:design_system/src/theme/app_theme.dart';
import 'package:design_system/src/widgets/background/liquid_background.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    this.imageColors,
    this.colorsListenable,
    this.fallbackColors = AppTheme.defaultColors,
  });

  final List<Color>? imageColors;
  final ValueListenable<List<Color>>? colorsListenable;
  final List<Color> fallbackColors;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          widget.colorsListenable != null
              ? LiquidBackground(colorsListenable: widget.colorsListenable)
              : LiquidBackground(
                  colors: widget.imageColors ?? widget.fallbackColors,
                ),
          _buildFrostOverlay(),
        ],
      ),
    );
  }

  Widget _buildFrostOverlay() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: SizedBox.expand(
          child: Container(
            color: Theme.of(
              context,
            ).colorScheme.onSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
