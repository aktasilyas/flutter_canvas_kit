import 'dart:ui';

/// Rect için yardımcı extension metodları.
extension RectExtension on Rect {
  /// Rect'in köşe noktaları.
  List<Offset> get corners => [
        topLeft,
        topRight,
        bottomRight,
        bottomLeft,
      ];

  /// Rect'in kenar orta noktaları.
  List<Offset> get edgeMidpoints => [
        Offset(center.dx, top), // Üst orta
        Offset(right, center.dy), // Sağ orta
        Offset(center.dx, bottom), // Alt orta
        Offset(left, center.dy), // Sol orta
      ];

  /// Rect'i genişletir (tüm yönlerde).
  Rect expand(double amount) {
    return Rect.fromLTRB(
      left - amount,
      top - amount,
      right + amount,
      bottom + amount,
    );
  }

  /// Rect'i daraltır (tüm yönlerde).
  Rect contract(double amount) {
    return expand(-amount);
  }

  /// Rect'i ölçekler (merkez etrafında).
  Rect scaleFromCenter(double factor) {
    final newWidth = width * factor;
    final newHeight = height * factor;
    return Rect.fromCenter(
      center: center,
      width: newWidth,
      height: newHeight,
    );
  }

  /// Rect'i taşır.
  Rect translate(double dx, double dy) {
    return shift(Offset(dx, dy));
  }

  /// Rect içinde bir nokta var mı?
  bool containsPoint(Offset point) {
    return contains(point);
  }

  /// Başka bir Rect ile kesişiyor mu?
  bool intersectsWith(Rect other) {
    return overlaps(other);
  }

  /// İki Rect'in kesişim alanı.
  Rect? intersectionWith(Rect other) {
    if (!overlaps(other)) return null;
    return intersect(other);
  }

  /// İki Rect'i kapsayan en küçük Rect.
  Rect union(Rect other) {
    return expandToInclude(other);
  }

  /// Aspect ratio (genişlik / yükseklik).
  double get aspectRatio {
    if (height == 0) return 0;
    return width / height;
  }

  /// Rect'in alanı.
  double get area => width * height;

  /// Rect'in çevresi.
  double get perimeter => 2 * (width + height);

  /// Rect'in diyagonal uzunluğu.
  double get diagonal {
    return topLeft.distanceTo(bottomRight);
  }

  /// Bir noktaya en yakın kenar noktası.
  Offset nearestPointTo(Offset point) {
    final x = point.dx.clamp(left, right);
    final y = point.dy.clamp(top, bottom);
    return Offset(x, y);
  }

  /// JSON'a dönüştürür.
  Map<String, double> toJson() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }
}

/// Rect factory extension.
extension RectFactory on Rect {
  /// JSON'dan Rect oluşturur.
  static Rect fromJson(Map<String, dynamic> json) {
    return Rect.fromLTRB(
      (json['left'] as num).toDouble(),
      (json['top'] as num).toDouble(),
      (json['right'] as num).toDouble(),
      (json['bottom'] as num).toDouble(),
    );
  }

  /// Offset listesinden bounding box oluşturur.
  static Rect fromPoints(List<Offset> points) {
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.dx;
    double minY = points.first.dy;
    double maxX = points.first.dx;
    double maxY = points.first.dy;

    for (final point in points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Offset için mesafe hesaplama (rect_extension'da kullanılıyor).
extension _OffsetDistance on Offset {
  double distanceTo(Offset other) {
    final dx = this.dx - other.dx;
    final dy = this.dy - other.dy;
    return (dx * dx + dy * dy).sqrt();
  }
}

/// double için sqrt (dart:math import etmeden).
extension _DoubleSqrt on double {
  double sqrt() {
    if (this <= 0) return 0;
    double guess = this / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + this / guess) / 2;
    }
    return guess;
  }
}
