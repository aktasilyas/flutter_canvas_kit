import 'dart:typed_data';
import 'dart:ui';

/// Canvas üzerindeki resim elemanı.
///
/// Immutable entity.
final class ImageElement {
  /// Benzersiz kimlik.
  final String id;

  /// Resim verisi (bytes).
  final Uint8List? imageData;

  /// Resim dosya yolu (alternatif).
  final String? imagePath;

  /// Konum (sol üst köşe).
  final Offset position;

  /// Genişlik.
  final double width;

  /// Yükseklik.
  final double height;

  /// Opaklık (0.0 - 1.0).
  final double opacity;

  /// Döndürme açısı (radyan).
  final double rotation;

  /// En-boy oranı korunsun mu?
  final bool maintainAspectRatio;

  /// Orijinal genişlik.
  final double? originalWidth;

  /// Orijinal yükseklik.
  final double? originalHeight;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  const ImageElement({
    required this.id,
    this.imageData,
    this.imagePath,
    required this.position,
    required this.width,
    required this.height,
    this.opacity = 1.0,
    this.rotation = 0,
    this.maintainAspectRatio = true,
    this.originalWidth,
    this.originalHeight,
    required this.createdAt,
  }) : assert(imageData != null || imagePath != null,
            'Either imageData or imagePath must be provided');

  /// Yeni image element oluşturur.
  factory ImageElement.create({
    Uint8List? imageData,
    String? imagePath,
    required Offset position,
    required double width,
    required double height,
    double opacity = 1.0,
    double rotation = 0,
    bool maintainAspectRatio = true,
    double? originalWidth,
    double? originalHeight,
  }) {
    return ImageElement(
      id: _generateId(),
      imageData: imageData,
      imagePath: imagePath,
      position: position,
      width: width,
      height: height,
      opacity: opacity,
      rotation: rotation,
      maintainAspectRatio: maintainAspectRatio,
      originalWidth: originalWidth ?? width,
      originalHeight: originalHeight ?? height,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  /// Sınırlayıcı kutu.
  Rect get boundingBox =>
      Rect.fromLTWH(position.dx, position.dy, width, height);

  /// Merkez noktası.
  Offset get center =>
      Offset(position.dx + width / 2, position.dy + height / 2);

  /// En-boy oranı.
  double get aspectRatio => width / height;

  /// Hit test.
  bool hitTest(Offset point, {double tolerance = 5.0}) {
    return boundingBox.inflate(tolerance).contains(point);
  }

  /// Taşır.
  ImageElement translate(double dx, double dy) {
    return copyWith(position: position.translate(dx, dy));
  }

  /// Ölçekler.
  ImageElement scale(double factor, Offset anchor) {
    final newWidth = width * factor;
    final newHeight = height * factor;
    final newPosition = Offset(
      anchor.dx + (position.dx - anchor.dx) * factor,
      anchor.dy + (position.dy - anchor.dy) * factor,
    );

    return copyWith(
      position: newPosition,
      width: newWidth,
      height: newHeight,
    );
  }

  /// Yeniden boyutlandırır.
  ImageElement resize(double newWidth, double newHeight) {
    if (maintainAspectRatio &&
        originalWidth != null &&
        originalHeight != null) {
      final originalAspectRatio = originalWidth! / originalHeight!;
      final newAspectRatio = newWidth / newHeight;

      if (newAspectRatio > originalAspectRatio) {
        newWidth = newHeight * originalAspectRatio;
      } else {
        newHeight = newWidth / originalAspectRatio;
      }
    }

    return copyWith(width: newWidth, height: newHeight);
  }

  ImageElement copyWith({
    String? id,
    Uint8List? imageData,
    String? imagePath,
    Offset? position,
    double? width,
    double? height,
    double? opacity,
    double? rotation,
    bool? maintainAspectRatio,
    double? originalWidth,
    double? originalHeight,
    DateTime? createdAt,
  }) {
    return ImageElement(
      id: id ?? this.id,
      imageData: imageData ?? this.imageData,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
      opacity: opacity ?? this.opacity,
      rotation: rotation ?? this.rotation,
      maintainAspectRatio: maintainAspectRatio ?? this.maintainAspectRatio,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (imagePath != null) 'imagePath': imagePath,
      // imageData base64 encode için ayrı işlem gerekir
      'position': {'x': position.dx, 'y': position.dy},
      'width': width,
      'height': height,
      'opacity': opacity,
      'rotation': rotation,
      'maintainAspectRatio': maintainAspectRatio,
      if (originalWidth != null) 'originalWidth': originalWidth,
      if (originalHeight != null) 'originalHeight': originalHeight,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ImageElement.fromJson(Map<String, dynamic> json) {
    return ImageElement(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String?,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      maintainAspectRatio: json['maintainAspectRatio'] as bool? ?? true,
      originalWidth: (json['originalWidth'] as num?)?.toDouble(),
      originalHeight: (json['originalHeight'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageElement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ImageElement(id: $id, size: ${width.toInt()}x${height.toInt()})';
}
