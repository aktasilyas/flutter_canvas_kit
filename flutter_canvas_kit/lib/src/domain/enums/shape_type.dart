/// Şekil kategorileri.
enum ShapeCategory {
  /// Çizgi bazlı (line, arrow).
  line,

  /// Dikdörtgen bazlı.
  rectangle,

  /// Elips bazlı.
  ellipse,

  /// Çokgen bazlı.
  polygon,

  /// Serbest form.
  freeform,
}

/// Geometrik şekil tipleri.
enum ShapeType {
  /// Düz çizgi.
  line(
    displayName: 'Line',
    category: ShapeCategory.line,
    canBeFilled: false,
    hasCornerRadius: false,
    defaultPointCount: 2,
  ),

  /// Ok (tek yönlü).
  arrow(
    displayName: 'Arrow',
    category: ShapeCategory.line,
    canBeFilled: false,
    hasCornerRadius: false,
    defaultPointCount: 2,
  ),

  /// Çift yönlü ok.
  doubleArrow(
    displayName: 'Double Arrow',
    category: ShapeCategory.line,
    canBeFilled: false,
    hasCornerRadius: false,
    defaultPointCount: 2,
  ),

  /// Dikdörtgen.
  rectangle(
    displayName: 'Rectangle',
    category: ShapeCategory.rectangle,
    canBeFilled: true,
    hasCornerRadius: true,
    defaultPointCount: 4,
  ),

  /// Yuvarlatılmış dikdörtgen.
  roundedRectangle(
    displayName: 'Rounded Rectangle',
    category: ShapeCategory.rectangle,
    canBeFilled: true,
    hasCornerRadius: true,
    defaultPointCount: 4,
  ),

  /// Kare.
  square(
    displayName: 'Square',
    category: ShapeCategory.rectangle,
    canBeFilled: true,
    hasCornerRadius: true,
    defaultPointCount: 4,
  ),

  /// Elips.
  ellipse(
    displayName: 'Ellipse',
    category: ShapeCategory.ellipse,
    canBeFilled: true,
    hasCornerRadius: false,
    defaultPointCount: 0,
  ),

  /// Daire.
  circle(
    displayName: 'Circle',
    category: ShapeCategory.ellipse,
    canBeFilled: true,
    hasCornerRadius: false,
    defaultPointCount: 0,
  ),

  /// Üçgen.
  triangle(
    displayName: 'Triangle',
    category: ShapeCategory.polygon,
    canBeFilled: true,
    hasCornerRadius: false,
    defaultPointCount: 3,
  ),

  /// Yıldız.
  star(
    displayName: 'Star',
    category: ShapeCategory.polygon,
    canBeFilled: true,
    hasCornerRadius: false,
    defaultPointCount: 5,
  ),

  /// Çokgen.
  polygon(
    displayName: 'Polygon',
    category: ShapeCategory.polygon,
    canBeFilled: true,
    hasCornerRadius: false,
    defaultPointCount: 6,
  ),

  /// Serbest çokgen.
  freeformPolygon(
    displayName: 'Freeform',
    category: ShapeCategory.freeform,
    canBeFilled: true,
    hasCornerRadius: false,
    defaultPointCount: 0,
  );

  const ShapeType({
    required this.displayName,
    required this.category,
    required this.canBeFilled,
    required this.hasCornerRadius,
    required this.defaultPointCount,
  });

  /// Kullanıcıya gösterilecek isim.
  final String displayName;

  /// Şekil kategorisi.
  final ShapeCategory category;

  /// Dolgu destekliyor mu?
  final bool canBeFilled;

  /// Köşe yarıçapı ayarı var mı?
  final bool hasCornerRadius;

  /// Varsayılan köşe/nokta sayısı.
  final int defaultPointCount;

  /// Minimum köşe sayısı (polygon için).
  int get minPointCount {
    return switch (category) {
      ShapeCategory.polygon => 3,
      ShapeCategory.freeform => 3,
      _ => defaultPointCount,
    };
  }

  /// Maksimum köşe sayısı (polygon için).
  int get maxPointCount {
    return switch (category) {
      ShapeCategory.polygon => 12,
      ShapeCategory.freeform => 100,
      _ => defaultPointCount,
    };
  }

  /// Çizgi bazlı şekil mi?
  bool get isLineBased => category == ShapeCategory.line;

  /// Kapalı şekil mi?
  bool get isClosed => category != ShapeCategory.line;
}
