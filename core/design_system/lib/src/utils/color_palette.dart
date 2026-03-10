import 'dart:ui';

const List<Color> defaultBackgroundFallbackPalette = [
  Color(0xFF6B4E9D),
  Color(0xFF4A47A3),
  Color(0xFF1E88E5),
];

List<Color> ensureMinColorCount(
  List<Color> colors, {
  int minCount = 4,
  List<Color> fallback = defaultBackgroundFallbackPalette,
}) {
  if (colors.length >= minCount) return colors;
  if (colors.isEmpty) {
    return ensureMinColorCount(
      List<Color>.of(fallback),
      minCount: minCount,
      fallback: fallback,
    );
  }
  final out = List<Color>.from(colors);
  while (out.length < minCount) {
    out.add(out[out.length % colors.length]);
  }
  return out;
}
