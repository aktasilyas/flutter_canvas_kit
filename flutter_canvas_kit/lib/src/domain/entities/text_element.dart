import 'dart:ui';

/// Metin hizalama.
enum TextAlignment {
  left,
  center,
  right,
}

/// Canvas üzerindeki metin elemanı.
///
/// Immutable entity.
final class TextElement {
  /// Benzersiz kimlik.
  final String id;

  /// Metin içeriği.
  final String text;

  /// Konum (sol üst köşe).
  final Offset position;

  /// Metin rengi.
  final Color color;

  /// Font boyutu.
  final double fontSize;

  /// Font ailesi.
  final String fontFamily;

  /// Kalın mı?
  final bool isBold;

  /// İtalik mi?
  final bool isItalic;

  /// Altı çizili mi?
  final bool isUnderline;

  /// Metin hizalama.
  final TextAlignment alignment;

  /// Döndürme açısı (radyan).
  final double rotation;

  /// Maksimum genişlik (null = sınırsız).
  final double? maxWidth;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  const TextElement({
    required this.id,
    required this.text,
    required this.position,
    this.color = const Color(0xFF000000),
    this.fontSize = 16.0,
    this.fontFamily = 'Roboto',
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.alignment = TextAlignment.left,
    this.rotation = 0,
    this.maxWidth,
    required this.createdAt,
  });

  /// Yeni text element oluşturur.
  factory TextElement.create({
    required String text,
    required Offset position,
    Color color = const Color(0xFF000000),
    double fontSize = 16.0,
    String fontFamily = 'Roboto',
    bool isBold = false,
    bool isItalic = false,
    bool isUnderline = false,
    TextAlignment alignment = TextAlignment.left,
    double rotation = 0,
    double? maxWidth,
  }) {
    return TextElement(
      id: _generateId(),
      text: text,
      position: position,
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
      isBold: isBold,
      isItalic: isItalic,
      isUnderline: isUnderline,
      alignment: alignment,
      rotation: rotation,
      maxWidth: maxWidth,
      createdAt: DateTime.now(),
    );
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  /// Tahmini sınırlayıcı kutu.
  Rect get boundingBox {
    final charWidth = fontSize * 0.6;
    final estimatedWidth = maxWidth ?? (text.length * charWidth);
    final lineCount =
        maxWidth != null ? (text.length * charWidth / maxWidth!).ceil() : 1;
    final height = fontSize * 1.2 * lineCount;

    return Rect.fromLTWH(position.dx, position.dy, estimatedWidth, height);
  }

  /// Hit test.
  bool hitTest(Offset point, {double tolerance = 5.0}) {
    return boundingBox.inflate(tolerance).contains(point);
  }

  /// Taşır.
  TextElement translate(double dx, double dy) {
    return copyWith(position: position.translate(dx, dy));
  }

  TextElement copyWith({
    String? id,
    String? text,
    Offset? position,
    Color? color,
    double? fontSize,
    String? fontFamily,
    bool? isBold,
    bool? isItalic,
    bool? isUnderline,
    TextAlignment? alignment,
    double? rotation,
    double? maxWidth,
    DateTime? createdAt,
  }) {
    return TextElement(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      alignment: alignment ?? this.alignment,
      rotation: rotation ?? this.rotation,
      maxWidth: maxWidth ?? this.maxWidth,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'position': {'x': position.dx, 'y': position.dy},
      'color': color.toARGB32(),
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'isBold': isBold,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'alignment': alignment.name,
      'rotation': rotation,
      if (maxWidth != null) 'maxWidth': maxWidth,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TextElement.fromJson(Map<String, dynamic> json) {
    return TextElement(
      id: json['id'] as String,
      text: json['text'] as String,
      position: Offset(
        (json['position']['x'] as num).toDouble(),
        (json['position']['y'] as num).toDouble(),
      ),
      color: Color(json['color'] as int),
      fontSize: (json['fontSize'] as num).toDouble(),
      fontFamily: json['fontFamily'] as String? ?? 'Roboto',
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      alignment: TextAlignment.values.firstWhere(
        (a) => a.name == json['alignment'],
        orElse: () => TextAlignment.left,
      ),
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      maxWidth: (json['maxWidth'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TextElement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TextElement(id: $id, text: "${text.length > 20 ? '${text.substring(0, 20)}...' : text}")';
}
