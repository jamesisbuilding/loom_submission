import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:design_system/src/utils/animated_press_mixin.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class UploadTile extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onTap;
  final bool shimmerEnabled;

  const UploadTile({
    super.key,
    this.child,
    this.onTap,
    this.shimmerEnabled = false,
  });

  @override
  State<UploadTile> createState() => _UploadTileState();
}

class _UploadTileState extends State<UploadTile> with AnimatedPressMixin {
  @override
  void onPressComplete() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return buildPressable(
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(0),
        child: Shimmer(
          enabled: widget.shimmerEnabled,
          child: LiquidGlassLayer(
            settings: LiquidGlassSettings(
              thickness: 20,
              blur: 10,
              glassColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            child: LiquidGlass(
              shape: LiquidRoundedSuperellipse(borderRadius: 4),
              child: Container(
                height: 300,
                width: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.08),
                      offset: const Offset(0, 8),
                      blurRadius: 18,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
