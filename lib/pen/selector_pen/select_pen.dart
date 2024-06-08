import 'package:flutter/cupertino.dart';
import 'package:reading_note/pen/pen.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/selector_pen/indexable_area.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';

import '../../note_page/note_page.dart';
import '../../protobuf/note.pb.dart' as pb;
import '../pen_stroke_tracker.dart';

/// not visible to [PenManager], added automatically by [StatusManager] if needed
class SelectPen extends Pen with ChangeNotifier {
  NotePage? page;
  Offset? touchingOn;
  List<pb.NotePageItem> selected = [];
  IndexableArea? _indexableArea;

  SelectPen(NoteType noteType, int pageNumber) : super(-1, PenType.selectPen, material.Colors.black, 30) {
    statusManager.waitNotePage(noteType, pageNumber, _onNotePage);
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

  @override
  PenStrokeTracker beginPaint(Offset position, NotePage page, int pageNumber) {
    return PositionTracker(this, position, page, (position) {
      touchingOn = position;
      int ts = DateTime.now().millisecondsSinceEpoch;
      final result = IndexableArea.getOrCreate(page).select(Rect.fromCenter(center: position, width: lineWidth, height: lineWidth));
      selected.addAll(result);
      _triggerRepaint();
      logDebug("selected: new:${result.length} total:${selected.length} position:$position lineWidth:$lineWidth cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
    });
  }

  @override
  void endPaint() {
    touchingOn = null;
    _triggerRepaint();
  }

  void _onNotePage(NotePage page) {
    _indexableArea = IndexableArea.getOrCreate(this.page = page);
    logDebug("_indexableArea: $_indexableArea");
  }

  void _triggerRepaint() {
    notifyListeners();
  }
}
