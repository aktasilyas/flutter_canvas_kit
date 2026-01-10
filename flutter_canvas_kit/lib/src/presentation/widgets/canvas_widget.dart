import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';
import 'package:flutter_canvas_kit/src/presentation/canvas/canvas_config.dart';
import 'package:flutter_canvas_kit/src/presentation/canvas/canvas_theme.dart';
import 'package:flutter_canvas_kit/src/presentation/controllers/canvas_controller.dart';
import 'package:flutter_canvas_kit/src/presentation/painters/canvas_painter.dart';
import 'package:flutter_canvas_kit/src/presentation/tools/tool.dart';

/// Ana canvas widget'ı.
///
/// Çizim, zoom, pan ve tüm kullanıcı etkileşimlerini yönetir.
class CanvasWidget extends StatefulWidget {
  /// Canvas kontrolcüsü.
  final CanvasController controller;

  /// Yapılandırma.
  final CanvasConfig config;

  /// Tema.
  final CanvasTheme theme;

  /// Aktif araç.
  final Tool? tool;

  /// Çizim başladığında.
  final VoidCallback? onDrawStart;

  /// Çizim bittiğinde.
  final VoidCallback? onDrawEnd;

  /// Zoom değiştiğinde.
  final ValueChanged<double>? onZoomChanged;

  const CanvasWidget({
    super.key,
    required this.controller,
    this.config = const CanvasConfig(),
    this.theme = const CanvasTheme(),
    this.tool,
    this.onDrawStart,
    this.onDrawEnd,
    this.onZoomChanged,
  });

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  /// Transform matrisi.
  late TransformationController _transformController;

  /// Pointer ID takibi.
  int? _activePointerId;

  /// Çizim aktif mi?
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _initializeTransform();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _initializeTransform() {
    final scale = widget.config.initialZoom;
    _transformController.value = Matrix4.identity()..scale(scale);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.controller.currentPage;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: widget.theme.outsideCanvasColor,
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: widget.config.minZoom,
            maxScale: widget.config.maxZoom,
            panEnabled: !_isDrawing,
            scaleEnabled: widget.config.enableMultiTouch,
            onInteractionUpdate: _onInteractionUpdate,
            child: Center(
              child: Container(
                width: page.width,
                height: page.height,
                decoration: widget.theme.showPageShadow
                    ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: widget.theme.pageShadowColor,
                            blurRadius: 10,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      )
                    : null,
                child: ClipRect(
                  child: Listener(
                    onPointerDown: _onPointerDown,
                    onPointerMove: _onPointerMove,
                    onPointerUp: _onPointerUp,
                    onPointerCancel: _onPointerCancel,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size(page.width, page.height),
                        painter: CanvasPainter(
                          page: page,
                          activeStrokePoints:
                              widget.controller.activeStrokePoints,
                          activeShape: widget.controller.activeShape,
                          activeStrokeColor: widget.controller.currentColor,
                          activeStrokeWidth: widget.controller.currentWidth,
                          selectedIds: widget.controller.selectedIds,
                          debugMode: widget.config.debugMode,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final scale = _transformController.value.getMaxScaleOnAxis();
    widget.controller.setZoom(scale);
    widget.onZoomChanged?.call(scale);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.config.readOnly || widget.controller.isReadOnly) return;

    // İlk parmağı takip et
    if (_activePointerId != null) return;
    _activePointerId = event.pointer;
    _isDrawing = true;

    final localPosition = _getLocalPosition(event.localPosition);
    final point = _createStrokePoint(localPosition, event);

    widget.tool?.onPointerDown(
      widget.controller,
      point,
      PointerDownData(
        screenPosition: event.position,
        canvasPosition: localPosition,
        pressure: _getPressure(event),
        kind: _getPointerKind(event.kind),
        pointerId: event.pointer,
      ),
    );

    widget.onDrawStart?.call();
    setState(() {});
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isDrawing) return;
    if (event.pointer != _activePointerId) return;

    final localPosition = _getLocalPosition(event.localPosition);
    final point = _createStrokePoint(localPosition, event);

    widget.tool?.onPointerMove(
      widget.controller,
      point,
      PointerMoveData(
        screenPosition: event.position,
        canvasPosition: localPosition,
        pressure: _getPressure(event),
        kind: _getPointerKind(event.kind),
        pointerId: event.pointer,
        delta: event.delta,
      ),
    );

    setState(() {});
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointerId) return;

    final localPosition = _getLocalPosition(event.localPosition);
    final point = StrokePoint.fromOffset(localPosition);

    widget.tool?.onPointerUp(
      widget.controller,
      point,
      PointerUpData(
        screenPosition: event.position,
        canvasPosition: localPosition,
        kind: _getPointerKind(event.kind),
        pointerId: event.pointer,
      ),
    );

    _activePointerId = null;
    _isDrawing = false;
    widget.onDrawEnd?.call();
    setState(() {});
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointerId) return;

    widget.tool?.onPointerCancel(widget.controller);

    _activePointerId = null;
    _isDrawing = false;
    setState(() {});
  }

  Offset _getLocalPosition(Offset position) {
    return position;
  }

  StrokePoint _createStrokePoint(Offset position, PointerEvent event) {
    return StrokePoint.fromOffset(
      position,
      pressure: _getPressure(event),
      timestamp: event.timeStamp.inMilliseconds,
    );
  }

  double _getPressure(PointerEvent event) {
    if (!widget.config.enablePressure) return 0.5;
    if (event.pressure == 0 || event.pressure == 1) return 0.5;
    return event.pressure.clamp(0.0, 1.0);
  }

  CanvasPointerKind _getPointerKind(ui.PointerDeviceKind kind) {
    return switch (kind) {
      ui.PointerDeviceKind.touch => CanvasPointerKind.touch,
      ui.PointerDeviceKind.stylus => CanvasPointerKind.stylus,
      ui.PointerDeviceKind.mouse => CanvasPointerKind.mouse,
      _ => CanvasPointerKind.unknown,
    };
  }
}
