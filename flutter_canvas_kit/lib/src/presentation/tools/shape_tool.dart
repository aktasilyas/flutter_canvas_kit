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

  /// Geçici şekil (çizim sırasında preview için).
  Shape? _tempShape;
  Shape? get tempShape => _tempShape;

  /// Shift tuşu basılı mı? (kare/daire zorla).
  bool _constrainProportions = false;
  bool get constrainProportions => _constrainProportions;
  set constrainProportions(bool value) {
    _constrainProportions = value;
    _updateTempShape();
  }

  /// Şekil çizme başladı mı?
  bool get isDrawing => _startPoint != null;

  @override
  void onPointerDown(
    CanvasController controller,
    StrokePoint point,
    PointerDownData data,
  ) {
    _startPoint = data.canvasPosition;
    _currentEndPoint = data.canvasPosition;
    _updateTempShape(controller: controller);
  }

  @override
  void onPointerMove(
    CanvasController controller,
    StrokePoint point,
    PointerMoveData data,
  ) {
    if (_startPoint == null) return;

    _currentEndPoint = data.canvasPosition;
    _updateTempShape(controller: controller);
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
      final shape = _createShape(
        controller.currentShapeType,
        _startPoint!,
        _currentEndPoint!,
        controller,
      );

      controller.addShapeToActiveLayer(shape);
    }

    _reset();
  }

  @override
  void onPointerCancel(CanvasController controller) {
    _reset();
    super.onPointerCancel(controller);
  }

  /// Şekil çizimini iptal eder.
  void cancel() {
    _reset();
  }

  void _reset() {
    _startPoint = null;
    _currentEndPoint = null;
    _tempShape = null;
  }

  void _updateTempShape({CanvasController? controller}) {
    if (_startPoint == null || _currentEndPoint == null) {
      _tempShape = null;
      return;
    }

    if (controller == null) return;

    var endPoint = _currentEndPoint!;

    // Orantılı şekil (shift tuşu)
    if (_constrainProportions) {
      endPoint = _constrainToSquare(_startPoint!, endPoint);
    }

    _tempShape = _createShape(
      controller.currentShapeType,
      _startPoint!,
      endPoint,
      controller,
    );
  }

  Shape _createShape(
    ShapeType type,
    Offset start,
    Offset end,
    CanvasController controller,
  ) {
    return Shape.create(
      type: type,
      startPoint: start,
      endPoint: end,
      style: controller.currentStyle,
      isFilled: controller.shapeFilled,
    );
  }

  /// Bitiş noktasını kare orantısına zorlar.
  Offset _constrainToSquare(Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final size = dx.abs() > dy.abs() ? dx.abs() : dy.abs();

    return Offset(
      start.dx + (dx >= 0 ? size : -size),
      start.dy + (dy >= 0 ? size : -size),
    );
  }

  @override
  void onDoubleTap(CanvasController controller, Offset position) {
    // Çift tıklama ile bir sonraki şekil tipine geç
    const types = ShapeType.values;
    final currentIndex = types.indexOf(controller.currentShapeType);
    final nextIndex = (currentIndex + 1) % types.length;
    controller.setShapeType(types[nextIndex]);
  }
}
