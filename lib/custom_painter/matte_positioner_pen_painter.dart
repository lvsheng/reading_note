import 'package:flutter/cupertino.dart';
import 'package:reading_note/custom_painter/paint_matte.dart';
import 'package:reading_note/pen/matte_positioner_pen.dart';

import 'coordinate_converter.dart';

class MattePositionerPenPainter extends CustomPainter {
  final MattePositionerPen _pen;
  final int _pageNumber;
  final CoordConverter _coordinateConverter;

  MattePositionerPenPainter(this._pen, this._pageNumber, this._coordinateConverter): super(repaint: _pen);

  @override
  void paint(Canvas canvas, Size size) {
    for (final item in _pen.getItems(_pageNumber)) {
      paintMatte(canvas: canvas, coordinateConverter: _coordinateConverter, item: item, triggerRepaint: _pen.triggerRepaint, forPenPainter: true);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => _pageNumber != (oldDelegate as MattePositionerPenPainter)._pageNumber;
}
