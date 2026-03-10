import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImagePaletteService {
  const ImagePaletteService();

  List<Color> extractRandomColorsFromBytes(
    Uint8List bytes, {
    int count = 5,
  }) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null || decoded.width == 0 || decoded.height == 0) {
      return const <Color>[];
    }

    final seed = _fnv1a32(bytes);
    final rnd = Random(seed);

    final maxAttempts = max(200, count * 80);
    final colors = <Color>[];

    for (var attempts = 0;
        attempts < maxAttempts && colors.length < count;
        attempts++) {
      final x = rnd.nextInt(decoded.width);
      final y = rnd.nextInt(decoded.height);

      final p = decoded.getPixel(x, y);
      final a = p.a.toInt();
      if (a < 40) continue;

      final c = Color.fromARGB(
        a,
        p.r.toInt(),
        p.g.toInt(),
        p.b.toInt(),
      );

      if (_isDistinctEnough(colors, c)) {
        colors.add(c);
      }
    }

    return colors;
  }

  static bool _isDistinctEnough(List<Color> existing, Color candidate) {
    for (final e in existing) {
      final dr = (e.red - candidate.red).abs();
      final dg = (e.green - candidate.green).abs();
      final db = (e.blue - candidate.blue).abs();
      if (dr + dg + db < 60) return false;
    }
    return true;
  }

  static int _fnv1a32(Uint8List bytes) {
    var hash = 0x811c9dc5;
    for (final b in bytes) {
      hash ^= b;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }
}

