import 'dart:math';

import 'package:flutter/cupertino.dart';
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
import '../path_generator.dart';
import '../pen_stroke_tracker.dart';

class _ItemPosition {
  final double x;
  final double y;
  final double? xNormalized;
  final double? yNormalized;
  final double? scale;

  _ItemPosition(pb.NotePageItem item, [Rect? normalizeBase])
      : x = item.x,
        y = item.y,
        xNormalized = normalizeBase == null ? null : (item.x - normalizeBase.left) / normalizeBase.width,
        yNormalized = normalizeBase == null ? null : (item.y - normalizeBase.top) / normalizeBase.height,
        scale = item.hasScale() ? item.scale : null;
}

enum MagnetPosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// not visible to [PenManager], added automatically by [StatusManager] if needed
class SelectPen extends Pen with ChangeNotifier {
  NotePage? page;
  Offset? touchingOn;
  var selected = Selected();
  Rect? selectedBoundingBox;
  (MagnetPosition, Selected, Rect)? magnet;
  IndexableArea? _indexableArea;
  bool _moving = false;
  bool _changingPen = false;
  bool _changingDecoration = false;
  bool paintSelectedStatus = true;
  bool paintOutline = true;

  SelectPen() : super(-1, PenType.selectPen, material.Colors.black, 0);

  Size _size = userPreferences.selectPenSize;

  Size get size => _size;

  final scaleCornerRadius = 5.0;

  bool get moving => _moving;

  bool get changingPen => _changingPen;

  bool get changingDecoration => _changingDecoration;

  set moving(bool value) {
    _moving = value;
    _triggerRepaint();
  }

  set changingPen(bool value) {
    assert(selected.isNotEmpty);
    _changingPen = value;
  }

  set changingDecoration(bool value) {
    assert(selected.isNotEmpty);
    _changingDecoration = value;
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

  Offset? _movingLastPosition;
  List<_ItemPosition>? _positionsBeforeMoving;
  List<pb.NotePageItem>? _itemsMoving;

  @override
  PenStrokeTracker beginPaint(Offset position, NotePage page, int pageNumber) {
    paintSelectedStatus = true;

    _indexableArea ??= IndexableArea.getOrCreate(this.page ??= page);
    touchingOn = position;
    _refreshGlobalModal(); // trigger remove global modal

    if (!_moving) {
      // select more mode
      return PositionTracker(this, touchingOn!, page, (position) {
        touchingOn = position;
        _select();
        _triggerRepaint(); // todo: selected与touchingOn分开绘制，提升性能？
      });
    }

    // move or scale mode
    final scaleOriginInfo = _shouldTrackOnScale(touchingOn!);
    final isScale = scaleOriginInfo != null;
    Offset? originalDiagonalDiff;
    Rect? originalDiagonalRect;
    double? hWRate;
    if (isScale) {
      originalDiagonalDiff = scaleOriginInfo.$2 - scaleOriginInfo.$1;
      assert(originalDiagonalDiff.dx.abs() == selectedBoundingBox!.width && originalDiagonalDiff.dy.abs() == selectedBoundingBox!.height);
      originalDiagonalRect = Rect.fromLTWH(scaleOriginInfo.$1.dx, scaleOriginInfo.$1.dy, originalDiagonalDiff.dx, originalDiagonalDiff.dy);
      hWRate = originalDiagonalDiff.dy / originalDiagonalDiff.dx;
    }
    _movingLastPosition = touchingOn!;
    assert(_itemsMoving == null);
    _itemsMoving = selected.iterateAllItems().toList(growable: false);
    _positionsBeforeMoving = _itemsMoving!.map((i) => _ItemPosition(i, isScale ? originalDiagonalRect! : null)).toList(growable: false);
    for (final item in _itemsMoving!) {
      IndexableArea.itemBeforeUpdate(item, page);
    }

    return PositionTracker(this, touchingOn!, page, (position) {
      touchingOn = position;
      if (isScale) {
        // scale mode
        _updateScale(position, scaleOriginInfo.$1, originalDiagonalDiff!, hWRate!);
      } else {
        // move mode
        _updateMove(position);
      }

      paintOutline = false;
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

  void _updateScale(Offset current, Offset origin, Offset originalDiagonalDiff, double hWRate) {
    final currentRelativeX = current.dx - origin.dx;
    final currentDiagonalDiff = Offset(currentRelativeX, hWRate * currentRelativeX); // ignore current y, keep hWRate
    final scale = currentDiagonalDiff.dx / originalDiagonalDiff.dx;
    for (final (index, item) in _itemsMoving!.indexed) {
      final originalPosition = _positionsBeforeMoving![index];
      final originalScale = originalPosition.scale ?? 1.0;
      item.scale = originalScale * scale;
      if (item.scale == 1.0) item.clearScale();

      item.x = originalPosition.xNormalized! * currentDiagonalDiff.dx + origin.dx;
      item.y = originalPosition.yNormalized! * currentDiagonalDiff.dy + origin.dy;
    }
  }

  @override
  void endPaint() {
    if (_itemsMoving != null) {
      paintOutline = true;
      for (final item in _itemsMoving!) {
        IndexableArea.itemAfterUpdated(item, page!);
      }

      final itemsMoving = _itemsMoving!;
      final positionsBeforeMoving = _positionsBeforeMoving!;
      final positionsCopyAfterMoving = itemsMoving.map((i) => _ItemPosition(i)).toList(growable: false);
      final capturedPage = page!;
      bool isFirstCall = true;
      statusManager.historyStack.doo(() {
        if (isFirstCall) {
          isFirstCall = false;
          return;
        }

        // redo:
        for (final item in itemsMoving) {
          IndexableArea.itemBeforeUpdate(item, capturedPage);
        }
        _copyPositionAndScale(positionsCopyAfterMoving, itemsMoving);
        for (final item in itemsMoving) {
          IndexableArea.itemAfterUpdated(item, capturedPage);
        }

        page!.triggerRepaint();
        _updateSelectedBoundingBoxIfNeeded();
        paintSelectedStatus = true;
        _triggerRepaint();
      }, () {
        for (final item in itemsMoving) {
          IndexableArea.itemBeforeUpdate(item, capturedPage);
        }
        _copyPositionAndScale(positionsBeforeMoving, itemsMoving);
        for (final item in itemsMoving) {
          IndexableArea.itemAfterUpdated(item, capturedPage);
        }

        page!.triggerRepaint();
        _updateSelectedBoundingBoxIfNeeded();
        paintSelectedStatus = true;
        _triggerRepaint();
      });
    }

    touchingOn = null;
    _movingLastPosition = null;
    _itemsMoving = null;
    _positionsBeforeMoving = null;

    _triggerRepaint();
    _refreshGlobalModal();

    super.endPaint();
  }

  void _copyPositionAndScale(List<_ItemPosition> from, List<pb.NotePageItem> to) {
    assert(from.length == to.length);
    for (final (index, item) in to.indexed) {
      assert(!item.deleted);
      final fromItem = from[index];
      if (fromItem.scale != null) {
        item.scale = fromItem.scale!;
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
  (
    Offset /*origin*/,
    Offset
    /*diagonal*/
  )? _shouldTrackOnScale(Offset position) {
    for (final pair in [
      (selectedBoundingBox!.topLeft, selectedBoundingBox!.bottomRight),
      (selectedBoundingBox!.topRight, selectedBoundingBox!.bottomLeft),
      (selectedBoundingBox!.bottomLeft, selectedBoundingBox!.topRight),
      (selectedBoundingBox!.bottomRight, selectedBoundingBox!.topLeft),
    ]) {
      final diff = position - pair.$2;
      final threshold = scaleCornerRadius * 1.5;
      if (diff.distance < threshold) {
        return pair;
      }
    }
    return null;
  }

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

  static const _defaultSize = Size(10.0, 10.0);

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
    magnet?.$2.clear();
    magnet = null;
    _moving = false;
    _changingPen = false;
    paintSelectedStatus = true;
    paintOutline = true;
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
      paintSelectedStatus = true;
      _triggerRepaint();
    });
    page!.markHasItemsDeleted();
  }

  void changePen(Pen pen) {
    final penId = PathGenerator.generatePbPenId(pen, page!.data.penPool);
    final items = selected.iterateAllItems().where((item) => item.whichContent() == pb.NotePageItem_Content.path).toList(growable: false);
    final List<int> oldPenIds = List.generate(items.length, (index) => items[index].path.penId);
    statusManager.historyStack.doo(() {
      for (final item in items) {
        assert(!item.deleted);
        item.path.penId = penId;
      }
      page!.triggerRepaint();
      paintSelectedStatus = false;
      _triggerRepaint();
    }, () {
      for (final (index, item) in items.indexed) {
        assert(!item.deleted);
        item.path.penId = oldPenIds[index];
      }
      page!.triggerRepaint();
      paintSelectedStatus = false;
      _triggerRepaint();
    });
  }

  void changeDecoration(pb.DecorationType? decoration) {
    final mattes = selected
        .iterateAllItems()
        .where((item) => item.whichContent() == pb.NotePageItem_Content.matteId)
        .map((item) => page!.data.independentNoteData.mattePool[item.matteId]!)
        .toList(growable: false);
    final oldDecorations = mattes.map((matte) => matte.hasDecoration() ? matte.decoration : null).toList(growable: false);
    statusManager.historyStack.doo(() {
      for (final matte in mattes) {
        if (decoration == null) {
          matte.clearDecoration();
        } else {
          matte.decoration = decoration;
        }
      }
      page!.triggerRepaint();
      paintSelectedStatus = false;
      _triggerRepaint();
    }, () {
      for (final (index, matte) in mattes.indexed) {
        final decoration = oldDecorations[index];
        if (decoration == null) {
          matte.clearDecoration();
        } else {
          matte.decoration = decoration;
        }
      }
      page!.triggerRepaint();
      paintSelectedStatus = false;
      _triggerRepaint();
    });
  }

  void magnetFromSelected(MagnetPosition pos) {
    assert(selectedBoundingBox != null);
    magnet = (pos, selected, selectedBoundingBox!);
    selected = Selected();
    selectedBoundingBox = null;
    _triggerRepaint();
  }

  void magnetToSelected(MagnetPosition pos) {
    logInfo("magnetToSelected $pos");
    assert(magnet != null);
    assert(selectedBoundingBox != null);
    _magnetUpdatePosition(magnet!.$2, magnet!.$1, magnet!.$3, selectedBoundingBox!, pos);
    selected.addAnother(magnet!.$2);
    magnet = null;
    _updateSelectedBoundingBoxIfNeeded();
    _triggerRepaint();
  }

  void _magnetUpdatePosition(
      Selected selected, MagnetPosition magnetPosition, Rect rect, Rect targetRect, MagnetPosition targetMagnetPosition) {
    late final Offset targetOffset;
    switch (targetMagnetPosition) {
      case MagnetPosition.topLeft:
        targetOffset = targetRect.topLeft;
        break;
      case MagnetPosition.topCenter:
        targetOffset = targetRect.topCenter;
        break;
      case MagnetPosition.topRight:
        targetOffset = targetRect.topRight;
        break;
      case MagnetPosition.centerLeft:
        targetOffset = targetRect.centerLeft;
        break;
      case MagnetPosition.centerRight:
        targetOffset = targetRect.centerRight;
        break;
      case MagnetPosition.bottomLeft:
        targetOffset = targetRect.bottomLeft;
        break;
      case MagnetPosition.bottomCenter:
        targetOffset = targetRect.bottomCenter;
        break;
      case MagnetPosition.bottomRight:
        targetOffset = targetRect.bottomRight;
        break;
    }

    late Offset newTopLeft;
    switch (magnetPosition) {
      case MagnetPosition.topLeft:
        newTopLeft = targetOffset;
        break;
      case MagnetPosition.topCenter:
        newTopLeft = Offset(targetOffset.dx - rect.width / 2, targetOffset.dy);
        break;
      case MagnetPosition.topRight:
        newTopLeft = Offset(targetOffset.dx - rect.width, targetOffset.dy);
        break;
      case MagnetPosition.centerLeft:
        newTopLeft = Offset(targetOffset.dx, targetOffset.dy - rect.height / 2);
        break;
      case MagnetPosition.centerRight:
        newTopLeft = Offset(targetOffset.dx - rect.width, targetOffset.dy - rect.height / 2);
        break;
      case MagnetPosition.bottomLeft:
        newTopLeft = Offset(targetOffset.dx, targetOffset.dy - rect.height);
        break;
      case MagnetPosition.bottomCenter:
        newTopLeft = Offset(targetOffset.dx - rect.width / 2, targetOffset.dy - rect.height);
        break;
      case MagnetPosition.bottomRight:
        newTopLeft = Offset(targetOffset.dx - rect.width, targetOffset.dy - rect.height);
        break;
    }

    bool isBottom(MagnetPosition pos) => [MagnetPosition.bottomLeft, MagnetPosition.bottomCenter, MagnetPosition.bottomRight].contains(pos);
    bool isTop(MagnetPosition pos) => [MagnetPosition.topLeft, MagnetPosition.topCenter, MagnetPosition.topRight].contains(pos);
    const yPaddingFactor = 0.2;
    if (isBottom(magnetPosition) && isTop(targetMagnetPosition)) {
      newTopLeft = newTopLeft.translate(0, -targetRect.height * yPaddingFactor);
    } else if (isTop(magnetPosition) && isBottom(targetMagnetPosition)) {
      newTopLeft = newTopLeft.translate(0, targetRect.height * yPaddingFactor);
    }

    final Offset offset = newTopLeft - rect.topLeft;
    final capturedItems = selected.iterateAllItems().toList(growable: false);
    final capturedPage = page!;
    statusManager.historyStack.doo(() {
      for (final item in capturedItems) {
        IndexableArea.itemBeforeUpdate(item, capturedPage);
        item.x += offset.dx;
        item.y += offset.dy;
        IndexableArea.itemAfterUpdated(item, capturedPage);
      }
      _updateSelectedBoundingBoxIfNeeded(); // for redo (selected do not change, but position changed)
      _triggerRepaint();
      page!.triggerRepaint();
    }, () {
      for (final item in capturedItems) {
        IndexableArea.itemBeforeUpdate(item, capturedPage);
        item.x -= offset.dx;
        item.y -= offset.dy;
        IndexableArea.itemAfterUpdated(item, capturedPage);
      }
      _updateSelectedBoundingBoxIfNeeded();
      _triggerRepaint();
      page!.triggerRepaint();
    });
  }
}
