import 'package:flutter/cupertino.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/status_manager/pen_manager.dart';

import '../pen.dart';

final _penManager = PenManager();

final statusManager = StatusManager._();

enum InteractiveMode {
  bookHandwrite, // = 0. DO NOT CHANGE ORDER - INDEX IS USED!
  bookMatting, // = 1. DO NOT CHANGE ORDER - INDEX IS USED!
  noteHandwrite, // = 2. DO NOT CHANGE ORDER - INDEX IS USED!
  notePlaceMatte, // = 3. DO NOT CHANGE ORDER - INDEX IS USED!
}

enum PlaceMattePhase {
  moveTogether,
  moveSeparately,
  done,
}

class StatusManager extends ChangeNotifier {
  InteractiveMode _mode = InteractiveMode.bookHandwrite;

  StatusManager._();

  InteractiveMode get currentMode => _mode;

  NoteType get interactingNoteType => (const [
        NoteType.bookMarkNote,
        NoteType.bookMarkNote,
        NoteType.independentNote,
        NoteType.independentNote,
      ])[_mode.index];

  List<Pen> get interactingPenList {
    final result = _penManager.penListOf(interactingNoteType);
    if (result.isEmpty) {
      // todo: 是否不应该此时这样做？但防止下次绘画时没有笔，还是要避免画笔列表空
      _penManager.resetPenList(interactingNoteType);
    }
    return result;
  }

  Pen get usingPen => _penManager.currentPenOf(interactingNoteType);

  void gotoIndependentNote() {
    _mode = InteractiveMode.noteHandwrite;
    notifyListeners();
  }

  void gotoBook() {
    _mode = InteractiveMode.bookHandwrite; // todo: or matting
    notifyListeners();
  }

  List<Pen> resetPenList(NoteType noteType) {
    final result = _penManager.resetPenList(noteType);
    notifyListeners();
    return result;
  }

  set usingPen(Pen pen) {
    _penManager.setCurrentPen(interactingNoteType, pen);
    notifyListeners();
  }
}
