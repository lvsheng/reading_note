import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';
import 'package:reading_note/status_manager/matting_manager.dart';

import 'note_page.dart';

class MarkNotePage extends NotePage {
  MarkNotePage(super.pageNumber, super.noteBook, super.data, super.file);

  Offset canvasPositionToPagePosition(Offset localPosition, Rect pageRect) {
    Offset result = Offset(localPosition.dx / pageRect.width, localPosition.dy / pageRect.height);
    return result = Offset(result.dx * data.width, result.dy * data.height);
  }

  Offset pagePositionToCanvas(pb.Point pagePosition, Rect pageRect) {
    Offset result = Offset(pagePosition.x / data.width, pagePosition.y / data.height);
    return result = Offset(result.dx * pageRect.width, result.dy * pageRect.height);
  }

  double pageWidthToCanvas(double v, Rect pageRect) => v / data.width * pageRect.width;

  double _pageHeightToCanvas(double v, Rect pageRect) => v / data.height * pageRect.height;

  Rect pageRectToCanvas(Rect rect, Rect pageRect) => Rect.fromLTRB(pageWidthToCanvas(rect.left, pageRect),
      _pageHeightToCanvas(rect.top, pageRect), pageWidthToCanvas(rect.right, pageRect), _pageHeightToCanvas(rect.bottom, pageRect));

  pb.MattingMark? mattingMarkOfId(int id) => data.markNoteData.mattingMarkPool[id];

  @visibleForTesting
  get mattingMarkPool => data.markNoteData.mattingMarkPool;

  @override
  bool endDraw() {
    if (!super.endDraw()) return false;

    final tuple = _addMattingMark();
    MattingManager.instanceOf(noteBook.book).startOne(tuple.item2, tuple.item1, noteBook.document, pageNumber);

    return true;
  }

  Tuple2<int, pb.MattingMark> _addMattingMark() {
    final drawingItem = data.items.last;
    final endPoint = drawingItem.path.points.last; // fixme
    final id = ++data.markNoteData.lastMattingMarkId;
    final startX = drawingItem.x;
    final endX = drawingItem.x + endPoint.x;
    final result = data.markNoteData.mattingMarkPool[id] = pb.MattingMark()
      ..horizontal = (pb.MattingMarkHorizontal()
        ..left = min(startX, endX)
        ..right = max(startX, endX)
        ..y = drawingItem.y + endPoint.y / 2
        ..height = (endPoint.y).abs());
    data.items.add(pb.NotePageItem()..mattingMarkId = id);
    triggerRepaint();
    return Tuple2(id, result);
  }

  @override
  bool check(Offset p) => p > const Offset(0, 0) && p < Offset(data.width, data.height);

  @override
  double get defaultPenWidth => 1.0;
}
