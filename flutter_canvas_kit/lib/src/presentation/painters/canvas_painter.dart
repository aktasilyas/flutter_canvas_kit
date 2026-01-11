import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_canvas_kit/src/domain/entities/canvas_page.dart';
import 'package:flutter_canvas_kit/src/domain/entities/layer.dart';
import 'package:flutter_canvas_kit/src/domain/entities/shape.dart';
import 'package:flutter_canvas_kit/src/domain/entities/stroke.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_background.dart';
import 'package:flutter_canvas_kit/src/domain/enums/shape_type.dart';
import 'package:flutter_canvas_kit/src/domain/enums/stroke_type.dart';
import 'package:flutter_canvas_kit/src/domain/value_objects/stroke_point.dart';

/// Canvas painter.
///
/// Sayfa içeriğini (background, layers, strokes, shapes) render eder.
class CanvasPainter extends CustomPainter {
  /// Çizilecek sayfa.
  final CanvasPage page;

  /// Aktif çizim noktaları (çizim sırasında).
  final List<StrokePoint>? activeStrokePoints;

  /// Aktif şekil (çizim sırasında preview için).
  final Shape? activeShape;

  /// Aktif çizim stili.
  final Color activeStrokeColor;
  final double activeStrokeWidth;
  final StrokeType activeStrokeType;

  /// Seçili eleman ID'leri.
  final Set<String> selectedIds;

  /// Debug modu.
  final bool debugMode;

  /// Statik içeriği (background, strokes, shapes) çizsin mi?
  final bool paintStaticContent;

  /// Aktif içeriği (cursor, draft, selection) çizsin mi?
  final bool paintActiveContent;

  CanvasPainter({
    required this.page,
    this.activeStrokePoints,
    this.activeShape,
    this.activeStrokeColor = const Color(0xFF000000),
    this.activeStrokeWidth = 2.0,
    this.activeStrokeType = StrokeType.pen,
    this.selectedIds = const {},
    this.debugMode = false,
    this.paintStaticContent = true,
    this.paintActiveContent = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Statik Katman (Arka plan + Kaydedilmiş Çizimler)
    if (paintStaticContent) {
      _paintBackground(canvas, size);

      for (final layer in page.layers) {
        if (!layer.isVisible) continue;
        _paintLayer(canvas, layer);
      }
    }

    // 2. Aktif Katman (O an çizilen çizgi, şekil önizlemesi, seçimler)
    if (paintActiveContent) {
      // Aktif çizim (stroke)
      if (activeStrokePoints != null && activeStrokePoints!.isNotEmpty) {
        _paintActiveStroke(canvas);
      }

      // Aktif şekil (preview)
      if (activeShape != null) {
        _paintShape(canvas, activeShape!);
      }

      // Seçim göstergeleri
      if (selectedIds.isNotEmpty) {
        _paintSelectionIndicators(canvas);
      }
      
      // Debug bilgileri (genelde en üstte olsun isteriz)
      if (debugMode) {
        _paintDebugInfo(canvas, size);
      }
    }
  }

  // ... (keeping helper methods equivalent, just method signature changed in prev steps or unaffected)

  // ...

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    // 1. Statik Katman: Sayfa nesnesi değiştiğinde (yeni bir şey eklendiğinde/silindiğinde) boya.
    // İpucu: controller.currentPage her zaman copyWith() ile yeni instance dönerse !identical() yeterli.
    // Ama CanvasPage == operatörü id-tabanlı olduğu için != operatörü burada yanıltıcıdır.
    if (paintStaticContent && !paintActiveContent) {
      return !identical(page, oldDelegate.page);
    }

    // 2. Aktif Katman: Çizim, seçim veya araç ayarları değiştiğinde boya.
    if (!paintStaticContent && paintActiveContent) {
      // Liste içi mutasyonları (add) yakalamak için uzunluk kontrolü şarttır.
      final pointsChanged = activeStrokePoints != oldDelegate.activeStrokePoints ||
          (activeStrokePoints?.length != oldDelegate.activeStrokePoints?.length);

      return pointsChanged ||
          activeShape != oldDelegate.activeShape ||
          activeStrokeType != oldDelegate.activeStrokeType ||
          activeStrokeColor != oldDelegate.activeStrokeColor ||
          activeStrokeWidth != oldDelegate.activeStrokeWidth ||
          selectedIds != oldDelegate.selectedIds ||
          debugMode != oldDelegate.debugMode ||
          !identical(page, oldDelegate.page);
    }

    // 3. Karışık Mod (Varsayılan): Herhangi bir değişiklikte boya.
    return !identical(page, oldDelegate.page) ||
        activeStrokePoints != oldDelegate.activeStrokePoints ||
        (activeStrokePoints?.length != oldDelegate.activeStrokePoints?.length) ||
        activeShape != oldDelegate.activeShape ||
        activeStrokeType != oldDelegate.activeStrokeType ||
        selectedIds != oldDelegate.selectedIds ||
        debugMode != oldDelegate.debugMode;
  }

  void _paintBackground(Canvas canvas, Size size) {
    // Sayfa arka plan rengi
    final bgPaint = Paint()..color = page.backgroundColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, page.width, page.height),
      bgPaint,
    );

    // Arka plan deseni
    if (page.background != PageBackground.blank) {
      _paintBackgroundPattern(canvas);
    }
  }

  void _paintBackgroundPattern(Canvas canvas) {
    final paint = Paint()
      ..color = page.gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final spacing = page.gridSpacing;

    switch (page.background) {
      case PageBackground.lined:
        for (double y = spacing; y < page.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(page.width, y), paint);
        }
        break;

      case PageBackground.grid:
        // Yatay çizgiler
        for (double y = spacing; y < page.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(page.width, y), paint);
        }
        // Dikey çizgiler
        for (double x = spacing; x < page.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, page.height), paint);
        }
        break;

      case PageBackground.dotted:
        final dotPaint = Paint()
          ..color = page.gridColor
          ..style = PaintingStyle.fill;
        for (double y = spacing; y < page.height; y += spacing) {
          for (double x = spacing; x < page.width; x += spacing) {
            canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
          }
        }
        break;

      default:
        break;
    }
  }

  void _paintLayer(Canvas canvas, Layer layer) {
    // Katman opaklığı
    if (layer.opacity < 1.0) {
      canvas.saveLayer(
        null,
        Paint()..color = Color.fromRGBO(255, 255, 255, layer.opacity),
      );
    }

    // Tüm elemanları timestamp'e göre sırala ve çiz
    final elements = <_PaintElement>[];

    for (final stroke in layer.strokes) {
      elements.add(_PaintElement(stroke.createdAt, stroke: stroke));
    }
    for (final shape in layer.shapes) {
      elements.add(_PaintElement(shape.createdAt, shape: shape));
    }

    // Eski elemanlar önce çizilsin (altta kalsın)
    elements.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final element in elements) {
      if (element.stroke != null) {
        _paintStroke(canvas, element.stroke!);
      } else if (element.shape != null) {
        _paintShape(canvas, element.shape!);
      }
    }

    if (layer.opacity < 1.0) {
      canvas.restore();
    }
  }

  void _paintStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final baseWidth = stroke.style.width;
    final thinning = stroke.style.thinning;
    final usesPressure = stroke.style.usesPressure;

    // Tek nokta - daire çiz
    if (stroke.points.length == 1) {
      final point = stroke.points.first;
      final width = usesPressure
          ? _calculateWidth(baseWidth, point.pressure, thinning)
          : baseWidth;
      final paint = Paint()
        ..color = stroke.style.effectiveColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point.offset, width / 2, paint);
      return;
    }

    // Neon stroke
    if (stroke.style.type == StrokeType.neon) {
      _paintNeonStroke(canvas, stroke);
      return;
    }

    // Dashed stroke
    if (stroke.style.type == StrokeType.dashed) {
      _paintDashedStroke(canvas, stroke);
      return;
    }

    // Basınç kullanılmıyorsa (ballPen, highlighter) - basit path çiz
    if (!usesPressure || thinning == 0) {
      final paint = Paint()
        ..color = stroke.style.effectiveColor
        ..strokeWidth = baseWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      // Highlighter için multiply blend mode (isteğe bağlı, daha gerçekçi görünür)
      if (stroke.style.type == StrokeType.highlighter) {
        paint.blendMode = BlendMode.multiply;
      }

      final path = _createStrokePath(stroke.points);
      canvas.drawPath(path, paint);
      return;
    }

    // Basınç duyarlı çizim - her segment için ayrı kalınlık
    _paintPressureSensitiveStroke(canvas, stroke);
  }

  void _paintNeonStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;
    
    final path = _createStrokePath(stroke.points);
    final color = stroke.style.effectiveColor;
    final width = stroke.style.width;

    // Glow layers
    for (double i = 1; i <= 3; i++) {
        final paint = Paint()
          ..color = color.withValues(alpha: 0.2 / i)
          ..strokeWidth = width * (2 * i) 
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * i);
        canvas.drawPath(path, paint);
    }
    
    // Core line (white)
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = width * 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(path, corePaint);
  }

  void _paintDashedStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;
    
    final path = _createStrokePath(stroke.points);
    final paint = Paint()
      ..color = stroke.style.effectiveColor
      ..strokeWidth = stroke.style.width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashPath = _createDashedPath(path, stroke.style.width * 2, stroke.style.width);
    canvas.drawPath(dashPath, paint);
  }
  
  Path _createDashedPath(Path source, double dashWidth, double dashSpace) {
    final path = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        path.addPath(segment, Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    return path;
  }

  void _paintPressureSensitiveStroke(Canvas canvas, Stroke stroke) {
    final points = stroke.points;
    final baseWidth = stroke.style.width;
    final thinning = stroke.style.thinning;
    final color = stroke.style.effectiveColor;

    // Her nokta için daire çiz (basit ama etkili yöntem)
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final width = _calculateWidth(baseWidth, point.pressure, thinning);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point.offset, width / 2, paint);
    }

    // Noktalar arası bağlantılar için çizgiler
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final width1 = _calculateWidth(baseWidth, p1.pressure, thinning);
      final width2 = _calculateWidth(baseWidth, p2.pressure, thinning);
      final avgWidth = (width1 + width2) / 2;

      final paint = Paint()
        ..color = color
        ..strokeWidth = avgWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p1.offset, p2.offset, paint);
    }
  }

  double _calculateWidth(double baseWidth, double pressure, double thinning) {
    // thinning: 0 = sabit kalınlık, 1 = maksimum basınç etkisi
    // pressure: 0.0 - 1.0
    final minWidth = baseWidth * (1.0 - thinning);
    final maxWidth = baseWidth * (1.0 + thinning * 0.5);
    return minWidth + (maxWidth - minWidth) * pressure;
  }

  void _paintActiveStroke(Canvas canvas) {
    if (activeStrokePoints == null || activeStrokePoints!.isEmpty) return;

    final points = activeStrokePoints!;
    final thinning = activeStrokeType.thinning;
    final usesPressure = activeStrokeType.usesPressure;

    // Tek nokta - daire çiz
    if (points.length == 1) {
      final point = points.first;
      final width = usesPressure
          ? _calculateWidth(activeStrokeWidth, point.pressure, thinning)
          : activeStrokeWidth;
      final paint = Paint()
        ..color = activeStrokeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point.offset, width / 2, paint);
      return;
    }

    // Neon active stroke
    if (activeStrokeType == StrokeType.neon) {
      _paintActiveNeonStroke(canvas);
      return;
    }

    // Dashed active stroke
    if (activeStrokeType == StrokeType.dashed) {
      _paintActiveDashedStroke(canvas);
      return;
    }

    // Basınç kullanılmıyorsa - basit path çiz
    if (!usesPressure || thinning == 0) {
      final paint = Paint()
        ..color = activeStrokeColor
        ..strokeWidth = activeStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      
      if (activeStrokeType == StrokeType.highlighter) {
        paint.blendMode = BlendMode.multiply;
      }

      final path = _createStrokePath(points);
      canvas.drawPath(path, paint);
      return;
    }

    // Basınç duyarlı aktif çizim
    _paintPressureSensitiveActiveStroke(canvas);
  }

  void _paintActiveNeonStroke(Canvas canvas) {
    final points = activeStrokePoints!;
    final path = _createStrokePath(points);
    final color = activeStrokeColor;
    final width = activeStrokeWidth;

    // Glow layers
    for (double i = 1; i <= 3; i++) {
        final paint = Paint()
          ..color = color.withValues(alpha: 0.2 / i)
          ..strokeWidth = width * (2 * i) 
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * i);
        canvas.drawPath(path, paint);
    }
    
    // Core line
    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = width * 0.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
      
    canvas.drawPath(path, corePaint);
  }

  void _paintActiveDashedStroke(Canvas canvas) {
    final points = activeStrokePoints!;
    final path = _createStrokePath(points);
    final paint = Paint()
      ..color = activeStrokeColor
      ..strokeWidth = activeStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dashPath = _createDashedPath(path, activeStrokeWidth * 2, activeStrokeWidth);
    canvas.drawPath(dashPath, paint);
  }

  void _paintPressureSensitiveActiveStroke(Canvas canvas) {
    final points = activeStrokePoints!;
    final thinning = activeStrokeType.thinning;

    // Her nokta için daire çiz
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final width =
          _calculateWidth(activeStrokeWidth, point.pressure, thinning);

      final paint = Paint()
        ..color = activeStrokeColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(point.offset, width / 2, paint);
    }

    // Noktalar arası bağlantılar
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final width1 = _calculateWidth(activeStrokeWidth, p1.pressure, thinning);
      final width2 = _calculateWidth(activeStrokeWidth, p2.pressure, thinning);
      final avgWidth = (width1 + width2) / 2;

      final paint = Paint()
        ..color = activeStrokeColor
        ..strokeWidth = avgWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(p1.offset, p2.offset, paint);
    }
  }

  Path _createStrokePath(List<StrokePoint> points) {
    final path = Path();
    path.moveTo(points.first.x, points.first.y);

    if (points.length == 2) {
      path.lineTo(points.last.x, points.last.y);
    } else {
      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.x + p1.x) / 2;
        final midY = (p0.y + p1.y) / 2;
        path.quadraticBezierTo(p0.x, p0.y, midX, midY);
      }
      path.lineTo(points.last.x, points.last.y);
    }

    return path;
  }

  void _paintShape(Canvas canvas, Shape shape) {
    final strokePaint = Paint()
      ..color = shape.style.effectiveColor
      ..strokeWidth = shape.style.width
      ..style = PaintingStyle.stroke;

    final fillPaint = shape.isFilled
        ? (Paint()
          ..color = shape.effectiveFillColor
          ..style = PaintingStyle.fill)
        : null;

    final rect = Rect.fromPoints(shape.startPoint, shape.endPoint);

    switch (shape.type) {
      case ShapeType.rectangle:
      case ShapeType.square:
        if (fillPaint != null) canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, strokePaint);
        break;

      case ShapeType.roundedRectangle:
        final rrect = RRect.fromRectAndRadius(
          rect,
          Radius.circular(shape.cornerRadius),
        );
        if (fillPaint != null) canvas.drawRRect(rrect, fillPaint);
        canvas.drawRRect(rrect, strokePaint);
        break;

      case ShapeType.ellipse:
      case ShapeType.circle:
        if (fillPaint != null) canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, strokePaint);
        break;

      case ShapeType.line:
        canvas.drawLine(shape.startPoint, shape.endPoint, strokePaint);
        break;

      case ShapeType.arrow:
        _paintArrow(canvas, shape.startPoint, shape.endPoint, strokePaint);
        break;

      case ShapeType.doubleArrow:
        _paintArrow(canvas, shape.startPoint, shape.endPoint, strokePaint);
        _paintArrow(canvas, shape.endPoint, shape.startPoint, strokePaint);
        break;

      case ShapeType.triangle:
        final path = _createTrianglePath(rect);
        if (fillPaint != null) canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
        break;

      case ShapeType.star:
        final path = _createStarPath(rect, shape.pointCount);
        if (fillPaint != null) canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
        break;

      case ShapeType.polygon:
        final path = _createPolygonPath(rect, shape.pointCount);
        if (fillPaint != null) canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
        break;

      default:
        if (fillPaint != null) canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, strokePaint);
    }
  }

  void _paintArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);

    // Ok başı
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = (dx * dx + dy * dy);
    if (length == 0) return;

    final unitX = dx / _sqrt(length);
    final unitY = dy / _sqrt(length);

    final arrowSize = paint.strokeWidth * 4;
    final arrowAngle = 0.5; // ~30 derece

    final p1 = Offset(
      end.dx - arrowSize * (unitX + arrowAngle * unitY),
      end.dy - arrowSize * (unitY - arrowAngle * unitX),
    );
    final p2 = Offset(
      end.dx - arrowSize * (unitX - arrowAngle * unitY),
      end.dy - arrowSize * (unitY + arrowAngle * unitX),
    );

    canvas.drawLine(end, p1, paint);
    canvas.drawLine(end, p2, paint);
  }

  Path _createTrianglePath(Rect rect) {
    final path = Path();
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.left, rect.bottom);
    path.close();
    return path;
  }

  Path _createStarPath(Rect rect, int points) {
    final path = Path();
    final center = rect.center;
    final outerRadius = math.min(rect.width, rect.height) / 2;
    final innerRadius = outerRadius * 0.4;
    final step = math.pi / points;

    path.moveTo(
      center.dx + outerRadius * math.cos(-math.pi / 2),
      center.dy + outerRadius * math.sin(-math.pi / 2),
    );

    for (int i = 1; i <= points * 2; i++) {
        final radius = i % 2 == 0 ? outerRadius : innerRadius;
        final angle = -math.pi / 2 + step * i;
        path.lineTo(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        );
    }
    path.close();
    return path;
  }

  Path _createPolygonPath(Rect rect, int points) {
    final path = Path();
    final center = rect.center;
    final radius = math.min(rect.width, rect.height) / 2;
    final step = (math.pi * 2) / points;

    path.moveTo(
      center.dx + radius * math.cos(-math.pi / 2),
      center.dy + radius * math.sin(-math.pi / 2),
    );

    for (int i = 1; i < points; i++) {
      final angle = -math.pi / 2 + step * i;
      path.lineTo(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
    }
    path.close();
    return path;
  }

  void _paintSelectionIndicators(Canvas canvas) {
    final selectionPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final layer in page.layers) {
      for (final stroke in layer.strokes) {
        if (selectedIds.contains(stroke.id)) {
          final bounds = stroke.boundingBox.inflate(4);
          canvas.drawRect(bounds, selectionPaint);
        }
      }
      for (final shape in layer.shapes) {
        if (selectedIds.contains(shape.id)) {
          final bounds = shape.boundingBox.inflate(4);
          canvas.drawRect(bounds, selectionPaint);
        }
      }
    }
  }

  void _paintDebugInfo(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Page: ${page.width.toInt()}x${page.height.toInt()}\n'
            'Layers: ${page.layerCount}\n'
            'Elements: ${page.totalElementCount}',
        style: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.drawRect(
      Rect.fromLTWH(8, 8, textPainter.width + 8, textPainter.height + 8),
      Paint()..color = const Color(0xCCFFFFFF),
    );
    textPainter.paint(canvas, const Offset(12, 12));
  }

  double _sqrt(double value) {
    if (value <= 0) return 0;
    double guess = value / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + value / guess) / 2;
    }
    return guess;
  }
}

/// Çizim sıralaması için yardımcı sınıf.
class _PaintElement {
  final DateTime timestamp;
  final Stroke? stroke;
  final Shape? shape;

  _PaintElement(this.timestamp, {this.stroke, this.shape});
}
