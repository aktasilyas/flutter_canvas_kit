import 'dart:ui';

import 'package:flutter_canvas_kit/src/core/constants/canvas_constants.dart';
import 'package:flutter_canvas_kit/src/domain/entities/image_element.dart';
import 'package:flutter_canvas_kit/src/domain/entities/shape.dart';
import 'package:flutter_canvas_kit/src/domain/entities/stroke.dart';
import 'package:flutter_canvas_kit/src/domain/entities/text_element.dart';
import 'package:flutter_canvas_kit/src/domain/enums/blend_mode.dart';

/// Tek bir katman.
///
/// Stroke, Shape, TextElement ve ImageElement içerir.
/// Photoshop/Procreate benzeri katman sistemi.
final class Layer {
  /// Benzersiz kimlik.
  final String id;

  /// Katman adı.
  final String name;

  /// Çizgiler (stroke).
  final List<Stroke> strokes;

  /// Şekiller.
  final List<Shape> shapes;

  /// Metin elemanları.
  final List<TextElement> textElements;

  /// Resim elemanları.
  final List<ImageElement> imageElements;

  /// Görünür mü?
  final bool isVisible;

  /// Kilitli mi?
  final bool isLocked;

  /// Opaklık (0.0 - 1.0).
  final double opacity;

  /// Karıştırma modu.
  final LayerBlendMode blendMode;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  const Layer({
    required this.id,
    required this.name,
    this.strokes = const [],
    this.shapes = const [],
    this.textElements = const [],
    this.imageElements = const [],
    this.isVisible = true,
    this.isLocked = false,
    this.opacity = CanvasConstants.defaultLayerOpacity,
    this.blendMode = LayerBlendMode.normal,
    required this.createdAt,
  });

  /// Yeni katman oluşturur.
  factory Layer.create({
    required String name,
    List<Stroke>? strokes,
    List<Shape>? shapes,
    List<TextElement>? textElements,
    List<ImageElement>? imageElements,
    bool isVisible = true,
    bool isLocked = false,
    double opacity = CanvasConstants.defaultLayerOpacity,
    LayerBlendMode blendMode = LayerBlendMode.normal,
  }) {
    return Layer(
      id: _generateId(),
      name: name,
      strokes: strokes ?? const [],
      shapes: shapes ?? const [],
      textElements: textElements ?? const [],
      imageElements: imageElements ?? const [],
      isVisible: isVisible,
      isLocked: isLocked,
      opacity: opacity,
      blendMode: blendMode,
      createdAt: DateTime.now(),
    );
  }

  /// Varsayılan isimle katman oluşturur.
  factory Layer.withDefaultName(int index) {
    return Layer.create(name: 'Layer ${index + 1}');
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Katman boş mu?
  bool get isEmpty =>
      strokes.isEmpty &&
      shapes.isEmpty &&
      textElements.isEmpty &&
      imageElements.isEmpty;

  /// Toplam eleman sayısı.
  int get elementCount =>
      strokes.length +
      shapes.length +
      textElements.length +
      imageElements.length;

  /// Sadece stroke'ları döndürür (eski API uyumluluğu için).
  List<Stroke> get elements => strokes;

  /// Tüm elemanların bounding box'ı.
  Rect get boundingBox {
    if (isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    void expandBounds(Rect rect) {
      if (rect.left < minX) minX = rect.left;
      if (rect.top < minY) minY = rect.top;
      if (rect.right > maxX) maxX = rect.right;
      if (rect.bottom > maxY) maxY = rect.bottom;
    }

    for (final stroke in strokes) {
      expandBounds(stroke.boundingBox);
    }
    for (final shape in shapes) {
      expandBounds(shape.boundingBox);
    }
    for (final text in textElements) {
      expandBounds(text.boundingBox);
    }
    for (final image in imageElements) {
      expandBounds(image.boundingBox);
    }

    if (minX == double.infinity) return Rect.zero;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  // ---------------------------------------------------------------------------
  // Stroke İşlemleri
  // ---------------------------------------------------------------------------

  /// Stroke ekler.
  Layer addStroke(Stroke stroke) {
    return copyWith(strokes: [...strokes, stroke]);
  }

  /// Stroke günceller.
  Layer updateStroke(String strokeId, Stroke newStroke) {
    return copyWith(
      strokes: strokes.map((s) => s.id == strokeId ? newStroke : s).toList(),
    );
  }

  /// Stroke siler.
  Layer removeStroke(String strokeId) {
    return copyWith(
      strokes: strokes.where((s) => s.id != strokeId).toList(),
    );
  }

  /// ID ile stroke bulur.
  Stroke? getStrokeById(String strokeId) {
    for (final stroke in strokes) {
      if (stroke.id == strokeId) return stroke;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Shape İşlemleri
  // ---------------------------------------------------------------------------

  /// Shape ekler.
  Layer addShape(Shape shape) {
    return copyWith(shapes: [...shapes, shape]);
  }

  /// Shape siler.
  Layer removeShape(String shapeId) {
    return copyWith(
      shapes: shapes.where((s) => s.id != shapeId).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Text İşlemleri
  // ---------------------------------------------------------------------------

  /// Text ekler.
  Layer addText(TextElement text) {
    return copyWith(textElements: [...textElements, text]);
  }

  /// Text siler.
  Layer removeText(String textId) {
    return copyWith(
      textElements: textElements.where((t) => t.id != textId).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Image İşlemleri
  // ---------------------------------------------------------------------------

  /// Image ekler.
  Layer addImage(ImageElement image) {
    return copyWith(imageElements: [...imageElements, image]);
  }

  /// Image siler.
  Layer removeImage(String imageId) {
    return copyWith(
      imageElements: imageElements.where((i) => i.id != imageId).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Hit Testing
  // ---------------------------------------------------------------------------

  /// Noktadaki stroke'ları bulur.
  List<Stroke> hitTest(Offset point, {double tolerance = 10.0}) {
    return strokes
        .where((s) => s.hitTest(point, tolerance: tolerance))
        .toList();
  }

  /// Rect içindeki stroke'ları bulur.
  List<Stroke> hitTestRect(Rect rect) {
    return strokes.where((s) => rect.overlaps(s.boundingBox)).toList();
  }

  // ---------------------------------------------------------------------------
  // Genel İşlemler
  // ---------------------------------------------------------------------------

  /// Katmanı temizler.
  Layer clear() {
    return copyWith(
      strokes: const [],
      shapes: const [],
      textElements: const [],
      imageElements: const [],
    );
  }

  /// Tüm elemanları taşır.
  Layer translate(double dx, double dy) {
    return copyWith(
      strokes: strokes.map((s) => s.translate(dx, dy)).toList(),
      shapes: shapes.map((s) => s.translate(dx, dy)).toList(),
      textElements: textElements.map((t) => t.translate(dx, dy)).toList(),
      imageElements: imageElements.map((i) => i.translate(dx, dy)).toList(),
    );
  }

  Layer copyWith({
    String? id,
    String? name,
    List<Stroke>? strokes,
    List<Shape>? shapes,
    List<TextElement>? textElements,
    List<ImageElement>? imageElements,
    bool? isVisible,
    bool? isLocked,
    double? opacity,
    LayerBlendMode? blendMode,
    DateTime? createdAt,
  }) {
    return Layer(
      id: id ?? this.id,
      name: name ?? this.name,
      strokes: strokes ?? this.strokes,
      shapes: shapes ?? this.shapes,
      textElements: textElements ?? this.textElements,
      imageElements: imageElements ?? this.imageElements,
      isVisible: isVisible ?? this.isVisible,
      isLocked: isLocked ?? this.isLocked,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'strokes': strokes.map((s) => s.toJson()).toList(),
      'shapes': shapes.map((s) => s.toJson()).toList(),
      'textElements': textElements.map((t) => t.toJson()).toList(),
      'imageElements': imageElements.map((i) => i.toJson()).toList(),
      'isVisible': isVisible,
      'isLocked': isLocked,
      'opacity': opacity,
      'blendMode': blendMode.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Layer.fromJson(Map<String, dynamic> json) {
    return Layer(
      id: json['id'] as String,
      name: json['name'] as String,
      strokes: (json['strokes'] as List?)
              ?.map((s) => Stroke.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      shapes: (json['shapes'] as List?)
              ?.map((s) => Shape.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      textElements: (json['textElements'] as List?)
              ?.map((t) => TextElement.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      imageElements: (json['imageElements'] as List?)
              ?.map((i) => ImageElement.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      isVisible: json['isVisible'] as bool? ?? true,
      isLocked: json['isLocked'] as bool? ?? false,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      blendMode: LayerBlendMode.values.firstWhere(
        (b) => b.name == json['blendMode'],
        orElse: () => LayerBlendMode.normal,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Layer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Layer(id: $id, name: $name, elements: $elementCount)';
}
