import 'dart:ui';

import 'package:flutter_canvas_kit/src/domain/enums/tool_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';

/// Pointer cihaz türü.
enum CanvasPointerKind {
  touch,
  stylus,
  mouse,
  unknown,
}

/// Pointer down event verisi.
class PointerDownData {
  /// Ekran koordinatı.
  final Offset screenPosition;

  /// Canvas koordinatı (transform uygulanmış).
  final Offset canvasPosition;

  /// Basınç (0.0 - 1.0).
  final double pressure;

  /// Stylus eğimi (radyan).
  final double tilt;

  /// Pointer türü.
  final CanvasPointerKind kind;

  /// Pointer ID.
  final int pointerId;

  const PointerDownData({
    required this.screenPosition,
    required this.canvasPosition,
    this.pressure = 0.5,
    this.tilt = 0.0,
    this.kind = CanvasPointerKind.unknown,
    this.pointerId = 0,
  });
}

/// Pointer move event verisi.
class PointerMoveData {
  final Offset screenPosition;
  final Offset canvasPosition;
  final double pressure;
  final double tilt;
  final CanvasPointerKind kind;
  final int pointerId;

  /// Önceki konumdan delta.
  final Offset delta;

  const PointerMoveData({
    required this.screenPosition,
    required this.canvasPosition,
    this.pressure = 0.5,
    this.tilt = 0.0,
    this.kind = CanvasPointerKind.unknown,
    this.pointerId = 0,
    this.delta = Offset.zero,
  });
}

/// Pointer up event verisi.
class PointerUpData {
  final Offset screenPosition;
  final Offset canvasPosition;
  final CanvasPointerKind kind;
  final int pointerId;

  const PointerUpData({
    required this.screenPosition,
    required this.canvasPosition,
    this.kind = CanvasPointerKind.unknown,
    this.pointerId = 0,
  });
}

/// Tüm araçların base class'ı.
///
/// Her araç bu sınıfı extend eder ve kendi davranışını tanımlar.
///
/// ## Lifecycle
///
/// ```
/// onSelected → onPointerDown → onPointerMove (x N) → onPointerUp → onDeselected
/// ```
abstract class Tool {
  /// Araç tipi.
  ToolType get type;

  /// Araç aktif mi?
  bool _isActive = false;
  bool get isActive => _isActive;

  /// Araç seçildiğinde çağrılır.
  void onSelected(CanvasController controller) {
    _isActive = true;
  }

  /// Başka araç seçildiğinde çağrılır.
  void onDeselected(CanvasController controller) {
    _isActive = false;
  }

  /// Dokunma başladığında çağrılır.
  void onPointerDown(
    CanvasController controller,
    StrokePoint point,
    PointerDownData data,
  );

  /// Dokunma hareket ettiğinde çağrılır.
  void onPointerMove(
    CanvasController controller,
    StrokePoint point,
    PointerMoveData data,
  );

  /// Dokunma bittiğinde çağrılır.
  void onPointerUp(
    CanvasController controller,
    StrokePoint point,
    PointerUpData data,
  );

  /// Dokunma iptal edildiğinde çağrılır.
  void onPointerCancel(CanvasController controller) {
    _isActive = false;
  }

  /// İkincil dokunma (sağ tık veya uzun basma).
  void onSecondaryTap(CanvasController controller, Offset position) {}

  /// Çift dokunma.
  void onDoubleTap(CanvasController controller, Offset position) {}
}

/// Çizim araçları için base class.
///
/// Pen, Highlighter, Pencil bu sınıfı extend eder.
abstract class DrawingTool extends Tool {
  @override
  void onPointerDown(
    CanvasController controller,
    StrokePoint point,
    PointerDownData data,
  ) {
    controller.startStroke(point);
  }

  @override
  void onPointerMove(
    CanvasController controller,
    StrokePoint point,
    PointerMoveData data,
  ) {
    controller.continueStroke(point);
  }

  @override
  void onPointerUp(
    CanvasController controller,
    StrokePoint point,
    PointerUpData data,
  ) {
    controller.endStroke();
  }

  @override
  void onPointerCancel(CanvasController controller) {
    controller.cancelStroke();
    super.onPointerCancel(controller);
  }
}
