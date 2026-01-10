import 'dart:ui';

/// Canvas tema ayarları.
///
/// UI elementleri için renkler ve stiller.
class CanvasTheme {
  /// Seçim kutusu rengi.
  final Color selectionColor;

  /// Seçim kutusu dolgu rengi.
  final Color selectionFillColor;

  /// Seçim handle rengi.
  final Color handleColor;

  /// Seçim handle boyutu.
  final double handleSize;

  /// Grid çizgi rengi.
  final Color gridColor;

  /// Grid çizgi kalınlığı.
  final double gridLineWidth;

  /// Cursor rengi.
  final Color cursorColor;

  /// Cursor boyutu.
  final double cursorSize;

  /// Silgi önizleme rengi.
  final Color eraserPreviewColor;

  /// Canvas dışı alan rengi.
  final Color outsideCanvasColor;

  /// Sayfa gölgesi.
  final bool showPageShadow;

  /// Sayfa gölge rengi.
  final Color pageShadowColor;

  const CanvasTheme({
    this.selectionColor = const Color(0xFF2196F3),
    this.selectionFillColor = const Color(0x202196F3),
    this.handleColor = const Color(0xFF1976D2),
    this.handleSize = 10.0,
    this.gridColor = const Color(0xFFE0E0E0),
    this.gridLineWidth = 1.0,
    this.cursorColor = const Color(0xFF000000),
    this.cursorSize = 20.0,
    this.eraserPreviewColor = const Color(0x40FF0000),
    this.outsideCanvasColor = const Color(0xFFBDBDBD),
    this.showPageShadow = true,
    this.pageShadowColor = const Color(0x40000000),
  });

  /// Varsayılan açık tema.
  static const CanvasTheme light = CanvasTheme();

  /// Koyu tema.
  static const CanvasTheme dark = CanvasTheme(
    selectionColor: Color(0xFF64B5F6),
    selectionFillColor: Color(0x2064B5F6),
    handleColor: Color(0xFF42A5F5),
    gridColor: Color(0xFF424242),
    cursorColor: Color(0xFFFFFFFF),
    eraserPreviewColor: Color(0x40FF5252),
    outsideCanvasColor: Color(0xFF303030),
    pageShadowColor: Color(0x60000000),
  );

  CanvasTheme copyWith({
    Color? selectionColor,
    Color? selectionFillColor,
    Color? handleColor,
    double? handleSize,
    Color? gridColor,
    double? gridLineWidth,
    Color? cursorColor,
    double? cursorSize,
    Color? eraserPreviewColor,
    Color? outsideCanvasColor,
    bool? showPageShadow,
    Color? pageShadowColor,
  }) {
    return CanvasTheme(
      selectionColor: selectionColor ?? this.selectionColor,
      selectionFillColor: selectionFillColor ?? this.selectionFillColor,
      handleColor: handleColor ?? this.handleColor,
      handleSize: handleSize ?? this.handleSize,
      gridColor: gridColor ?? this.gridColor,
      gridLineWidth: gridLineWidth ?? this.gridLineWidth,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorSize: cursorSize ?? this.cursorSize,
      eraserPreviewColor: eraserPreviewColor ?? this.eraserPreviewColor,
      outsideCanvasColor: outsideCanvasColor ?? this.outsideCanvasColor,
      showPageShadow: showPageShadow ?? this.showPageShadow,
      pageShadowColor: pageShadowColor ?? this.pageShadowColor,
    );
  }
}
