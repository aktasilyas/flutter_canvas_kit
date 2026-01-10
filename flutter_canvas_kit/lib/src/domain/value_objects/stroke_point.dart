import 'dart:ui';

/// Çizgi üzerindeki tek bir nokta.
///
/// Konum, basınç ve zaman bilgisi içerir.
/// Immutable value object.
final class StrokePoint {
  /// X koordinatı.
  final double x;

  /// Y koordinatı.
  final double y;

  /// Basınç değeri (0.0 - 1.0).
  ///
  /// 0.0 = minimum basınç, 1.0 = maksimum basınç.
  /// Basınç desteklemeyen cihazlarda varsayılan 0.5.
  final double pressure;

  /// Zaman damgası (milisaniye).
  ///
  /// Çizimin başlangıcından itibaren geçen süre.
  final int timestamp;

  /// Stylus eğim açısı (radyan, opsiyonel).
  final double? tilt;

  const StrokePoint({
    required this.x,
    required this.y,
    this.pressure = 0.5,
    this.timestamp = 0,
    this.tilt,
  });

  /// Offset'ten oluşturur.
  factory StrokePoint.fromOffset(
    Offset offset, {
    double pressure = 0.5,
    int timestamp = 0,
    double? tilt,
  }) {
    return StrokePoint(
      x: offset.dx,
      y: offset.dy,
      pressure: pressure,
      timestamp: timestamp,
      tilt: tilt,
    );
  }

  /// Offset olarak döndürür.
  Offset get offset => Offset(x, y);

  /// Başka bir noktaya olan mesafe.
  double distanceTo(StrokePoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy).sqrt();
  }

  /// İki nokta arasında interpolasyon.
  StrokePoint lerpTo(StrokePoint other, double t) {
    return StrokePoint(
      x: x + (other.x - x) * t,
      y: y + (other.y - y) * t,
      pressure: pressure + (other.pressure - pressure) * t,
      timestamp: (timestamp + (other.timestamp - timestamp) * t).round(),
      tilt: tilt != null && other.tilt != null
          ? tilt! + (other.tilt! - tilt!) * t
          : tilt ?? other.tilt,
    );
  }

  /// Noktayı taşır.
  StrokePoint translate(double dx, double dy) {
    return StrokePoint(
      x: x + dx,
      y: y + dy,
      pressure: pressure,
      timestamp: timestamp,
      tilt: tilt,
    );
  }

  /// Noktayı ölçekler.
  StrokePoint scale(double factor) {
    return StrokePoint(
      x: x * factor,
      y: y * factor,
      pressure: pressure,
      timestamp: timestamp,
      tilt: tilt,
    );
  }

  /// Merkez etrafında ölçekler.
  StrokePoint scaleAround(double factor, double centerX, double centerY) {
    return StrokePoint(
      x: centerX + (x - centerX) * factor,
      y: centerY + (y - centerY) * factor,
      pressure: pressure,
      timestamp: timestamp,
      tilt: tilt,
    );
  }

  StrokePoint copyWith({
    double? x,
    double? y,
    double? pressure,
    int? timestamp,
    double? tilt,
  }) {
    return StrokePoint(
      x: x ?? this.x,
      y: y ?? this.y,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
      tilt: tilt ?? this.tilt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'pressure': pressure,
      'timestamp': timestamp,
      if (tilt != null) 'tilt': tilt,
    };
  }

  factory StrokePoint.fromJson(Map<String, dynamic> json) {
    return StrokePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble() ?? 0.5,
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      tilt: (json['tilt'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StrokePoint &&
        other.x == x &&
        other.y == y &&
        other.pressure == pressure &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(x, y, pressure, timestamp);

  @override
  String toString() => 'StrokePoint($x, $y, p:$pressure)';
}

/// double için sqrt extension.
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
