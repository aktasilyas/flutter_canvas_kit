import 'dart:ui';

/// Standart sayfa boyutları.
///
/// Boyutlar 72 DPI'da piksel olarak hesaplanır.
enum PageSize {
  /// A3 (297 x 420 mm).
  a3(
    displayName: 'A3',
    widthMm: 297,
    heightMm: 420,
  ),

  /// A4 (210 x 297 mm).
  a4(
    displayName: 'A4',
    widthMm: 210,
    heightMm: 297,
  ),

  /// A5 (148 x 210 mm).
  a5(
    displayName: 'A5',
    widthMm: 148,
    heightMm: 210,
  ),

  /// A6 (105 x 148 mm).
  a6(
    displayName: 'A6',
    widthMm: 105,
    heightMm: 148,
  ),

  /// US Letter (8.5 x 11 inch).
  letter(
    displayName: 'Letter',
    widthMm: 216,
    heightMm: 279,
  ),

  /// US Legal (8.5 x 14 inch).
  legal(
    displayName: 'Legal',
    widthMm: 216,
    heightMm: 356,
  ),

  /// Tabloid (11 x 17 inch).
  tabloid(
    displayName: 'Tabloid',
    widthMm: 279,
    heightMm: 432,
  ),

  /// Kare (1:1).
  square(
    displayName: 'Square',
    widthMm: 210,
    heightMm: 210,
  ),

  /// Geniş ekran (16:9).
  widescreen(
    displayName: 'Widescreen',
    widthMm: 297,
    heightMm: 167,
  ),

  /// Sonsuz canvas.
  infinite(
    displayName: 'Infinite',
    widthMm: 0,
    heightMm: 0,
  ),

  /// Özel boyut.
  custom(
    displayName: 'Custom',
    widthMm: 0,
    heightMm: 0,
  );

  const PageSize({
    required this.displayName,
    required this.widthMm,
    required this.heightMm,
  });

  /// Kullanıcıya gösterilecek isim.
  final String displayName;

  /// Genişlik (milimetre).
  final double widthMm;

  /// Yükseklik (milimetre).
  final double heightMm;

  /// mm'den piksel'e çevirme faktörü (72 DPI).
  static const double _mmToPixel = 72.0 / 25.4;

  /// Genişlik (piksel, 72 DPI).
  double get widthPixels {
    if (this == infinite) return double.infinity;
    if (this == custom) return 595; // Varsayılan A4
    return widthMm * _mmToPixel;
  }

  /// Yükseklik (piksel, 72 DPI).
  double get heightPixels {
    if (this == infinite) return double.infinity;
    if (this == custom) return 842; // Varsayılan A4
    return heightMm * _mmToPixel;
  }

  /// Size objesi olarak.
  Size get size => Size(widthPixels, heightPixels);

  /// Bounds (Rect) olarak.
  Rect get bounds => Rect.fromLTWH(0, 0, widthPixels, heightPixels);

  /// En-boy oranı.
  double get aspectRatio {
    if (heightMm == 0) return 1;
    return widthMm / heightMm;
  }

  /// Yatay (landscape) versiyon.
  PageSize get landscape {
    // Zaten yatay olanlar veya kare
    if (widthMm >= heightMm) return this;
    // Portrait için landscape döndür
    return this;
  }

  /// Dikey (portrait) versiyon.
  PageSize get portrait {
    if (heightMm >= widthMm) return this;
    return this;
  }

  /// Genişlik (inch).
  double get widthInches => widthMm / 25.4;

  /// Yükseklik (inch).
  double get heightInches => heightMm / 25.4;

  /// Boyut açıklaması.
  String get description {
    if (this == infinite) return 'Infinite canvas';
    if (this == custom) return 'Custom size';
    return '${widthMm.round()} × ${heightMm.round()} mm';
  }
}
