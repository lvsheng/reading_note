import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/status_manager/pen_manager.dart';
import 'package:tuple/tuple.dart';
import '../pen/pen.dart';

final _penManager = PenManager();

final statusManager = StatusManager._();

// todo: mixin, Note status, opening logic in main
class StatusManager extends ChangeNotifier {
  bool _ready = false;
  File? reading; // fixme
  NoteType _interacting = NoteType.book;
  Tuple2<Pen, NotePage>? _drawing;
  bool _mattingOrPuttingMatte = false;

  StatusManager._() {
    Future.wait([_penManager.readyFuture, fileSystemProxy.rootDirectoryReady]).then((_) {
      _ready = true;
      notifyListeners();
    });
  }

  bool get ready => _ready;

  NoteType get interacting => _interacting;

  List<Pen> get interactingPenList {
    final result = _penManager.penListOf(interacting);
    if (result.isEmpty) {
      // todo: 是否不应该此时这样做？但防止下次绘画时没有笔，还是要避免画笔列表空
      _penManager.resetPenList(interacting);
    }
    return result;
  }

  Pen get usingPen {
    if (_mattingOrPuttingMatte) {
      return _interacting == NoteType.note ? _penManager.mattePlacePen : _penManager.mattingPen;
    }
    return _penManager.currentPenOf(interacting);
  }

  NotePage? get drawingPage => _drawing?.item2;

  Pen? get drawingPen => _drawing?.item1;

  void switchToNote() {
    _interacting = NoteType.note;
    _mattingOrPuttingMatte = _penManager.puttingMatteWhenNote;
    notifyListeners();
  }

  void finishPlaceMatte() {
    _mattingOrPuttingMatte = _penManager.puttingMatteWhenNote = false;
    notifyListeners();
  }

  void switchToBook() {
    _interacting = NoteType.book;
    _mattingOrPuttingMatte = _penManager.mattingWhenBook;
    notifyListeners();
  }

  set usingPen(Pen pen) {
    assert(pen.type != PenType.mattingMarkPen);
    assert(pen.type != PenType.mattePositionerPen);
    _penManager.setCurrentPen(interacting, pen);
    notifyListeners();
  }

  bool get mattingOrPuttingMatte => _mattingOrPuttingMatte;
  void switchMattingOrPuttingMatte() {
    _mattingOrPuttingMatte = !_mattingOrPuttingMatte;
    notifyListeners();
  }

  dynamic beginDrawing(Pen pen, NotePage page) {
    // todo: return adjustor, 比如一边画一边调整高度
    _drawing = Tuple2(pen, page);
    notifyListeners();
  }

  void endDrawing() {
    _drawing = null;
    notifyListeners();
  }
}
