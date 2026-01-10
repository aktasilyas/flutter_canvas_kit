import 'dart:ui' as ui;

/// Karıştırma modu kategorileri.
enum BlendCategory {
  /// Normal mod.
  normal,

  /// Karartma modları.
  darken,

  /// Aydınlatma modları.
  lighten,

  /// Kontrast modları.
  contrast,

  /// Inversiyon modları.
  inversion,
}

/// Katman karıştırma modları.
///
/// Flutter'ın [ui.BlendMode] ile uyumlu.
enum LayerBlendMode {
  /// Normal (varsayılan).
  normal(
    displayName: 'Normal',
    category: BlendCategory.normal,
    flutterMode: ui.BlendMode.srcOver,
  ),

  /// Çarpma (karartır).
  multiply(
    displayName: 'Multiply',
    category: BlendCategory.darken,
    flutterMode: ui.BlendMode.multiply,
  ),

  /// Karartma (daha koyu olanı al).
  darken(
    displayName: 'Darken',
    category: BlendCategory.darken,
    flutterMode: ui.BlendMode.darken,
  ),

  /// Renk yakma.
  colorBurn(
    displayName: 'Color Burn',
    category: BlendCategory.darken,
    flutterMode: ui.BlendMode.colorBurn,
  ),

  /// Ekran (aydınlatır).
  screen(
    displayName: 'Screen',
    category: BlendCategory.lighten,
    flutterMode: ui.BlendMode.screen,
  ),

  /// Aydınlatma (daha açık olanı al).
  lighten(
    displayName: 'Lighten',
    category: BlendCategory.lighten,
    flutterMode: ui.BlendMode.lighten,
  ),

  /// Renk soldurma.
  colorDodge(
    displayName: 'Color Dodge',
    category: BlendCategory.lighten,
    flutterMode: ui.BlendMode.colorDodge,
  ),

  /// Bindirme.
  overlay(
    displayName: 'Overlay',
    category: BlendCategory.contrast,
    flutterMode: ui.BlendMode.overlay,
  ),

  /// Yumuşak ışık.
  softLight(
    displayName: 'Soft Light',
    category: BlendCategory.contrast,
    flutterMode: ui.BlendMode.softLight,
  ),

  /// Sert ışık.
  hardLight(
    displayName: 'Hard Light',
    category: BlendCategory.contrast,
    flutterMode: ui.BlendMode.hardLight,
  ),

  /// Fark.
  difference(
    displayName: 'Difference',
    category: BlendCategory.inversion,
    flutterMode: ui.BlendMode.difference,
  ),

  /// Dışlama.
  exclusion(
    displayName: 'Exclusion',
    category: BlendCategory.inversion,
    flutterMode: ui.BlendMode.exclusion,
  );

  const LayerBlendMode({
    required this.displayName,
    required this.category,
    required this.flutterMode,
  });

  /// Kullanıcıya gösterilecek isim.
  final String displayName;

  /// Kategori.
  final BlendCategory category;

  /// Flutter BlendMode karşılığı.
  final ui.BlendMode flutterMode;

  /// Flutter BlendMode'a dönüştür.
  ui.BlendMode toFlutterBlendMode() => flutterMode;

  /// Flutter BlendMode'dan LayerBlendMode'a dönüştür.
  static LayerBlendMode fromFlutterBlendMode(ui.BlendMode mode) {
    for (final blendMode in LayerBlendMode.values) {
      if (blendMode.flutterMode == mode) {
        return blendMode;
      }
    }
    return LayerBlendMode.normal;
  }
}
