/// Canvas işlemlerinde oluşabilecek hataların base class'ı.
sealed class CanvasException implements Exception {
  /// Hata mesajı.
  final String message;

  /// Ek detaylar.
  final String? details;

  const CanvasException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    if (details != null) {
      return '$runtimeType: $message\nDetails: $details';
    }
    return '$runtimeType: $message';
  }
}

// ---------------------------------------------------------------------------
// Katman Hataları
// ---------------------------------------------------------------------------

/// Katman bulunamadı hatası.
final class LayerNotFoundException extends CanvasException {
  final String layerId;

  LayerNotFoundException({required this.layerId})
      : super(message: 'Layer not found: $layerId');
}

/// Maksimum katman sayısı aşıldı hatası.
final class MaxLayersExceededException extends CanvasException {
  final int maxLayers;

  MaxLayersExceededException({required this.maxLayers})
      : super(message: 'Maximum layer count exceeded: $maxLayers');
}

/// Katman kilitli hatası.
final class LayerLockedException extends CanvasException {
  final String layerId;

  LayerLockedException({required this.layerId})
      : super(message: 'Layer is locked: $layerId');
}

// ---------------------------------------------------------------------------
// Sayfa Hataları
// ---------------------------------------------------------------------------

/// Sayfa bulunamadı hatası.
final class PageNotFoundException extends CanvasException {
  final int pageIndex;

  PageNotFoundException({required this.pageIndex})
      : super(message: 'Page not found at index: $pageIndex');
}

// ---------------------------------------------------------------------------
// Serialization Hataları
// ---------------------------------------------------------------------------

/// Geçersiz JSON hatası.
final class InvalidJsonException extends CanvasException {
  InvalidJsonException({String? details})
      : super(
          message: 'Invalid JSON format',
          details: details,
        );
}

/// Uyumsuz versiyon hatası.
final class IncompatibleVersionException extends CanvasException {
  final int documentVersion;
  final int supportedVersion;

  IncompatibleVersionException({
    required this.documentVersion,
    required this.supportedVersion,
  }) : super(
          message: 'Document version $documentVersion is not supported. '
              'Max supported version: $supportedVersion',
        );
}

// ---------------------------------------------------------------------------
// Export Hataları
// ---------------------------------------------------------------------------

/// Resim export hatası.
final class ImageExportException extends CanvasException {
  final String format;

  ImageExportException({
    required this.format,
    String? details,
  }) : super(
          message: 'Failed to export image as $format',
          details: details,
        );
}

/// SVG export hatası.
final class SvgExportException extends CanvasException {
  SvgExportException({String? details})
      : super(
          message: 'Failed to export SVG',
          details: details,
        );
}

// ---------------------------------------------------------------------------
// Genel Hatalar
// ---------------------------------------------------------------------------

/// Kaynak bulunamadı hatası.
final class ResourceNotFoundException extends CanvasException {
  final String resourceType;
  final String resourceId;

  ResourceNotFoundException({
    required this.resourceType,
    required this.resourceId,
  }) : super(message: '$resourceType not found: $resourceId');
}

/// Geçersiz işlem hatası.
final class InvalidOperationException extends CanvasException {
  InvalidOperationException({
    required String message,
    String? details,
  }) : super(message: message, details: details);
}
