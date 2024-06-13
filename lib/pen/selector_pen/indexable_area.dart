import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:quiver/collection.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/util/log.dart';
import 'package:tuple/tuple.dart';
import '../../note_page/note_page.dart';

const _logging = true;

LruMap<String /*notebook meta path*/, LruMap<int /*pageId*/, IndexableArea>> _map = LruMap(maximumSize: 2);

extension PbPoint on pb.Point {
  bool insideRect(Rect rect, double startX, double startY) {
    final absoluteX = x + startX;
    final absoluteY = y + startY;
    return absoluteX >= rect.left && absoluteX <= rect.right && absoluteY >= rect.top && absoluteY <= rect.bottom;
  }
}

class ItemWrapper {
  pb.NotePageItem item;
  late Rect boundingBox;
  IndexableArea _belongedArea;

  set _selected(bool value) => item.selected = value;

  bool get _selected => item.selected; // still false if ancestor area is [_allSelected]

  ItemWrapper(this.item, this._belongedArea, pb.NotePage pbPage) {
    boundingBox = boundingBoxOfItem(item, pbPage);
    if (_logging) logDebug("got boundingBox: $boundingBox"); //, for item: $item");
  }

  static Rect boundingBoxOfItem(pb.NotePageItem item, pb.NotePage pbPage) {
    late Rect result;
    switch (item.whichContent()) {
      case pb.NotePageItem_Content.path:
        result = _rectOfPath(item);
        break;
      case pb.NotePageItem_Content.mattingMarkId:
        result = _rectOfMatting(item, pbPage);
        break;
      case pb.NotePageItem_Content.matteId:
        result = _rectOfMatte(item, pbPage);
        break;
      case pb.NotePageItem_Content.notSet:
        assert(false);
    }
    return result;
  }

  static Rect _rectOfPath(pb.NotePageItem item) {
    final startX = item.x, startY = item.y;
    double minX = 0, minY = 0, maxX = 0, maxY = 0;
    for (final p in item.path.points) {
      minX = min(p.x, minX);
      maxX = max(p.x, maxX);
      minY = min(p.y, minY);
      maxY = max(p.y, maxY);
    }

    if (item.hasScale()) {
      minX *= item.scale;
      maxX *= item.scale;
      minY *= item.scale;
      maxY *= item.scale;
    }

    return Rect.fromLTRB(startX + minX, startY + minY, startX + maxX, startY + maxY);
  }

  static Rect _rectOfMatting(pb.NotePageItem item, pb.NotePage pbPage) {
    assert(!item.hasScale());
    final mattingMark = pbPage.markNoteData.mattingMarkPool[item.mattingMarkId]!;
    switch (mattingMark.whichContent()) {
      case pb.MattingMark_Content.horizontal:
        final halfHeight = mattingMark.horizontal.height / 2;
        return Rect.fromLTRB(mattingMark.horizontal.left, mattingMark.horizontal.y - halfHeight, mattingMark.horizontal.right,
            mattingMark.horizontal.y + halfHeight);

      case pb.MattingMark_Content.vertical:
      case pb.MattingMark_Content.line:
      case pb.MattingMark_Content.rectangle:
      case pb.MattingMark_Content.notSet:
        assert(false);
    }
    return Rect.zero;
  }

  static Rect _rectOfMatte(pb.NotePageItem item, pb.NotePage pbPage) {
    final matte = pbPage.independentNoteData.mattePool[item.matteId];
    if (matte == null) {
      logError("disappeared matte: $item");
      return Rect.fromLTWH(item.x, item.y, 30, 30);
    }

    Rect result = Rect.fromLTWH(item.x, item.y, matte.imageWidth.toDouble(), matte.imageHeight.toDouble());
    if (item.hasScale()) {
      result = Rect.fromLTWH(result.left, result.top, result.width * item.scale, result.height * item.scale);
      if (_logging) logDebug("item.hasScale: $item");
    }
    return result;
  }
}

typedef _HitCacheStack = List<Tuple2<Rect /*effect area*/, List<IndexableArea>>>;

/// cover the [left, right)~[top, bottom) area
class IndexableArea extends Rect {
  static const String _tag = "[IndexableArea]";

  static IndexableArea getOrCreate(NotePage page) {
    final book = _map[page.noteBook.metaFile.path] ??= LruMap(maximumSize: 50);
    final pageArea = book[page.pageNumber] ??= IndexableArea.forPage(page);

    return pageArea;
  }

  static void itemAdded(pb.NotePageItem item, NotePage page) {
    if (item.whichContent() == pb.NotePageItem_Content.mattingMarkId) return;
    final pageArea = _map[page.noteBook.metaFile.path]?[page.pageNumber];
    if (pageArea == null) {
      logDebug("pageArea not found!: $page");
      return;
    }
    logDebug("itemAdded: $item $page");
    pageArea._addItem(ItemWrapper(item, pageArea, page.data));
  }

  static void itemRemoved(pb.NotePageItem item, NotePage page) {
    if (item.whichContent() == pb.NotePageItem_Content.mattingMarkId) return;
    final pageArea = _map[page.noteBook.metaFile.path]?[page.pageNumber];
    if (pageArea == null) {
      logDebug("pageArea not found! $page");
      return;
    }
    pageArea._removeItem(ItemWrapper(item, pageArea, page.data));
  }

  static void itemBeforeUpdate(pb.NotePageItem item, NotePage page) {
    if (item.whichContent() == pb.NotePageItem_Content.mattingMarkId) return;
    itemRemoved(item, page);
  }

  static void itemAfterUpdated(pb.NotePageItem item, NotePage page) {
    if (item.whichContent() == pb.NotePageItem_Content.mattingMarkId) return;
    itemAdded(item, page);
  }

  final NotePage _page;
  final List<ItemWrapper> _items = [];
  bool _itemsSorted = false;
  List /*rows*/ <List< /*columns*/ IndexableArea>>? _subAreas;
  double _subAreaWidth = 0;
  double _subAreaRedundantRate = 0;
  bool _doNotSplitSubAreas = false;
  _HitCacheStack? _hitCacheStack;
  bool allSelected = false;

  @visibleForTesting
  IndexableArea.forPage(this._page) : super.fromLTRB(0, 0, _page.data.width, _page.data.height) {
    final ts = DateTime.timestamp();
    _items.addAll(_page.data.items
        .where((item) => item.whichContent() != pb.NotePageItem_Content.mattingMarkId)
        .map((i) => ItemWrapper(i, this, _page.data)));
    logInfo("$_tag construct _items: count:${_items.length} cost:${DateTime.timestamp().difference(ts).inMilliseconds}ms");
    _splitSubAreasIfNeed();
  }

  IndexableArea(this._page, super.left, super.top, super.right, super.bottom) : super.fromLTRB();

  void _addItem(ItemWrapper item, [bool movedFromParentItems = false]) {
    assert(item._belongedArea == this);
    if (_logging) logDebug("_addItem ${item.boundingBox} into $this");
    if (_subAreas == null) {
      if (_itemsSorted) {
        int index = _items.length;
        for (final (i, each) in _items.indexed) {
          if (item.boundingBox.left <= each.boundingBox.left) {
            index = i;
            break;
          }
        }
        _items.insert(index, item);
      } else {
        _items.add(item);
      }
      return;
    }
    assert(!movedFromParentItems);
    _addItemIntoSubArea(item);
  }

  void _removeItem(ItemWrapper wrapper) {
    if (_subAreas == null) {
      _items.removeWhere((each) => wrapper.item == each.item);
      return;
    }
    _removeItemFromSubArea(wrapper);
  }

  static const _splitThresholdForItemCount = 100; // todo: choose a real value

  void _splitSubAreasIfNeed() {
    if (_subAreas != null) return;
    if (_doNotSplitSubAreas) return;

    final ts = DateTime.timestamp();
    final countItems = _items.length;
    if (countItems < _splitThresholdForItemCount) {
      return;
    }

    _initSubAreas();
    _moveItemsIntoSubAreas();
    const subAreaRedundantRateThreshold = 1.5;
    if (_subAreaRedundantRate > subAreaRedundantRateThreshold) {
      // To avoid unnecessary infinite subdivision by only looking at countItems (e.g., extreme case: numerous lines converging at a single point)
      for (final row in _subAreas!) {
        for (final subArea in row) {
          subArea._doNotSplitSubAreas = true;
        }
      }
    }

    if (_logging) {
      logInfo("$_tag _tryDivideSubAreas: countItems:$countItems cost:${DateTime.timestamp().difference(ts).inMilliseconds}ms");
    }
  }

  void _initSubAreas() {
    assert(_subAreas == null);
    _subAreas = [];

    const countColumns = 8;
    _subAreaWidth = width / countColumns;
    for (double t = top; t <= bottom; t += _subAreaWidth) {
      double b = t + _subAreaWidth;

      final List<IndexableArea> columns = [];
      for (double l = left; l <= right; l += _subAreaWidth) {
        double r = l + _subAreaWidth;
        final subArea = IndexableArea(_page, l, t, r, b);
        columns.add(subArea);
      }

      _subAreas!.add(columns);
    }
    if (_logging) {
      logInfo("$_tag _initSubAreas: ${_subAreas!.length}*${_subAreas!.first.length} unit-size:$_subAreaWidth this:$this width:$width");
      logDebug("  ${_subAreas!.first.first} ~ ${_subAreas!.last.last}");
    }
  }

  void _moveItemsIntoSubAreas() {
    assert(_subAreas != null);
    for (final item in _items) {
      _addItemIntoSubArea(item, true);
    }

    final cItems = _items.length;
    final cItemsInSubAreas = _countItemsInSubAreas();
    assert(_subAreaRedundantRate == 0);
    _subAreaRedundantRate = cItemsInSubAreas / cItems;
    if (_logging) {
      logDebug(
          "_moveItemsIntoSubAreas: redundant-rate:${cItemsInSubAreas / cItems} items.length:$cItems subArea.itemsCount:$cItemsInSubAreas");
    }
    _items.clear();
  }

  int _countItemsInSubAreas() {
    // if (_subAreas == null) return _items.length;
    assert(_subAreas != null);
    int c = 0;
    for (final row in _subAreas!) {
      for (final subArea in row) {
        assert(subArea._subAreas == null);
        c += subArea._items.length;
        // c += subArea._countItemsInSubAreas();
      }
    }
    return c;
  }

  void _addItemIntoSubArea(ItemWrapper item, [bool fromItems = false]) {
    final box = item.boundingBox;
    final intersectedSubAreas = _getIntersectedSubAreas(box);
    if (_logging) logDebug("_addItemIntoSubArea intersectedSubAreas.length: ${intersectedSubAreas.length}");
    for (final targetArea in intersectedSubAreas) {
      targetArea._addItem(item.._belongedArea = targetArea, fromItems);
    }
  }

  void _removeItemFromSubArea(ItemWrapper item) {
    final box = item.boundingBox;
    final intersectedSubAreas = _getIntersectedSubAreas(box);
    if (_logging) logDebug("_removeItemFromSubArea intersectedSubAreas.length: ${intersectedSubAreas.length}");
    for (final targetArea in intersectedSubAreas) {
      targetArea._removeItem(item);
    }
  }

  Iterable<IndexableArea> _getIntersectedSubAreas(Rect target) sync* {
    assert(_subAreas != null);
    assert(target.intersect(this).width >= 0 && target.intersect(this).height >= 0);
    if (_logging) logDebug("_getIntersectedSubAreas fro $target in $this");

    final insideRect = Rect.fromLTWH(target.left - left, target.top - top, target.width, target.height);
    final int startColIndex = (insideRect.left / _subAreaWidth).floor();
    final int endColIndex = (insideRect.right / _subAreaWidth).floor();
    final int startRowIndex = (insideRect.top / _subAreaWidth).floor();
    final int endRowIndex = (insideRect.bottom / _subAreaWidth).floor();
    final int s = max(startRowIndex, 0);
    final int e = min(endRowIndex, _subAreas!.length - 1);
    for (int i = s; i <= e; ++i) {
      final row = _subAreas![i];
      for (int j = startColIndex; j <= endColIndex; ++j) {
        if (j < 0) continue;
        assert(j <= row.length);
        if (j == row.length) break;

        yield row[j];
        if (_logging) logDebug("  yield:${row[j]} i:$i s:$startRowIndex e:$endRowIndex j:$j s:$startColIndex e:$endColIndex from $this");
      }
    }
  }

  Iterable<Object /*pb.NotePageItem or IndexableArea*/ > select(Rect targetArea, [_HitCacheStack? cache]) sync* {
    if (allSelected) return;

    final ts = DateTime.timestamp();
    cache ??= _hitCacheStack ??= [];
    // todo: search cache first

    final effectTarget = intersect(targetArea);
    if (effectTarget.width < 0 || effectTarget.height < 0) {
      return;
    }

    if (effectTarget == this) {
      allSelected = true;
      yield this;
      if (_logging) logDebug("$_tag select(hit all). cost:${DateTime.timestamp().difference(ts).inMilliseconds}ms");
      return;
    }

    // todo: merge the split/sort into current iterate (only one level, not recursively), keep O(n)? or the recursive O(n*log(n)) is ok on user first tap?
    _splitSubAreasIfNeed();

    if (_subAreas != null) {
      for (final area in _getIntersectedSubAreas(effectTarget)) {
        yield* area.select(effectTarget, cache);
      }
      if (_logging) logDebug("$_tag select(proxy to subAreas). cost:${DateTime.timestamp().difference(ts).inMilliseconds}ms");
      return;
    }

    _sortItemsIfNeed();
    if (_logging) logDebug("$_tag select. sort(${_items.length}) cost:${DateTime.timestamp().difference(ts).inMilliseconds}ms");

    for (final wrapper in _items) {
      if (wrapper._selected || wrapper.item.deleted) continue;

      final itemRect = wrapper.boundingBox;
      if (itemRect.left > effectTarget.right) break;
      if (itemRect.right < effectTarget.left) continue;
      if (itemRect.bottom < effectTarget.top) continue;
      if (itemRect.top > effectTarget.bottom) continue;

      final item = wrapper.item;
      bool hit = false;
      switch (item.whichContent()) {
        case pb.NotePageItem_Content.path:
          for (var point in item.path.points) {
            if (item.hasScale()) {
              final scale = item.scale;
              point = pb.Point(x: point.x * scale, y: point.y * scale);
            }
            if (point.insideRect(effectTarget, item.x, item.y)) {
              hit = true;
              break;
            }
          }
          break;

        case pb.NotePageItem_Content.mattingMarkId:
        case pb.NotePageItem_Content.matteId:
          hit = true;
          break;

        case pb.NotePageItem_Content.notSet:
          assert(false);
      }

      if (hit) {
        wrapper._selected = true;
        yield item;
      }
    }
    if (_logging) logDebug("$_tag select. total cost:${DateTime.timestamp().difference(ts).inMilliseconds}ms");
  }

  void _sortItemsIfNeed() {
    assert(_subAreas == null);
    if (_itemsSorted) return;
    _itemsSorted = true;
    _items.sort((a, b) => a.boundingBox.left > b.boundingBox.left ? 1 : -1);
  }

  int _iterateId = 0;

  Iterable<pb.NotePageItem> iterateAllItems(int iterateId) sync* {
    if (_iterateId == iterateId) {
      if (_logging) logInfo("repeated iterate on $this, ignore it"); // todo: reproduce the issue
      return;
    }
    _iterateId = iterateId;

    if (_subAreas == null) {
      for (final wrapper in _items) {
        if (wrapper.item.iterateId == iterateId) {
          if (_logging) logInfo("repeated iterate on $wrapper, ignore it"); // todo: reproduce the issue
          continue;
        }
        wrapper.item.iterateId = _iterateId;
        if (wrapper.item.deleted) continue;
        yield wrapper.item;
      }
      return;
    }

    for (final row in _subAreas!) {
      for (final area in row) {
        yield* area.iterateAllItems(iterateId);
      }
    }
  }
}
