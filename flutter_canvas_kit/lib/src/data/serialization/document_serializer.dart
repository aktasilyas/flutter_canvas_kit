import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_canvas_kit/src/core/errors/canvas_exception.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_document.dart';

/// Döküman serializasyon servisi.
///
/// JSON formatında kaydetme ve yükleme.
abstract final class DocumentSerializer {
  /// Döküman format versiyonu.
  static const int formatVersion = 1;

  /// Dosya uzantısı.
  static const String fileExtension = '.fck';

  /// MIME tipi.
  static const String mimeType = 'application/x-flutter-canvas-kit';

  // ---------------------------------------------------------------------------
  // JSON String
  // ---------------------------------------------------------------------------

  /// Dökümanı JSON string'e dönüştürür.
  static String toJsonString(CanvasDocument document, {bool pretty = false}) {
    final json = document.toJson();

    if (pretty) {
      return const JsonEncoder.withIndent('  ').convert(json);
    }
    return jsonEncode(json);
  }

  /// JSON string'den döküman oluşturur.
  static CanvasDocument fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      throw InvalidJsonException(details: 'Failed to parse JSON: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // JSON Map
  // ---------------------------------------------------------------------------

  /// Dökümanı JSON map'e dönüştürür.
  static Map<String, dynamic> toJson(CanvasDocument document) {
    return document.toJson();
  }

  /// JSON map'ten döküman oluşturur.
  static CanvasDocument fromJson(Map<String, dynamic> json) {
    // Versiyon kontrolü
    final version = json['version'] as int? ?? 1;

    if (version > formatVersion) {
      throw IncompatibleVersionException(
        documentVersion: version,
        supportedVersion: formatVersion,
      );
    }

    // Eski versiyonları migrate et
    final migratedJson = _migrateIfNeeded(json, version);

    return CanvasDocument.fromJson(migratedJson);
  }

  /// Eski versiyonları yeni formata migrate eder.
  static Map<String, dynamic> _migrateIfNeeded(
    Map<String, dynamic> json,
    int fromVersion,
  ) {
    var result = Map<String, dynamic>.from(json);

    // Version 1 → 2 migration (gelecek için örnek)
    // if (fromVersion < 2) {
    //   result = _migrateV1ToV2(result);
    // }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Bytes
  // ---------------------------------------------------------------------------

  /// Dökümanı byte array'e dönüştürür.
  static Uint8List toBytes(CanvasDocument document) {
    final jsonString = toJsonString(document);
    return Uint8List.fromList(utf8.encode(jsonString));
  }

  /// Byte array'den döküman oluşturur.
  static CanvasDocument fromBytes(Uint8List bytes) {
    final jsonString = utf8.decode(bytes);
    return fromJsonString(jsonString);
  }

  // ---------------------------------------------------------------------------
  // Compressed Bytes
  // ---------------------------------------------------------------------------

  /// Dökümanı sıkıştırılmış byte array'e dönüştürür.
  static Uint8List toCompressedBytes(CanvasDocument document) {
    final bytes = toBytes(document);
    return Uint8List.fromList(gzip.encode(bytes));
  }

  /// Sıkıştırılmış byte array'den döküman oluşturur.
  static CanvasDocument fromCompressedBytes(Uint8List compressedBytes) {
    final bytes = Uint8List.fromList(gzip.decode(compressedBytes));
    return fromBytes(bytes);
  }

  // ---------------------------------------------------------------------------
  // File I/O
  // ---------------------------------------------------------------------------

  /// Dökümanı dosyaya kaydeder.
  static Future<void> saveToFile(
    CanvasDocument document,
    String filePath,
  ) async {
    final file = File(filePath);
    final jsonString = toJsonString(document, pretty: true);
    await file.writeAsString(jsonString);
  }

  /// Dosyadan döküman yükler.
  static Future<CanvasDocument> loadFromFile(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw ResourceNotFoundException(
        resourceType: 'File',
        resourceId: filePath,
      );
    }

    final jsonString = await file.readAsString();
    return fromJsonString(jsonString);
  }

  /// Dökümanı sıkıştırılmış dosyaya kaydeder.
  static Future<void> saveToCompressedFile(
    CanvasDocument document,
    String filePath,
  ) async {
    final file = File(filePath);
    final bytes = toCompressedBytes(document);
    await file.writeAsBytes(bytes);
  }

  /// Sıkıştırılmış dosyadan döküman yükler.
  static Future<CanvasDocument> loadFromCompressedFile(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw ResourceNotFoundException(
        resourceType: 'File',
        resourceId: filePath,
      );
    }

    final bytes = await file.readAsBytes();
    return fromCompressedBytes(bytes);
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  /// JSON'ın geçerli bir döküman olup olmadığını kontrol eder.
  static bool isValidJson(Map<String, dynamic> json) {
    try {
      // Gerekli alanlar
      if (!json.containsKey('id')) return false;
      if (!json.containsKey('title')) return false;
      if (!json.containsKey('pages')) return false;
      if (json['pages'] is! List) return false;
      if ((json['pages'] as List).isEmpty) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  /// JSON string'in geçerli olup olmadığını kontrol eder.
  static bool isValidJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return isValidJson(json);
    } catch (_) {
      return false;
    }
  }

  /// Dosyanın geçerli bir döküman dosyası olup olmadığını kontrol eder.
  static Future<bool> isValidFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final content = await file.readAsString();
      return isValidJsonString(content);
    } catch (_) {
      return false;
    }
  }
}
