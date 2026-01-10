import 'dart:ui';

import 'package:flutter/painting.dart' show HSLColor;

/// Color için yardımcı extension metodları.
extension ColorExtension on Color {
  // -------------------------------------------------------------------------
  // Yardımcı getter'lar (0-255 int değerler)
  // -------------------------------------------------------------------------

  int get _red => (r * 255).round();
  int get _green => (g * 255).round();
  int get _blue => (b * 255).round();
  int get _alpha => (a * 255).round();

  /// Rengi belirli bir opacity ile döndürür.
  Color withOpacityValue(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  /// Rengi açar (beyaza yaklaştırır).
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Rengi koyulaştırır (siyaha yaklaştırır).
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Rengin tamamlayıcısını (complementary) döndürür.
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }

  /// Rengin gri tonunu döndürür.
  Color get grayscale {
    final gray = (0.299 * _red + 0.587 * _green + 0.114 * _blue).round();
    return Color.fromARGB(_alpha, gray, gray, gray);
  }

  /// Rengin tersini döndürür.
  Color get inverted {
    return Color.fromARGB(_alpha, 255 - _red, 255 - _green, 255 - _blue);
  }

  /// İki renk arasında interpolasyon.
  Color lerpTo(Color other, double t) {
    return Color.lerp(this, other, t) ?? this;
  }

  /// Kontrast renk (siyah veya beyaz).
  Color get contrastColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Renk açık mı?
  bool get isLight => computeLuminance() > 0.5;

  /// Renk koyu mu?
  bool get isDark => !isLight;

  /// Hex string'e dönüştürür (#RRGGBB).
  String toHex({bool includeAlpha = false}) {
    if (includeAlpha) {
      return '#${_alpha.toRadixString(16).padLeft(2, '0')}'
              '${_red.toRadixString(16).padLeft(2, '0')}'
              '${_green.toRadixString(16).padLeft(2, '0')}'
              '${_blue.toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();
    }
    return '#${_red.toRadixString(16).padLeft(2, '0')}'
            '${_green.toRadixString(16).padLeft(2, '0')}'
            '${_blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  /// RGB string'e dönüştürür.
  String toRgbString() {
    return 'rgb($_red, $_green, $_blue)';
  }

  /// RGBA string'e dönüştürür.
  String toRgbaString() {
    return 'rgba($_red, $_green, $_blue, ${a.toStringAsFixed(2)})';
  }
}

/// Color factory yardımcı sınıfı.
abstract final class ColorUtils {
  /// Hex string'den Color oluşturur.
  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// HSL değerlerinden Color oluşturur.
  static Color fromHSL(double h, double s, double l, [double a = 1.0]) {
    return HSLColor.fromAHSL(a, h, s, l).toColor();
  }
}
