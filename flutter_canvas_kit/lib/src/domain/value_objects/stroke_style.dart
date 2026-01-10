import 'dart:ui';

import 'package:flutter_canvas_kit/src/core/constants/canvas_constants.dart';
import 'package:flutter_canvas_kit/src/domain/enums/stroke_type.dart';

/// Çizgi stili.
///
/// Renk, kalınlık, opaklık ve tip bilgisi içerir.
/// Immutable value object.
final class StrokeStyle {
  /// Çizgi rengi.
  final Color color;

  /// Çizgi kalınlığı (piksel).
  final double width;

  /// Opaklık (0.0 - 1.0).
  final double opacity;

  /// Çizgi tipi.
  final StrokeType type;

  const StrokeStyle({
    this.color = CanvasConstants.defaultStrokeColor,
    this.width = CanvasConstants.defaultStrokeWidth,
    this.opacity = 1.0,
    this.type = StrokeType.pen,
  });

  /// Kalem stili oluşturur.
  factory StrokeStyle.pen({
    Color color = CanvasConstants.defaultStrokeColor,
    double width = CanvasConstants.defaultStrokeWidth,
    double opacity = 1.0,
  }) {
    return StrokeStyle(
      color: color,
      width: width,
      opacity: opacity,
      type: StrokeType.pen,
    );
  }

  /// Fosforlu kalem stili oluşturur.
  factory StrokeStyle.highlighter({
    Color color = const Color(0xFFFFEB3B), // Sarı
    double width = 20.0,
  }) {
    return StrokeStyle(
      color: color,
      width: width,
      opacity: CanvasConstants.highlighterOpacity,
      type: StrokeType.highlighter,
    );
  }

  /// Kurşun kalem stili oluşturur.
  factory StrokeStyle.pencil({
    Color color = const Color(0xFF424242), // Koyu gri
    double width = 1.5,
    double opacity = 0.9,
  }) {
    return StrokeStyle(
      color: color,
      width: width,
      opacity: opacity,
      type: StrokeType.pencil,
    );
  }

  /// Opaklık uygulanmış renk.
  Color get effectiveColor {
    final a = (color.a * opacity).clamp(0.0, 1.0);
    return color.withValues(alpha: a);
  }

  /// perfect_freehand için thinning değeri.
  double get thinning => type.thinning;

  /// perfect_freehand için smoothing değeri.
  double get smoothing => type.smoothing;

  /// perfect_freehand için streamline değeri.
  double get streamline => type.streamline;

  /// Basınç kullanılıyor mu?
  bool get usesPressure => type.usesPressure;

  StrokeStyle copyWith({
    Color? color,
    double? width,
    double? opacity,
    StrokeType? type,
  }) {
    return StrokeStyle(
      color: color ?? this.color,
      width: width ?? this.width,
      opacity: opacity ?? this.opacity,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'color': color.toARGB32(),
      'width': width,
      'opacity': opacity,
      'type': type.name,
    };
  }

  factory StrokeStyle.fromJson(Map<String, dynamic> json) {
    return StrokeStyle(
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      type: StrokeType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => StrokeType.pen,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StrokeStyle &&
        other.color == color &&
        other.width == width &&
        other.opacity == opacity &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(color, width, opacity, type);

  @override
  String toString() =>
      'StrokeStyle(color: $color, width: $width, opacity: $opacity, type: ${type.name})';
}
