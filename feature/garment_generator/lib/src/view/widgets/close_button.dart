import 'package:delayed_display/delayed_display.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class CustomCloseButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool visible;
  const CustomCloseButton({
    super.key,
    required this.onTap,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: 40,
      child: DelayedDisplay(
        slidingBeginOffset: const Offset(0, 0),
        child: CustomIconButton(onTap: () => onTap(), icon: Icon(Icons.close)),
      ),
    );
  }
}
