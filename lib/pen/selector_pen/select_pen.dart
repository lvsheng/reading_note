import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:protobuf/protobuf.dart';
import 'package:reading_note/pen/pen.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/selector_pen/indexable_area.dart';
import 'package:reading_note/pen/selector_pen/selected.dart';
import 'package:reading_note/status_manager/global_modal_manager.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:reading_note/util/log.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import '../../note_page/note_page.dart';
import '../pen_stroke_tracker.dart';

/// not visible to [PenManager], added automatically by [StatusManager] if needed
class SelectPen extends Pen with ChangeNotifier {
  NotePage? page;
  Offset? touchingOn;
  final selected = Selected();
  IndexableArea? _indexableArea;
  bool _moving = false;

  SelectPen() : super(-1, PenType.selectPen, material.Colors.black, 0);

  Size _size = userPreferences.selectPenSize;

  Size get size => _size;

  final scaleCornerRadius = 5.0;

  bool get moving => _moving;

  set moving(bool value) {
    assert(selected.isNotEmpty);
    _moving = value;
    _triggerRepaint();
  }

  static const _errorNotAllowed = "MattePlacePen id not allowed!"; // fixme: divorce not allowed behavior from base Pen
  @override
  get id => throw _errorNotAllowed;

  @override
  set type(PenType value) => throw _errorNotAllowed;

  @override
  set color(Color value) => throw _errorNotAllowed;

  @override
  set lineWidth(double value) => throw _errorNotAllowed;

  Offset? _movingStart;
  Offset? _movingLastPosition;
  List<pb.NotePageItem>? _itemCopyBeforeMoving;
  List<pb.NotePageItem>? _itemsMoving;

  @override
  PenStrokeTracker beginPaint(Offset position, NotePage page, int pageNumber) {
    _indexableArea ??= IndexableArea.getOrCreate(this.page ??= page);
    touchingOn = position;
    _refreshGlobalModal(); // trigger remove global modal

    if (!_moving) {
      return PositionTracker(this, touchingOn!, page, (position) {
        touchingOn = position;
        _select();
        _triggerRepaint(); // todo: selected与touchingOn分开绘制，提升性能？
      });
    }

    _movingLastPosition = _movingStart = touchingOn!;
    _itemsMoving = selected.iterateAllItems().toList(growable: false);
    _itemCopyBeforeMoving = _itemsMoving!.map((i) {
      assert(i.selected == true);
      assert(i.deleted == false);
      return i.deepCopy()..selected = true;
    }).toList(growable: false);
    for (var item in _itemsMoving!) {
      IndexableArea.itemBeforeUpdate(item, page);
    }

    final scaleOrigin = _shouldTrackOnScale(touchingOn!);

    return PositionTracker(this, touchingOn!, page, (position) {
      touchingOn = position;
      _updateMove(position);
      _triggerRepaint();
      _updateSelectedBoundingBoxIfNeeded();
      _movingLastPosition = position;
    });
  }

  void _updateMove(Offset position) {
    final diff = position - _movingLastPosition!;
    for (final item in _itemsMoving!) {
      item.x += diff.dx;
      item.y += diff.dy;
    }
  }

  void _updateScale(Offset position) {}

  @override
  void endPaint() {
    if (_itemsMoving != null) {
      for (final item in _itemsMoving!) {
        IndexableArea.itemAfterUpdated(item, page!);
      }

      final itemsMoving = _itemsMoving!;
      final itemsCopyBeforeMoving = _itemCopyBeforeMoving!;
      final itemsCopyAfterMoving = itemsMoving.map((i) => i.deepCopy()).toList(growable: false);
      final closurePage = page!;
      bool isFirstCall = true;
      statusManager.historyStack.doo(() {
        if (isFirstCall) {
          isFirstCall = false;
          return;
        }

        // redo:
        for (var item in itemsMoving) {
          IndexableArea.itemBeforeUpdate(item, closurePage);
        }
        _copyPositionAndScale(itemsCopyAfterMoving, itemsMoving);
        for (var item in itemsMoving) {
          IndexableArea.itemAfterUpdated(item, closurePage);
        }

        page!.triggerRepaint();
        _updateSelectedBoundingBoxIfNeeded();
        _triggerRepaint();
      }, () {
        for (var item in itemsMoving) {
          IndexableArea.itemBeforeUpdate(item, closurePage);
        }
        _copyPositionAndScale(itemsCopyBeforeMoving, itemsMoving);
        for (var item in itemsMoving) {
          IndexableArea.itemAfterUpdated(item, closurePage);
        }

        page!.triggerRepaint();
        _updateSelectedBoundingBoxIfNeeded();
        _triggerRepaint();
      });
    }

    touchingOn = null;
    _movingStart = null;
    _movingLastPosition = null;
    _itemsMoving = null;
    _itemCopyBeforeMoving = null;

    _triggerRepaint();
    _refreshGlobalModal();

    super.endPaint();
  }

  void _copyPositionAndScale(List<pb.NotePageItem> from, List<pb.NotePageItem> to) {
    assert(from.length == to.length);
    for (final (index, item) in to.indexed) {
      assert(!item.deleted);
      final fromItem = from[index];
      if (fromItem.hasScale()) {
        item.scale = fromItem.scale;
      }
      item.x = fromItem.x;
      item.y = fromItem.y;
    }
  }

  void _updateSelectedBoundingBoxIfNeeded() {
    if (selected.isNotEmpty) {
      selectedBoundingBox = _calculateSelectedBoundingBox();
    } else {
      selectedBoundingBox = null;
    }
  }

  Rect _calculateSelectedBoundingBox() {
    double? l, t, r, b;
    for (final item in selected.iterateAllItems()) {
      final boundingBox = ItemWrapper.boundingBoxOfItem(item, page!.data);
      if (l == null) {
        l = boundingBox.left;
        t = boundingBox.top;
        r = boundingBox.right;
        b = boundingBox.bottom;
      }
      l = min(l, boundingBox.left);
      t = min(t!, boundingBox.top);
      r = max(r!, boundingBox.right);
      b = max(b!, boundingBox.bottom);
    }
    assert(l != null && t != null && r != null && b != null);
    return Rect.fromLTRB(l!, t!, r!, b!);
  }

  /// @return: scale origin
  Offset? _shouldTrackOnScale(Offset position) {
    for (final corner in [
      selectedBoundingBox!.topLeft,
      selectedBoundingBox!.topRight,
      selectedBoundingBox!.bottomLeft,
      selectedBoundingBox!.bottomRight
    ]) {
      final diff = position - corner;
      final threshold = scaleCornerRadius * 1.5;
      if (diff.distance < threshold) {
        return corner;
      }
    }
    return null;
  }

  Rect? selectedBoundingBox;

  void _select() {
    assert(touchingOn != null);
    int ts = DateTime.now().millisecondsSinceEpoch;
    int lengthBefore = selected.length;
    selected.addAll(// judge whether result.isNotEmpty will cause iterable move next, so addAll directly
        _indexableArea!.select(Rect.fromCenter(center: touchingOn!, width: size.width, height: size.height)));
    if (selected.length > lengthBefore) {
      selectedBoundingBox = _calculateSelectedBoundingBox();
      logDebug(
          "selected: new:${selected.length - lengthBefore} total:${selected.length} position:$touchingOn size:$size cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
    }
  }

  void _triggerRepaint() {
    notifyListeners();
  }

  bool get adjusting => _heightAdjustingStart != null || _widthAdjustingStart != null;

  /// for SelectingPanel

  double? _heightAdjustingStart;

  void beginAdjustHeight() {
    _heightAdjustingStart = size.height;
    _refreshGlobalModal();
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
    _refreshGlobalModal();
  }

  void endAdjustHeight() {
    _heightAdjustingStart = null;
    _refreshGlobalModal();
  }

  double? _widthAdjustingStart;

  void beginAdjustWidth() {
    _widthAdjustingStart = size.width;
    _refreshGlobalModal();
  }

  void adjustWidth(double diff) {
    size = Size(_adjust(_widthAdjustingStart!, diff), size.height);
    _refreshGlobalModal();
  }

  void endAdjustWidth() {
    _widthAdjustingStart = null;
    _refreshGlobalModal();
  }

  static const _defaultSize = Size(50.0, 50.0);

  void resetSize() {
    _heightAdjustingStart = size.height;
    size = _defaultSize;
    _refreshGlobalModal();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _heightAdjustingStart = null;
      _refreshGlobalModal();
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

  void _refreshGlobalModal() {
    final oldShowingModal = _showingModal;
    _showingModal = touchingOn == null && adjusting;

    if (!_showingModal) {
      if (oldShowingModal) globalModalManager.remove(_buildGlobalModal);
      return;
    }

    globalModalManager.update(_buildGlobalModal);
  }

  Widget _buildGlobalModal() {
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
    _moving = false;
    _triggerRepaint();
  }

  void finish() {
    refresh();
    statusManager.toggleSelectingMode();
  }

  void delete() {
    final items = selected.iterateAllItems().toList(growable: false);
    statusManager.historyStack.doo(() {
      for (final item in items) {
        assert(!item.deleted);
        item.deleted = true;
        IndexableArea.itemRemoved(item, page!);
      }
      page!.triggerRepaint();
      refresh();
    }, () {
      for (final item in items) {
        assert(item.deleted);
        item.deleted = false;
        item.selected = true;
        IndexableArea.itemAdded(item, page!);
      }
      page!.triggerRepaint();
      selected.addAll(items);
      _triggerRepaint();
    });
    page!.markHasItemsDeleted();
  }
}
