import 'dart:math' as math;
import 'dart:ui';

/// Offset için yardımcı extension metodları.
extension OffsetExtension on Offset {
  /// İki nokta arasındaki mesafe.
  double distanceTo(Offset other) {
    final dx = this.dx - other.dx;
    final dy = this.dy - other.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// İki nokta arasındaki açı (radyan).
  double angleTo(Offset other) {
    return math.atan2(other.dy - dy, other.dx - dx);
  }

  /// Noktayı bir merkez etrafında döndürür.
  Offset rotateAround(Offset center, double radians) {
    final cosA = math.cos(radians);
    final sinA = math.sin(radians);
    final translated = this - center;

    return Offset(
      translated.dx * cosA - translated.dy * sinA + center.dx,
      translated.dx * sinA + translated.dy * cosA + center.dy,
    );
  }

  /// Noktayı bir merkez etrafında ölçekler.
  Offset scaleAround(Offset center, double factor) {
    return Offset(
      center.dx + (dx - center.dx) * factor,
      center.dy + (dy - center.dy) * factor,
    );
  }

  /// İki nokta arasında lineer interpolasyon.
  Offset lerpTo(Offset other, double t) {
    return Offset(
      dx + (other.dx - dx) * t,
      dy + (other.dy - dy) * t,
    );
  }

  /// Noktayı normalize eder (birim vektör).
  Offset get normalized {
    final length = distance;
    if (length == 0) return Offset.zero;
    return Offset(dx / length, dy / length);
  }

  /// Dik vektör (90 derece döndürülmüş).
  Offset get perpendicular => Offset(-dy, dx);

  /// Vektörün uzunluğu (orijinden mesafe).
  /// Not: Offset.distance zaten bunu veriyor, bu alias.
  double get length => distance;

  /// Vektörün uzunluğunun karesi (performans için).
  double get lengthSquared => dx * dx + dy * dy;

  /// İki vektörün dot product'ı.
  double dot(Offset other) {
    return dx * other.dx + dy * other.dy;
  }

  /// İki vektörün cross product'ı (2D'de skaler).
  double cross(Offset other) {
    return dx * other.dy - dy * other.dx;
  }

  /// Noktayı verilen sınırlar içine kısıtlar.
  Offset clampToRect(Rect bounds) {
    return Offset(
      dx.clamp(bounds.left, bounds.right),
      dy.clamp(bounds.top, bounds.bottom),
    );
  }

  /// JSON'a dönüştürür.
  Map<String, double> toJson() {
    return {'x': dx, 'y': dy};
  }
}

/// Offset için factory extension.
extension OffsetFactory on Offset {
  /// JSON'dan Offset oluşturur.
  static Offset fromJson(Map<String, dynamic> json) {
    return Offset(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
    );
  }
}
