import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:quiver/iterables.dart' as iterables;
import 'package:reading_note/custom_painter/paint_matte.dart';
import 'package:reading_note/pen/selector_pen/indexable_area.dart';
import 'package:reading_note/status_manager/matting_manager.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';
import '../file_system_proxy.dart';
import '../note_page/note_page.dart';
import '../user_preferences.dart';
import 'pen.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;

import 'pen_stroke_tracker.dart';

enum _PenStatus {
  recommending,
  adjusting,
  nothingToDo,
}

/// not visible to [PenManager], added automatically by [StatusManager] if needed
class MattePositionerPen extends Pen with ChangeNotifier {
  MattePositionerPen()
      : _mattes = const [],
        super(-1, PenType.mattePositionerPen, material.Colors.black, 0) {
    __scale = userPreferences.matteScaleOf(statusManager.reading!);
    mattingManager.addListener(onMattingManagerChange);
    onMattingManagerChange(); // trigger initial handle
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

  late double __scale;

  double get _scale => __scale;

  set _scale(double value) {
    __scale = value;
    userPreferences.setMatteScale(statusManager.reading!, value);
  }

  int _latestPageNumber = -1;
  NotePage? _currentPage; // todo: listen on notebook pageview page change
  bool _oneByOne = true;

  Axis _direction = Axis.vertical;
  double _padding = 3;
  Offset? _latestPosition;
  pb.Matte? _handling;
  int _handlingIndex = -1;
  _PenStatus _status = _PenStatus.recommending;
  List<pb.NotePageItem>? _adjustingPageItems;
  List<pb.Matte> _mattes;

  Offset get _position {
    assert(_handling != null);
    if (_latestPosition != null) {
      return Offset(_latestPosition!.dx - _handling!.imageWidth * _scale, _latestPosition!.dy - _handling!.imageHeight * _scale);
    }
    if (_currentPage?.data.items.isNotEmpty != true) {
      return const Offset(0, 0);
    }

    final latestItem = _currentPage!.data.items.last;
    if (latestItem.whichContent() == pb.NotePageItem_Content.matteId) {
      final matteId = latestItem.matteId;
      final matte = _currentPage!.data.independentNoteData.mattePool[matteId];
      if (matte == null) return const Offset(0, 0);

      final scale = latestItem.hasScale() ? latestItem.scale : 1.0;
      if (_direction == Axis.vertical) {
        // justify: left
        return Offset(latestItem.x, latestItem.y + matte.imageHeight * scale + _padding);
      } else {
        // justify: bottom
        return Offset(
            latestItem.x + matte.imageWidth * scale + _padding, latestItem.y + matte.imageHeight * scale - _handling!.imageHeight * _scale);
      }
    } else if (latestItem.whichContent() == pb.NotePageItem_Content.path) {
      final maxX = latestItem.x + iterables.max(latestItem.path.points.map((p) => p.x))!;
      final maxY = latestItem.y + iterables.max(latestItem.path.points.map((p) => p.y))!;
      if (_direction == Axis.vertical) {
        // justify: right
        return Offset(maxX - _handling!.imageWidth * _scale, maxY + _padding);
      } else {
        // justify: bottom
        return Offset(maxX + _padding, maxY - _handling!.imageHeight * _scale);
      }
    } else {
      throw "Invalid latestItem.whichContent(): $latestItem";
    }
  }

  @override
  PenStrokeTracker beginPaint(Offset position, NotePage page, int pageNumber) {
    if (_mattes.isEmpty) {
      return PositionTracker(this, position, page, null);
    }

    if (_currentPage != page && _status == _PenStatus.adjusting) {
      // remove adjusting from old page
      for (int i = 0; i < _adjustingPageItems!.length; ++i) {
        _removePageItem(_adjustingPageItems![i], _currentPage!.data);
      }
    }
    _currentPage = page; // fixme? or keep this mode?

    if (_latestPageNumber != pageNumber) {
      _changeStatus(_PenStatus.recommending);
    }
    _latestPageNumber = pageNumber;
    _latestPosition = position;

    switch (_status) {
      case _PenStatus.recommending:
        _changeStatus(_PenStatus.adjusting);
        break;
      case _PenStatus.adjusting:
        _repositionAdjustingPageItems();
        break;
      case _PenStatus.nothingToDo:
      // TODO: Handle this case.
    }

    triggerRepaint();
    return PositionTracker(this, position, page, updateLatestPosition);
  }

  void onUserConfirm() {
    final handlingList = _oneByOne ? [_handling!] : _mattes;
    final positions = _calculatePositions(handlingList);
    final List<pb.NotePageItem> confirmedItems = [];
    switch (_status) {
      case _PenStatus.recommending:
        assert(_adjustingPageItems == null);
        for (final (index, matte) in handlingList.indexed) {
          final item = _createPageItem(matte, _currentPage!, positions[index]);
          confirmedItems.add(item);
        }
        mattingManager.removeAll(handlingList);
        assert(_mattes.isEmpty || _mattes[_handlingIndex] == _handling); // updated by onMattingManagerChange from removeAll
        break;

      case _PenStatus.adjusting:
        assert(_adjustingPageItems != null);
        for (final item in _adjustingPageItems!) {
          // re-order as [latestItem] used in [_position] calculation
          _currentPage!.data.items.remove(item);
          _currentPage!.data.items.add(item);
          confirmedItems.add(item);
        }
        _changeStatus(_PenStatus.recommending);
        mattingManager.removeAll(handlingList);
        assert(_mattes.isEmpty || _mattes[_handlingIndex] == _handling); // updated by [onMattingManagerChange] from removeAll
        assert(_mattes.isNotEmpty || _status == _PenStatus.nothingToDo); // updated by [onMattingManagerChange] from removeAll

      case _PenStatus.nothingToDo:
        assert(false);
        break;
    }

    if (mattingManager.status == MattingStatus.isEmpty) {
      // maybe _mattes.isEmpty, if so, waiting MattingStatus.ing to allDone
      statusManager.finishPlaceMatte();
    }
    _latestPosition = null; // trigger [_position] calculation
    triggerRepaint();
    _currentPage!.triggerRepaint();

    bool isFirst = true;
    final capturedPage = _currentPage!;
    statusManager.historyStack.doo(() {
      if (isFirst) {
        isFirst = false;
        return;
      }
      // redo:
      for (final item in confirmedItems) {
        capturedPage.data.items.add(item);
      }
      capturedPage.triggerRepaint();
    }, () {
      // undo:
      for (final item in confirmedItems) {
        capturedPage.removeItem(item);
      }
      capturedPage.triggerRepaint();
    });
  }

  bool couldConfirm() => _status != _PenStatus.nothingToDo;

  Iterable<MattePaintItem> getItems(int pageNumber) {
    if (_status == _PenStatus.nothingToDo || pageNumber != _latestPageNumber) {
      return const [];
    }

    assert(_mattes.isNotEmpty);
    assert(_handling != null && _mattes.contains(_handling!) && _mattes.indexOf(_handling!) == _handlingIndex);

    final positions = _calculatePositions(_mattes);
    final results =
        List.filled(_mattes.length, (matte: _mattes.first, status: MatteStatus.adjusting, position: const Offset(0, 0), scale: _scale));
    for (final (index, matte) in _mattes.indexed) {
      results[index] =
          (matte: matte, status: _getMatteStatus(!_oneByOne || _handlingIndex == index), position: positions[index], scale: _scale);
    }

    logDebug("getItems return: $results");
    return results;
  }

  void onMattingManagerChange() {
    _mattes = mattingManager.getMattes();

    switch (_status) {
      case _PenStatus.adjusting:
      case _PenStatus.recommending:
        if (_mattes.isEmpty) {
          _changeStatus(_PenStatus.nothingToDo);
        }
        break;

      case _PenStatus.nothingToDo:
        if (_mattes.isNotEmpty) {
          _changeStatus(_PenStatus.recommending);
        }
        break;
    }

    if (_mattes.isNotEmpty) {
      if (_handlingIndex == -1) {
        assert(_handling == null);
        assert(_status == _PenStatus.recommending);
        _handling = _mattes.first;
        _handlingIndex = 0;
      }

      final newIndex = _mattes.indexOf(_handling!);
      if (newIndex == -1 || _status == _PenStatus.recommending) {
        // keep _currentIndex
        while (_handlingIndex >= _mattes.length) {
          --_handlingIndex;
        }
        _handling = _mattes[_handlingIndex];
      } else if (_status == _PenStatus.adjusting) {
        // keep _current
        _handlingIndex = newIndex;
      } else {
        logError("Wrong status for MattePositionerPen");
      }
    } else {
      _mattes = const [];
      assert(_status == _PenStatus.nothingToDo);
      return;
    }

    triggerRepaint();
  }

  void triggerRepaint() {
    notifyListeners();
  }

  void updateLatestPosition(Offset position) {
    if (position == _latestPosition) {
      return;
    }
    _latestPosition = position;
    _repositionAdjustingPageItems();
    triggerRepaint();
  }

  void changeDirection(Axis axis) {
    _direction = axis;
    _repositionAdjustingPageItems();
    triggerRepaint();
    _currentPage!.triggerRepaint();
  }

  void _repositionAdjustingPageItems() {
    if (_status == _PenStatus.adjusting) {
      final items = _adjustingPageItems!;
      // final oldPositions = items.map((item) => Offset(item.x, item.y)).toList(growable: false);
      final positions = _calculatePositions(items.map((item) => _matteOfPageItem(item, _currentPage!.data)).toList(growable: false));
      final page = _currentPage!;
      for (final (index, item) in items.indexed) {
        // assert(item.x == oldPositions[index].dx && item.y == oldPositions[index].dy);
        final newPosition = positions[index];
        IndexableArea.itemBeforeUpdate(item, page); // todo: 性能是否ok? 避免在移动中重建索引？
        item.x = newPosition.dx;
        item.y = newPosition.dy;
        IndexableArea.itemAfterUpdated(item, page);
      }
    }
  }

  void toggleOneByOne() {
    _oneByOne = !_oneByOne;

    // todo: 翻页时手动onUserConfirm?，确保到下一页不会拿到错误的_currentPage
    if (_status == _PenStatus.adjusting) {
      if (_oneByOne) {
        // remove needless items
        for (int i = 1; i < _adjustingPageItems!.length; ++i) {
          _removePageItem(_adjustingPageItems![i], _currentPage!.data);
        }
        while (_adjustingPageItems!.length > 1) {
          _adjustingPageItems!.removeLast();
        }
      } else {
        // create extra items
        assert(_adjustingPageItems!.length == 1);
        assert(_handlingIndex == 0); // todo: 换序功能移到中转站的话，去掉_handlingIndex
        final positions = _calculatePositions(_mattes);
        for (int i = 1; i < _mattes.length; ++i) {
          _adjustingPageItems!.add(_createPageItem(_mattes[i], _currentPage!, positions[i]));
        }
      }
    }

    triggerRepaint();
    _currentPage!.triggerRepaint();
  }

  double? _scaleAdjustingStart;

  void beginAdjustScale() => _scaleAdjustingStart = _scale;

  void adjustScale(double diff) {
    _updateScale(_scaleAdjustingStart! - diff / 300);
  }

  void resetScale() {
    _updateScale(1.0);
  }

  void _updateScale(double value) {
    value = max(value, 0.01);
    _scale = value;

    if (_status == _PenStatus.adjusting) {
      for (final item in _adjustingPageItems!) {
        IndexableArea.itemBeforeUpdate(item, _currentPage!);
        if (_scale != 1.0) {
          item.scale = _scale;
        } else {
          item.clearScale();
        }
        IndexableArea.itemAfterUpdated(item, _currentPage!);
      }
      _repositionAdjustingPageItems();
    }

    triggerRepaint();
    _currentPage!.triggerRepaint();
  }

  double? _paddingAdjustingStart;

  void beginAdjustPadding() => _paddingAdjustingStart = _padding;

  void adjustPadding(double diff) {
    _padding = _paddingAdjustingStart! + diff / 10;
    _repositionAdjustingPageItems();
    triggerRepaint();
    _currentPage!.triggerRepaint();
  }

  MatteStatus _getMatteStatus(bool handling) {
    if (!handling) {
      return MatteStatus.waiting;
    }
    late MatteStatus result;
    switch (_status) {
      case _PenStatus.recommending:
        result = MatteStatus.recommended;
        break;
      case _PenStatus.adjusting:
        result = MatteStatus.adjusting;
        break;
      case _PenStatus.nothingToDo:
        assert(false);
        result = MatteStatus.done;
        break;
    }
    return result;
  }

  List<Offset> _calculatePositions(List<pb.Matte> mattes) {
    if (mattes.isEmpty) {
      return const [];
    }
    assert(_handlingIndex > -1 && _handlingIndex < mattes.length);

    final position = _position;
    Offset curPosition = position;
    final results = List.filled(mattes.length, curPosition);
    late Offset beforeHandling;
    for (final (index, matte) in mattes.indexed) {
      if (_handlingIndex == index) {
        assert(_handling == matte);
        beforeHandling = curPosition - position;
      }

      if (_direction == Axis.vertical) {
        // justify: left
        results[index] = curPosition;

        curPosition = Offset(curPosition.dx, curPosition.dy + matte.imageHeight * _scale + _padding);
      } else {
        // justify: bottom
        results[index] = Offset(curPosition.dx, curPosition.dy + _handling!.imageHeight * _scale - matte.imageHeight * _scale);

        curPosition = Offset(curPosition.dx + matte.imageWidth * _scale + _padding, curPosition.dy);
      }
    }
    if (_handlingIndex != 0) {
      for (final (index, cur) in results.indexed) {
        results[index] = cur - beforeHandling;
      }
    }
    return results;
  }

  void _changeStatus(_PenStatus status) {
    switch (status) {
      case _PenStatus.recommending:
        _adjustingPageItems = null;
        break;

      case _PenStatus.adjusting:
        assert(_status == _PenStatus.recommending);
        assert(_adjustingPageItems == null);
        assert(_latestPosition != null);
        assert(_currentPage != null);
        if (_oneByOne) {
          final matte = _handling!;
          _adjustingPageItems = [_createPageItem(matte, _currentPage!, _latestPosition!)];
        } else {
          final positions = _calculatePositions(_mattes);
          _adjustingPageItems = [];
          for (final (index, matte) in _mattes.indexed) {
            _adjustingPageItems!.add(_createPageItem(matte, _currentPage!, positions[index]));
          }
        }
        break;

      case _PenStatus.nothingToDo:
        _handling = null;
        _handlingIndex = -1;
        _latestPosition = null;
        _adjustingPageItems = null;
        break;
    }
    _status = status;
    triggerRepaint();
  }

  pb.NotePageItem _createPageItem(pb.Matte matte, NotePage page, Offset position) {
    if (matte.bookPath == fileSystemProxy.localPath(statusManager.reading!)) {
      logDebug("same book, clear: ${matte.bookPath}");
      matte.clearBookPath(); // same book, save space
    }

    final id = ++page.data.independentNoteData.lastMatteId;
    page.data.independentNoteData.mattePool[id] = matte;
    final result = pb.NotePageItem()
      ..x = position.dx
      ..y = position.dy
      ..matteId = id;
    if (_scale != 1.0) {
      result.scale = _scale;
    }
    page.data.items.add(result);

    IndexableArea.itemAdded(result, page);
    return result;
  }

  void _removePageItem(pb.NotePageItem item, pb.NotePage pbPage) {
    assert(item.whichContent() == pb.NotePageItem_Content.matteId);
    int id = item.matteId;
    IndexableArea.itemRemoved(item, _currentPage!); //  must before mattePool.remove, otherwise cannot construct boundingBoxOfItem
    final removed = pbPage.independentNoteData.mattePool.remove(id);
    assert(removed != null);
    final removeIdSuccess = pbPage.items.remove(item);
    assert(removeIdSuccess);
  }

  pb.Matte _matteOfPageItem(pb.NotePageItem item, pb.NotePage pbPage) => pbPage.independentNoteData.mattePool[item.matteId]!;
}
