import 'package:flutter/cupertino.dart';
import 'package:reading_note/pen/pen.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/selector_pen/indexable_area.dart';
import 'package:reading_note/pen/selector_pen/selected.dart';
import 'package:reading_note/status_manager/global_modal_manager.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:reading_note/util/log.dart';

import '../../note_page/note_page.dart';
import '../pen_stroke_tracker.dart';

/// not visible to [PenManager], added automatically by [StatusManager] if needed
class SelectPen extends Pen with ChangeNotifier {
  NotePage? page;
  Offset? touchingOn;
  final selected = Selected();
  IndexableArea? _indexableArea;

  SelectPen() : super(-1, PenType.selectPen, material.Colors.black, 0);

  Size _size = userPreferences.selectPenSize;

  Size get size => _size;

  static const _errorNotAllowed = "MattePlacePen id not allowed!"; // fixme: divorce not allowed behavior from base Pen
  @override
  get id => throw _errorNotAllowed;

  @override
  set type(PenType value) => throw _errorNotAllowed;

  @override
  set color(Color value) => throw _errorNotAllowed;

  @override
  set lineWidth(double value) => throw _errorNotAllowed;

  @override
  PenStrokeTracker beginPaint(Offset position, NotePage page, int pageNumber) {
    _indexableArea ??= IndexableArea.getOrCreate(this.page ??= page);
    touchingOn = position;
    _refreshGlobalModel();
    return PositionTracker(this, position, page, (position) {
      touchingOn = position;
      _select();
      _triggerRepaint(); // todo: selected与touchingOn分开绘制？
    });
  }

  void _select() {
    assert(touchingOn != null);
    int ts = DateTime.now().millisecondsSinceEpoch;
    int lengthBefore = selected.length;
    selected.addAll(// judge whether result.isNotEmpty will cause iterable move next, so addAll directly
        _indexableArea!.select(Rect.fromCenter(center: touchingOn!, width: size.width, height: size.height)));
    if (selected.length > lengthBefore) {
      logDebug(
          "selected: new:${selected.length - lengthBefore} total:${selected.length} position:$touchingOn size:$size cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
    }
  }

  @override
  void endPaint() {
    touchingOn = null;
    _triggerRepaint();
    _refreshGlobalModel();
  }

  void _triggerRepaint() {
    notifyListeners();
  }

  bool get adjusting => _heightAdjustingStart != null || _widthAdjustingStart != null;

  /// for SelectingPanel

  double? _heightAdjustingStart;

  void beginAdjustHeight() {
    _heightAdjustingStart = size.height;
    _refreshGlobalModel();
  }

  double _adjust(double start, double diff) {
    final threshold = _defaultSize.width;
    const minMultiple = 10;
    if (start < threshold) {
      return start + diff / minMultiple;
    }

    var result = start + diff;
    if (result < threshold) {
      final remained = threshold - result;
      result = threshold - remained / minMultiple;
    }
    return result;
  }

  void adjustHeight(double diff) {
    final oldSize = size;
    final wHRate = oldSize.width / oldSize.height;
    final newHeight = _adjust(_heightAdjustingStart!, diff);
    size = Size(newHeight * wHRate, newHeight);
    _refreshGlobalModel();
  }

  void endAdjustHeight() {
    _heightAdjustingStart = null;
    _refreshGlobalModel();
  }

  double? _widthAdjustingStart;

  void beginAdjustWidth() {
    _widthAdjustingStart = size.width;
    _refreshGlobalModel();
  }

  void adjustWidth(double diff) {
    size = Size(_adjust(_widthAdjustingStart!, diff), size.height);
    _refreshGlobalModel();
  }

  void endAdjustWidth() {
    _widthAdjustingStart = null;
    _refreshGlobalModel();
  }

  static const _defaultSize = Size(50.0, 50.0);

  void resetSize() {
    _heightAdjustingStart = size.height;
    size = _defaultSize;
    _refreshGlobalModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heightAdjustingStart = null;
      _refreshGlobalModel();
    });
  }

  set size(Size value) {
    if (page != null) {
      final maxWidth = page!.data.width * 2;
      final maxHeight = page!.data.height * 2;
      if (value.width > maxWidth) value = Size(maxWidth, value.height);
      if (value.height > maxHeight) value = Size(value.width, maxHeight);
    }
    _size = userPreferences.selectPenSize = value;
    if (touchingOn != null) {
      _select();
    }
    _triggerRepaint();
  }

  bool _showingModal = false;

  void _refreshGlobalModel() {
    final oldShowingModal = _showingModal;
    _showingModal = touchingOn == null && adjusting;

    if (!_showingModal) {
      if (oldShowingModal) globalModalManager.remove(_build);
      return;
    }

    globalModalManager.update(_build);
  }

  Widget _build() {
    // CoordConverter coordConverter = NoteCoordConverter(); // todo: 拿到当前的笔记/书coordConverter，展示按当前页缩放后的结果
    // final penSize = coordConverter.pageSizeToCanvas(size);
    final penSize = size;
    return Container(
      width: penSize.width,
      height: penSize.height,
      decoration: BoxDecoration(border: Border.all(width: 0, color: material.Colors.grey)),
    );
  }

  void refresh() {
    selected.clear();
  }

  void finish() {
    refresh();
    statusManager.toggleSelectingMode();
  }

  void delete() {
    final items = selected.iterateAllItems().toList(growable: false);
    page!.historyStack.doo(() {
      for (final item in items) {
        assert(!item.deleted);
        item.deleted = true;
      }
      selected.clear();
    }, () {
      for (final item in items) {
        assert(item.deleted);
        item.deleted = false; // todo: remove on save disk
      }
      selected.addAll(items);
    });
    page!.markHasItemsDeleted();
    page!.triggerRepaint();
    _triggerRepaint();
  }
}
