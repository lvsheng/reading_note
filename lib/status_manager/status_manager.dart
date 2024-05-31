import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/pen/matte_positioner.dart';
import 'package:reading_note/status_manager/matting_manager.dart';
import 'package:reading_note/status_manager/pen_manager.dart';
import 'package:tuple/tuple.dart';
import '../pen/matte_positioner_pen.dart';
import '../pen/pen.dart';

final _penManager = PenManager();

final statusManager = StatusManager._();

// todo: mixin, Note status, opening logic in main
class StatusManager extends ChangeNotifier {
  bool _ready = false;

  NoteType _interactingNoteType = NoteType.book;
  Tuple2<Pen, NotePage>? _drawing;
  File? reading; // fixme

  StatusManager._() {
    Future.wait([_penManager.readyFuture, fileSystemProxy.rootDirectoryReady]).then((_) {
      _ready = true;
      notifyListeners();
    });
  }

  bool get ready => _ready;

  NoteType get interactingNoteType => _interactingNoteType;

  List<Pen> get interactingPenList {
    final result = _penManager.penListOf(interactingNoteType);
    if (result.isEmpty) {
      // todo: 是否不应该此时这样做？但防止下次绘画时没有笔，还是要避免画笔列表空
      _penManager.resetPenList(interactingNoteType);
    }
    return result;
  }

  bool _delayPlaceMatte = false;

  MattePositionerPen? _mattePlacePen;

  bool get mattePlacePenVisible => interactingNoteType == NoteType.note && _mattePlacePen != null;

  Pen get usingPen {
    if (!mattePlacePenVisible || _delayPlaceMatte) {
      return _penManager.currentPenOf(interactingNoteType);
    } else {
      return _mattePlacePen!;
    }
  }

  NotePage? get drawingPage => _drawing?.item2;

  Pen? get drawingPen => _drawing?.item1;

  void switchToNote() {
    if (mattingManager.isNotEmpty && _mattePlacePen == null) {
      _mattePlacePen = MattePositionerPen();
    }
    _interactingNoteType = NoteType.note;
    notifyListeners();
  }

  void finishPlaceMatte() {
    assert(_mattePlacePen != null && _mattePlacePen == usingPen);
    _mattePlacePen = null;
    _delayPlaceMatte = false;
  }

  void switchToBook() {
    _interactingNoteType = NoteType.book;
    notifyListeners();
  }

  set usingPen(Pen pen) {
    if (pen is! MattePositionerPen) {
      _penManager.setCurrentPen(interactingNoteType, pen);
    } else {
      assert(_delayPlaceMatte && mattePlacePenVisible);
      _delayPlaceMatte = false;
      assert(usingPen is MattePositionerPen);
    }

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
