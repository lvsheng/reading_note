import 'dart:ui';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'pen.dart';
import 'pen_stroke_tracker.dart';

class PathGenerator extends PenStrokeTracker {
  late final pb.NotePageItem _drawingItem;

  PathGenerator(super.pen, super.startPosition, super.page, super.pbPage);

  @override
  void start(Offset position) {
    pbPage.items.add(_drawingItem = pb.NotePageItem()
      ..x = position.dx
      ..y = position.dy
      ..path = (pb.Path()..penId = _generatePbPenId(pen, pbPage.penPool)));
  }

  @override
  void move(Offset position) => _drawingItem.path.points.add(pb.Point(x: position.dx - _drawingItem.x, y: position.dy - _drawingItem.y));

  @override
  bool stop() {
    bool success = _drawingItem.path.points.isNotEmpty;
    if (!success) {
      pbPage.items.removeLast();
    }
    return success;
  }

  int _generatePbPenId(Pen pen, Map<int, pb.Pen> pbPenPool) {
    int lastPenId = 0;
    pb.Pen? result;

    // try find the existing same pen
    for (final each in pbPenPool.entries) {
      lastPenId = each.key;
      if (each.value.type.value != pen.type.index) continue;
      if (each.value.color != pen.color.value) continue;
      if (each.value.lineWidth != pen.lineWidth) continue;
      result = each.value;
      break;
    }

    // if not found, register one
    result ??= pbPenPool[++lastPenId] = pb.Pen()
      ..type = pb.PenType.values[pen.type.index]
      ..color = pen.color.value
      ..lineWidth = pen.lineWidth;

    return lastPenId;
  }
}