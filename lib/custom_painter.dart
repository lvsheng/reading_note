import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;

import 'note_page.dart';

class PDFOverlayPainter extends CustomPainter {
  final Rect _pageRect;
  final PdfPage _page;
  final BookMarkNotePage _note;

  PDFOverlayPainter(this._pageRect, this._page, this._note) : super(repaint: _note);

  @override
  void paint(Canvas canvas, Size size) {
    logDebug("p${_page.pageNumber}: CustomPainter.size: $size");
    logDebug("p${_page.pageNumber}: CustomPainter.pageRect: .size:${_pageRect.size} rect:$_pageRect");
    logDebug("p${_page.pageNumber}: CustomPainter.diff: ${_pageRect.size - size}");
    logDebug("p${_page.pageNumber}: CustomPainter.page: .size:${_page.size} .w/h:${_page.width}/${_page.height}");

    _paintDrawingData(canvas);
  }

  _paintDrawingData(Canvas canvas) {
    int ts = DateTime.now().millisecondsSinceEpoch;
    int countPoints = 0;

    final paint = Paint()
      ..strokeWidth = BookMarkNotePage.pagePositionToCanvasPosition(pb.Point(x: 0.5, y: 0.0), _pageRect, _page.size).dx
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    _note.forEachPageItem((item) {
      final points = item.path.points
          .map((point) => BookMarkNotePage.pagePositionToCanvasPosition(point, _pageRect, _page.size))
          .toList(growable: false);
      countPoints += points.length;

      canvas.drawPoints(PointMode.polygon, points, paint); // fixme: 在impeller下raster性能极差，卡顿明显。暂用skia

      // for debug
      // final oldColor = paint.color;
      // paint.color = Colors.deepPurpleAccent;
      // canvas.drawPoints(PointMode.points, points, paint);
      // paint.color = oldColor;
    });

    // todo: performance
    logDebug("[StylusGesture] _paintDrawingData end. countPoints:$countPoints cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }

  @override
  bool shouldRepaint(PDFOverlayPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(PDFOverlayPainter oldDelegate) => false;
}
