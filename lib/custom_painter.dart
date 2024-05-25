import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reading_note/log.dart';

class PDFOverlayPainter extends CustomPainter {
  final Rect _pageRect;
  final PdfPage _page;

  PDFOverlayPainter(this._pageRect, this._page);

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
    paintWrongPositionSky(canvas, size);
    paintPointExactlyOnPage(canvas, size);
  }

  void paintPointExactlyOnPage(Canvas canvas, Size size) {
    const startY = 296.0;
    // 中间部分两个相临点
    const dotLT1Position = Offset(3, 3 + startY);
    final dotLT1PositionNormalized = Offset(
        dotLT1Position.dx / _page.size.width,
        dotLT1Position.dy / _page.size.height);
    const dotLT2Position = Offset(15, 15 + startY);
    final dotLT2PositionNormalized = Offset(
        dotLT2Position.dx / _page.size.width,
        dotLT2Position.dy / _page.size.height);
    // 右下角部分三个相临点
    final dotBR1Position = Offset(_page.size.width - 3, _page.size.height - 3);
    final dotBR1PositionNormalized = Offset(
        dotBR1Position.dx / _page.size.width,
        dotBR1Position.dy / _page.size.height);
    final dotBR2Position =
        Offset(_page.size.width - 15, _page.size.height - 15);
    final dotBR2PositionNormalized = Offset(
        dotBR2Position.dx / _page.size.width,
        dotBR2Position.dy / _page.size.height);
    final dotBR3Position =
        Offset(_page.size.width - 16, _page.size.height - 16);
    final dotBR3PositionNormalized = Offset(
        dotBR3Position.dx / _page.size.width,
        dotBR3Position.dy / _page.size.height);
    final points = [
      dotLT1PositionNormalized,
      dotLT2PositionNormalized,
      dotBR1PositionNormalized,
      dotBR2PositionNormalized,
      dotBR3PositionNormalized,
    ]
        .map((dot) => Offset(dot.dx * size.width, dot.dy * size.height))
        .toList(growable: false);
    logDebug("points: $points");
    // size也要相应归一化再放大
    const penWidth = 1;
    final penWidthNormalized = penWidth / _page.size.width;
    final paint = Paint()
      ..strokeWidth = penWidthNormalized * size.width
      ..style = PaintingStyle.stroke;
    paint.color = Colors.deepPurpleAccent;
    canvas.drawPoints(PointMode.points, points, paint);
  }

  // 直接size定位不ok
  void paintWrongPositionSky(Canvas canvas, Size size) {
    final Rect rect =
        const Offset(200, 200) & Size(size.width - 400, size.height - 400);
    const RadialGradient gradient = RadialGradient(
      center: Alignment(0.7, -0.6),
      radius: 0.2,
      colors: <Color>[Color(0xFFFFFF00), Color(0x990099FF)],
      stops: <double>[0.4, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Page ${_page.pageNumber}',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 30,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(
        minWidth: 0,
        maxWidth: size.width,
      );
    final offset = Offset(
        size.width - textPainter.width, size.height - textPainter.height);
    textPainter.paint(canvas, offset);
    final paint = Paint()
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    paint.color = Colors.black;
    canvas.drawRect(
        Rect.fromLTRB(200, 200, size.width - 200, size.height - 200), paint);
  }

  @override
  bool shouldRepaint(PDFOverlayPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(PDFOverlayPainter oldDelegate) => false;
}
