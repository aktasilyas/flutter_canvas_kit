import 'dart:ui';

import 'package:flutter_canvas_kit/src/core/constants/canvas_constants.dart';

/// Canvas yapılandırma ayarları.
///
/// Widget oluşturulurken geçirilir, runtime'da değiştirilemez.
class CanvasConfig {
  /// Minimum zoom seviyesi.
  final double minZoom;

  /// Maksimum zoom seviyesi.
  final double maxZoom;

  /// Başlangıç zoom seviyesi.
  final double initialZoom;

  /// Zoom adımı (pinch/scroll).
  final double zoomStep;

  /// Hit test toleransı (piksel).
  final double hitTestTolerance;

  /// Grid göster.
  final bool showGrid;

  /// Grid'e snap.
  final bool snapToGrid;

  /// Grid aralığı.
  final double gridSpacing;

  /// Çoklu dokunma desteği.
  final bool enableMultiTouch;

  /// Stylus basınç desteği.
  final bool enablePressure;

  /// Palm rejection (avuç içi reddi).
  final bool enablePalmRejection;

  /// Debug mode (bounds, fps göster).
  final bool debugMode;

  /// Arka plan rengi (sayfa dışı alan).
  final Color canvasBackgroundColor;

  /// Read-only mod.
  final bool readOnly;

  const CanvasConfig({
    this.minZoom = CanvasConstants.minZoom,
    this.maxZoom = CanvasConstants.maxZoom,
    this.initialZoom = CanvasConstants.defaultZoom,
    this.zoomStep = CanvasConstants.zoomStep,
    this.hitTestTolerance = CanvasConstants.defaultHitTolerance,
    this.showGrid = false,
    this.snapToGrid = false,
    this.gridSpacing = CanvasConstants.defaultGridSpacing,
    this.enableMultiTouch = true,
    this.enablePressure = true,
    this.enablePalmRejection = true,
    this.debugMode = false,
    this.canvasBackgroundColor = const Color(0xFFE0E0E0),
    this.readOnly = false,
  });

  /// Varsayılan yapılandırma.
  static const CanvasConfig defaultConfig = CanvasConfig();

  /// Sadece görüntüleme için yapılandırma.
  static const CanvasConfig viewOnly = CanvasConfig(
    readOnly: true,
    enableMultiTouch: true,
    enablePressure: false,
    enablePalmRejection: false,
  );

  /// Debug yapılandırması.
  static const CanvasConfig debug = CanvasConfig(
    debugMode: true,
    showGrid: true,
  );

  CanvasConfig copyWith({
    double? minZoom,
    double? maxZoom,
    double? initialZoom,
    double? zoomStep,
    double? hitTestTolerance,
    bool? showGrid,
    bool? snapToGrid,
    double? gridSpacing,
    bool? enableMultiTouch,
    bool? enablePressure,
    bool? enablePalmRejection,
    bool? debugMode,
    Color? canvasBackgroundColor,
    bool? readOnly,
  }) {
    return CanvasConfig(
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      initialZoom: initialZoom ?? this.initialZoom,
      zoomStep: zoomStep ?? this.zoomStep,
      hitTestTolerance: hitTestTolerance ?? this.hitTestTolerance,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      gridSpacing: gridSpacing ?? this.gridSpacing,
      enableMultiTouch: enableMultiTouch ?? this.enableMultiTouch,
      enablePressure: enablePressure ?? this.enablePressure,
      enablePalmRejection: enablePalmRejection ?? this.enablePalmRejection,
      debugMode: debugMode ?? this.debugMode,
      canvasBackgroundColor:
          canvasBackgroundColor ?? this.canvasBackgroundColor,
      readOnly: readOnly ?? this.readOnly,
    );
  }
}
