import 'package:flutter/material.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_page.dart';
import 'package:flutter_canvas_kit/src/domain/entities/layer.dart';
import 'package:flutter_canvas_kit/src/domain/entities/shape.dart';
import 'package:flutter_canvas_kit/src/domain/entities/stroke.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_background.dart';
import 'package:flutter_canvas_kit/src/domain/enums/shape_type.dart';
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

  /// Seçili eleman ID'leri.
  final Set<String> selectedIds;

  /// Debug modu.
  final bool debugMode;

  CanvasPainter({
    required this.page,
    this.activeStrokePoints,
    this.activeShape,
    this.activeStrokeColor = const Color(0xFF000000),
    this.activeStrokeWidth = 2.0,
    this.selectedIds = const {},
    this.debugMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Arka plan
    _paintBackground(canvas, size);

    // Katmanlar
    for (final layer in page.layers) {
      if (!layer.isVisible) continue;
      _paintLayer(canvas, layer);
    }

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

    // Debug bilgileri
    if (debugMode) {
      _paintDebugInfo(canvas, size);
    }
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

    final paint = Paint()
      ..color = stroke.style.effectiveColor
      ..strokeWidth = stroke.style.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      canvas.drawCircle(
        stroke.points.first.offset,
        stroke.style.width / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = _createStrokePath(stroke.points);
    canvas.drawPath(path, paint);
  }

  void _paintActiveStroke(Canvas canvas) {
    if (activeStrokePoints == null || activeStrokePoints!.isEmpty) return;

    final paint = Paint()
      ..color = activeStrokeColor
      ..strokeWidth = activeStrokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (activeStrokePoints!.length == 1) {
      canvas.drawCircle(
        activeStrokePoints!.first.offset,
        activeStrokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      return;
    }

    final path = _createStrokePath(activeStrokePoints!);
    canvas.drawPath(path, paint);
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

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return page != oldDelegate.page ||
        activeStrokePoints != oldDelegate.activeStrokePoints ||
        activeShape != oldDelegate.activeShape ||
        selectedIds != oldDelegate.selectedIds;
  }
}

/// Çizim sıralaması için yardımcı sınıf.
class _PaintElement {
  final DateTime timestamp;
  final Stroke? stroke;
  final Shape? shape;

  _PaintElement(this.timestamp, {this.stroke, this.shape});
}
