# Changelog

Bu proje [Semantic Versioning](https://semver.org/lang/tr/) kullanır.
Format [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) standardına uyar.

<!--
============================================================================
CHANGELOG YAZIM KURALLARI
============================================================================

Her versiyon için şu başlıkları kullan (uygun olanları):

### Added (Eklendi)
- Yeni özellikler

### Changed (Değişti)
- Mevcut özelliklerdeki değişiklikler

### Deprecated (Kullanımdan Kaldırılacak)
- Yakında kaldırılacak özellikler

### Removed (Kaldırıldı)
- Kaldırılan özellikler

### Fixed (Düzeltildi)
- Bug fix'ler

### Security (Güvenlik)
- Güvenlik yamaları

KURALLAR:
1. En yeni versiyon en üstte
2. Tarih formatı: YYYY-MM-DD
3. Her madde - ile başlar
4. Link'ler en altta

============================================================================
-->

## [Unreleased]

### Added
- Proje yapısı oluşturuldu (Clean Architecture)
- Temel model sınıfları planlandı

---

## [0.1.0] - 2024-XX-XX

### Added
- 🎨 **Çekirdek çizim motoru**
  - `StrokePoint`: Basınç ve eğim verisi ile nokta modeli
  - `Stroke`: Çizgi modeli (pen, highlighter, pencil desteği)
  - `perfect_freehand` entegrasyonu

- 📚 **Katman sistemi** ⭐ (Piyasada ilk!)
  - `Layer`: Katman modeli
  - Görünürlük ve kilit kontrolü
  - Opaklık ve blend mode desteği
  - Katman sıralama

- 📄 **Sayfa yönetimi**
  - `CanvasPage`: Çoklu katman desteği
  - Sayfa şablonları (blank, lined, grid, dotted)
  - Özel sayfa boyutları

- 📁 **Döküman yapısı**
  - `CanvasDocument`: Çoklu sayfa desteği
  - JSON serialization

- 🛠️ **Araçlar**
  - Kalem (basınç duyarlı)
  - Fosforlu kalem (şeffaf, üst üste binmez)
  - Kurşun kalem (dokulu)
  - Silgi (stroke ve kısmi mod)

- 📐 **Şekil araçları**
  - Çizgi ve ok
  - Dikdörtgen ve yuvarlatılmış dikdörtgen
  - Daire/elips
  - Üçgen ve yıldız

- ↩️ **Geçmiş yönetimi**
  - Undo/Redo (100 adım)
  - State-based history

- 📤 **Export**
  - PNG export
  - JSON export/import

### Performance
- Two-layer rendering (cache + active)
- Viewport culling
- RepaintBoundary optimizasyonu

---

## Planlanan Versiyonlar

### [0.2.0] - Planlandı
- [ ] Metin aracı
- [ ] Resim/sticker ekleme
- [ ] SVG export
- [ ] Seçim ve transform araçları

### [0.3.0] - Planlandı
- [ ] PDF üzerine çizim
- [ ] PDF export
- [ ] Gelişmiş silgi (kısmi silme)

### [1.0.0] - Planlandı
- [ ] Stabil API
- [ ] %80+ test coverage
- [ ] Kapsamlı dokümantasyon
- [ ] Performans benchmarkları

---

<!--
Link tanımlamaları (GitHub otomatik oluşturur)
-->
[Unreleased]: https://github.com/user/flutter_canvas_kit/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/user/flutter_canvas_kit/releases/tag/v0.1.0
