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
    _paintPaint(canvas);

    if (_pen.selected.isEmpty) {
      return;
    }

    double? l, t, r, b;
    for (final item in _pen.selected.iterateAllItems()) {
      _pageItemsPainter.paintSelectedItem(canvas, item);

      final boundingBox = ItemWrapper.boundingBoxOfItem(item, _pen.page!.data);
      if (l == null) {
        l = boundingBox.left;
        t = boundingBox.top;
        r = boundingBox.right;
        b = boundingBox.bottom;
      }
      l = min(l, boundingBox.left);
      t = min(t!, boundingBox.top);
      r = max(r!, boundingBox.right);
      b = max(b!, boundingBox.bottom);
    }
    assert(l != null && t != null && r != null && b != null);

    _paintOutline(canvas, _coordinateConverter.pageRectToCanvas(Rect.fromLTRB(l!, t!, r!, b!)));
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => (oldDelegate as SelectPenPainter)._pen != _pen;
}
