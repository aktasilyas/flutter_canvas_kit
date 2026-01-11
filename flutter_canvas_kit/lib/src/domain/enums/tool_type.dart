/// Canvas araç tipleri.
enum ToolType {
  /// Standart kalem.
  pen(
    displayName: 'Pen',
    supportsColor: true,
    supportsWidth: true,
    supportsOpacity: true,
  ),

  /// Fosforlu kalem (yarı saydam).
  highlighter(
    displayName: 'Highlighter',
    supportsColor: true,
    supportsWidth: true,
    supportsOpacity: false, // Sabit opaklık
  ),

  /// Kurşun kalem (doku efektli).
  pencil(
    displayName: 'Pencil',
    supportsColor: true,
    supportsWidth: true,
    supportsOpacity: true,
  ),

  /// Neon (glow) pen.
  neon(
    displayName: 'Neon',
    supportsColor: true,
    supportsWidth: true,
    supportsOpacity: true,
  ),

  /// Dashed line pen.
  dashed(
    displayName: 'Dashed',
    supportsColor: true,
    supportsWidth: true,
    supportsOpacity: false,
  ),

  /// Silgi.
  eraser(
    displayName: 'Eraser',
    supportsColor: false,
    supportsWidth: true,
    supportsOpacity: false,
  ),

  /// Geometrik şekil aracı.
  shape(
    displayName: 'Shape',
    supportsColor: true,
    supportsWidth: true,
    supportsOpacity: true,
  ),

  /// Metin aracı.
  text(
    displayName: 'Text',
    supportsColor: true,
    supportsWidth: false,
    supportsOpacity: true,
  ),

  /// Resim ekleme aracı.
  image(
    displayName: 'Image',
    supportsColor: false,
    supportsWidth: false,
    supportsOpacity: true,
  ),

  /// Seçim aracı (dikdörtgen).
  selection(
    displayName: 'Selection',
    supportsColor: false,
    supportsWidth: false,
    supportsOpacity: false,
  ),

  /// Kement seçim aracı (serbest çizim).
  lasso(
    displayName: 'Lasso',
    supportsColor: false,
    supportsWidth: false,
    supportsOpacity: false,
  ),

  /// El aracı (pan).
  hand(
    displayName: 'Hand',
    supportsColor: false,
    supportsWidth: false,
    supportsOpacity: false,
  );

  const ToolType({
    required this.displayName,
    required this.supportsColor,
    required this.supportsWidth,
    required this.supportsOpacity,
  });

  /// Kullanıcıya gösterilecek isim.
  final String displayName;

  /// Renk ayarı destekliyor mu?
  final bool supportsColor;

  /// Kalınlık ayarı destekliyor mu?
  final bool supportsWidth;

  /// Opaklık ayarı destekliyor mu?
  final bool supportsOpacity;

  /// Çizim aracı mı? (stroke oluşturur)
  bool get isDrawingTool {
    return this == pen ||
        this == highlighter ||
        this == pencil ||
        this == neon ||
        this == dashed;
  }

  /// Seçim aracı mı?
  bool get isSelectionTool {
    return this == selection || this == lasso;
  }

  /// İçerik ekleme aracı mı?
  bool get isContentTool {
    return this == text || this == image;
  }

  /// Navigasyon aracı mı?
  bool get isNavigationTool {
    return this == hand;
  }
}
