import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';

import 'note_page.dart';

abstract class NotePainter extends CustomPainter {
  final NotePage _note;
  late Tuple2<int /*penId*/, Paint> _lastPaint;

  NotePainter(this._note) : super(repaint: _note) {
    _lastPaint = Tuple2(
        0,
        Paint()
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    _updatePenIfNeeded(_note.defaultPenId, _note.getPen(_note.defaultPenId), true);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintDrawingData(canvas);
  }

  _paintDrawingData(Canvas canvas) {
    int ts = DateTime.now().millisecondsSinceEpoch;
    int countPoints = 0;

    _note.forEachPageItem((item) {
      switch (item.whichContent()) {
        case pb.NotePageItem_Content.path:
          final path = item.path;
          _updatePenIfNeeded(path.penId, _note.getPen(path.penId));
          final points = path.points.map((point) => pagePositionToCanvasPosition(point)).toList(growable: false);
          countPoints += points.length;
          canvas.drawPoints(PointMode.polygon, points, _lastPaint.item2);
          break;

        default:
          throw "TODO";
      }
    });

    logDebug("[StylusGesture] _paintDrawingData end. countPoints:$countPoints cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }

  void _updatePenIfNeeded(int penId, pb.Pen pen, [bool force = false]) {
    if (!force && penId == _lastPaint.item1) {
      return;
    }

    _lastPaint = Tuple2(
        penId,
        _lastPaint.item2
          ..color = Color(pen.color)
          ..strokeWidth = pageWidthToCanvasWidth(pen.strokeWidth));
  }

  double pageWidthToCanvasWidth(double v);

  Offset pagePositionToCanvasPosition(pb.Point pagePosition);

  @override
  bool shouldRepaint(NotePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(NotePainter oldDelegate) => false;
}

class MarkNotePainter extends NotePainter {
  final Rect _pageRect;

  MarkNotePainter(this._pageRect, super.note);

  @override
  double pageWidthToCanvasWidth(double v) => (_note as MarkNotePage).pageWidthToCanvasWidth(v, _pageRect);

  @override
  Offset pagePositionToCanvasPosition(pb.Point pagePosition) =>
      (_note as MarkNotePage).pagePositionToCanvasPosition(pagePosition, _pageRect);
}

class IndependentNotePainter extends NotePainter {
  double _scale = 1.0;

  IndependentNotePainter(super.note);

  set scale(double value) => _scale = value;

  @override
  Offset pagePositionToCanvasPosition(pb.Point pagePosition) =>
      (_note as IndependentNotePage).pagePositionToCanvasPosition(pagePosition, _scale);

  @override
  double pageWidthToCanvasWidth(double v) => (_note as IndependentNotePage).pageWidthToCanvasWidth(v, _scale);
}
