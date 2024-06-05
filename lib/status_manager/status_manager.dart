import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/status_manager/matting_manager.dart';
import 'package:reading_note/status_manager/pen_manager.dart';
import 'package:reading_note/user_preferences.dart';
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

  int get notePageIndex => userPreferences.notePageOf(reading!) ?? 0;
  set notePageIndex(int index) => userPreferences.setNotePage(reading!, index);

  List<Pen> get penList {
    final result = [_mattingOrMattePositionerPen]; // todo: 橡皮、选择笔
    result.addAll(_penManager.list);
    if (result.isEmpty) {
      // todo: 是否不应该此时这样做？但防止下次绘画时没有笔，还是要避免画笔列表空
      _penManager.resetPenList(interacting);
    }
    return result;
  }

  Pen get usingPen {
    if (_mattingOrPuttingMatte) {
      return _mattingOrMattePositionerPen;
    }
    return _penManager.currentPenOf(interacting);
  }

  Pen get _mattingOrMattePositionerPen => _interacting == NoteType.note ? _penManager.mattePlacePen : _penManager.mattingPen;

  NotePage? get drawingPage => _drawing?.item2;

  Pen? get drawingPen => _drawing?.item1;

  void switchToNote() {
    _interacting = NoteType.note;
    _mattingOrPuttingMatte = mattingManager.isNotEmpty;
    notifyListeners();
  }

  void finishPlaceMatte() {
    _mattingOrPuttingMatte = false;
    notifyListeners();
  }

  void switchToBook() {
    _interacting = NoteType.book;
    _mattingOrPuttingMatte = _penManager.mattingWhenBook;
    notifyListeners();
  }

  set usingPen(Pen pen) {
    if (pen == usingPen) return;
    if (pen.type == PenType.mattingMarkPen) {
      assert(interacting == NoteType.book);
      _mattingOrPuttingMatte = _penManager.mattingWhenBook = true;
    } else if (pen.type == PenType.mattePositionerPen) {
      assert(interacting == NoteType.note);
      _mattingOrPuttingMatte = true;
    } else {
      _penManager.setCurrentPen(interacting, pen);
      _mattingOrPuttingMatte = false;
      if (interacting == NoteType.book) _penManager.mattingWhenBook = false;
    }
    notifyListeners();
  }

  List<Pen> _turnPenList = const [];
  int _turnPenBaseIndex = 0;
  void beginTurnPen() {
    _turnPenList = penList.where((e) => e != _mattingOrMattePositionerPen).toList(growable: false);
    _turnPenBaseIndex = _turnPenList.indexWhere((e) => e == statusManager.usingPen);
  }
  void turnPen(int offset) {
    final index = (_turnPenBaseIndex + offset) % _turnPenList.length;
    usingPen = _turnPenList[index];
  }

  static const int commonPenIndex = 3; // fixme
  void useCommonPen() => usingPen = penList[commonPenIndex];

  bool get mattingOrPuttingMatte => _mattingOrPuttingMatte;
  void switchMattingOrPuttingMatte() {
    _mattingOrPuttingMatte = !_mattingOrPuttingMatte;
    notifyListeners();
  }

  void beginDrawing(Pen pen, NotePage page) {
    _drawing = Tuple2(pen, page);
    notifyListeners();
  }

  void endDrawing(Offset position) {
    _drawing = null;
    notifyListeners();
  }
}
