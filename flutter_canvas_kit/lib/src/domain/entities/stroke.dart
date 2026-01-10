import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_style.dart';

/// Tek bir çizgi (fırça darbesi).
///
/// Bir veya daha fazla [StrokePoint]'ten oluşur.
/// Immutable entity.
final class Stroke {
  /// Benzersiz kimlik.
  final String id;

  /// Çizgiyi oluşturan noktalar.
  final List<StrokePoint> points;

  /// Çizgi stili.
  final StrokeStyle style;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  /// Önbelleğe alınmış bounding box.
  Rect? _cachedBoundingBox;

  Stroke({
    required this.id,
    required this.points,
    required this.style,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Yeni benzersiz ID ile stroke oluşturur.
  factory Stroke.create({
    required List<StrokePoint> points,
    required StrokeStyle style,
  }) {
    return Stroke(
      id: _generateId(),
      points: List.unmodifiable(points),
      style: style,
    );
  }

  /// Basit ID üreteci.
  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  /// Çizgi boş mu?
  bool get isEmpty => points.isEmpty;

  /// Çizgide kaç nokta var?
  int get pointCount => points.length;

  /// İlk nokta.
  StrokePoint? get firstPoint => points.isNotEmpty ? points.first : null;

  /// Son nokta.
  StrokePoint? get lastPoint => points.isNotEmpty ? points.last : null;

  /// Sınırlayıcı kutu.
  Rect get boundingBox {
    if (_cachedBoundingBox != null) return _cachedBoundingBox!;

    if (points.isEmpty) {
      _cachedBoundingBox = Rect.zero;
      return _cachedBoundingBox!;
    }

    double minX = points.first.x;
    double minY = points.first.y;
    double maxX = points.first.x;
    double maxY = points.first.y;

    for (final point in points) {
      if (point.x < minX) minX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }

    // Çizgi kalınlığını hesaba kat
    final padding = style.width / 2;
    _cachedBoundingBox = Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );

    return _cachedBoundingBox!;
  }

  /// Toplam çizgi uzunluğu.
  double get totalLength {
    if (points.length < 2) return 0;

    double length = 0;
    for (int i = 1; i < points.length; i++) {
      length += points[i - 1].distanceTo(points[i]);
    }
    return length;
  }

  /// Bir noktanın çizgiye yakın olup olmadığını kontrol eder.
  bool hitTest(Offset point, {double tolerance = 10.0}) {
    // Önce bounding box kontrolü
    if (!boundingBox.inflate(tolerance).contains(point)) {
      return false;
    }

    // Her segment için mesafe kontrolü
    for (int i = 0; i < points.length - 1; i++) {
      final distance = _pointToSegmentDistance(
        point,
        points[i].offset,
        points[i + 1].offset,
      );
      if (distance <= tolerance + style.width / 2) {
        return true;
      }
    }

    // Tek nokta kontrolü
    if (points.length == 1) {
      final dx = point.dx - points.first.x;
      final dy = point.dy - points.first.y;
      return (dx * dx + dy * dy) <=
          (tolerance + style.width / 2) * (tolerance + style.width / 2);
    }

    return false;
  }

  /// Nokta-segment mesafesi hesaplar.
  double _pointToSegmentDistance(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;

    final abLengthSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abLengthSquared == 0) {
      return (p - a).distance;
    }

    final t =
        ((ap.dx * ab.dx + ap.dy * ab.dy) / abLengthSquared).clamp(0.0, 1.0);
    final closest = Offset(a.dx + t * ab.dx, a.dy + t * ab.dy);

    return (p - closest).distance;
  }

  /// Çizgiyi taşır.
  Stroke translate(double dx, double dy) {
    return Stroke(
      id: id,
      points: points.map((p) => p.translate(dx, dy)).toList(),
      style: style,
      createdAt: createdAt,
    );
  }

  /// Çizgiyi ölçekler.
  Stroke scale(double factor, Offset center) {
    return Stroke(
      id: id,
      points: points
          .map((p) => p.scaleAround(factor, center.dx, center.dy))
          .toList(),
      style: style,
      createdAt: createdAt,
    );
  }

  /// Nokta ekler (yeni stroke döndürür).
  Stroke addPoint(StrokePoint point) {
    return Stroke(
      id: id,
      points: [...points, point],
      style: style,
      createdAt: createdAt,
    );
  }

  /// Noktaları basitleştirir (Ramer-Douglas-Peucker).
  Stroke simplify(double tolerance) {
    if (points.length < 3) return this;

    final simplified = _rdpSimplify(points, tolerance);
    return Stroke(
      id: id,
      points: simplified,
      style: style,
      createdAt: createdAt,
    );
  }

  /// Ramer-Douglas-Peucker algoritması.
  List<StrokePoint> _rdpSimplify(List<StrokePoint> pts, double epsilon) {
    if (pts.length < 3) return pts;

    double maxDistance = 0;
    int maxIndex = 0;

    final first = pts.first;
    final last = pts.last;

    for (int i = 1; i < pts.length - 1; i++) {
      final distance = _pointToSegmentDistance(
        pts[i].offset,
        first.offset,
        last.offset,
      );
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    if (maxDistance > epsilon) {
      final left = _rdpSimplify(pts.sublist(0, maxIndex + 1), epsilon);
      final right = _rdpSimplify(pts.sublist(maxIndex), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [first, last];
    }
  }

  Stroke copyWith({
    String? id,
    List<StrokePoint>? points,
    StrokeStyle? style,
    DateTime? createdAt,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? this.points,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points.map((p) => p.toJson()).toList(),
      'style': style.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Stroke.fromJson(Map<String, dynamic> json) {
    return Stroke(
      id: json['id'] as String,
      points: (json['points'] as List)
          .map((p) => StrokePoint.fromJson(p as Map<String, dynamic>))
          .toList(),
      style: StrokeStyle.fromJson(json['style'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stroke && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Stroke(id: $id, points: ${points.length})';
}
