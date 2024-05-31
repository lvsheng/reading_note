import 'package:flutter/cupertino.dart';
import 'package:reading_note/pen/pen.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/status_manager/status_manager.dart';

import '../note_page/note_page.dart';

abstract class PenStrokeTracker {
  @protected
  final Pen pen;
  final NotePage page;
  @protected
  late pb.NotePage pbPage;

  PenStrokeTracker(this.pen, Offset startPosition, this.page, this.pbPage) {
    statusManager.beginDrawing(pen, page);
    start(startPosition);
  }

  bool end() {
    statusManager.endDrawing();
    return stop();
  }

  @protected
  void start(Offset position);

  void move(Offset position);

  @protected
  bool stop();
}
/*

class WaitingTracker extends PenStrokeTracker {
  WaitingTracker(super.pen, super.startPosition, super.page, super.pbPage);

  @override
  void move(Offset position) {
    // todo: paint waiting on global canvas?
  }

  @override
  void start(Offset position) {
    // TODO: implement start
  }

  @override
  bool stop() {
    // TODO: implement stop
    return false;
  }
}
*/
