import 'tool_type.dart';

/// Çizgi (stroke) tipleri.
///
/// Her tip için perfect_freehand kütüphanesi parametreleri tanımlı.
enum StrokeType {
  /// Standart kalem çizgisi.
  ///
  /// Yumuşak, basınç duyarlı.
  pen(
    displayName: 'Pen',
    thinning: 0.5,
    smoothing: 0.5,
    streamline: 0.5,
    usesPressure: true,
  ),

  /// Fosforlu kalem çizgisi.
  ///
  /// Sabit kalınlık, yarı saydam, multiply blend.
  highlighter(
    displayName: 'Highlighter',
    thinning: 0.0, // Basınç etkisi yok
    smoothing: 0.5,
    streamline: 0.5,
    usesPressure: false,
  ),

  /// Kurşun kalem çizgisi.
  ///
  /// Yüksek basınç hassasiyeti, daha az yumuşatma.
  pencil(
    displayName: 'Pencil',
    thinning: 0.7, // Daha fazla basınç etkisi
    smoothing: 0.3, // Daha az yumuşatma
    streamline: 0.3,
    usesPressure: true,
  );

  const StrokeType({
    required this.displayName,
    required this.thinning,
    required this.smoothing,
    required this.streamline,
    required this.usesPressure,
  });

  /// Kullanıcıya gösterilecek isim.
  final String displayName;

  /// İncelme miktarı (0.0 - 1.0).
  ///
  /// Basınç azaldıkça çizgi ne kadar incelir.
  /// 0 = sabit kalınlık, 1 = maksimum incelme.
  final double thinning;

  /// Yumuşatma miktarı (0.0 - 1.0).
  ///
  /// Çizginin ne kadar yumuşak/düzgün olacağı.
  final double smoothing;

  /// Akış düzeltme (0.0 - 1.0).
  ///
  /// Hızlı hareketlerde gecikme/düzeltme miktarı.
  final double streamline;

  /// Basınç verisi kullanılıyor mu?
  final bool usesPressure;

  /// ToolType'dan StrokeType'a dönüşüm.
  static StrokeType? fromToolType(ToolType tool) {
    return switch (tool) {
      ToolType.pen => StrokeType.pen,
      ToolType.highlighter => StrokeType.highlighter,
      ToolType.pencil => StrokeType.pencil,
      _ => null,
    };
  }
}
