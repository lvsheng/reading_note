import 'dart:math';
import 'dart:ui';
import 'package:reading_note/pen/pen_stroke_tracker.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/util/log.dart';
import '../status_manager/matting_manager.dart';

class MattingMarkGenerator extends PenStrokeTracker {
  late final int _markId;
  late final pb.MattingMark _mark;
  late final pb.NotePageItem _drawingItem;
  Offset _latestPosition = const Offset(0, 0);

  MattingMarkGenerator(super.pen, super.startPosition, super.page);

  @override
  void start(Offset position) {
    _markId = ++page.data.markNoteData.lastMattingMarkId;
    _mark = page.data.markNoteData.mattingMarkPool[_markId] = pb.MattingMark()..horizontal = pb.MattingMarkHorizontal();
    _updateMarkPosition(position.dx, position.dx, position.dy, pen.lineWidth);
    page.data.items.add(_drawingItem = pb.NotePageItem()
      ..x = position.dx
      ..y = position.dy
      ..mattingMarkId = _markId);
    _latestPosition = position;
  }

  @override
  bool stop() {
    mattingManager.startOne(_mark, _markId, page);
    return true;
  }

  @override
  void move(Offset position) {
    double diffY = position.dy - _drawingItem.y;
    _updateMarkPosition(_drawingItem.x, position.dx, _drawingItem.y + diffY / 3, pen.lineWidth);
    _latestPosition = position;
  }

  void _updateMarkPosition(double startX, double nowX, double nowY, double height) {
    _mark.horizontal
      ..left = min(startX, nowX)
      ..right = max(startX, nowX)
      ..y = nowY
      ..height = height;
  }

  // for control pannel : todo: diverse the interface
  double? _heightAdjustingStart;
  void startAdjustHeight() => _heightAdjustingStart = _mark.horizontal.height;
  void adjustHeight(double increment) {
    if (frozen) return;
    final h = _mark.horizontal;
    _updateMarkPosition(h.left, h.right, h.y, pen.lineWidth = _heightAdjustingStart! + increment / 10);
    page.triggerRepaint();
  }

  double? _leftAdjustingStart;
  void startAdjustLeft() => _leftAdjustingStart = _drawingItem.x;
  void adjustLeft(double increment) {
    if (frozen) return;
    _drawingItem.x = _leftAdjustingStart! + increment / 10;
    move(_latestPosition);
    page.triggerRepaint();
  }
}
