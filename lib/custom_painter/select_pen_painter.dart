import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/custom_painter/page_items_painter.dart';
import '../note_page/note_page.dart';
import '../pen/selector_pen/indexable_area.dart';
import '../pen/selector_pen/select_pen.dart';
import 'coordinate_converter.dart';

class SelectPenPainter extends CustomPainter {
  final SelectPen _pen;
  final CoordConverter _coordinateConverter;
  final PageItemsPainter _pageItemsPainter;

  SelectPenPainter(this._pen, this._coordinateConverter, NotePage page) : _pageItemsPainter = PageItemsPainter(page, _coordinateConverter), super(repaint: _pen);

  @override
  void paint(Canvas canvas, Size size) {
    _paintPaint(canvas);
    _pageItemsPainter.paintSelected(canvas, _pen.selected);
    _paintOutline(canvas);
  }

  void _paintPaint(Canvas canvas) {
    var position = _pen.touchingOn;
    if (position == null) return;
    position = _coordinateConverter.pageOffsetToCanvas(position);
    final size = _coordinateConverter.pageSizeToCanvas(_pen.size);
    final width = _coordinateConverter.penWidthToCanvas(_pen.lineWidth);
    const borderSide = BorderSide();
    paintBorder(canvas, Rect.fromCenter(center: position, width: size.width, height: size.height),
        top: borderSide, bottom: borderSide, left: borderSide, right: borderSide);
  }

  void _paintOutline(Canvas canvas) {
    if (_pen.selected.isEmpty) return;

    final first = _pen.selected.first;
    final firstBoundingBox = ItemWrapper.boundingBoxOfItem(first, _pen.page!.data);
    var l = firstBoundingBox.left;
    var t = firstBoundingBox.top;
    var r = firstBoundingBox.right;
    var b = firstBoundingBox.bottom;
    if (_pen.selected.length > 1) {
      for (final item in _pen.selected) {
        final boundingBox = ItemWrapper.boundingBoxOfItem(item, _pen.page!.data);
        l = min(l, boundingBox.left);
        t = min(t, boundingBox.top);
        r = max(r, boundingBox.right);
        b = max(b, boundingBox.bottom);
      }
    }
    final outline = _coordinateConverter.pageRectToCanvas(Rect.fromLTRB(l, t, r, b));

    const borderSide = BorderSide(width: 0, color: material.Colors.grey);
    paintBorder(canvas, outline,
        top: borderSide, bottom: borderSide, left: borderSide, right: borderSide);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => (oldDelegate as SelectPenPainter)._pen != _pen;
}
