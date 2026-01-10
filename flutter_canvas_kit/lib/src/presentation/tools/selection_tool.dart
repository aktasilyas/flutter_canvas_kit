import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Seçim modu.
enum SelectionMode {
  /// Tek eleman seçimi.
  single,

  /// Dikdörtgen seçim kutusu.
  rectangle,

  /// Seçili elemanları taşıma.
  move,
}

/// Seçim aracı.
///
/// Elemanları seçer ve taşır.
class SelectionTool extends Tool {
  @override
  ToolType get type => ToolType.selection;

  /// Mevcut seçim modu.
  SelectionMode _mode = SelectionMode.single;
  SelectionMode get mode => _mode;

  /// Seçim kutusu başlangıç noktası.
  Offset? _selectionStart;

  /// Seçim kutusu bitiş noktası.
  Offset? _selectionEnd;

  /// Taşıma başlangıç noktası.
  Offset? _moveStart;

  /// Seçim kutusu (dikdörtgen seçim için).
  Rect? get selectionRect {
    if (_selectionStart == null || _selectionEnd == null) return null;
    return Rect.fromPoints(_selectionStart!, _selectionEnd!);
  }

  /// Seçim modu aktif mi?
  bool get isSelecting => _mode == SelectionMode.rectangle;

  /// Taşıma modu aktif mi?
  bool get isMoving => _mode == SelectionMode.move;

  @override
  void onSelected(CanvasController controller) {
    super.onSelected(controller);
    _reset();
  }

  @override
  void onDeselected(CanvasController controller) {
    _reset();
    super.onDeselected(controller);
  }

  @override
  void onPointerDown(
    CanvasController controller,
    StrokePoint point,
    PointerDownData data,
  ) {
    final position = data.canvasPosition;

    // Seçili eleman var mı ve üzerine mi tıklandı?
    if (controller.hasSelection) {
      // Seçim alanına mı tıklandı?
      final hits = controller.activeLayer.hitTest(position);
      final hitIds = hits.map((s) => s.id).toSet();
      final selectedInHits = controller.selectedIds.intersection(hitIds);

      if (selectedInHits.isNotEmpty) {
        // Seçili eleman üzerine tıklandı - taşıma modu
        _mode = SelectionMode.move;
        _moveStart = position;
        return;
      }
    }

    // Hit test - herhangi bir eleman var mı?
    final hits = controller.activeLayer.hitTest(position);

    if (hits.isNotEmpty) {
      // Tek eleman seçimi
      controller.clearSelection();
      controller.selectElement(hits.first.id);
      _mode = SelectionMode.move;
      _moveStart = position;
    } else {
      // Dikdörtgen seçim başlat
      controller.clearSelection();
      _mode = SelectionMode.rectangle;
      _selectionStart = position;
      _selectionEnd = position;
    }
  }

  @override
  void onPointerMove(
    CanvasController controller,
    StrokePoint point,
    PointerMoveData data,
  ) {
    final position = data.canvasPosition;

    switch (_mode) {
      case SelectionMode.rectangle:
        _selectionEnd = position;
        // TODO: Seçim kutusunu render etmek için notify
        break;

      case SelectionMode.move:
        if (_moveStart != null && controller.hasSelection) {
          // TODO: controller.moveSelected implementasyonu eklenince aktif edilecek
          // final delta = position - _moveStart!;
          // controller.moveSelected(delta.dx, delta.dy);
          _moveStart = position;
        }
        break;

      case SelectionMode.single:
        break;
    }
  }

  @override
  void onPointerUp(
    CanvasController controller,
    StrokePoint point,
    PointerUpData data,
  ) {
    if (_mode == SelectionMode.rectangle && selectionRect != null) {
      // Seçim kutusundaki elemanları seç
      final hits = controller.activeLayer.hitTestRect(selectionRect!);
      for (final stroke in hits) {
        controller.selectElement(stroke.id);
      }
    }

    _resetInteraction();
  }

  @override
  void onPointerCancel(CanvasController controller) {
    _resetInteraction();
    super.onPointerCancel(controller);
  }

  @override
  void onDoubleTap(CanvasController controller, Offset position) {
    // Çift tıklama ile tüm elemanları seç
    controller.selectAll();
  }

  /// Seçili elemanları siler.
  void deleteSelected(CanvasController controller) {
    controller.deleteSelected();
  }

  /// Seçimi temizler.
  void clearSelection(CanvasController controller) {
    controller.clearSelection();
    _reset();
  }

  void _resetInteraction() {
    _selectionStart = null;
    _selectionEnd = null;
    _moveStart = null;
    _mode = SelectionMode.single;
  }

  void _reset() {
    _resetInteraction();
  }
}
