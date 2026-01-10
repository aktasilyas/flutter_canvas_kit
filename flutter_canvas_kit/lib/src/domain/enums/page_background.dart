/// Sayfa arka plan desenleri.
enum PageBackground {
  /// Boş (düz renk).
  blank(
    displayName: 'Blank',
    hasLines: false,
    hasVerticalLines: false,
    hasDots: false,
    defaultSpacing: 0,
  ),

  /// Yatay çizgili (defter).
  lined(
    displayName: 'Lined',
    hasLines: true,
    hasVerticalLines: false,
    hasDots: false,
    defaultSpacing: 25,
  ),

  /// Kareli (grid).
  grid(
    displayName: 'Grid',
    hasLines: true,
    hasVerticalLines: true,
    hasDots: false,
    defaultSpacing: 25,
  ),

  /// Noktalı.
  dotted(
    displayName: 'Dotted',
    hasLines: false,
    hasVerticalLines: false,
    hasDots: true,
    defaultSpacing: 25,
  ),

  /// İzometrik grid.
  isometric(
    displayName: 'Isometric',
    hasLines: true,
    hasVerticalLines: true,
    hasDots: false,
    defaultSpacing: 25,
  ),

  /// Müzik notası çizgisi.
  music(
    displayName: 'Music',
    hasLines: true,
    hasVerticalLines: false,
    hasDots: false,
    defaultSpacing: 8,
  ),

  /// Cornell not alma formatı.
  cornell(
    displayName: 'Cornell',
    hasLines: true,
    hasVerticalLines: true,
    hasDots: false,
    defaultSpacing: 25,
  ),

  /// Özel (kullanıcı tanımlı resim).
  custom(
    displayName: 'Custom',
    hasLines: false,
    hasVerticalLines: false,
    hasDots: false,
    defaultSpacing: 0,
  );

  const PageBackground({
    required this.displayName,
    required this.hasLines,
    required this.hasVerticalLines,
    required this.hasDots,
    required this.defaultSpacing,
  });

  /// Kullanıcıya gösterilecek isim.
  final String displayName;

  /// Yatay çizgi var mı?
  final bool hasLines;

  /// Dikey çizgi var mı?
  final bool hasVerticalLines;

  /// Nokta var mı?
  final bool hasDots;

  /// Varsayılan çizgi/nokta aralığı.
  final double defaultSpacing;

  /// Özel render gerekiyor mu?
  bool get requiresCustomRendering {
    return this == isometric ||
        this == music ||
        this == cornell ||
        this == custom;
  }

  /// Basit desen mi? (performans optimizasyonu için)
  bool get isSimplePattern {
    return this == blank || this == lined || this == grid || this == dotted;
  }
}
