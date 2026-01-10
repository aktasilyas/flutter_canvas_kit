import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_canvas_kit/src/core/errors/canvas_exception.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_document.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_page.dart';
import 'package:flutter_canvas_kit/src/domain/entities/stroke.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_background.dart';

/// PNG export ayarları.
class PngExportOptions {
  /// Çıktı genişliği (null = sayfa genişliği).
  final double? width;

  /// Çıktı yüksekliği (null = sayfa yüksekliği).
  final double? height;

  /// Piksel yoğunluğu.
  final double pixelRatio;

  /// Arka plan rengi (null = şeffaf).
  final ui.Color? backgroundColor;

  /// Sayfa arka plan deseni dahil mi?
  final bool includeBackground;

  /// Sadece içerik alanını export et.
  final bool cropToContent;

  /// İçerik etrafında padding.
  final double contentPadding;

  const PngExportOptions({
    this.width,
    this.height,
    this.pixelRatio = 2.0,
    this.backgroundColor,
    this.includeBackground = true,
    this.cropToContent = false,
    this.contentPadding = 20.0,
  });

  /// Varsayılan ayarlar.
  static const PngExportOptions defaultOptions = PngExportOptions();

  /// Yüksek kalite ayarları.
  static const PngExportOptions highQuality = PngExportOptions(
    pixelRatio: 3.0,
  );

  /// Web için optimize edilmiş ayarlar.
  static const PngExportOptions webOptimized = PngExportOptions(
    pixelRatio: 1.0,
  );

  /// Thumbnail için ayarlar.
  static const PngExportOptions thumbnail = PngExportOptions(
    width: 200,
    height: 200,
    pixelRatio: 1.0,
    cropToContent: true,
  );
}

/// PNG export servisi.
///
/// Canvas içeriğini PNG formatına export eder.
abstract final class PngExporter {
  /// Sayfayı PNG byte array olarak export eder.
  static Future<Uint8List> exportPage(
    CanvasPage page, {
    PngExportOptions options = const PngExportOptions(),
  }) async {
    try {
      // Boyutları hesapla
      double exportWidth;
      double exportHeight;

      if (options.cropToContent && !page.isEmpty) {
        final contentBounds = page.contentBoundingBox;
        exportWidth =
            options.width ?? (contentBounds.width + options.contentPadding * 2);
        exportHeight = options.height ??
            (contentBounds.height + options.contentPadding * 2);
      } else {
        exportWidth = options.width ?? page.width;
        exportHeight = options.height ?? page.height;
      }

      final pixelWidth = (exportWidth * options.pixelRatio).toInt();
      final pixelHeight = (exportHeight * options.pixelRatio).toInt();

      // Picture recorder oluştur
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // Scale uygula
      canvas.scale(options.pixelRatio);

      // Content offset (crop için)
      double offsetX = 0;
      double offsetY = 0;

      if (options.cropToContent && !page.isEmpty) {
        final contentBounds = page.contentBoundingBox;
        offsetX = -contentBounds.left + options.contentPadding;
        offsetY = -contentBounds.top + options.contentPadding;
        canvas.translate(offsetX, offsetY);
      }

      // Arka plan çiz
      if (options.backgroundColor != null) {
        canvas.drawRect(
          ui.Rect.fromLTWH(-offsetX, -offsetY, exportWidth, exportHeight),
          ui.Paint()..color = options.backgroundColor!,
        );
      } else if (options.includeBackground) {
        // Sayfa arka planı
        canvas.drawRect(
          ui.Rect.fromLTWH(-offsetX, -offsetY, exportWidth, exportHeight),
          ui.Paint()..color = page.backgroundColor,
        );

        // Grid/pattern
        _renderBackground(
            canvas, page, exportWidth, exportHeight, offsetX, offsetY);
      }

      // Sayfa içeriğini çiz
      _renderPageContent(canvas, page);

      // Picture'ı image'a dönüştür
      final picture = recorder.endRecording();
      final image = await picture.toImage(pixelWidth, pixelHeight);

      // PNG bytes'a dönüştür
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw ImageExportException(
          format: 'PNG',
          details: 'Failed to convert image to bytes',
        );
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      if (e is ImageExportException) rethrow;
      throw ImageExportException(
        format: 'PNG',
        details: e.toString(),
      );
    }
  }

  /// Dökümanın tüm sayfalarını export eder.
  static Future<List<Uint8List>> exportDocument(
    CanvasDocument document, {
    PngExportOptions options = const PngExportOptions(),
  }) async {
    final results = <Uint8List>[];

    for (final page in document.pages) {
      final bytes = await exportPage(page, options: options);
      results.add(bytes);
    }

    return results;
  }

  /// Sayfayı dosyaya kaydeder.
  static Future<void> saveToFile(
    CanvasPage page,
    String filePath, {
    PngExportOptions options = const PngExportOptions(),
  }) async {
    final bytes = await exportPage(page, options: options);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
  }

  /// Dökümanı birden fazla dosyaya kaydeder.
  static Future<List<String>> saveDocumentToFiles(
    CanvasDocument document,
    String directory,
    String baseName, {
    PngExportOptions options = const PngExportOptions(),
  }) async {
    final savedPaths = <String>[];

    for (int i = 0; i < document.pages.length; i++) {
      final fileName = '${baseName}_${i + 1}.png';
      final filePath = '$directory/$fileName';

      await saveToFile(document.pages[i], filePath, options: options);
      savedPaths.add(filePath);
    }

    return savedPaths;
  }

  /// Arka plan desenini render eder.
  static void _renderBackground(
    ui.Canvas canvas,
    CanvasPage page,
    double width,
    double height,
    double offsetX,
    double offsetY,
  ) {
    if (page.background == PageBackground.blank) return;

    final paint = ui.Paint()
      ..color = page.gridColor
      ..strokeWidth = 1.0
      ..style = ui.PaintingStyle.stroke;

    final spacing = page.gridSpacing;
    final startX = -offsetX;
    final startY = -offsetY;
    final endX = startX + width;
    final endY = startY + height;

    if (page.background == PageBackground.lined ||
        page.background == PageBackground.grid) {
      // Yatay çizgiler
      for (double y = startY; y <= endY; y += spacing) {
        canvas.drawLine(
          ui.Offset(startX, y),
          ui.Offset(endX, y),
          paint,
        );
      }
    }

    if (page.background == PageBackground.grid) {
      // Dikey çizgiler
      for (double x = startX; x <= endX; x += spacing) {
        canvas.drawLine(
          ui.Offset(x, startY),
          ui.Offset(x, endY),
          paint,
        );
      }
    }

    if (page.background == PageBackground.dotted) {
      // Noktalar
      final dotPaint = ui.Paint()
        ..color = page.gridColor
        ..style = ui.PaintingStyle.fill;

      for (double y = startY; y <= endY; y += spacing) {
        for (double x = startX; x <= endX; x += spacing) {
          canvas.drawCircle(ui.Offset(x, y), 1.5, dotPaint);
        }
      }
    }
  }

  /// Sayfa içeriğini render eder.
  static void _renderPageContent(ui.Canvas canvas, CanvasPage page) {
    // Katmanları alttan üste çiz
    for (final layer in page.layers) {
      if (!layer.isVisible || layer.opacity <= 0) continue;

      // Katman opaklığı
      if (layer.opacity < 1.0) {
        canvas.saveLayer(
          null,
          ui.Paint()..color = ui.Color.fromRGBO(255, 255, 255, layer.opacity),
        );
      }

      // Stroke'ları çiz
      for (final stroke in layer.strokes) {
        _renderStroke(canvas, stroke);
      }

      // TODO: Shape, Text, Image render

      if (layer.opacity < 1.0) {
        canvas.restore();
      }
    }
  }

  /// Tek bir stroke'u render eder.
  static void _renderStroke(ui.Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = ui.Paint()
      ..color = stroke.style.effectiveColor
      ..strokeWidth = stroke.style.width
      ..strokeCap = ui.StrokeCap.round
      ..strokeJoin = ui.StrokeJoin.round
      ..style = ui.PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      // Tek nokta - daire çiz
      canvas.drawCircle(
        stroke.points.first.offset,
        stroke.style.width / 2,
        paint..style = ui.PaintingStyle.fill,
      );
      return;
    }

    // Path oluştur
    final path = ui.Path();
    path.moveTo(stroke.points.first.x, stroke.points.first.y);

    if (stroke.points.length == 2) {
      // İki nokta - düz çizgi
      path.lineTo(stroke.points.last.x, stroke.points.last.y);
    } else {
      // Çok nokta - smooth curve
      for (int i = 1; i < stroke.points.length - 1; i++) {
        final p0 = stroke.points[i];
        final p1 = stroke.points[i + 1];
        final midX = (p0.x + p1.x) / 2;
        final midY = (p0.y + p1.y) / 2;
        path.quadraticBezierTo(p0.x, p0.y, midX, midY);
      }
      // Son noktaya
      final last = stroke.points.last;
      path.lineTo(last.x, last.y);
    }

    canvas.drawPath(path, paint);
  }
}
