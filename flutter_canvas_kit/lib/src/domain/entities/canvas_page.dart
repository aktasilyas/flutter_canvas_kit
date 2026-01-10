import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/entities/layer.dart';
import 'package:flutter_canvas_kit/src/domain/entities/stroke.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_background.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_size.dart';

/// Tek bir sayfa.
///
/// Birden fazla [Layer] içerir.
final class CanvasPage {
  /// Benzersiz kimlik.
  final String id;

  /// Sayfa başlığı.
  final String? title;

  /// Katmanlar.
  final List<Layer> layers;

  /// Aktif katman indexi.
  final int activeLayerIndex;

  /// Sayfa boyutu.
  final PageSize pageSize;

  /// Özel genişlik (custom size için).
  final double? customWidth;

  /// Özel yükseklik (custom size için).
  final double? customHeight;

  /// Arka plan tipi.
  final PageBackground background;

  /// Arka plan rengi.
  final Color backgroundColor;

  /// Grid/çizgi rengi.
  final Color gridColor;

  /// Grid/çizgi aralığı.
  final double gridSpacing;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  const CanvasPage({
    required this.id,
    this.title,
    required this.layers,
    this.activeLayerIndex = 0,
    this.pageSize = PageSize.a4,
    this.customWidth,
    this.customHeight,
    this.background = PageBackground.blank,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.gridColor = const Color(0xFFE0E0E0),
    this.gridSpacing = 25.0,
    required this.createdAt,
  });

  /// Boş sayfa oluşturur.
  factory CanvasPage.empty({
    String? title,
    PageSize pageSize = PageSize.a4,
    PageBackground background = PageBackground.blank,
    Color backgroundColor = const Color(0xFFFFFFFF),
  }) {
    return CanvasPage(
      id: _generateId(),
      title: title,
      layers: [Layer.withDefaultName(0)],
      activeLayerIndex: 0,
      pageSize: pageSize,
      background: background,
      backgroundColor: backgroundColor,
      gridSpacing: background.defaultSpacing,
      createdAt: DateTime.now(),
    );
  }

  /// Çizgili sayfa.
  factory CanvasPage.lined({String? title, PageSize pageSize = PageSize.a4}) {
    return CanvasPage.empty(
      title: title,
      pageSize: pageSize,
      background: PageBackground.lined,
    );
  }

  /// Kareli sayfa.
  factory CanvasPage.grid({String? title, PageSize pageSize = PageSize.a4}) {
    return CanvasPage.empty(
      title: title,
      pageSize: pageSize,
      background: PageBackground.grid,
    );
  }

  /// Noktalı sayfa.
  factory CanvasPage.dotted({String? title, PageSize pageSize = PageSize.a4}) {
    return CanvasPage.empty(
      title: title,
      pageSize: pageSize,
      background: PageBackground.dotted,
    );
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Sayfa genişliği.
  double get width {
    if (pageSize == PageSize.custom && customWidth != null) {
      return customWidth!;
    }
    return pageSize.widthPixels;
  }

  /// Sayfa yüksekliği.
  double get height {
    if (pageSize == PageSize.custom && customHeight != null) {
      return customHeight!;
    }
    return pageSize.heightPixels;
  }

  /// Sayfa boyutu Size olarak.
  Size get size => Size(width, height);

  /// Sayfa bounds Rect olarak.
  Rect get bounds => Rect.fromLTWH(0, 0, width, height);

  /// Sonsuz sayfa mı?
  bool get isInfinite => pageSize == PageSize.infinite;

  /// Katman sayısı.
  int get layerCount => layers.length;

  /// Aktif katman.
  Layer get activeLayer => layers[activeLayerIndex.clamp(0, layers.length - 1)];

  /// Toplam eleman sayısı.
  int get totalElementCount =>
      layers.fold(0, (sum, layer) => sum + layer.elementCount);

  /// Sayfa boş mu?
  bool get isEmpty => layers.every((layer) => layer.isEmpty);

  /// Tüm içeriğin bounding box'ı.
  Rect get contentBoundingBox {
    if (isEmpty) return Rect.zero;

    Rect? combined;
    for (final layer in layers) {
      if (layer.isEmpty) continue;
      final layerBounds = layer.boundingBox;
      combined = combined?.expandToInclude(layerBounds) ?? layerBounds;
    }
    return combined ?? Rect.zero;
  }

  // ---------------------------------------------------------------------------
  // Katman İşlemleri
  // ---------------------------------------------------------------------------

  /// Katman ekler.
  CanvasPage addLayer({String? name, int? index}) {
    final newLayer = Layer.create(name: name ?? 'Layer ${layers.length + 1}');
    final insertIndex = index ?? layers.length;

    return copyWith(
      layers: [
        ...layers.sublist(0, insertIndex),
        newLayer,
        ...layers.sublist(insertIndex)
      ],
      activeLayerIndex: insertIndex,
    );
  }

  /// Katman siler.
  CanvasPage removeLayer(String layerId) {
    if (layers.length <= 1) return this; // En az 1 katman olmalı

    final index = layers.indexWhere((l) => l.id == layerId);
    if (index == -1) return this;

    final newLayers = layers.where((l) => l.id != layerId).toList();
    final newActiveIndex = activeLayerIndex >= newLayers.length
        ? newLayers.length - 1
        : activeLayerIndex;

    return copyWith(
      layers: newLayers,
      activeLayerIndex: newActiveIndex,
    );
  }

  /// Katmanı günceller.
  CanvasPage updateLayer(String layerId, Layer newLayer) {
    return copyWith(
      layers: layers.map((l) => l.id == layerId ? newLayer : l).toList(),
    );
  }

  /// Aktif katmanı değiştirir.
  CanvasPage setActiveLayerIndex(int index) {
    if (index < 0 || index >= layers.length) return this;
    return copyWith(activeLayerIndex: index);
  }

  /// Katmanları yeniden sıralar.
  CanvasPage reorderLayers(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= layers.length) return this;
    if (newIndex < 0 || newIndex >= layers.length) return this;

    final newLayers = List<Layer>.from(layers);
    final layer = newLayers.removeAt(oldIndex);
    newLayers.insert(newIndex, layer);

    // Aktif katman indexini güncelle
    int newActiveIndex = activeLayerIndex;
    if (activeLayerIndex == oldIndex) {
      newActiveIndex = newIndex;
    } else if (oldIndex < activeLayerIndex && newIndex >= activeLayerIndex) {
      newActiveIndex--;
    } else if (oldIndex > activeLayerIndex && newIndex <= activeLayerIndex) {
      newActiveIndex++;
    }

    return copyWith(layers: newLayers, activeLayerIndex: newActiveIndex);
  }

  /// ID ile katman bulur.
  Layer? getLayerById(String layerId) {
    for (final layer in layers) {
      if (layer.id == layerId) return layer;
    }
    return null;
  }

  /// ID ile katman indexi bulur.
  int getLayerIndex(String layerId) {
    return layers.indexWhere((l) => l.id == layerId);
  }

  // ---------------------------------------------------------------------------
  // Aktif Katman Kısayolları
  // ---------------------------------------------------------------------------

  /// Aktif katmana stroke ekler.
  CanvasPage addStrokeToActiveLayer(Stroke stroke) {
    final updatedLayer = activeLayer.addStroke(stroke);
    return updateLayer(activeLayer.id, updatedLayer);
  }

  /// Aktif katmandan stroke siler.
  CanvasPage removeStrokeFromActiveLayer(String strokeId) {
    final updatedLayer = activeLayer.removeStroke(strokeId);
    return updateLayer(activeLayer.id, updatedLayer);
  }

  // ---------------------------------------------------------------------------
  // Genel İşlemler
  // ---------------------------------------------------------------------------

  /// Sayfayı temizler.
  CanvasPage clear() {
    return copyWith(
      layers: [Layer.withDefaultName(0)],
      activeLayerIndex: 0,
    );
  }

  /// Sayfayı kopyalar.
  CanvasPage duplicate() {
    return copyWith(
      id: _generateId(),
      title: title != null ? '$title (copy)' : null,
      createdAt: DateTime.now(),
    );
  }

  CanvasPage copyWith({
    String? id,
    String? title,
    List<Layer>? layers,
    int? activeLayerIndex,
    PageSize? pageSize,
    double? customWidth,
    double? customHeight,
    PageBackground? background,
    Color? backgroundColor,
    Color? gridColor,
    double? gridSpacing,
    DateTime? createdAt,
  }) {
    return CanvasPage(
      id: id ?? this.id,
      title: title ?? this.title,
      layers: layers ?? this.layers,
      activeLayerIndex: activeLayerIndex ?? this.activeLayerIndex,
      pageSize: pageSize ?? this.pageSize,
      customWidth: customWidth ?? this.customWidth,
      customHeight: customHeight ?? this.customHeight,
      background: background ?? this.background,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gridColor: gridColor ?? this.gridColor,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (title != null) 'title': title,
      'layers': layers.map((l) => l.toJson()).toList(),
      'activeLayerIndex': activeLayerIndex,
      'pageSize': pageSize.name,
      if (customWidth != null) 'customWidth': customWidth,
      if (customHeight != null) 'customHeight': customHeight,
      'background': background.name,
      'backgroundColor': backgroundColor.toARGB32(),
      'gridColor': gridColor.toARGB32(),
      'gridSpacing': gridSpacing,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CanvasPage.fromJson(Map<String, dynamic> json) {
    return CanvasPage(
      id: json['id'] as String,
      title: json['title'] as String?,
      layers: (json['layers'] as List)
          .map((l) => Layer.fromJson(l as Map<String, dynamic>))
          .toList(),
      activeLayerIndex: json['activeLayerIndex'] as int? ?? 0,
      pageSize: PageSize.values.firstWhere(
        (s) => s.name == json['pageSize'],
        orElse: () => PageSize.a4,
      ),
      customWidth: (json['customWidth'] as num?)?.toDouble(),
      customHeight: (json['customHeight'] as num?)?.toDouble(),
      background: PageBackground.values.firstWhere(
        (b) => b.name == json['background'],
        orElse: () => PageBackground.blank,
      ),
      backgroundColor: Color(json['backgroundColor'] as int),
      gridColor: Color(json['gridColor'] as int),
      gridSpacing: (json['gridSpacing'] as num?)?.toDouble() ?? 25.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CanvasPage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CanvasPage(id: $id, title: $title, layers: $layerCount)';
}
