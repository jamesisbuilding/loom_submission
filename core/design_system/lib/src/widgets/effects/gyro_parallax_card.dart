import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Wraps [child] with a 3D tilt effect driven by the device gyroscope.
/// When [enabled] is false, returns [child] unchanged.
/// Only activates on mobile (iOS/Android); no-op on web/desktop.
class GyroParallaxCard extends StatefulWidget {
  const GyroParallaxCard({
    super.key,
    required this.child,
    this.enabled = true,
    this.maxTiltDegrees = 8,
    this.sensitivity = 0.6,
    this.smoothing = 0.85,
    this.gyroscopeStream,
  });

  final Widget child;
  final bool enabled;
  final double maxTiltDegrees;
  final double sensitivity;
  final double smoothing;

  /// For tests: when provided, this stream is used instead of device gyroscope.
  final Stream<GyroscopeEvent>? gyroscopeStream;

  @override
  State<GyroParallaxCard> createState() => _GyroParallaxCardState();
}

class _GyroParallaxCardState extends State<GyroParallaxCard> {
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  final ValueNotifier<({double x, double y})> _tilt = ValueNotifier((
    x: 0.0,
    y: 0.0,
  ));
  bool _gyroAvailable = false;

  double _targetX = 0.0;
  double _targetY = 0.0;

  static const _radToDeg = 180 / math.pi;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _startGyro();
  }

  @override
  void didUpdateWidget(covariant GyroParallaxCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled ||
        widget.gyroscopeStream != oldWidget.gyroscopeStream) {
      if (widget.enabled) {
        _startGyro();
      } else {
        _stopGyro();
        _resetTilt();
      }
    }
  }

  void _startGyro() {
    _gyroSubscription?.cancel();
    final stream = widget.gyroscopeStream;

    if (stream != null) {
      _gyroSubscription = stream.listen(_onGyro);
      _gyroAvailable = true;
      return;
    }

    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      try {
        _gyroSubscription = gyroscopeEventStream(
          samplingPeriod: const Duration(milliseconds: 16),
        ).listen(_onGyro);
        _gyroAvailable = true;
      } catch (_) {
        _gyroAvailable = false;
      }
    } else {
      _gyroAvailable = false;
    }
  }

  void _stopGyro() {
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _gyroAvailable = false;
  }

  void _resetTilt() {
    _targetX = 0.0;
    _targetY = 0.0;
    _tilt.value = (x: 0.0, y: 0.0);
  }

  void _onGyro(GyroscopeEvent e) {
    if (!mounted || !_gyroAvailable) return;

    final maxRad = widget.maxTiltDegrees / _radToDeg;
    final sens = widget.sensitivity;
    final smooth = widget.smoothing;
    const dt = 0.016;

    _targetX += e.y * sens * dt;
    _targetY += -e.x * sens * dt;

    _targetX = _targetX.clamp(-maxRad, maxRad);
    _targetY = _targetY.clamp(-maxRad, maxRad);

    final prev = _tilt.value;
    final newX = prev.x + (_targetX - prev.x) * (1 - smooth);
    final newY = prev.y + (_targetY - prev.y) * (1 - smooth);
    _tilt.value = (x: newX, y: newY);
  }

  @override
  void dispose() {
    _stopGyro();
    _tilt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !_gyroAvailable) return widget.child;

    return ValueListenableBuilder<({double x, double y})>(
      valueListenable: _tilt,
      builder: (context, tilt, _) {
        return RepaintBoundary(
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(tilt.y)
              ..rotateY(tilt.x),
            child: widget.child,
          ),
        );
      },
    );
  }
}

