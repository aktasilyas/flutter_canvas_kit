import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_canvas_kit/src/core/constants/canvas_constants.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_document.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_page.dart';
import 'package:flutter_canvas_kit/src/domain/entities/layer.dart';
import 'package:flutter_canvas_kit/src/domain/entities/shape.dart';
import 'package:flutter_canvas_kit/src/domain/entities/stroke.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_background.dart';
import 'package:flutter_canvas_kit/src/domain/enums/shape_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/stroke_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_style.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/history_manager.dart';

/// Canvas kontrolcüsü.
///
/// Döküman, araç, stil ve tüm canvas durumunu yönetir.
/// Widget'lar bu controller'ı dinleyerek güncellenir.
class CanvasController extends ChangeNotifier {
  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// Geçmiş yöneticisi.
  final HistoryManager _historyManager;

  /// Döküman.
  CanvasDocument _document;

  /// Mevcut araç.
  ToolType _currentTool = ToolType.pen;

  /// Mevcut çizgi stili.
  StrokeStyle _currentStyle = const StrokeStyle();

  /// Mevcut şekil tipi (shape tool için).
  ShapeType _currentShapeType = ShapeType.rectangle;

  /// Şekil dolgulu mu?
  bool _shapeFilled = false;

  /// Aktif çizgi (çizim sırasında).
  List<StrokePoint>? _activeStrokePoints;

  /// Seçili eleman ID'leri.
  final Set<String> _selectedIds = {};

  /// Zoom seviyesi.
  double _zoom = CanvasConstants.defaultZoom;

  /// Pan offset.
  Offset _panOffset = Offset.zero;

  /// Read-only mod.
  bool _isReadOnly = false;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  CanvasController({
    CanvasDocument? document,
    HistoryManager? historyManager,
  })  : _document = document ?? CanvasDocument.empty(),
        _historyManager = historyManager ?? HistoryManager() {
    _historyManager.initialize(_document);
  }

  // ---------------------------------------------------------------------------
  // Getters - Document
  // ---------------------------------------------------------------------------

  /// Döküman.
  CanvasDocument get document => _document;

  /// Mevcut sayfa.
  CanvasPage get currentPage => _document.currentPage;

  /// Mevcut sayfa indexi.
  int get currentPageIndex => _document.currentPageIndex;

  /// Sayfa sayısı.
  int get pageCount => _document.pageCount;

  /// Aktif katman.
  Layer get activeLayer => currentPage.activeLayer;

  /// Aktif katman indexi.
  int get activeLayerIndex => currentPage.activeLayerIndex;

  /// Katman sayısı.
  int get layerCount => currentPage.layerCount;

  /// Katmanlar.
  List<Layer> get layers => currentPage.layers;

  // ---------------------------------------------------------------------------
  // Getters - Tool & Style
  // ---------------------------------------------------------------------------

  /// Mevcut araç.
  ToolType get currentTool => _currentTool;

  /// Mevcut çizgi stili.
  StrokeStyle get currentStyle => _currentStyle;

  /// Mevcut renk.
  Color get currentColor => _currentStyle.color;

  /// Mevcut kalınlık.
  double get currentWidth => _currentStyle.width;

  /// Mevcut şekil tipi.
  ShapeType get currentShapeType => _currentShapeType;

  /// Şekil dolgulu mu?
  bool get shapeFilled => _shapeFilled;

  // ---------------------------------------------------------------------------
  // Getters - State
  // ---------------------------------------------------------------------------

  /// Çizim yapılıyor mu?
  bool get isDrawing => _activeStrokePoints != null;

  /// Aktif stroke (çizim sırasında).
  List<StrokePoint>? get activeStrokePoints => _activeStrokePoints;

  /// Seçili eleman var mı?
  bool get hasSelection => _selectedIds.isNotEmpty;

  /// Seçili eleman ID'leri.
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  /// Zoom seviyesi.
  double get zoom => _zoom;

  /// Pan offset.
  Offset get panOffset => _panOffset;

  /// Read-only mod.
  bool get isReadOnly => _isReadOnly;

  /// Undo yapılabilir mi?
  bool get canUndo => _historyManager.canUndo;

  /// Redo yapılabilir mi?
  bool get canRedo => _historyManager.canRedo;

  /// History manager.
  HistoryManager get historyManager => _historyManager;

  // ---------------------------------------------------------------------------
  // Document Operations
  // ---------------------------------------------------------------------------

  /// Yeni döküman yükler.
  void loadDocument(CanvasDocument document) {
    _document = document;
    _historyManager.initialize(document);
    _selectedIds.clear();
    _activeStrokePoints = null;
    notifyListeners();
  }

  /// Dökümanı günceller (history'ye ekler).
  void _updateDocument(CanvasDocument newDocument) {
    _document = newDocument;
    _historyManager.pushState(newDocument);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Page Operations
  // ---------------------------------------------------------------------------

  /// Sayfa ekler.
  void addPage({CanvasPage? page, int? index}) {
    _updateDocument(_document.addPage(page: page, index: index));
  }

  /// Sayfa siler.
  void removePage(int index) {
    _updateDocument(_document.removePage(index));
  }

  /// Sayfaya git.
  void goToPage(int index) {
    if (index < 0 || index >= _document.pageCount) return;
    _document = _document.goToPage(index);
    _selectedIds.clear();
    notifyListeners();
  }

  /// Sonraki sayfa.
  void nextPage() {
    if (_document.currentPageIndex >= _document.pageCount - 1) return;
    goToPage(_document.currentPageIndex + 1);
  }

  /// Önceki sayfa.
  void previousPage() {
    if (_document.currentPageIndex <= 0) return;
    goToPage(_document.currentPageIndex - 1);
  }

  /// Sayfa arka planını değiştirir.
  void setPageBackground(PageBackground background) {
    final updatedPage = currentPage.copyWith(
      background: background,
      gridSpacing: background.defaultSpacing,
    );
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Sayfa arka plan rengini değiştirir.
  void setPageBackgroundColor(Color color) {
    final updatedPage = currentPage.copyWith(backgroundColor: color);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  // ---------------------------------------------------------------------------
  // Layer Operations
  // ---------------------------------------------------------------------------

  /// Katman ekler.
  void addLayer({String? name}) {
    final updatedPage = currentPage.addLayer(name: name);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Katman siler.
  void removeLayer(String layerId) {
    final updatedPage = currentPage.removeLayer(layerId);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Aktif katmanı değiştirir.
  void setActiveLayerIndex(int index) {
    if (index < 0 || index >= currentPage.layerCount) return;
    final updatedPage = currentPage.setActiveLayerIndex(index);
    _document = _document.updateCurrentPage(updatedPage);
    notifyListeners();
  }

  /// Katman görünürlüğünü değiştirir.
  void toggleLayerVisibility(String layerId) {
    final layer = currentPage.getLayerById(layerId);
    if (layer == null) return;

    final updatedLayer = layer.copyWith(isVisible: !layer.isVisible);
    final updatedPage = currentPage.updateLayer(layerId, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Katman kilidini değiştirir.
  void toggleLayerLock(String layerId) {
    final layer = currentPage.getLayerById(layerId);
    if (layer == null) return;

    final updatedLayer = layer.copyWith(isLocked: !layer.isLocked);
    final updatedPage = currentPage.updateLayer(layerId, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Katman opaklığını değiştirir.
  void setLayerOpacity(String layerId, double opacity) {
    final layer = currentPage.getLayerById(layerId);
    if (layer == null) return;

    final updatedLayer = layer.copyWith(opacity: opacity.clamp(0.0, 1.0));
    final updatedPage = currentPage.updateLayer(layerId, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Katman adını değiştirir.
  void renameLayer(String layerId, String newName) {
    final layer = currentPage.getLayerById(layerId);
    if (layer == null) return;

    final updatedLayer = layer.copyWith(name: newName);
    final updatedPage = currentPage.updateLayer(layerId, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Katmanları yeniden sıralar.
  void reorderLayers(int oldIndex, int newIndex) {
    final updatedPage = currentPage.reorderLayers(oldIndex, newIndex);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  // ---------------------------------------------------------------------------
  // Tool Operations
  // ---------------------------------------------------------------------------

  /// Araç seçer.
  void selectTool(ToolType tool) {
    if (_currentTool == tool) return;

    _currentTool = tool;

    // Araç tipine göre stroke type güncelle
    final strokeType = StrokeType.fromToolType(tool);
    if (strokeType != null && _currentStyle.type != strokeType) {
      _currentStyle = _currentStyle.copyWith(type: strokeType);
    }

    notifyListeners();
  }

  /// Renk ayarlar.
  void setColor(Color color) {
    _currentStyle = _currentStyle.copyWith(color: color);
    notifyListeners();
  }

  /// Kalınlık ayarlar.
  void setStrokeWidth(double width) {
    _currentStyle = _currentStyle.copyWith(
      width: width.clamp(
        CanvasConstants.minStrokeWidth,
        CanvasConstants.maxStrokeWidth,
      ),
    );
    notifyListeners();
  }

  /// Opaklık ayarlar.
  void setOpacity(double opacity) {
    _currentStyle = _currentStyle.copyWith(opacity: opacity.clamp(0.0, 1.0));
    notifyListeners();
  }

  /// Stil ayarlar.
  void setStyle(StrokeStyle style) {
    _currentStyle = style;
    notifyListeners();
  }

  /// Şekil tipi ayarlar.
  void setShapeType(ShapeType type) {
    _currentShapeType = type;
    notifyListeners();
  }

  /// Şekil dolgu ayarı.
  void setShapeFilled(bool filled) {
    _shapeFilled = filled;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Drawing Operations
  // ---------------------------------------------------------------------------

  /// Çizim başlatır.
  void startStroke(StrokePoint point) {
    if (_isReadOnly) return;
    if (activeLayer.isLocked) return;

    _historyManager.beginBatch();
    _activeStrokePoints = [point];
    notifyListeners();
  }

  /// Çizime nokta ekler.
  void continueStroke(StrokePoint point) {
    if (_activeStrokePoints == null) return;

    _activeStrokePoints!.add(point);
    notifyListeners();
  }

  /// Çizimi bitirir.
  void endStroke() {
    if (_activeStrokePoints == null) return;

    // Stroke oluştur
    final stroke = Stroke.create(
      points: _activeStrokePoints!,
      style: _currentStyle,
    );

    // Katmana ekle
    final updatedLayer = activeLayer.addStroke(stroke);
    final updatedPage = currentPage.updateLayer(activeLayer.id, updatedLayer);
    _document = _document.updateCurrentPage(updatedPage);

    // Temizle
    _activeStrokePoints = null;
    _historyManager.endBatch();
    notifyListeners();
  }

  /// Çizimi iptal eder.
  void cancelStroke() {
    if (_activeStrokePoints == null) return;

    _activeStrokePoints = null;
    _historyManager.cancelBatch();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Eraser Operations
  // ---------------------------------------------------------------------------

  /// Belirli noktadaki stroke'ları siler.
  void eraseAt(Offset position, {double radius = 10.0}) {
    if (_isReadOnly) return;
    if (activeLayer.isLocked) return;

    final hits = activeLayer.hitTest(position, tolerance: radius);
    if (hits.isEmpty) return;

    var updatedLayer = activeLayer;
    for (final stroke in hits) {
      updatedLayer = updatedLayer.removeStroke(stroke.id);
    }

    final updatedPage = currentPage.updateLayer(activeLayer.id, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  // ---------------------------------------------------------------------------
  // Selection Operations
  // ---------------------------------------------------------------------------

  /// Eleman seçer.
  void selectElement(String elementId) {
    _selectedIds.add(elementId);
    notifyListeners();
  }

  /// Eleman seçimini kaldırır.
  void deselectElement(String elementId) {
    _selectedIds.remove(elementId);
    notifyListeners();
  }

  /// Tüm seçimi temizler.
  void clearSelection() {
    if (_selectedIds.isEmpty) return;
    _selectedIds.clear();
    notifyListeners();
  }

  /// Tümünü seç.
  void selectAll() {
    for (final stroke in activeLayer.strokes) {
      _selectedIds.add(stroke.id);
    }
    notifyListeners();
  }

  /// Seçili elemanları siler.
  void deleteSelected() {
    if (_selectedIds.isEmpty) return;
    if (_isReadOnly) return;
    if (activeLayer.isLocked) return;

    var updatedLayer = activeLayer;
    for (final id in _selectedIds) {
      updatedLayer = updatedLayer.removeStroke(id);
    }

    final updatedPage = currentPage.updateLayer(activeLayer.id, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
    _selectedIds.clear();
  }

  // ---------------------------------------------------------------------------
  // Shape Operations
  // ---------------------------------------------------------------------------

  /// Aktif katmana shape ekler.
  void addShapeToActiveLayer(Shape shape) {
    if (_isReadOnly) return;
    if (activeLayer.isLocked) return;

    final updatedLayer = activeLayer.addShape(shape);
    final updatedPage = currentPage.updateLayer(activeLayer.id, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Aktif katmandan shape siler.
  void removeShapeFromActiveLayer(String shapeId) {
    if (_isReadOnly) return;
    if (activeLayer.isLocked) return;

    final updatedLayer = activeLayer.removeShape(shapeId);
    final updatedPage = currentPage.updateLayer(activeLayer.id, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  // ---------------------------------------------------------------------------
  // Zoom & Pan Operations
  // ---------------------------------------------------------------------------

  /// Zoom ayarlar.
  void setZoom(double zoom) {
    _zoom = zoom.clamp(CanvasConstants.minZoom, CanvasConstants.maxZoom);
    notifyListeners();
  }

  /// Zoom in.
  void zoomIn() {
    setZoom(_zoom * CanvasConstants.zoomStep);
  }

  /// Zoom out.
  void zoomOut() {
    setZoom(_zoom / CanvasConstants.zoomStep);
  }

  /// Zoom sıfırla.
  void resetZoom() {
    _zoom = CanvasConstants.defaultZoom;
    _panOffset = Offset.zero;
    notifyListeners();
  }

  /// Pan ayarlar.
  void setPanOffset(Offset offset) {
    _panOffset = offset;
    notifyListeners();
  }

  /// Pan ekler.
  void pan(Offset delta) {
    _panOffset += delta;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // History Operations
  // ---------------------------------------------------------------------------

  /// Geri al.
  void undo() {
    final document = _historyManager.undo();
    if (document != null) {
      _document = document;
      _selectedIds.clear();
      notifyListeners();
    }
  }

  /// Yinele.
  void redo() {
    final document = _historyManager.redo();
    if (document != null) {
      _document = document;
      _selectedIds.clear();
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Utility Operations
  // ---------------------------------------------------------------------------

  /// Aktif katmanı temizler.
  void clearActiveLayer() {
    if (_isReadOnly) return;
    if (activeLayer.isLocked) return;

    final updatedLayer = activeLayer.clear();
    final updatedPage = currentPage.updateLayer(activeLayer.id, updatedLayer);
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Sayfayı temizler.
  void clearCurrentPage() {
    if (_isReadOnly) return;

    final updatedPage = currentPage.clear();
    _updateDocument(_document.updateCurrentPage(updatedPage));
  }

  /// Dökümanı temizler.
  void clearDocument() {
    if (_isReadOnly) return;

    _updateDocument(_document.clear());
  }

  /// Read-only modu ayarlar.
  void setReadOnly(bool readOnly) {
    _isReadOnly = readOnly;
    notifyListeners();
  }

  @override
  void dispose() {
    _historyManager.dispose();
    super.dispose();
  }
}
