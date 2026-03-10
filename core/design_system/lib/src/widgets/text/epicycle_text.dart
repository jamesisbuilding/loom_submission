
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';


// ---------------------------------------------------------------------------
// Vec3 — minimal 3D vector
// ---------------------------------------------------------------------------
class Vec3 {
  final double x, y, z;
  const Vec3(this.x, this.y, this.z);
  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 operator *(double s) => Vec3(x * s, y * s, z * s);
  double get length => math.sqrt(x * x + y * y + z * z);
  Vec3 get normalized {
    final l = length;
    return l == 0 ? const Vec3(0, 0, 0) : Vec3(x / l, y / l, z / l);
  }
  Vec3 cross(Vec3 o) => Vec3(
    y * o.z - z * o.y,
    z * o.x - x * o.z,
    x * o.y - y * o.x,
  );
  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;
}

// ---------------------------------------------------------------------------
// Arm definition — mirrors JS arms array
// ---------------------------------------------------------------------------
class Arm {
  final double length;
  final Vec3   rotation; // Euler XYZ in radians
  final double frequency;
  const Arm({required this.length, required this.rotation, required this.frequency});
}

// Default arms from the JS source
const List<Arm> _defaultArms = [
  Arm(length: 0.36, rotation: Vec3(0, 0, 0),             frequency: 1),
  Arm(length: 0.43, rotation: Vec3(1.66, 0, 0),           frequency: 4),
  Arm(length: 0.19, rotation: Vec3(3.68, 1.54, 1.71),     frequency: 5),
];

// ---------------------------------------------------------------------------
// Matrix4 — only what we need: Euler rotation + vector transform
// ---------------------------------------------------------------------------
class _Mat3 {
  // Row-major 3x3
  final List<double> m;
  const _Mat3(this.m);

  static _Mat3 fromEulerXYZ(double rx, double ry, double rz) {
    final cx = math.cos(rx), sx = math.sin(rx);
    final cy = math.cos(ry), sy = math.sin(ry);
    final cz = math.cos(rz), sz = math.sin(rz);
    // R = Rz * Ry * Rx
    return _Mat3([
      cy*cz,  cz*sx*sy - cx*sz,  cx*cz*sy + sx*sz,
      cy*sz,  cx*cz + sx*sy*sz,  cx*sy*sz - cz*sx,
      -sy,    cy*sx,             cx*cy,
    ]);
  }

  Vec3 transform(Vec3 v) => Vec3(
    m[0]*v.x + m[1]*v.y + m[2]*v.z,
    m[3]*v.x + m[4]*v.y + m[5]*v.z,
    m[6]*v.x + m[7]*v.y + m[8]*v.z,
  );
}

// ---------------------------------------------------------------------------
// Spline — CatmullRom implemented in Dart, arc-length parameterised
// ---------------------------------------------------------------------------
class CatmullRomSpline {
  final List<Vec3> _pts;
  final List<double> _arc; // cumulative arc length
  final double totalLength;

  CatmullRomSpline._(this._pts, this._arc, this.totalLength);

  factory CatmullRomSpline.fromControlPoints(List<Vec3> ctrl, {int samples = 4000}) {
    final pts = <Vec3>[];
    final n = ctrl.length;

    for (int i = 0; i < samples; i++) {
      final t = i / (samples - 1);
      pts.add(_catmullRomAt(ctrl, t, n));
    }

    final arc = <double>[0];
    double cum = 0;
    for (int i = 1; i < pts.length; i++) {
      cum += (pts[i] - pts[i-1]).length;
      arc.add(cum);
    }
    return CatmullRomSpline._(pts, arc, cum);
  }

  static Vec3 _catmullRomAt(List<Vec3> pts, double t, int n) {
    final seg  = (t * (n - 1)).floor().clamp(0, n - 2);
    final local = t * (n - 1) - seg;
    final p0 = pts[(seg - 1).clamp(0, n - 1)];
    final p1 = pts[seg];
    final p2 = pts[(seg + 1).clamp(0, n - 1)];
    final p3 = pts[(seg + 2).clamp(0, n - 1)];
    return _cr(p0, p1, p2, p3, local);
  }

  static Vec3 _cr(Vec3 p0, Vec3 p1, Vec3 p2, Vec3 p3, double t) {
    final t2 = t * t, t3 = t2 * t;
    return Vec3(
      0.5 * ((2*p1.x) + (-p0.x+p2.x)*t + (2*p0.x-5*p1.x+4*p2.x-p3.x)*t2 + (-p0.x+3*p1.x-3*p2.x+p3.x)*t3),
      0.5 * ((2*p1.y) + (-p0.y+p2.y)*t + (2*p0.y-5*p1.y+4*p2.y-p3.y)*t2 + (-p0.y+3*p1.y-3*p2.y+p3.y)*t3),
      0.5 * ((2*p1.z) + (-p0.z+p2.z)*t + (2*p0.z-5*p1.z+4*p2.z-p3.z)*t2 + (-p0.z+3*p1.z-3*p2.z+p3.z)*t3),
    );
  }

  // Arc-length → world position
  Vec3 atArc(double s) {
    final w = s % totalLength;
    int lo = 0, hi = _pts.length - 1;
    while (lo < hi - 1) {
      final mid = (lo + hi) >> 1;
      if (_arc[mid] < w) lo = mid; else hi = mid;
    }
    final span = _arc[hi] - _arc[lo];
    final f    = span == 0 ? 0.0 : (w - _arc[lo]) / span;
    final a = _pts[lo], b = _pts[hi];
    return Vec3(a.x + (b.x-a.x)*f, a.y + (b.y-a.y)*f, a.z + (b.z-a.z)*f);
  }

  // Tangent via forward difference
  Vec3 tangentAt(double s) {
    final eps = totalLength * 0.0003;
    final a = atArc(s);
    final b = atArc(s + eps);
    return (b - a).normalized;
  }
}

// ---------------------------------------------------------------------------
// Geometry builder — mirrors calculateSplinePoints + drawCircleAroundPoint
// ---------------------------------------------------------------------------
Vec3 _drawCircleAroundPoint(
    Vec3 origin, Vec3 rotation, double length, int step, int total, double freq) {
  final angle = (step / total) * math.pi * 2 * freq;
  final local = Vec3(length * math.cos(angle), length * math.sin(angle), 0);
  final mat = _Mat3.fromEulerXYZ(rotation.x, rotation.y, rotation.z);
  return mat.transform(local) + origin;
}

CatmullRomSpline buildSpline(List<Arm> arms, {int numPoints = 1000}) {
  final pts = <Vec3>[];
  for (int step = 0; step <= numPoints; step++) {
    final p1 = _drawCircleAroundPoint(
      const Vec3(0,0,0), arms[0].rotation, arms[0].length, step, numPoints, arms[0].frequency);
    final p2 = arms.length > 1
      ? _drawCircleAroundPoint(p1, arms[1].rotation, arms[1].length, step, numPoints, arms[1].frequency)
      : p1;
    final p3 = arms.length > 2
      ? _drawCircleAroundPoint(p2, arms[2].rotation, arms[2].length, step, numPoints, arms[2].frequency)
      : p2;
    pts.add(p3);
  }
  return CatmullRomSpline.fromControlPoints(pts);
}

// ---------------------------------------------------------------------------
// EpicycleText widget
// ---------------------------------------------------------------------------

/// A widget that paints an animated "epicyclic" text effect with the supplied string.
/// All UI scaffolding has been removed; this is just a painter for the effect.
/// 
/// The painted text is equal to the input [text] (repeated if desired for the effect).
class EpicycleText extends StatefulWidget {
  final String text;
  final double fontSize;
  final double tickerSpeed;
  final int wordRepeats;
  final List<Arm> arms;

  // Optionally allow custom arms, fontSize, speed, repeats.
  const EpicycleText({
    super.key,
    required this.text,
    this.fontSize = 18.0,
    this.tickerSpeed = 3.0,
    this.wordRepeats = 14,
    this.arms = _defaultArms,
  });

  @override
  State<EpicycleText> createState() => _EpicycleTextState();
}

class _EpicycleTextState extends State<EpicycleText>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;

  late CatmullRomSpline _spline;

  // View rotation (auto-rotate; see original logic)
  double _viewRotX = 0.3 + math.pi;
  double _viewRotY = 0.0;

  // Drag state for manual orbit (optional—can be omitted for minimalism)
  Offset? _dragStart;
  double  _dragBaseX = 0, _dragBaseY = 0;

  @override
  void initState() {
    super.initState();
    _spline = buildSpline(widget.arms);
    _ticker = createTicker((elapsed) {
      setState(() { _time = elapsed.inMicroseconds / 1e6; });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  // Helper: apply 3D orbit rotation
  Vec3 _applyView(Vec3 p) {
    final ay = _time * 0.18 + _viewRotY;
    final ax = _viewRotX;

    // Rotate Y
    double x = p.x * math.cos(ay) + p.z * math.sin(ay);
    double z = -p.x * math.sin(ay) + p.z * math.cos(ay);
    double y = p.y;

    // Rotate X
    final y2 = y * math.cos(ax) - z * math.sin(ax);
    final z2 = y * math.sin(ax) + z * math.cos(ax);
    return Vec3(x, y2, z2);
  }

  // Helper: perspective projection to screen (centered in CustomPaint)
  (Offset, double) _project(Vec3 world, Size size) {
    final v    = _applyView(world);
    const fov  = 2.2;
    final d    = v.z + fov;
    final s    = fov / (d == 0 ? 0.001 : d);
    final r    = math.min(size.width, size.height) * 0.42;
    return (
      Offset(size.width * 0.5 + v.x * r * s, size.height * 0.5 - v.y * r * s),
      ((v.z + 1.2) / 2.4).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          painter: _EpicyclePainter(
            spline:      _spline,
            word:        widget.text,
            time:        _time,
            size:        size,
            tickerSpeed: widget.tickerSpeed,
            wordRepeats: widget.wordRepeats,
            fontSize:    widget.fontSize,
            project:     (v) => _project(v, size),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------
class _EpicyclePainter extends CustomPainter {
  final CatmullRomSpline spline;
  final String  word;
  final double  time, tickerSpeed, fontSize;
  final int     wordRepeats;
  final Size    size;
  final (Offset, double) Function(Vec3) project;

  _EpicyclePainter({
    required this.spline,
    required this.word,
    required this.time,
    required this.tickerSpeed,
    required this.wordRepeats,
    required this.fontSize,
    required this.size,
    required this.project,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (word.isEmpty) return;

    // Arc spacing per character — proportional to fontSize relative to curve
    final double charArc =
        spline.totalLength / (word.length * wordRepeats) * 0.92;

    // Advance head over time — ticker
    final double head = (time * tickerSpeed * charArc) % spline.totalLength;

    // Build full repeated string
    final String full = (word + ' ') * wordRepeats;

    // Collect render data, sort back-to-front
    final chars = <_CD>[];

    for (int i = 0; i < full.length; i++) {
      final ch = full[i];
      if (ch == ' ') continue;

      final double arcPos = (head + i * charArc) % spline.totalLength;
      final Vec3   wPos   = spline.atArc(arcPos);
      final Vec3   wNext  = spline.atArc(arcPos + charArc * 0.5);

      final (Offset scr,  double d0) = project(wPos);
      final (Offset scrN, double _)  = project(wNext);

      // Skip off-screen
      if (scr.dx < -80 || scr.dx > size.width  + 80) continue;
      if (scr.dy < -80 || scr.dy > size.height + 80) continue;

      final double angle   = math.atan2(scrN.dy - scr.dy, scrN.dx - scr.dx);
      final double scale   = 0.4 + d0 * 1.1;
      final bool   flipped = d0 < 0.32;

      chars.add(_CD(ch, scr, angle, scale, d0, flipped));
    }

    chars.sort((a, b) => a.depth.compareTo(b.depth));

    for (final c in chars) {
      canvas.save();
      canvas.translate(c.pos.dx, c.pos.dy);
      canvas.rotate(c.angle);
      if (c.flipped) canvas.scale(-1, 1);

      final double sz      = fontSize * c.scale;
      // final double opacity = (c.depth * 1.3).clamp(0.12, 1.0);
      // Color: deep violet far → bright white/cyan close
      final Color col = Color.lerp(
        const Color(0xFF2A0845),
        const Color(0xFFDDF4FF),
        c.depth,
      )!; 
      // !.withValues(alpha: opacity);

      final tp = TextPainter(
        text: TextSpan(
          text: c.ch,
          style: TextStyle(
            color:       col,
            fontSize:    sz,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            shadows: [
              Shadow(
                // color:      col.withValues(alpha: 0.7),
                // blurRadius: sz * 0.5,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EpicyclePainter old) =>
      old.time != time || old.word != word;
}

// Render data container
class _CD {
  final String ch;
  final Offset pos;
  final double angle, scale, depth;
  final bool   flipped;
  const _CD(this.ch, this.pos, this.angle, this.scale, this.depth, this.flipped);
}
