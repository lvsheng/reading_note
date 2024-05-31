import 'dart:math';
import 'dart:ui';
import 'package:reading_note/pen/pen_stroke_tracker.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import '../status_manager/matting_manager.dart';

class MattingMarkGenerator extends PenStrokeTracker {
  late final int _markId;
  late final pb.MattingMark _mark;
  late final pb.NotePageItem _drawingItem;

  MattingMarkGenerator(super.pen, super.startPosition, super.page, super.pbPage);

  @override
  void start(Offset position) {
    _markId = ++pbPage.markNoteData.lastMattingMarkId;
    _mark = pbPage.markNoteData.mattingMarkPool[_markId] = pb.MattingMark()..horizontal = pb.MattingMarkHorizontal();
    _updateMarkPosition(position.dx, position.dx, position.dy, pen.lineWidth);
    pbPage.items.add(_drawingItem = pb.NotePageItem()
      ..x = position.dx
      ..y = position.dy
      ..mattingMarkId = _markId);
  }

  @override
  void move(Offset position) => _updateMarkPosition(_drawingItem.x, position.dx, position.dy, pen.lineWidth);

  @override
  bool stop() {
    mattingManager.startOne(_mark, _markId, page.noteBook.document, page.pageNumber);
    return true;
  }

  void _updateMarkPosition(double startX, double nowX, double nowY, double height) {
    _mark.horizontal
      ..left = min(startX, nowX)
      ..right = max(startX, nowX)
      ..y = nowY
      ..height = height;
  }
}
