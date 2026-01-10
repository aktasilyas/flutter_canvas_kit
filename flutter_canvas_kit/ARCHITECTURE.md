# 🏗️ Flutter Canvas Kit - Mimari Dökümanı

## Neden Clean Architecture?

Bu paket, **Clean Architecture** prensiplerine göre tasarlandı. Amaçlarımız:

1. **Test Edilebilirlik**: Her katman bağımsız test edilebilir
2. **Bakım Kolaylığı**: Değişiklikler izole, yan etkiler minimum
3. **Esneklik**: İç implementasyon değişse bile dış API sabit kalır
4. **Anlaşılabilirlik**: Yeni geliştiriciler kodu hızlıca anlayabilir

---

## 📁 Klasör Yapısı

```
flutter_canvas_kit/
│
├── lib/
│   ├── flutter_canvas_kit.dart      # 📤 Public API (tek giriş noktası)
│   │
│   └── src/                          # 🔒 Internal (private) kod
│       │
│       ├── core/                     # 🧱 Çekirdek - Her yerde kullanılan
│       │   ├── constants/            #    Sabit değerler
│       │   ├── errors/               #    Hata sınıfları
│       │   ├── extensions/           #    Dart extension'ları
│       │   ├── typedefs/             #    Type tanımlamaları
│       │   └── utils/                #    Yardımcı fonksiyonlar
│       │
│       ├── domain/                   # 💎 İş Mantığı - Framework bağımsız
│       │   ├── entities/             #    Veri modelleri (Stroke, Layer, Page)
│       │   ├── enums/                #    Enum tanımlamaları
│       │   ├── repositories/         #    Repository arayüzleri (abstract)
│       │   └── value_objects/        #    Değer nesneleri (Color, Point)
│       │
│       ├── data/                     # 💾 Veri Katmanı - Veri işlemleri
│       │   ├── repositories/         #    Repository implementasyonları
│       │   ├── serialization/        #    JSON/Binary dönüşümler
│       │   └── export/               #    PNG, SVG, PDF export
│       │
│       └── presentation/             # 🎨 Sunum Katmanı - Flutter UI
│           ├── canvas/               #    Ana canvas widget'ları
│           ├── controllers/          #    State yönetimi
│           ├── painters/             #    CustomPainter sınıfları
│           ├── tools/                #    Çizim araçları
│           ├── widgets/              #    UI widget'ları (toolbar, panels)
│           └── themes/               #    Tema ve stil
│
├── example/                          # 📱 Örnek uygulama
│   └── lib/
│       └── main.dart
│
├── test/                             # 🧪 Testler
│   ├── unit/                         #    Unit testler
│   ├── widget/                       #    Widget testler
│   └── integration/                  #    Entegrasyon testler
│
├── ARCHITECTURE.md                   # 📖 Bu dosya
├── CHANGELOG.md                      # 📝 Değişiklik geçmişi
├── README.md                         # 📚 Kullanım kılavuzu
├── LICENSE                           # ⚖️ MIT Lisansı
├── pubspec.yaml                      # 📦 Paket tanımı
└── analysis_options.yaml             # 🔍 Lint kuralları
```

---

## 🧅 Katman Açıklamaları

### 1. Core (Çekirdek) 🧱

**Amaç**: Tüm katmanlar tarafından kullanılan ortak kod.

**İçerik**:
- `constants/` - Sabit değerler (max undo steps, default colors)
- `errors/` - Özel exception sınıfları
- `extensions/` - Dart extension'ları (Offset, Color, Path)
- `utils/` - Matematik, path işlemleri, platform kontrolleri

**Kurallar**:
- ❌ Hiçbir katmana bağımlı OLMAMALI
- ❌ Flutter widget içermemeli (sadece dart:ui kullanabilir)
- ✅ Pure Dart kodu

```dart
// ✅ DOĞRU - Core'da olabilir
extension OffsetExtension on Offset {
  double distanceTo(Offset other) => (this - other).distance;
}

// ❌ YANLIŞ - Core'da olmamalı (Flutter widget)
class MyButton extends StatelessWidget { ... }
```

---

### 2. Domain (İş Mantığı) 💎

**Amaç**: Uygulamanın kalbi. Framework'ten tamamen bağımsız iş kuralları.

**İçerik**:
- `entities/` - Temel veri modelleri (Stroke, Layer, Page, Document)
- `enums/` - Tool types, shape types, blend modes
- `repositories/` - Soyut repository arayüzleri
- `value_objects/` - Değer nesneleri (StrokePoint, StrokeStyle)

**Kurallar**:
- ❌ Flutter'a bağımlı OLMAMALI (dart:ui hariç)
- ❌ Dış kütüphanelere bağımlı OLMAMALI
- ✅ Sadece Core katmanını kullanabilir
- ✅ Test edilmesi en kolay katman

```dart
// ✅ DOĞRU - Domain entity
class Stroke {
  final String id;
  final List<StrokePoint> points;
  final StrokeStyle style;
  
  // İş mantığı metodları
  Rect get boundingBox => _calculateBoundingBox();
  bool containsPoint(Offset point) => ...;
}

// ❌ YANLIŞ - Flutter bağımlılığı
class Stroke extends StatelessWidget { ... }  // Widget olmamalı!
```

---

### 3. Data (Veri) 💾

**Amaç**: Veri işlemleri - kaydetme, yükleme, dönüştürme, export.

**İçerik**:
- `repositories/` - Repository implementasyonları
- `serialization/` - JSON encoder/decoder, binary format
- `export/` - PNG, SVG, PDF export işlemleri

**Kurallar**:
- ✅ Domain katmanını kullanabilir
- ✅ Core katmanını kullanabilir
- ✅ Dış kütüphaneler kullanabilir (image, pdf)
- ❌ Presentation katmanını kullanmamalı

```dart
// ✅ DOĞRU - Data katmanında
class StrokeSerializer {
  Map<String, dynamic> toJson(Stroke stroke) => {...};
  Stroke fromJson(Map<String, dynamic> json) => ...;
}

class PngExporter {
  Future<Uint8List> export(Document doc) async => ...;
}
```

---

### 4. Presentation (Sunum) 🎨

**Amaç**: Kullanıcı arayüzü ve etkileşim.

**İçerik**:
- `canvas/` - CanvasWidget, GestureHandler
- `controllers/` - CanvasController (state management)
- `painters/` - CustomPainter implementasyonları
- `tools/` - PenTool, EraserTool, ShapeTool
- `widgets/` - Toolbar, LayerPanel, ColorPicker
- `themes/` - CanvasTheme, varsayılan stiller

**Kurallar**:
- ✅ Tüm katmanları kullanabilir
- ✅ Flutter widget'ları içerir
- ✅ Kullanıcı etkileşimini yönetir

```dart
// ✅ DOĞRU - Presentation katmanında
class CanvasWidget extends StatefulWidget {
  final CanvasController controller;
  ...
}

class StrokePainter extends CustomPainter {
  final List<Stroke> strokes;
  ...
}
```

---

## 📊 Bağımlılık Kuralları

```
┌─────────────────────────────────────────────────┐
│                 PRESENTATION                     │
│            (Flutter UI, Widgets)                 │
└─────────────────────┬───────────────────────────┘
                      │ kullanır
                      ▼
┌─────────────────────────────────────────────────┐
│                    DATA                          │
│         (Serialization, Export)                  │
└─────────────────────┬───────────────────────────┘
                      │ kullanır
                      ▼
┌─────────────────────────────────────────────────┐
│                   DOMAIN                         │
│          (Entities, Business Logic)              │
└─────────────────────┬───────────────────────────┘
                      │ kullanır
                      ▼
┌─────────────────────────────────────────────────┐
│                    CORE                          │
│         (Utils, Extensions, Constants)           │
└─────────────────────────────────────────────────┘
```

**Altın Kural**: Ok yönünde bağımlılık olabilir, tersi ASLA!

---

## 📝 Dosya İsimlendirme Kuralları

| Tür | Format | Örnek |
|-----|--------|-------|
| Dosya | snake_case | `stroke_point.dart` |
| Sınıf | PascalCase | `StrokePoint` |
| Değişken | camelCase | `strokeWidth` |
| Sabit | SCREAMING_SNAKE | `MAX_UNDO_STEPS` |
| Private | _önEk | `_calculateBounds()` |
| Extension | XxxExtension | `OffsetExtension` |

---

## 🧪 Test Stratejisi

```
test/
├── unit/                    # Birim testleri
│   ├── domain/              # Entity testleri
│   │   ├── stroke_test.dart
│   │   └── layer_test.dart
│   └── data/                # Serialization testleri
│       └── json_serializer_test.dart
│
├── widget/                  # Widget testleri
│   ├── canvas_widget_test.dart
│   └── toolbar_test.dart
│
└── integration/             # Entegrasyon testleri
    └── drawing_flow_test.dart
```

**Hedef**: %80+ code coverage

---

## 🎯 SOLID Prensipleri Uygulaması

### S - Single Responsibility (Tek Sorumluluk)
```dart
// ✅ Her sınıfın tek bir görevi var
class Stroke { }           // Sadece çizgi verisi
class StrokePainter { }    // Sadece çizgi render
class StrokeSerializer { } // Sadece JSON dönüşüm
```

### O - Open/Closed (Açık/Kapalı)
```dart
// ✅ Yeni tool eklemek için mevcut kodu değiştirmiyoruz
abstract class Tool {
  void onPointerDown(PointerEvent event);
}

class PenTool extends Tool { ... }
class EraserTool extends Tool { ... }
class NewTool extends Tool { ... }  // Yeni ekleme kolay
```

### L - Liskov Substitution
```dart
// ✅ Alt sınıflar üst sınıfın yerine kullanılabilir
void processTool(Tool tool) {
  tool.onPointerDown(event);  // Hangi tool olursa olsun çalışır
}
```

### I - Interface Segregation
```dart
// ✅ Küçük, özelleşmiş arayüzler
abstract class Drawable { void draw(Canvas canvas); }
abstract class Selectable { bool containsPoint(Offset p); }
abstract class Transformable { void translate(double dx, double dy); }

class Stroke implements Drawable, Selectable, Transformable { ... }
```

### D - Dependency Inversion
```dart
// ✅ Soyutlamalara bağımlı ol, somut sınıflara değil
abstract class ExportRepository {
  Future<Uint8List> exportToPng(Document doc);
}

class CanvasController {
  final ExportRepository _exporter;  // Soyut türe bağımlı
  CanvasController(this._exporter);
}
```

---

## 📚 Daha Fazla Bilgi

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter App Architecture](https://codewithandrea.com/articles/flutter-app-architecture-riverpod-introduction/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
