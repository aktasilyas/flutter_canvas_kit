import 'dart:ui';

/// Canvas için sabit değerler.
abstract final class CanvasConstants {
  // -------------------------------------------------------------------------
  // Çizgi Ayarları
  // -------------------------------------------------------------------------

  /// Minimum çizgi kalınlığı.
  static const double minStrokeWidth = 0.5;

  /// Maksimum çizgi kalınlığı.
  static const double maxStrokeWidth = 50.0;

  /// Varsayılan çizgi kalınlığı.
  static const double defaultStrokeWidth = 2.0;

  /// Varsayılan çizgi rengi.
  static const Color defaultStrokeColor = Color(0xFF000000);

  /// Fosforlu kalem opaklığı.
  static const double highlighterOpacity = 0.4;

  // -------------------------------------------------------------------------
  // Zoom Ayarları
  // -------------------------------------------------------------------------

  /// Minimum zoom seviyesi.
  static const double minZoom = 0.1;

  /// Maksimum zoom seviyesi.
  static const double maxZoom = 10.0;

  /// Varsayılan zoom seviyesi.
  static const double defaultZoom = 1.0;

  /// Zoom adımı (her zoom işleminde çarpan).
  static const double zoomStep = 1.25;

  // -------------------------------------------------------------------------
  // Geçmiş (Undo/Redo)
  // -------------------------------------------------------------------------

  /// Maksimum undo adım sayısı.
  static const int maxUndoSteps = 100;

  // -------------------------------------------------------------------------
  // Katman Ayarları
  // -------------------------------------------------------------------------

  /// Maksimum katman sayısı.
  static const int maxLayers = 50;

  /// Varsayılan katman opaklığı.
  static const double defaultLayerOpacity = 1.0;

  // -------------------------------------------------------------------------
  // Performans Ayarları
  // -------------------------------------------------------------------------

  /// Tile boyutu (piksel).
  static const int tileSize = 256;

  /// Maksimum cache'lenecek tile sayısı.
  static const int maxCachedTiles = 100;

  /// LOD düşük detay eşiği.
  static const double lodThresholdLow = 0.25;

  /// LOD orta detay eşiği.
  static const double lodThresholdMedium = 0.5;

  // -------------------------------------------------------------------------
  // Grid/Arka Plan
  // -------------------------------------------------------------------------

  /// Varsayılan grid aralığı.
  static const double defaultGridSpacing = 25.0;

  /// Grid çizgi rengi.
  static const Color gridLineColor = Color(0xFFE0E0E0);

  // -------------------------------------------------------------------------
  // Animasyon
  // -------------------------------------------------------------------------

  /// Varsayılan animasyon süresi.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 200);

  // -------------------------------------------------------------------------
  // Hit Testing
  // -------------------------------------------------------------------------

  /// Varsayılan dokunma toleransı (piksel).
  static const double defaultHitTolerance = 10.0;
}
