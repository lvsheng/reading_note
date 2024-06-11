import 'package:flutter/cupertino.dart';
import 'package:reading_note/util/log.dart';

typedef _HistoryItem = (
  VoidCallback /*do*/,
  VoidCallback /*undo*/,
);

class HistoryStack extends ChangeNotifier {
  final List<_HistoryItem> _doHistory = [];
  final List<_HistoryItem> _undoHistory = [];

  void doo(VoidCallback doo, VoidCallback undo) {
    doo();
    _doHistory.add((doo, undo));
    _undoHistory.clear();

    const int historyLimit = 300;
    const int removeCount = 100;
    if (_doHistory.length > historyLimit) {
      _doHistory.removeRange(0, removeCount);
    }
    notifyListeners();
  }

  bool get undoable => _doHistory.isNotEmpty;

  bool get redoable => _undoHistory.isNotEmpty;

  void undo() {
    assert(undoable);
    final item = _doHistory.removeLast();
    item.$2();
    _undoHistory.add(item);
    notifyListeners();
    logDebug("undo end");
  }

  void redo() {
    assert(redoable);
    final item = _undoHistory.removeLast();
    item.$1();
    _doHistory.add(item);
    notifyListeners();
    logDebug("redo end");
  }
}
