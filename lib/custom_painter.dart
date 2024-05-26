import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reading_note/log.dart';

import 'drawing_data.dart';

class PDFOverlayPainter extends CustomPainter {
  final Rect _pageRect;
  final PdfPage _page;
  final DrawingData _drawingData;
  final Key _drawingDataKey;

  PDFOverlayPainter(this._pageRect, this._page, this._drawingData, this._drawingDataKey);

  /*
  从最小放大到最大过程中各size变化（稍有移动导致offset变化）：
  1. CustomPainter.paint收到的Size参数：宽高比不变(638.6/1059.0~=0.6030)，size自小放大
  admin@bogon temp % cat build-error.log| grep 'p1: ' | grep 'CustomPainter.size'
  flutter: [debug] p1: CustomPainter.size: Size(638.6, 1059.0)
  flutter: [debug] p1: CustomPainter.size: Size(692.1, 1147.7)
  …
  flutter: [debug] p1: CustomPainter.size: Size(3163.5, 5246.2)
  admin@bogon temp %
  2. 回调传入的pageRect.size：同样的变化
  admin@bogon temp % cat build-error.log| grep 'p1: ' | grep 'CustomPainter.pageRect'
  flutter: [debug] p1: CustomPainter.pageRect: .size:Size(638.6, 1059.0) rect:Rect.fromLTRB(367.2, -5.2, 1005.8, 1053.8)
  …
  flutter: [debug] p1: CustomPainter.pageRect: .size:Size(3163.5, 5246.2) rect:Rect.fromLTRB(-926.3, -441.0, 2237.1, 4805.2)
  admin@bogon temp %
  3. 前两者的diff：不变，始终为0
  admin@bogon temp % cat build-error.log| grep 'p1: ' | grep 'CustomPainter.diff'
  flutter: [debug] p1: CustomPainter.diff: Offset(0.0, 0.0)
  …
  flutter: [debug] p1: CustomPainter.diff: Offset(0.0, 0.0)
  admin@bogon temp %
  4. 回调传入的page：大小不变
  admin@bogon temp % cat build-error.log| grep 'p1: ' | grep 'CustomPainter.page:'
  flutter: [debug] p1: CustomPainter.page: .size:Size(395.4, 655.8) .w/h:395.4329833984375/655.7758178710938
  …
  flutter: [debug] p1: CustomPainter.page: .size:Size(395.4, 655.8) .w/h:395.4329833984375/655.7758178710938
  admin@bogon temp %
   */
  @override
  void paint(Canvas canvas, Size size) {
    logDebug("p${_page.pageNumber}: CustomPainter.size: $size");
    logDebug(
        "p${_page.pageNumber}: CustomPainter.pageRect: .size:${_pageRect.size} rect:$_pageRect");
    logDebug(
        "p${_page.pageNumber}: CustomPainter.diff: ${_pageRect.size - size}");
    logDebug(
        "p${_page.pageNumber}: CustomPainter.page: .size:${_page.size} .w/h:${_page.width}/${_page.height}");

    _paintPointExactlyOnPage(canvas);
    _paintDrawingData(canvas);
  }

  _paintDrawingData(Canvas canvas) {
    logInfo("[StylusGesture] _paintDrawingData start");
    int ts = DateTime.now().millisecondsSinceEpoch;
    int countPoints = 0;

    final paint = Paint()
      ..strokeWidth = DrawingData.pagePositionToCanvasPosition(const Offset(1, 0.0), _pageRect, _page.size).dx
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    for (final List<Offset> path in _drawingData.pathList) {
      final points = path
          .map((point) => DrawingData.pagePositionToCanvasPosition(point, _pageRect, _page.size))
          .toList(growable: false);
      countPoints += points.length;

      canvas.drawPoints(PointMode.polygon, points, paint);

      // for debug
      // final oldColor = paint.color;
      // paint.color = Colors.deepPurpleAccent;
      // canvas.drawPoints(PointMode.points, points, paint);
      // paint.color = oldColor;
    }

    // todo: performance
    logDebug("[StylusGesture] _paintDrawingData end. countPoints:$countPoints cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }

  _paintPointExactlyOnPage(Canvas canvas) {
    final paint = Paint()
      ..strokeWidth = DrawingData.pagePositionToCanvasPosition(const Offset(1.0, 0.0), _pageRect, _page.size).dx
      ..style = PaintingStyle.stroke
      ..color = Colors.deepPurpleAccent;
    const startY = 296.0;
    canvas.drawPoints(PointMode.points, [
      // 中间部分两个相临点
      const Offset(3, 3 + startY),
      const Offset(15, 15 + startY),
      // 右下角部分三个相临点
      Offset(_page.size.width - 3, _page.size.height - 3),
      Offset(_page.size.width - 15, _page.size.height - 15),
      Offset(_page.size.width - 16, _page.size.height - 16),
    ].map((dot) => DrawingData.pagePositionToCanvasPosition(dot, _pageRect, _page.size)).toList(growable: false), paint);
  }

  @override
  bool shouldRepaint(PDFOverlayPainter oldDelegate) {
    final result = _drawingDataKey != oldDelegate._drawingDataKey;
    logDebug("[StylusGesture] shouldRepaint:$result");
    return result;
  }

  @override
  bool shouldRebuildSemantics(PDFOverlayPainter oldDelegate) => false;
}
