import 'package:flutter/cupertino.dart';
import 'package:reading_note/pen/pen.dart';
import 'package:reading_note/status_manager/status_manager.dart';

import '../note_page/note_page.dart';

abstract class PenStrokeTracker {
  @protected
  final Pen pen;
  final NotePage page;
  bool _frozen = false;

  PenStrokeTracker(this.pen, Offset startPosition, this.page) {
    statusManager.beginDrawing(pen, page);
    start(startPosition);
  }

  bool get frozen => _frozen;

  bool end(Offset position) {
    statusManager.endDrawing(position);
    pen.endPaint();
    return stop();
  }

  void froze() {
    _frozen = true;
    page.triggerRepaint();
  }

  @protected
  void start(Offset position) {}

  void move(Offset position);

  @protected
  bool stop() => true;
}

class PositionTracker extends PenStrokeTracker {
  final void Function(Offset position)? _onNewPosition;
  PositionTracker(super.pen, super.startPosition, super.page, this._onNewPosition);

  @override
  void start(Offset position) {
    if (_onNewPosition != null) _onNewPosition(position);
  }

  @override
  void move(Offset position) {
    if (_onNewPosition != null) _onNewPosition(position);
  }
}
