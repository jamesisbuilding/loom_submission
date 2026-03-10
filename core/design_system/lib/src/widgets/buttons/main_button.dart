import 'package:delayed_display/delayed_display.dart';
import 'package:design_system/src/utils/animated_press_mixin.dart';
import 'package:design_system/src/widgets/buttons/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class MainButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final bool isLoading;
  final List<Widget> buttons;
  final int collapseSignal;
  final bool animateIn;

  const MainButton({
    super.key,
    required this.onTap,
    required this.label,
    this.isLoading = false,
    this.buttons = const [],
    this.collapseSignal = 0,
    this.animateIn = true,
  });

  @override
  State<MainButton> createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> with AnimatedPressMixin {
  bool _expanded = false;
  late bool _entered;
  double get height => _expanded ? 44 + (widget.buttons.length * 58) : 60;

  double get width => _expanded
      ? 50
      : widget.isLoading
      ? 40
      : 300;

  @override
  initState() {
    super.initState();

    _entered = !widget.animateIn;
    if (widget.animateIn) _animateIn();
  }

  Future<void> _animateIn() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _entered = true;
    });
  }

  @override
  void onPressComplete() {
    if (_expanded) return;
    widget.onTap();
  }

  @override
  bool get enableLongPress => true;

  @override
  void onLongPressComplete() {
    if (!_expanded && widget.buttons.isNotEmpty) {
      _expanded = true;
      setState(() {});
    }
  }

  _toggleExpanded({required bool value}) {
    _expanded = value;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant MainButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      setState(() {});
    }
    if (oldWidget.collapseSignal != widget.collapseSignal && _expanded) {
      _toggleExpanded(value: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildPressable(
      child: AnimatedSlide(
        offset: !_entered ? Offset(0, 2) : Offset(0, 0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Stack(
          children: [
            LiquidGlassLayer(
              settings: LiquidGlassSettings(
                thickness: 20,
                blur: 10,
                glassColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              child: LiquidGlass(
                shape: LiquidRoundedSuperellipse(borderRadius: 50),
                child: IntrinsicHeight(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Cubic(0.175, 0.885, 0.32, 1.1),
                    height: height,
                    width: width,
                    child: _expanded
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: SizedBox(
                              width: 40,
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: IntrinsicHeight(
                                  child: Column(
                                    spacing: 8,
                                    children: [
                                      CustomIconButton(
                                        onTap: () =>
                                            _toggleExpanded(value: false),
                                        icon: Icon(Icons.close),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: Divider(
                                          height: 1,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      ...widget.buttons.map(
                                        (b) => Expanded(child: b),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : widget.isLoading
                        ? SpinKitPianoWave(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 12,
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8,
                              ),
                              child: DelayedDisplay(
                                slidingBeginOffset: const Offset(0, 0),
                                child: Text(
                                  widget.label.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
