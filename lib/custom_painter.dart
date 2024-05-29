import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/pdf_matting_util.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';

import 'note_page.dart';

abstract class NotePainter extends CustomPainter {
  final NotePage _note;
  late Tuple2<int /*penId*/, Paint> _lastPenPaint;
  static Paint? _markResultPaint;

  NotePainter(this._note) : super(repaint: _note) {
    _lastPenPaint = Tuple2(
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
          final points =
              path.points.map((point) => pagePositionToCanvas(pb.Point(x: point.x + item.x, y: point.y + item.y))).toList(growable: false);
          countPoints += points.length;
          canvas.drawPoints(PointMode.polygon, points, _lastPenPaint.item2);
          break;

        case pb.NotePageItem_Content.mattingMarkId:
          final mattingMark = (_note as MarkNotePage).getMattingMark(item.mattingMarkId);
          if (mattingMark == null) {
            logError("disappeared mattingMark ${item.mattingMarkId}");
            return;
          }
          late Rect rect;
          switch (mattingMark.whichContent()) {
            case pb.MattingMark_Content.horizontal:
              final halfHeight = mattingMark.horizontal.height / 2;
              rect = Rect.fromLTRB(mattingMark.horizontal.left, mattingMark.horizontal.y - halfHeight, mattingMark.horizontal.right,
                  mattingMark.horizontal.y + halfHeight);
              break;
            default:
              throw "TODO";
          }

          canvas.drawRect(
              pageRectToCanvas(rect),
              Paint()
                ..color = Colors.yellowAccent.withAlpha(125)
                ..style = PaintingStyle.fill);
          canvas.drawRect(
              pageRectToCanvas(rect),
              Paint()
                ..color = Colors.black87
                ..style = PaintingStyle.stroke
                ..strokeWidth = pageWidthToCanvas(1));
          break;

        case pb.NotePageItem_Content.mattingResultId:
          final mattingResult = (_note as IndependentNotePage).getMattingResult(item.mattingResultId);
          if (mattingResult == null) {
            logError("disappeared mattingResult: ${item.mattingResultId} for $_note");
            return;
          }
          final tuple = imageOfMattingResult(mattingResult);
          final image = tuple.item1;
          if (image == null) {
            logWarn("matting image not ready, wait it");
            tuple.item2!.then((_) => _note.triggerRepaint());
            return;
          }
          canvas.drawImage(image, pageOffsetToCanvas(Offset(item.x, item.y)), Paint());
        default:
          throw "TODO";
      }
    });

    logInfo("[StylusGesture] _paintDrawingData end. countPoints:$countPoints cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }

  void _updatePenIfNeeded(int penId, pb.Pen pen, [bool force = false]) {
    if (!force && penId == _lastPenPaint.item1) {
      return;
    }

    _lastPenPaint = Tuple2(
        penId,
        _lastPenPaint.item2
          ..color = Color(pen.color)
          ..strokeWidth = pageWidthToCanvas(pen.strokeWidth));
  }

  double pageWidthToCanvas(double v);

  Offset pagePositionToCanvas(pb.Point pagePosition);

  Rect pageRectToCanvas(Rect rect);

  Offset pageOffsetToCanvas(Offset pageOffset);

  @override
  bool shouldRepaint(NotePainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(NotePainter oldDelegate) => false;
}

class MarkNotePainter extends NotePainter {
  final Rect _pageRect;

  MarkNotePainter(this._pageRect, super.note);

  @override
  double pageWidthToCanvas(double v) => (_note as MarkNotePage).pageWidthToCanvas(v, _pageRect);

  @override
  Offset pagePositionToCanvas(pb.Point pagePosition) => (_note as MarkNotePage).pagePositionToCanvas(pagePosition, _pageRect);

  @override
  Rect pageRectToCanvas(Rect rect) => (_note as MarkNotePage).pageRectToCanvas(rect, _pageRect);

  @override
  Offset pageOffsetToCanvas(Offset offset) {
    // TODO: implement pageOffsetToCanvas
    throw UnimplementedError();
  }
}

class IndependentNotePainter extends NotePainter {
  double _scale = 1.0;

  IndependentNotePainter(super.note);

  set scale(double value) => _scale = value;

  @override
  Offset pagePositionToCanvas(pb.Point pagePosition) => (_note as IndependentNotePage).pagePositionToCanvas(pagePosition, _scale);

  @override
  double pageWidthToCanvas(double v) => (_note as IndependentNotePage).pageWidthToCanvas(v, _scale);

  @override
  Rect pageRectToCanvas(Rect pageRect) {
    // TODO: implement pageRectToCanvas
    throw UnimplementedError();
  }

  @override
  Offset pageOffsetToCanvas(Offset pageOffset) => (_note as IndependentNotePage).pageOffsetToCanvas(pageOffset, _scale);
}
