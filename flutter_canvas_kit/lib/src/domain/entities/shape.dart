import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/enums/shape_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_style.dart';

/// Geometrik şekil.
///
/// Dikdörtgen, daire, çizgi gibi vektörel şekilleri temsil eder.
/// Immutable entity.
final class Shape {
  /// Benzersiz kimlik.
  final String id;

  /// Şekil tipi.
  final ShapeType type;

  /// Başlangıç noktası.
  final Offset startPoint;

  /// Bitiş noktası.
  final Offset endPoint;

  /// Çizgi stili.
  final StrokeStyle style;

  /// Dolgulu mu?
  final bool isFilled;

  /// Dolgu rengi (null ise style.color kullanılır).
  final Color? fillColor;

  /// Köşe yarıçapı (rounded rectangle için).
  final double cornerRadius;

  /// Köşe sayısı (polygon, star için).
  final int pointCount;

  /// Döndürme açısı (radyan).
  final double rotation;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  const Shape({
    required this.id,
    required this.type,
    required this.startPoint,
    required this.endPoint,
    required this.style,
    this.isFilled = false,
    this.fillColor,
    this.cornerRadius = 0,
    this.pointCount = 4,
    this.rotation = 0,
    required this.createdAt,
  });

  /// Yeni shape oluşturur.
  factory Shape.create({
    required ShapeType type,
    required Offset startPoint,
    required Offset endPoint,
    required StrokeStyle style,
    bool isFilled = false,
    Color? fillColor,
    double cornerRadius = 0,
    int? pointCount,
    double rotation = 0,
  }) {
    return Shape(
      id: _generateId(),
      type: type,
      startPoint: startPoint,
      endPoint: endPoint,
      style: style,
      isFilled: isFilled,
      fillColor: fillColor,
      cornerRadius: cornerRadius,
      pointCount: pointCount ?? type.defaultPointCount,
      rotation: rotation,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  /// Sınırlayıcı kutu.
  Rect get boundingBox {
    final left = startPoint.dx < endPoint.dx ? startPoint.dx : endPoint.dx;
    final top = startPoint.dy < endPoint.dy ? startPoint.dy : endPoint.dy;
    final right = startPoint.dx > endPoint.dx ? startPoint.dx : endPoint.dx;
    final bottom = startPoint.dy > endPoint.dy ? startPoint.dy : endPoint.dy;

    final padding = style.width / 2;
    return Rect.fromLTRB(
      left - padding,
      top - padding,
      right + padding,
      bottom + padding,
    );
  }

  /// Merkez noktası.
  Offset get center => Offset(
        (startPoint.dx + endPoint.dx) / 2,
        (startPoint.dy + endPoint.dy) / 2,
      );

  /// Genişlik.
  double get width => (endPoint.dx - startPoint.dx).abs();

  /// Yükseklik.
  double get height => (endPoint.dy - startPoint.dy).abs();

  /// Efektif dolgu rengi.
  Color get effectiveFillColor => fillColor ?? style.color;

  /// Hit test.
  bool hitTest(Offset point, {double tolerance = 10.0}) {
    return boundingBox.inflate(tolerance).contains(point);
  }

  /// Şekli taşır.
  Shape translate(double dx, double dy) {
    return copyWith(
      startPoint: startPoint.translate(dx, dy),
      endPoint: endPoint.translate(dx, dy),
    );
  }

  /// Şekli ölçekler.
  Shape scale(double factor, Offset anchor) {
    return copyWith(
      startPoint: Offset(
        anchor.dx + (startPoint.dx - anchor.dx) * factor,
        anchor.dy + (startPoint.dy - anchor.dy) * factor,
      ),
      endPoint: Offset(
        anchor.dx + (endPoint.dx - anchor.dx) * factor,
        anchor.dy + (endPoint.dy - anchor.dy) * factor,
      ),
    );
  }

  Shape copyWith({
    String? id,
    ShapeType? type,
    Offset? startPoint,
    Offset? endPoint,
    StrokeStyle? style,
    bool? isFilled,
    Color? fillColor,
    double? cornerRadius,
    int? pointCount,
    double? rotation,
    DateTime? createdAt,
  }) {
    return Shape(
      id: id ?? this.id,
      type: type ?? this.type,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      style: style ?? this.style,
      isFilled: isFilled ?? this.isFilled,
      fillColor: fillColor ?? this.fillColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      pointCount: pointCount ?? this.pointCount,
      rotation: rotation ?? this.rotation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'startPoint': {'x': startPoint.dx, 'y': startPoint.dy},
      'endPoint': {'x': endPoint.dx, 'y': endPoint.dy},
      'style': style.toJson(),
      'isFilled': isFilled,
      if (fillColor != null) 'fillColor': fillColor!.toARGB32(),
      'cornerRadius': cornerRadius,
      'pointCount': pointCount,
      'rotation': rotation,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Shape.fromJson(Map<String, dynamic> json) {
    return Shape(
      id: json['id'] as String,
      type: ShapeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ShapeType.rectangle,
      ),
      startPoint: Offset(
        (json['startPoint']['x'] as num).toDouble(),
        (json['startPoint']['y'] as num).toDouble(),
      ),
      endPoint: Offset(
        (json['endPoint']['x'] as num).toDouble(),
        (json['endPoint']['y'] as num).toDouble(),
      ),
      style: StrokeStyle.fromJson(json['style'] as Map<String, dynamic>),
      isFilled: json['isFilled'] as bool? ?? false,
      fillColor:
          json['fillColor'] != null ? Color(json['fillColor'] as int) : null,
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 0,
      pointCount: json['pointCount'] as int? ?? 4,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shape && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Shape(id: $id, type: ${type.name})';
}
