import 'package:flutter/foundation.dart';

import 'package:flutter_canvas_kit/src/core/constants/canvas_constants.dart';
import 'package:flutter_canvas_kit/src/domain/entities/canvas_document.dart';

/// Döküman geçmişi yöneticisi.
///
/// Undo/Redo işlemlerini yönetir.
/// Her değişiklikte dökümanın snapshot'ını saklar.
class HistoryManager extends ChangeNotifier {
  /// Undo stack (geçmiş durumlar).
  final List<CanvasDocument> _undoStack = [];

  /// Redo stack (geri alınan durumlar).
  final List<CanvasDocument> _redoStack = [];

  /// Maksimum geçmiş adımı.
  final int maxSteps;

  /// Mevcut döküman.
  CanvasDocument? _currentDocument;

  /// Batch mode aktif mi?
  bool _isBatching = false;

  /// Batch başlangıcındaki döküman.
  CanvasDocument? _batchStartDocument;

  HistoryManager({
    this.maxSteps = CanvasConstants.maxUndoSteps,
  });

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Mevcut döküman.
  CanvasDocument? get currentDocument => _currentDocument;

  /// Undo yapılabilir mi?
  bool get canUndo => _undoStack.isNotEmpty;

  /// Redo yapılabilir mi?
  bool get canRedo => _redoStack.isNotEmpty;

  /// Undo stack boyutu.
  int get undoCount => _undoStack.length;

  /// Redo stack boyutu.
  int get redoCount => _redoStack.length;

  /// Değişiklik var mı? (ilk durumdan farklı mı)
  bool get hasChanges => _undoStack.isNotEmpty;

  /// Batch mode aktif mi?
  bool get isBatching => _isBatching;

  // ---------------------------------------------------------------------------
  // Core Operations
  // ---------------------------------------------------------------------------

  /// İlk dökümanı ayarlar (geçmişi sıfırlar).
  void initialize(CanvasDocument document) {
    _undoStack.clear();
    _redoStack.clear();
    _currentDocument = document;
    _isBatching = false;
    _batchStartDocument = null;
    notifyListeners();
  }

  /// Yeni durumu kaydeder.
  ///
  /// Her değişiklikte çağrılmalı.
  void pushState(CanvasDocument document) {
    if (_isBatching) {
      // Batch modda sadece current'ı güncelle, stack'e ekleme
      _currentDocument = document;
      return;
    }

    _pushStateInternal(document);
  }

  void _pushStateInternal(CanvasDocument document) {
    // Mevcut durumu undo stack'e ekle
    if (_currentDocument != null) {
      _undoStack.add(_currentDocument!);

      // Maksimum adım kontrolü
      while (_undoStack.length > maxSteps) {
        _undoStack.removeAt(0);
      }
    }

    // Yeni durumu kaydet
    _currentDocument = document;

    // Redo stack'i temizle (yeni değişiklik yapıldı)
    _redoStack.clear();

    notifyListeners();
  }

  /// Geri al (Undo).
  CanvasDocument? undo() {
    if (!canUndo) return null;

    // Mevcut durumu redo stack'e ekle
    if (_currentDocument != null) {
      _redoStack.add(_currentDocument!);
    }

    // Önceki durumu al
    _currentDocument = _undoStack.removeLast();

    notifyListeners();
    return _currentDocument;
  }

  /// Yinele (Redo).
  CanvasDocument? redo() {
    if (!canRedo) return null;

    // Mevcut durumu undo stack'e ekle
    if (_currentDocument != null) {
      _undoStack.add(_currentDocument!);
    }

    // Sonraki durumu al
    _currentDocument = _redoStack.removeLast();

    notifyListeners();
    return _currentDocument;
  }

  // ---------------------------------------------------------------------------
  // Batch Operations
  // ---------------------------------------------------------------------------

  /// Batch modu başlatır.
  ///
  /// Batch modda yapılan değişiklikler tek bir undo adımı olarak kaydedilir.
  /// Örnek: Bir çizgi çizilirken her nokta ayrı ayrı kaydedilmez,
  /// çizgi bitince tek seferde kaydedilir.
  void beginBatch() {
    if (_isBatching) return;

    _isBatching = true;
    _batchStartDocument = _currentDocument;
  }

  /// Batch modunu bitirir ve değişiklikleri kaydeder.
  void endBatch() {
    if (!_isBatching) return;

    _isBatching = false;

    // Değişiklik varsa kaydet
    if (_currentDocument != null && _batchStartDocument != null) {
      if (_currentDocument!.id != _batchStartDocument!.id ||
          _currentDocument!.modifiedAt != _batchStartDocument!.modifiedAt) {
        // Batch başlangıcını undo stack'e ekle
        _undoStack.add(_batchStartDocument!);

        while (_undoStack.length > maxSteps) {
          _undoStack.removeAt(0);
        }

        _redoStack.clear();
      }
    }

    _batchStartDocument = null;
    notifyListeners();
  }

  /// Batch modunu iptal eder ve başlangıç durumuna döner.
  CanvasDocument? cancelBatch() {
    if (!_isBatching) return null;

    _isBatching = false;
    _currentDocument = _batchStartDocument;
    _batchStartDocument = null;

    notifyListeners();
    return _currentDocument;
  }

  // ---------------------------------------------------------------------------
  // Utility Methods
  // ---------------------------------------------------------------------------

  /// Geçmişi temizler.
  void clear() {
    _undoStack.clear();
    _redoStack.clear();
    _currentDocument = null;
    _isBatching = false;
    _batchStartDocument = null;
    notifyListeners();
  }

  /// Geçmişi sıfırlar (mevcut durumu korur).
  void reset() {
    _undoStack.clear();
    _redoStack.clear();
    _isBatching = false;
    _batchStartDocument = null;
    notifyListeners();
  }

  /// Belirli bir duruma geri döner.
  CanvasDocument? goToState(int index) {
    if (index < 0 || index >= _undoStack.length) return null;

    // Mevcut ve sonraki durumları redo'ya taşı
    if (_currentDocument != null) {
      _redoStack.add(_currentDocument!);
    }

    for (int i = _undoStack.length - 1; i > index; i--) {
      _redoStack.add(_undoStack.removeAt(i));
    }

    _currentDocument = _undoStack.removeAt(index);

    notifyListeners();
    return _currentDocument;
  }

  /// Tüm geçmiş durumlarının listesi (debug için).
  List<CanvasDocument> get allStates {
    return [
      ..._undoStack,
      if (_currentDocument != null) _currentDocument!,
    ];
  }

  @override
  void dispose() {
    _undoStack.clear();
    _redoStack.clear();
    super.dispose();
  }
}
