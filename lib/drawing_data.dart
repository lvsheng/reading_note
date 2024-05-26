import 'package:flutter/material.dart';

class DrawingData {
  final List<List<Offset>> _pathList = [];
  final Size _size;
  List<Offset>? _drawing;

  DrawingData(this._size);

  startDraw() {
    assert(_drawing == null);
    _pathList.add(_drawing = []);
  }

  endDraw() {
    assert(_drawing != null);
    if (_drawing!.isEmpty) {
      _pathList.removeLast();
    }
    _drawing = null;
  }

  addPoint(Offset p) {
    assert(_drawing != null);
    if (!_check(p)) return;
    _drawing!.add(p);
  }

  static Offset canvasPositionToPagePosition(Offset localPosition, Rect pageRect, Size pageSize) {
    Offset result = Offset(localPosition.dx / pageRect.width, localPosition.dy / pageRect.height);
    return result = Offset(result.dx * pageSize.width, result.dy * pageSize.height);
  }

  static Offset pagePositionToCanvasPosition(Offset pagePosition, Rect pageRect, Size pageSize) {
    Offset result = Offset(pagePosition.dx / pageSize.width, pagePosition.dy / pageSize.height);
    return result = Offset(result.dx * pageRect.width, result.dy * pageRect.height);
  }

  List<List<Offset>> get pathList => _pathList;

  bool _check(Offset p) {
    return p > const Offset(0, 0) && p < Offset(_size.width, _size.height);
  }
}
