import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import '../pen/selector_pen/indexable_area.dart';
import '../pen/selector_pen/select_pen.dart';
import 'coordinate_converter.dart';

class SelectPenPainter extends CustomPainter {
  final SelectPen _pen;
  final CoordConverter _coordinateConverter;

  SelectPenPainter(this._pen, this._coordinateConverter) : super(repaint: _pen);

  @override
  void paint(Canvas canvas, Size size) {
    _paintPaint(canvas);
    _paintSelected(canvas);
  }

  void _paintPaint(Canvas canvas) {
    var position = _pen.touchingOn;
    if (position == null) return;
    position = _coordinateConverter.pageOffsetToCanvas(position);
    final width = _coordinateConverter.penWidthToCanvas(_pen.lineWidth);
    const borderSide = BorderSide();
    paintBorder(canvas, Rect.fromCenter(center: position, width: width, height: width),
        top: borderSide, bottom: borderSide, left: borderSide, right: borderSide);
  }

  void _paintSelected(Canvas canvas) {
    for (final item in _pen.selected) {
      const borderSide = BorderSide(color: material.Colors.lightBlueAccent);
      paintBorder(canvas, _coordinateConverter.pageRectToCanvas(ItemWrapper.boundingBoxOfItem(item, _pen.page!.data)),
          top: borderSide, bottom: borderSide, left: borderSide, right: borderSide);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
