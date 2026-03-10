
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin AnimatedPressMixin<T extends StatefulWidget> on State<T> {
  bool _expanded = false;

  /// Whether the button is in its expanded (normal) state.
  bool get isExpanded => _expanded;

  /// Delay before animate-in starts (in milliseconds).
  /// Override to customize.
  int get animateInDelay => 250;

  /// Duration of the press animation (in milliseconds).
  /// Override to customize.
  int get pressDuration => 75;

  /// Scale when pressed down.
  /// Override to customize.
  double get pressedScale => 0.9;

  /// Scale animation duration (in milliseconds).
  /// Override to customize.
  int get scaleDuration => 200;

  /// Scale animation curve.
  /// Override to customize.
  Curve get scaleCurve => Curves.easeOutBack;

  /// Called when the press animation completes.
  /// Override this to handle the tap callback.
  void onPressComplete();

  /// Whether long press is enabled. Override to return true when you override [onLongPressComplete].
  /// When false, [InkWell] is not given an [onLongPress] handler.
  bool get enableLongPress => false;

  /// Called when a press and hold (long press) completes.
  /// Override this to handle long-press logic, and override [enableLongPress] to return true.
  /// Default does nothing.
  void onLongPressComplete() {}

  @override
  void initState() {
    super.initState();
    _animateIn();
  }

  Future<void> _animateIn() async {
    await Future.delayed(Duration(milliseconds: animateInDelay));
    if (mounted) {
      setState(() {
        _expanded = true;
      });
    }
  }

  void handleTapCancel() {
    setState(() {
      _expanded = true;
    });
  }

  void handleTapDown() {
    HapticFeedback.lightImpact();
    setState(() {
      _expanded = false;
    });
  }

  void handleTapUp() {
    HapticFeedback.mediumImpact();
    setState(() {
      _expanded = true;
    });
  }

  Future<void> handleOnTap() async {
    handleTapDown();
    await Future.delayed(Duration(milliseconds: pressDuration));
    handleTapUp();
    onPressComplete();
  }

  Future<void> handleOnLongPress() async {
    handleTapDown();
    // The long press default duration is 500ms in Flutter, but you can adjust if needed
    await Future.delayed(Duration(milliseconds: 400));
    handleTapUp();
    onLongPressComplete();
  }

  Widget buildPressable({
    required Widget child,
    bool enableScale = true,
  
  }) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      child: InkWell(
        splashColor: Colors.transparent,
      
        onTap: () async => await handleOnTap(),
        onTapCancel: handleTapCancel,
        onTapDown: (_) => handleTapDown(),
        onLongPress: enableLongPress
            ? () async {
                await handleOnLongPress();
                onLongPressComplete();
              }
            : null,
        child: enableScale
            ? AnimatedScale(
                scale: _expanded ? 1.0 : pressedScale,
                duration: Duration(milliseconds: scaleDuration),
                curve: scaleCurve,
                child: child,
              )
            : child,
      ),
    );
  }
}