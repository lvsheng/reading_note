import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/custom_painter/paint_matte.dart';
import 'package:reading_note/pen/matting_mark_generator.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';
import '../note_page/independent_note_page.dart';
import '../note_page/mark_note_page.dart';
import '../note_page/note_page.dart';
import 'coordinate_converter.dart';

typedef _ItemPainter = int Function(Canvas canvas, pb.NotePageItem item, int indexForMattingMark, int lengthForMattingMark,
    [bool isSelected]);

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

    final List<pb.NotePageItem> failedItems = [];
    page.forEachPageItem((item, index, length) {
      if (item.deleted) return;
      final painted = _itemPainters[item.whichContent().index]!(canvas, item, index, length);
      if (painted == 0) failedItems.add(item);
      countPoints += painted;
    });

    if (_logging) {
      logInfo("[StylusGesture] _paintDrawingData end. countPoints:$countPoints cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
    }
    // if (failedItems.isNotEmpty) {
    //   logError("failedItems: $failedItems", false);
    // failedItems.forEach(page.removeItem); // just used to clean dirty data. will remove just-start-painting items, don't de-comment it
    // }
  }

  /// for [SelectPenPainter]
  void paintSelectedItem(Canvas canvas, pb.NotePageItem item) {
    assert(item.whichContent() != pb.NotePageItem_Content.mattingMarkId);
    _itemPainters[item.whichContent().index]!(canvas, item, 0, 0, true);
  }

  int _paintPath(Canvas canvas, pb.NotePageItem item, int _, int __, [bool isSelected = false]) {
    _updatePenIfNeeded(item.path.penId, page.getPen(item.path.penId));

    var points = item.path.points;
    if (item.hasScale()) {
      final scale = item.scale;
      points = points.map((p) => pb.Point(x: p.x * scale, y: p.y * scale)).toList(growable: false);
    }

    return _paintPoints(
        canvas,
        points
            .map((point) => _coordinateConverter.pagePositionToCanvas(pb.Point(x: point.x + item.x, y: point.y + item.y)))
            .toList(growable: false),
        isSelected);
  }

  int _paintPoints(Canvas canvas, List<Offset> points, bool isSelected) {
    // canvas.drawPoints(PointMode.polygon, points, _lastPenPaint.item2);
    // return points.length;

    if (points.isEmpty) {
      return 0;
    }

    final paint = _wrapSelectedPaintIfNeed(_lastPenPaint.item2, isSelected);
    if (points.length < 3) {
      canvas.drawPoints(PointMode.polygon, points, paint);
      return points.length;
    }

    final path = Path(); // TODO: Cache ui.Path for pb.Path
    path.moveTo(points[0].dx, points[0].dy);
    path.lineTo(points[1].dx, points[1].dy);

    if (points.length > 2) {
      path.moveTo(points[1].dx, points[1].dy);
      final l = points.length - 1;
      for (int i = 1; i < l; ++i) {
        final current = points[i];
        final next = points[i + 1];
        final centerX = (current.dx + next.dx) / 2;
        final centerY = (current.dy + next.dy) / 2;
        // TODO: Improve performance with large point sets. Consider using a shader to implement quadratic Bezier curves or rendering to an image like OneNote.
        //   https://www.shadertoy.com/view/MlKcDD
        path.quadraticBezierTo(current.dx, current.dy, centerX, centerY);
        path.moveTo(centerX, centerY);
      }
      canvas.drawPath(path, paint);
    }

    return points.length;
  }

  int _paintMattingMark(Canvas canvas, pb.NotePageItem item, int index, int length, [bool isSelected = false]) {
    final drawingPen = statusManager.drawingPen;
    final ongoingTracker = drawingPen?.ongoingTracker;
    bool editing =
        index == length - 1 && ongoingTracker is MattingMarkGenerator && statusManager.drawingPage == page && !ongoingTracker.frozen;
    if (!editing) return 0;

    assert(isSelected == false, "matting could not be selected");
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

    // draw fill
    canvas.drawRect(
        _coordinateConverter.pageRectToCanvas(rect),
        Paint()
          ..color = CupertinoColors.systemYellow.withAlpha(125)
          ..style = PaintingStyle.fill);

    // draw border
    if (editing) {
      canvas.drawRect(
          _coordinateConverter.pageRectToCanvas(rect),
          Paint()
            ..color = CupertinoColors.darkBackgroundGray
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0);
    }
    return 1;
  }

  int _paintMatte(Canvas canvas, pb.NotePageItem item, int _, int __, [bool isSelected = false]) {
    final matte = (page as IndependentNotePage).matteOfId(item.matteId);
    if (matte == null) {
      logError("disappeared matte: ${item.matteId} for $page", false);
      return 0;
    }

    paintMatte(
      canvas: canvas,
      coordinateConverter: _coordinateConverter,
      item: (matte: matte, status: MatteStatus.done, position: Offset(item.x, item.y), scale: item.hasScale() ? item.scale : 1.0),
      isSelected: isSelected,
      triggerRepaint: page.triggerRepaint,
    );
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
          ..strokeWidth = _coordinateConverter.penWidthToCanvas(pen.lineWidth));
  }

  Paint _wrapSelectedPaintIfNeed(Paint from, bool isSelected) {
    if (!isSelected) return from;
    return Paint()
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = from.color
      ..strokeWidth = from.strokeWidth
      ..colorFilter = ColorFilter.mode(material.Colors.grey.withOpacity(0.9), BlendMode.srcATop);
  }

  @override
  bool shouldRepaint(PageItemsPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(PageItemsPainter oldDelegate) => false;
}
