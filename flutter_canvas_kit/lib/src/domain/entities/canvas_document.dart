import 'package:flutter_canvas_kit/src/domain/entities/canvas_page.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_background.dart';
import 'package:flutter_canvas_kit/src/domain/enums/page_size.dart';

/// Canvas dökümanı.
///
/// Birden fazla [CanvasPage] içerir.
/// Notebook/defter konsepti.
final class CanvasDocument {
  /// Döküman format versiyonu.
  static const int currentVersion = 1;

  /// Benzersiz kimlik.
  final String id;

  /// Döküman başlığı.
  final String title;

  /// Döküman açıklaması.
  final String? description;

  /// Sayfalar.
  final List<CanvasPage> pages;

  /// Aktif sayfa indexi.
  final int currentPageIndex;

  /// Metadata (özel veriler).
  final Map<String, dynamic> metadata;

  /// Döküman versiyonu.
  final int version;

  /// Oluşturulma zamanı.
  final DateTime createdAt;

  /// Son değiştirilme zamanı.
  final DateTime modifiedAt;

  const CanvasDocument({
    required this.id,
    required this.title,
    this.description,
    required this.pages,
    this.currentPageIndex = 0,
    this.metadata = const {},
    this.version = currentVersion,
    required this.createdAt,
    required this.modifiedAt,
  });

  /// Boş döküman oluşturur.
  factory CanvasDocument.empty({
    String title = 'Untitled',
    String? description,
    PageSize pageSize = PageSize.a4,
    PageBackground background = PageBackground.blank,
  }) {
    final now = DateTime.now();
    return CanvasDocument(
      id: _generateId(),
      title: title,
      description: description,
      pages: [
        CanvasPage.empty(
          pageSize: pageSize,
          background: background,
        ),
      ],
      currentPageIndex: 0,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Not defteri oluşturur (çizgili).
  factory CanvasDocument.notebook({
    String title = 'Notebook',
    int pageCount = 1,
    PageSize pageSize = PageSize.a4,
  }) {
    final now = DateTime.now();
    return CanvasDocument(
      id: _generateId(),
      title: title,
      pages: List.generate(
        pageCount,
        (i) => CanvasPage.lined(title: 'Page ${i + 1}', pageSize: pageSize),
      ),
      currentPageIndex: 0,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Grafik kağıdı oluşturur (kareli).
  factory CanvasDocument.graphPaper({
    String title = 'Graph Paper',
    int pageCount = 1,
    PageSize pageSize = PageSize.a4,
  }) {
    final now = DateTime.now();
    return CanvasDocument(
      id: _generateId(),
      title: title,
      pages: List.generate(
        pageCount,
        (i) => CanvasPage.grid(title: 'Page ${i + 1}', pageSize: pageSize),
      ),
      currentPageIndex: 0,
      createdAt: now,
      modifiedAt: now,
    );
  }

  /// Sketch defteri (noktalı).
  factory CanvasDocument.sketchbook({
    String title = 'Sketchbook',
    int pageCount = 1,
    PageSize pageSize = PageSize.a4,
  }) {
    final now = DateTime.now();
    return CanvasDocument(
      id: _generateId(),
      title: title,
      pages: List.generate(
        pageCount,
        (i) => CanvasPage.dotted(title: 'Page ${i + 1}', pageSize: pageSize),
      ),
      currentPageIndex: 0,
      createdAt: now,
      modifiedAt: now,
    );
  }

  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Sayfa sayısı.
  int get pageCount => pages.length;

  /// Mevcut sayfa.
  CanvasPage get currentPage =>
      pages[currentPageIndex.clamp(0, pages.length - 1)];

  /// İlk sayfa.
  CanvasPage get firstPage => pages.first;

  /// Son sayfa.
  CanvasPage get lastPage => pages.last;

  /// Döküman boş mu?
  bool get isEmpty => pages.every((p) => p.isEmpty);

  /// Toplam eleman sayısı.
  int get totalElementCount =>
      pages.fold(0, (sum, page) => sum + page.totalElementCount);

  /// Toplam katman sayısı.
  int get totalLayerCount =>
      pages.fold(0, (sum, page) => sum + page.layerCount);

  // ---------------------------------------------------------------------------
  // Sayfa İşlemleri
  // ---------------------------------------------------------------------------

  /// Sayfa ekler.
  CanvasDocument addPage({CanvasPage? page, int? index}) {
    final newPage = page ?? CanvasPage.empty(title: 'Page ${pages.length + 1}');
    final insertIndex = index ?? pages.length;

    return copyWith(
      pages: [
        ...pages.sublist(0, insertIndex),
        newPage,
        ...pages.sublist(insertIndex),
      ],
      currentPageIndex: insertIndex,
      modifiedAt: DateTime.now(),
    );
  }

  /// Sayfa siler.
  CanvasDocument removePage(int index) {
    if (pages.length <= 1) return this; // En az 1 sayfa olmalı
    if (index < 0 || index >= pages.length) return this;

    final newPages = List<CanvasPage>.from(pages)..removeAt(index);
    final newCurrentIndex = currentPageIndex >= newPages.length
        ? newPages.length - 1
        : currentPageIndex;

    return copyWith(
      pages: newPages,
      currentPageIndex: newCurrentIndex,
      modifiedAt: DateTime.now(),
    );
  }

  /// Sayfayı günceller.
  CanvasDocument updatePage(int index, CanvasPage newPage) {
    if (index < 0 || index >= pages.length) return this;

    return copyWith(
      pages: [
        ...pages.sublist(0, index),
        newPage,
        ...pages.sublist(index + 1),
      ],
      modifiedAt: DateTime.now(),
    );
  }

  /// Mevcut sayfayı günceller.
  CanvasDocument updateCurrentPage(CanvasPage newPage) {
    return updatePage(currentPageIndex, newPage);
  }

  /// Aktif sayfayı değiştirir.
  CanvasDocument goToPage(int index) {
    if (index < 0 || index >= pages.length) return this;
    return copyWith(currentPageIndex: index);
  }

  /// Sonraki sayfaya git.
  CanvasDocument nextPage() {
    if (currentPageIndex >= pages.length - 1) return this;
    return copyWith(currentPageIndex: currentPageIndex + 1);
  }

  /// Önceki sayfaya git.
  CanvasDocument previousPage() {
    if (currentPageIndex <= 0) return this;
    return copyWith(currentPageIndex: currentPageIndex - 1);
  }

  /// Sayfaları yeniden sıralar.
  CanvasDocument reorderPages(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= pages.length) return this;
    if (newIndex < 0 || newIndex >= pages.length) return this;

    final newPages = List<CanvasPage>.from(pages);
    final page = newPages.removeAt(oldIndex);
    newPages.insert(newIndex, page);

    int newCurrentIndex = currentPageIndex;
    if (currentPageIndex == oldIndex) {
      newCurrentIndex = newIndex;
    } else if (oldIndex < currentPageIndex && newIndex >= currentPageIndex) {
      newCurrentIndex--;
    } else if (oldIndex > currentPageIndex && newIndex <= currentPageIndex) {
      newCurrentIndex++;
    }

    return copyWith(
      pages: newPages,
      currentPageIndex: newCurrentIndex,
      modifiedAt: DateTime.now(),
    );
  }

  /// Sayfayı kopyalar.
  CanvasDocument duplicatePage(int index) {
    if (index < 0 || index >= pages.length) return this;

    final duplicated = pages[index].duplicate();
    return addPage(page: duplicated, index: index + 1);
  }

  /// Index ile sayfa getirir.
  CanvasPage? getPage(int index) {
    if (index < 0 || index >= pages.length) return null;
    return pages[index];
  }

  /// ID ile sayfa bulur.
  CanvasPage? getPageById(String pageId) {
    for (final page in pages) {
      if (page.id == pageId) return page;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Genel İşlemler
  // ---------------------------------------------------------------------------

  /// Dökümanı temizler.
  CanvasDocument clear() {
    return copyWith(
      pages: [CanvasPage.empty()],
      currentPageIndex: 0,
      modifiedAt: DateTime.now(),
    );
  }

  /// Dökümanı kopyalar.
  CanvasDocument duplicate() {
    return copyWith(
      id: _generateId(),
      title: '$title (copy)',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  /// Başlığı değiştirir.
  CanvasDocument rename(String newTitle) {
    return copyWith(title: newTitle, modifiedAt: DateTime.now());
  }

  /// Metadata ekler.
  CanvasDocument setMetadata(String key, dynamic value) {
    return copyWith(
      metadata: {...metadata, key: value},
      modifiedAt: DateTime.now(),
    );
  }

  /// Metadata siler.
  CanvasDocument removeMetadata(String key) {
    final newMetadata = Map<String, dynamic>.from(metadata)..remove(key);
    return copyWith(metadata: newMetadata, modifiedAt: DateTime.now());
  }

  /// Başka bir dökümanla birleştirir.
  CanvasDocument merge(CanvasDocument other) {
    return copyWith(
      pages: [...pages, ...other.pages],
      modifiedAt: DateTime.now(),
    );
  }

  CanvasDocument copyWith({
    String? id,
    String? title,
    String? description,
    List<CanvasPage>? pages,
    int? currentPageIndex,
    Map<String, dynamic>? metadata,
    int? version,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return CanvasDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pages: pages ?? this.pages,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      metadata: metadata ?? this.metadata,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'pages': pages.map((p) => p.toJson()).toList(),
      'currentPageIndex': currentPageIndex,
      'metadata': metadata,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  factory CanvasDocument.fromJson(Map<String, dynamic> json) {
    return CanvasDocument(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      pages: (json['pages'] as List)
          .map((p) => CanvasPage.fromJson(p as Map<String, dynamic>))
          .toList(),
      currentPageIndex: json['currentPageIndex'] as int? ?? 0,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
      version: json['version'] as int? ?? currentVersion,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CanvasDocument && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'CanvasDocument(id: $id, title: $title, pages: $pageCount)';
}
