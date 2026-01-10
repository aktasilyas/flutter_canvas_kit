import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/entities/shape.dart';
import 'package:flutter_canvas_kit/src/domain/enums/shape_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Şekil çizme aracı.
///
/// Dikdörtgen, daire, çizgi gibi geometrik şekiller çizer.
class ShapeTool extends Tool {
  @override
  ToolType get type => ToolType.shape;

  /// Başlangıç noktası.
  Offset? _startPoint;

  /// Mevcut bitiş noktası.
  Offset? _currentEndPoint;

  /// Aktif controller referansı.
  CanvasController? _controller;

  /// Şekil çizme başladı mı?
  bool get isDrawing => _startPoint != null;

  @override
  void onPointerDown(
    CanvasController controller,
    StrokePoint point,
    PointerDownData data,
  ) {
    _controller = controller;
    _startPoint = data.canvasPosition;
    _currentEndPoint = data.canvasPosition;
    _updatePreview();
  }

  @override
  void onPointerMove(
    CanvasController controller,
    StrokePoint point,
    PointerMoveData data,
  ) {
    if (_startPoint == null) return;

    _currentEndPoint = data.canvasPosition;
    _updatePreview();
  }

  @override
  void onPointerUp(
    CanvasController controller,
    StrokePoint point,
    PointerUpData data,
  ) {
    if (_startPoint == null) return;

    // Minimum boyut kontrolü
    final width = (_currentEndPoint!.dx - _startPoint!.dx).abs();
    final height = (_currentEndPoint!.dy - _startPoint!.dy).abs();

    if (width > 5 || height > 5) {
      // Final şekil oluştur ve layer'a ekle
      final shape = _createShape(controller);
      controller.addShapeToActiveLayer(shape);
    } else {
      controller.clearActiveShape();
    }

    _reset();
  }

  @override
  void onPointerCancel(CanvasController controller) {
    controller.clearActiveShape();
    _reset();
    super.onPointerCancel(controller);
  }

  @override
  void onDeselected(CanvasController controller) {
    controller.clearActiveShape();
    _reset();
    super.onDeselected(controller);
  }

  void _reset() {
    _startPoint = null;
    _currentEndPoint = null;
    _controller = null;
  }

  void _updatePreview() {
    if (_startPoint == null ||
        _currentEndPoint == null ||
        _controller == null) {
      return;
    }

    final shape = _createShape(_controller!);
    _controller!.setActiveShape(shape);
  }

  Shape _createShape(CanvasController controller) {
    return Shape.create(
      type: controller.currentShapeType,
      startPoint: _startPoint!,
      endPoint: _currentEndPoint!,
      style: controller.currentStyle,
      isFilled: controller.shapeFilled,
    );
  }

  @override
  void onDoubleTap(CanvasController controller, Offset position) {
    // Çift tıklama ile bir sonraki şekil tipine geç
    final types = ShapeType.values;
    final currentIndex = types.indexOf(controller.currentShapeType);
    final nextIndex = (currentIndex + 1) % types.length;
    controller.setShapeType(types[nextIndex]);
  }
}
