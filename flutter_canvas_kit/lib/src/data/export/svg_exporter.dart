import 'dart:io';
import 'dart:ui';

import 'package:flutter_canvas_kit/src/core/errors/canvas_exception.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_document.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_page.dart';
import 'package:flutter_canvas_kit/src/domain/entities/stroke.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_background.dart';

/// SVG export ayarları.
class SvgExportOptions {
  /// Genişlik (null = sayfa genişliği).
  final double? width;

  /// Yükseklik (null = sayfa yüksekliği).
  final double? height;

  /// Arka plan dahil mi?
  final bool includeBackground;

  /// Arka plan rengi (null = şeffaf).
  final String? backgroundColor;

  /// Stroke'ları optimize et.
  final bool optimizeStrokes;

  /// Decimal precision.
  final int decimalPrecision;

  /// Sadece içerik alanını export et.
  final bool cropToContent;

  /// İçerik etrafında padding.
  final double contentPadding;

  const SvgExportOptions({
    this.width,
    this.height,
    this.includeBackground = true,
    this.backgroundColor,
    this.optimizeStrokes = true,
    this.decimalPrecision = 2,
    this.cropToContent = false,
    this.contentPadding = 20.0,
  });

  static const SvgExportOptions defaultOptions = SvgExportOptions();
}

/// SVG export servisi.
///
/// Canvas içeriğini SVG formatına export eder.
/// Vektörel format - sonsuz ölçeklenebilir.
abstract final class SvgExporter {
  /// Sayfayı SVG string olarak export eder.
  static String exportPage(
    CanvasPage page, {
    SvgExportOptions options = const SvgExportOptions(),
  }) {
    try {
      final precision = options.decimalPrecision;

      // Boyutları hesapla
      double exportWidth;
      double exportHeight;
      double offsetX = 0;
      double offsetY = 0;

      if (options.cropToContent && !page.isEmpty) {
        final contentBounds = page.contentBoundingBox;
        exportWidth =
            options.width ?? (contentBounds.width + options.contentPadding * 2);
        exportHeight = options.height ??
            (contentBounds.height + options.contentPadding * 2);
        offsetX = -contentBounds.left + options.contentPadding;
        offsetY = -contentBounds.top + options.contentPadding;
      } else {
        exportWidth = options.width ?? page.width;
        exportHeight = options.height ?? page.height;
      }

      final buffer = StringBuffer();

      // SVG header
      buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
      buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" '
          'width="${_format(exportWidth, precision)}" '
          'height="${_format(exportHeight, precision)}" '
          'viewBox="0 0 ${_format(exportWidth, precision)} ${_format(exportHeight, precision)}">');

      // Metadata
      buffer
          .writeln('  <title>${_escapeXml(page.title ?? 'Untitled')}</title>');
      buffer.writeln('  <desc>Created with Flutter Canvas Kit</desc>');

      // Background
      if (options.includeBackground) {
        final bgColor =
            options.backgroundColor ?? _colorToHex(page.backgroundColor);
        buffer.writeln('  <rect width="100%" height="100%" fill="$bgColor"/>');

        // Grid/pattern
        _writeBackground(buffer, page, exportWidth, exportHeight, precision);
      }

      // Content group (offset için)
      if (offsetX != 0 || offsetY != 0) {
        buffer.writeln(
            '  <g transform="translate(${_format(offsetX, precision)}, ${_format(offsetY, precision)})">');
      }

      // Layers
      for (int i = 0; i < page.layers.length; i++) {
        final layer = page.layers[i];

        if (!layer.isVisible) continue;

        buffer.writeln('  <g id="layer-$i" '
            '${layer.opacity < 1.0 ? 'opacity="${_format(layer.opacity, precision)}" ' : ''}'
            '>');

        // Strokes
        for (final stroke in layer.strokes) {
          _writeStroke(buffer, stroke, precision);
        }

        // TODO: Shape, Text, Image

        buffer.writeln('  </g>');
      }

      // Close content group
      if (offsetX != 0 || offsetY != 0) {
        buffer.writeln('  </g>');
      }

      // SVG footer
      buffer.writeln('</svg>');

      return buffer.toString();
    } catch (e) {
      throw SvgExportException(details: e.toString());
    }
  }

  /// Dökümanın tüm sayfalarını export eder.
  static List<String> exportDocument(
    CanvasDocument document, {
    SvgExportOptions options = const SvgExportOptions(),
  }) {
    return document.pages
        .map((page) => exportPage(page, options: options))
        .toList();
  }

  /// Sayfayı dosyaya kaydeder.
  static Future<void> saveToFile(
    CanvasPage page,
    String filePath, {
    SvgExportOptions options = const SvgExportOptions(),
  }) async {
    final svg = exportPage(page, options: options);
    final file = File(filePath);
    await file.writeAsString(svg);
  }

  /// Dökümanı birden fazla dosyaya kaydeder.
  static Future<List<String>> saveDocumentToFiles(
    CanvasDocument document,
    String directory,
    String baseName, {
    SvgExportOptions options = const SvgExportOptions(),
  }) async {
    final savedPaths = <String>[];

    for (int i = 0; i < document.pages.length; i++) {
      final fileName = '${baseName}_${i + 1}.svg';
      final filePath = '$directory/$fileName';

      await saveToFile(document.pages[i], filePath, options: options);
      savedPaths.add(filePath);
    }

    return savedPaths;
  }

  /// Arka plan desenini SVG olarak yazar.
  static void _writeBackground(
    StringBuffer buffer,
    CanvasPage page,
    double width,
    double height,
    int precision,
  ) {
    if (page.background == PageBackground.blank) return;

    final gridColor = _colorToHex(page.gridColor);
    final spacing = page.gridSpacing;

    // Pattern tanımı
    buffer.writeln('  <defs>');

    if (page.background == PageBackground.lined) {
      buffer.writeln('    <pattern id="lined" patternUnits="userSpaceOnUse" '
          'width="${_format(width, precision)}" height="${_format(spacing, precision)}">');
      buffer.writeln('      <line x1="0" y1="${_format(spacing, precision)}" '
          'x2="${_format(width, precision)}" y2="${_format(spacing, precision)}" '
          'stroke="$gridColor" stroke-width="1"/>');
      buffer.writeln('    </pattern>');
    } else if (page.background == PageBackground.grid) {
      buffer.writeln('    <pattern id="grid" patternUnits="userSpaceOnUse" '
          'width="${_format(spacing, precision)}" height="${_format(spacing, precision)}">');
      buffer.writeln(
          '      <path d="M ${_format(spacing, precision)} 0 L 0 0 0 ${_format(spacing, precision)}" '
          'fill="none" stroke="$gridColor" stroke-width="1"/>');
      buffer.writeln('    </pattern>');
    } else if (page.background == PageBackground.dotted) {
      buffer.writeln('    <pattern id="dotted" patternUnits="userSpaceOnUse" '
          'width="${_format(spacing, precision)}" height="${_format(spacing, precision)}">');
      buffer.writeln('      <circle cx="${_format(spacing / 2, precision)}" '
          'cy="${_format(spacing / 2, precision)}" r="1.5" fill="$gridColor"/>');
      buffer.writeln('    </pattern>');
    }

    buffer.writeln('  </defs>');

    // Pattern uygula
    if (page.background != PageBackground.blank) {
      final patternId = page.background.name;
      buffer.writeln(
          '  <rect width="100%" height="100%" fill="url(#$patternId)"/>');
    }
  }

  /// Stroke'u SVG path olarak yazar.
  static void _writeStroke(StringBuffer buffer, Stroke stroke, int precision) {
    if (stroke.points.isEmpty) return;

    final style = stroke.style;
    final color = _colorToHex(style.effectiveColor);
    final width = _format(style.width, precision);

    // Path data oluştur
    final pathData = _createPathData(stroke, precision);

    buffer.writeln('    <path '
        'd="$pathData" '
        'fill="none" '
        'stroke="$color" '
        'stroke-width="$width" '
        'stroke-linecap="round" '
        'stroke-linejoin="round"'
        '${style.opacity < 1.0 ? ' opacity="${_format(style.opacity, precision)}"' : ''}'
        '/>');
  }

  /// Stroke'dan SVG path data oluşturur.
  static String _createPathData(Stroke stroke, int precision) {
    final points = stroke.points;

    if (points.isEmpty) return '';
    if (points.length == 1) {
      // Tek nokta - küçük çizgi
      return 'M ${_format(points.first.x, precision)} '
          '${_format(points.first.y, precision)} l 0.01 0';
    }

    final buffer = StringBuffer();

    // Move to first point
    buffer.write('M ${_format(points.first.x, precision)} '
        '${_format(points.first.y, precision)}');

    if (points.length == 2) {
      // İki nokta - düz çizgi
      buffer.write(' L ${_format(points.last.x, precision)} '
          '${_format(points.last.y, precision)}');
    } else {
      // Smooth curve through points
      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final midX = (p0.x + p1.x) / 2;
        final midY = (p0.y + p1.y) / 2;

        buffer
            .write(' Q ${_format(p0.x, precision)} ${_format(p0.y, precision)} '
                '${_format(midX, precision)} ${_format(midY, precision)}');
      }

      // Son noktaya
      buffer.write(' L ${_format(points.last.x, precision)} '
          '${_format(points.last.y, precision)}');
    }

    return buffer.toString();
  }

  /// Color'ı hex string'e çevirir.
  static String _colorToHex(Color color) {
    final argb = color.toARGB32();
    final r = (argb >> 16) & 0xFF;
    final g = (argb >> 8) & 0xFF;
    final b = argb & 0xFF;
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// Double'ı formatlar.
  static String _format(double value, int precision) {
    return value.toStringAsFixed(precision);
  }

  /// XML özel karakterlerini escape eder.
  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
