import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Silgi modu.
enum EraserMode {
  /// Dokunulan tüm stroke'u siler.
  stroke,

  /// Sadece dokunulan kısmı siler (gelecekte).
  partial,
}

/// Silgi aracı.
///
/// Dokunulan stroke'ları siler.
class EraserTool extends Tool {
  @override
  ToolType get type => ToolType.eraser;

  /// Silgi modu.
  EraserMode mode = EraserMode.stroke;

  /// Silgi yarıçapı.
  double _radius = 10.0;
  double get radius => _radius;
  set radius(double value) => _radius = value.clamp(5.0, 50.0);

  /// Silme işlemi devam ediyor mu?
  bool _isErasing = false;

  @override
  void onPointerDown(
    CanvasController controller,
    StrokePoint point,
    PointerDownData data,
  ) {
    controller.historyManager.beginBatch();
    _isErasing = true;
    _eraseAt(controller, data.canvasPosition);
  }

  @override
  void onPointerMove(
    CanvasController controller,
    StrokePoint point,
    PointerMoveData data,
  ) {
    if (!_isErasing) return;
    _eraseAt(controller, data.canvasPosition);
  }

  @override
  void onPointerUp(
    CanvasController controller,
    StrokePoint point,
    PointerUpData data,
  ) {
    _isErasing = false;
    controller.historyManager.endBatch();
  }

  @override
  void onPointerCancel(CanvasController controller) {
    _isErasing = false;
    controller.historyManager.endBatch();
    super.onPointerCancel(controller);
  }

  /// Belirli noktada silme işlemi yapar.
  void _eraseAt(CanvasController controller, Offset position) {
    controller.eraseAt(position, radius: _radius);
  }
}
