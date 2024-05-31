import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:reading_note/pen/matting_mark_generator.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';
import 'package:reading_note/pdf_matting_performer.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';
import '../note_page/independent_note_page.dart';
import '../note_page/mark_note_page.dart';
import '../note_page/note_page.dart';
import 'coordinate_converter.dart';

typedef _ItemPainter = int Function(Canvas canvas, pb.NotePageItem item, int index, int length);

const _logging = false;

class PageItemsPainter extends CustomPainter {
  @protected
  final NotePage page;

  late Tuple2<int /*penId*/, Paint> _lastPenPaint;
  final CoordConverter _coordinateConverter;
  final List<_ItemPainter?> _itemPainters = List.filled(pb.NotePageItem_Content.values.length, null);

  PageItemsPainter(this.page, this._coordinateConverter) : super(repaint: page) {
    _lastPenPaint = Tuple2(
        0,
        Paint()
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
    _updatePenIfNeeded(page.defaultPenId, page.getPen(page.defaultPenId), true);
    _itemPainters[pb.NotePageItem_Content.path.index] = _paintPath;
    _itemPainters[pb.NotePageItem_Content.mattingMarkId.index] = _paintMattingMark;
    _itemPainters[pb.NotePageItem_Content.matteId.index] = _paintMatte;
  }

  @override
  void paint(Canvas canvas, Size size) {
    int ts = DateTime.now().millisecondsSinceEpoch;
    int countPoints = 0;

    page.forEachPageItem((item, index, length) {
      _itemPainters[item.whichContent().index]!(canvas, item, index, length);
    });

    _logging &&
        logInfo("[StylusGesture] _paintDrawingData end. countPoints:$countPoints cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }

  int _paintPath(Canvas canvas, pb.NotePageItem item, int index, int length) {
    final path = item.path;
    _updatePenIfNeeded(path.penId, page.getPen(path.penId));
    final points = path.points
        .map((point) => _coordinateConverter.pagePositionToCanvas(pb.Point(x: point.x + item.x, y: point.y + item.y)))
        .toList(growable: false);
    canvas.drawPoints(PointMode.polygon, points, _lastPenPaint.item2);
    return points.length;
  }

  int _paintMattingMark(Canvas canvas, pb.NotePageItem item, int index, int length) {
    final mattingMark = (page as MarkNotePage).mattingMarkOfId(item.mattingMarkId);
    if (mattingMark == null) {
      logError("disappeared mattingMark ${item.mattingMarkId}");
      return 0;
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
        _coordinateConverter.pageRectToCanvas(rect),
        Paint()
          ..color = CupertinoColors.systemYellow.withAlpha(125)
          ..style = PaintingStyle.fill);

    final drawingPen = statusManager.drawingPen;
    final ongoingTracker = drawingPen?.ongoingTracker;
    bool notEditing = index < length - 1 ||
        ongoingTracker is! MattingMarkGenerator ||
        statusManager.drawingPage != page ||
        ongoingTracker.frozen;
    if (notEditing) {
      canvas.drawRect(
          _coordinateConverter.pageRectToCanvas(rect),
          Paint()
            ..color = CupertinoColors.darkBackgroundGray
            ..style = PaintingStyle.stroke
            ..strokeWidth = _coordinateConverter.pageWidthToCanvas(0.3));
    }
    return 1;
  }

  int _paintMatte(Canvas canvas, pb.NotePageItem item, int index, int length) {
    final matte = (page as IndependentNotePage).matteOfId(item.matteId);
    if (matte == null) {
      logError("disappeared matte: ${item.matteId} for $page");
      return 0;
    }
    final tuple = imageOfMatte(matte);
    final image = tuple.item1;
    if (image == null) {
      logWarn("matte image not ready, wait it");
      tuple.item2!.then((_) => page.triggerRepaint());
      return 0;
    }
    canvas.drawImage(image, _coordinateConverter.pageOffsetToCanvas(Offset(item.x, item.y)), Paint());
    return 1;
  }

  void _updatePenIfNeeded(int penId, pb.Pen pen, [bool force = false]) {
    if (!force && penId == _lastPenPaint.item1) {
      return;
    }

    _lastPenPaint = Tuple2(
        penId,
        _lastPenPaint.item2
          ..color = Color(pen.color)
          ..strokeWidth = _coordinateConverter.pageWidthToCanvas(pen.lineWidth));
  }

  @override
  bool shouldRepaint(PageItemsPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(PageItemsPainter oldDelegate) => false;
}
