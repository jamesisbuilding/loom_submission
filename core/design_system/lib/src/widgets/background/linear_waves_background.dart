import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fast_noise/fast_noise.dart';

// ---------------------------------------------------------------------------
// Noise preset — everything needed to describe one noise configuration
// ---------------------------------------------------------------------------
class NoisePreset {
  final String label;
  final String description;
  final NoiseType noiseType;
  final int octaves;
  final double frequency;
  final FractalType fractalType;
  final CellularReturnType cellularReturnType;
  final CellularDistanceFunction cellularDistanceFunction;

  const NoisePreset({
    required this.label,
    required this.description,
    required this.noiseType,
    this.octaves = 1,
    this.frequency = 0.002,
    this.fractalType = FractalType.fbm,
    this.cellularReturnType = CellularReturnType.cellValue,
    this.cellularDistanceFunction = CellularDistanceFunction.euclidean,
  });
}

// ---------------------------------------------------------------------------
// Only the Cubic preset, as default and only option
// ---------------------------------------------------------------------------
const NoisePreset kCubicNoisePreset = NoisePreset(
  label: 'Cubic',
  description: 'Smoother interpolation than Perlin.',
  noiseType: NoiseType.cubic,
  frequency: 0.002,
);

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------
class WavePoint {
  final double x, y;
  double waveX = 0, waveY = 0;
  double cursorX = 0, cursorY = 0;
  double vx = 0, vy = 0;
  WavePoint(this.x, this.y);
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class LinearWavesBackground extends StatefulWidget {
  final Color backgroundColor;
  final Color lineColor;

  const LinearWavesBackground({
    super.key,
    this.backgroundColor = const Color(0xFFF40C3F),
    this.lineColor = const Color(0xFF160000),
  });

  @override
  State<LinearWavesBackground> createState() => _LinearWavesBackgroundState();
}

class _LinearWavesBackgroundState extends State<LinearWavesBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  // Only ever use one noise preset: cubic
  late dynamic _noise;

  double _mx = -10, _my = 0;
  double _lx = 0, _ly = 0;
  double _sx = 0, _sy = 0;
  double _vs = 0, _a = 0;
  bool _mouseSet = false;

  final List<List<WavePoint>> _lines = [];
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _buildNoise();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // ── Build noise object from cubic preset only ─────────────────────────────

  void _buildNoise() {
    final p = kCubicNoisePreset;
    _noise = buildNoise(
      seed: math.Random().nextInt(99999),
      noiseType: p.noiseType,
      octaves: p.octaves,
      frequency: p.frequency,
      fractalType: p.fractalType,
      cellularReturnType: p.cellularReturnType,
      cellularDistanceFunction: p.cellularDistanceFunction,
    );
  }

  // ── Tick ──────────────────────────────────────────────────────────────────

  void _tick(Duration elapsed) {
    final double t = elapsed.inMilliseconds.toDouble();

    _sx += (_mx - _sx) * 0.1;
    _sy += (_my - _sy) * 0.1;

    final double dx = _mx - _lx;
    final double dy = _my - _ly;
    final double d = math.sqrt(dx * dx + dy * dy);
    _vs += (d - _vs) * 0.1;
    _vs = _vs.clamp(0, 100);
    _a = math.atan2(dy, dx);
    _lx = _mx;
    _ly = _my;

    _movePoints(t);
    setState(() {});
  }

  // ── Point simulation ──────────────────────────────────────────────────────

  void _movePoints(double time) {
    for (final points in _lines) {
      for (final p in points) {
        // getNoise2 is the per-point call on the built noise object
        final double move =
            _noise.getNoise2(p.x + time * 0.0125, p.y + time * 0.005) * 12.0;

        p.waveX = math.cos(move) * 32.0;
        p.waveY = math.sin(move) * 16.0;

        final double cdx = p.x - _sx;
        final double cdy = p.y - _sy;
        final double cd = math.sqrt(cdx * cdx + cdy * cdy);
        final double l = math.max(175.0, _vs);

        if (cd < l) {
          final double s = 1 - cd / l;
          final double f = math.cos(cd * 0.001) * s;
          p.vx += math.cos(_a) * f * l * _vs * 0.00065;
          p.vy += math.sin(_a) * f * l * _vs * 0.00065;
        }

        p.vx += (0 - p.cursorX) * 0.005;
        p.vy += (0 - p.cursorY) * 0.005;
        p.vx *= 0.925;
        p.vy *= 0.925;
        p.cursorX += p.vx * 2.0;
        p.cursorY += p.vy * 2.0;
        p.cursorX = p.cursorX.clamp(-100.0, 100.0);
        p.cursorY = p.cursorY.clamp(-100.0, 100.0);
      }
    }
  }

  // ── Grid init ─────────────────────────────────────────────────────────────

  void _initLines(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (_lines.isNotEmpty && size == _lastSize) return;

    _lines.clear();
    _lastSize = size;

    const double xGap = 10;
    const double yGap = 32;

    final double oWidth = size.width + 200;
    final double oHeight = size.height + 30;

    final int totalLines = (oWidth / xGap).ceil();
    final int totalPoints = (oHeight / yGap).ceil();

    final double xStart = (size.width - xGap * totalLines) / 2;
    final double yStart = (size.height - yGap * totalPoints) / 2;

    for (int i = 0; i <= totalLines; i++) {
      _lines.add(
        List<WavePoint>.generate(
          totalPoints + 1,
          (j) => WavePoint(xStart + xGap * i, yStart + yGap * j),
        ),
      );
    }
  }

  // ── Input ─────────────────────────────────────────────────────────────────

  void _updateMouse(double x, double y) {
    _mx = x;
    _my = y;
    if (!_mouseSet) {
      _sx = x;
      _sy = y;
      _lx = x;
      _ly = y;
      _mouseSet = true;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColoredBox(
        color: widget.backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            _initLines(size);

            return MouseRegion(
              onHover: (e) =>
                  _updateMouse(e.localPosition.dx, e.localPosition.dy),
              child: GestureDetector(
                onPanUpdate: (e) =>
                    _updateMouse(e.localPosition.dx, e.localPosition.dy),
                // No tap gesture needed, UI is always hidden
                child: Stack(
                  children: [
                    // ── Wave canvas ───────────────────────────────────────────────
                    CustomPaint(
                      painter: _WavePainter(
                        lines: _lines,
                        lineColor: widget.lineColor,
                      ),
                      size: Size.infinite,
                    ),
                    // ── Cursor dot ────────────────────────────────────────────────
                    Positioned(
                      left: _sx - 2.5,
                      top: _sy - 2.5,
                      child: IgnorePointer(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: widget.lineColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                    // No menus or overlays, only cubic shown
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------
class _WavePainter extends CustomPainter {
  final List<List<WavePoint>> lines;
  final Color lineColor;

  _WavePainter({required this.lines, required this.lineColor});

  Offset _moved(WavePoint p, {required bool withCursor}) {
    double x = p.x + p.waveX + (withCursor ? p.cursorX : 0);
    double y = p.y + p.waveY + (withCursor ? p.cursorY : 0);
    return Offset((x * 10).roundToDouble() / 10, (y * 10).roundToDouble() / 10);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final points in lines) {
      final path = Path();
      final start = _moved(points[0], withCursor: false);
      path.moveTo(start.dx, start.dy);

      for (int i = 0; i < points.length; i++) {
        final p = _moved(points[i], withCursor: i != points.length - 1);
        path.lineTo(p.dx, p.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.lines != lines || old.lineColor != lineColor;
}
