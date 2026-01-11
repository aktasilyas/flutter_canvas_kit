import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/enums/eraser_mode.dart';
import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Silgi aracı.
///
/// Dokunulan stroke'ları siler.
class EraserTool extends Tool {
  @override
  ToolType get type => ToolType.eraser;

  // Radius removed, using controller.currentWidth / 2

  /// Silme işlemi devam ediyor mu?
  bool _isErasing = false;

  /// Alan silme için başlangıç noktası.
  Offset? _startPoint;
  
  /// Alan silme için mevcut nokta.
  Offset? _currentPoint;

  @override
  void onPointerDown(
    CanvasController controller,
    StrokePoint point,
    PointerDownData data,
  ) {
    if (controller.eraserMode == EraserMode.area) {
      _startPoint = data.canvasPosition;
      _currentPoint = data.canvasPosition;
      // Area seçim için shape preview kullanabiliriz (opsiyonel)
    } else {
      _isErasing = true;
      controller.historyManager.beginBatch();
      _eraseAt(controller, data.canvasPosition);
    }
  }

  @override
  void onPointerMove(
    CanvasController controller,
    StrokePoint point,
    PointerMoveData data,
  ) {
    if (controller.eraserMode == EraserMode.area) {
      if (_startPoint != null) {
        _currentPoint = data.canvasPosition;
        controller.setActiveEraserRect(Rect.fromPoints(_startPoint!, _currentPoint!));
      }
    } else if (_isErasing) {
      _eraseAt(controller, data.canvasPosition);
    }
  }

  @override
  void onPointerUp(
    CanvasController controller,
    StrokePoint point,
    PointerUpData data,
  ) {
    if (controller.eraserMode == EraserMode.area) {
      if (_startPoint != null && _currentPoint != null) {
        final rect = Rect.fromPoints(_startPoint!, _currentPoint!);
        controller.eraseArea(rect);
      }
      _startPoint = null;
      _currentPoint = null;
      controller.setActiveEraserRect(null);
    } else {
      _isErasing = false;
      controller.historyManager.endBatch();
    }
  }

  @override
  void onPointerCancel(CanvasController controller) {
    _isErasing = false;
    _startPoint = null;
    _currentPoint = null;
    controller.setActiveEraserRect(null);
    if (controller.historyManager.isBatching) {
        controller.historyManager.cancelBatch();
    }
    super.onPointerCancel(controller);
  }

  /// Belirli noktada silme işlemi yapar.
  void _eraseAt(CanvasController controller, Offset position) {
    // Controller'dan gelen eraserWidth (kalınlık) çap kabul edilir, yarıçap yarısıdır.
    final radius = controller.eraserWidth / 2;
    
    if (controller.eraserMode == EraserMode.pixel) {
      controller.erasePartial(position, radius: radius);
    } else {
      controller.eraseAt(position, radius: radius);
    }
  }
}
