import 'dart:ui';
import 'package:tuple/tuple.dart';

typedef HistoryItem = Tuple2<VoidCallback/*do*/, VoidCallback/*undo*/>;

class HistoryStack {
  final List<HistoryItem> _doHistory = [];
  final List<HistoryItem> _undoHistory = [];

  void doOne(HistoryItem item) {
    item.item1();
    _doHistory.add(item);
    _undoHistory.clear();
  }

  bool get undoable => _doHistory.isNotEmpty;

  bool get redoable => _undoHistory.isNotEmpty;

  void undo() {
    assert(undoable);
    final item = _doHistory.removeLast();
    item.item2();
    _undoHistory.add(item);
  }

  void redo() {
    assert(redoable);
    final item = _undoHistory.removeLast();
    item.item1();
    _doHistory.add(item);
  }
}
