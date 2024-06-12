import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/custom_painter/page_items_painter.dart';
import '../note_page/note_page.dart';
import '../pen/selector_pen/indexable_area.dart';
import '../pen/selector_pen/select_pen.dart';
import '../util/log.dart';
import 'coordinate_converter.dart';

const _logging = true;

class SelectPenPainter extends CustomPainter {
  final SelectPen _pen;
  final CoordConverter _coordinateConverter;
  final PageItemsPainter _pageItemsPainter;

  SelectPenPainter(this._pen, this._coordinateConverter, NotePage page)
      : _pageItemsPainter = PageItemsPainter(page, _coordinateConverter),
        super(repaint: _pen);

  @override
  void paint(Canvas canvas, Size size) {
    int ts = DateTime.now().millisecondsSinceEpoch;

    if (!_pen.moving) {
      _paintPaint(canvas);
    }

    if (_pen.selected.isEmpty) {
      return;
    }

    if (_pen.paintSelectedStatus) {
      for (final item in _pen.selected.iterateAllItems()) {
        _pageItemsPainter.paintSelectedItem(canvas, item);
      }
    }

    _paintOutline(canvas, _coordinateConverter.pageRectToCanvas(_pen.selectedBoundingBox!));
    if (_logging) logInfo("paintSelected end. cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }

  void _paintPaint(Canvas canvas) {
    var position = _pen.touchingOn;
    if (position == null) return;
    position = _coordinateConverter.pageOffsetToCanvas(position);
    final size = _coordinateConverter.pageSizeToCanvas(_pen.size);
    const borderSide = BorderSide();
    paintBorder(canvas, Rect.fromCenter(center: position, width: size.width, height: size.height),
        top: borderSide, bottom: borderSide, left: borderSide, right: borderSide);
  }

  void _paintOutline(Canvas canvas, Rect outline) {
    const borderSide = BorderSide(width: 0, color: material.Colors.grey);
    paintBorder(canvas, outline, top: borderSide, bottom: borderSide, left: borderSide, right: borderSide);

    if (_pen.moving) {
      _paintCornerCircle(canvas, outline.topLeft);
      _paintCornerCircle(canvas, outline.topRight);
      _paintCornerCircle(canvas, outline.bottomLeft);
      _paintCornerCircle(canvas, outline.bottomRight);
      _paintMove(canvas, outline.center);
    }
  }

  void _paintCornerCircle(Canvas canvas, Offset position) {
    // todo: convert to screen fixed size (ignore canvas scale up or down)
    final double radius = _pen.scaleCornerRadius;
    const double strokeWidth = 1;
    canvas.drawCircle(
        position,
        radius,
        Paint()
          ..color = CupertinoColors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);
    canvas.drawCircle(
        position,
        radius,
        Paint()
          ..color = CupertinoColors.systemGrey
          ..style = PaintingStyle.fill);
  }

  void _paintMove(Canvas canvas, Offset position) {
    const icon = material.Icons.open_with_sharp;
    const size = 30.0;
    TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
    textPainter.text = TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontSize: size, fontFamily: icon.fontFamily, color: CupertinoColors.black));
    textPainter.layout();
    textPainter.paint(canvas, position - const Offset(size / 2, size / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => (oldDelegate as SelectPenPainter)._pen != _pen;
}
