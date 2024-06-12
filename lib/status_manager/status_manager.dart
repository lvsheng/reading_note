import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:quiver/collection.dart';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/history_stack.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/pen/selector_pen/select_pen.dart';
import 'package:reading_note/status_manager/matting_manager.dart';
import 'package:reading_note/status_manager/pen_manager.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:reading_note/util/log.dart';
import 'package:tuple/tuple.dart';
import '../note_page/independent_note_page.dart';
import '../note_page/mark_note_page.dart';
import '../pen/matte_positioner_pen.dart';
import '../pen/pen.dart';

final _penManager = PenManager();

final statusManager = StatusManager._();

// todo: mixin, Note status, opening logic in main
class StatusManager extends ChangeNotifier {
  bool _ready = false;
  File? _reading;
  NoteType _interacting = NoteType.book;
  Tuple2<Pen, NotePage>? _drawing;
  bool _mattingOrPuttingMatte = false;

  Pen? _mattingPen;
  Pen? _mattePlacePen;
  final _selectingMode = List.generate(NoteType.values.length, (_) => LruMap<int /*pageIndex*/, bool>(maximumSize: 20));
  final _selectPen = List.generate(NoteType.values.length, (_) => LruMap<int, SelectPen>(maximumSize: 20));

  Map<int, Tuple2<IndependentNotePage?, Future<IndependentNotePage>?>>? _pageIndependentNoteMap;
  Map<int, Tuple2<MarkNotePage?, Future<MarkNotePage>?>>? _pageMarkNoteMap;

  StatusManager._() {
    Future.wait([_penManager.readyFuture, fileSystemProxy.rootDirectoryReady]).then((_) {
      _ready = true;
      notifyListeners();
    });
  }

  File? get reading => _reading;

  void saveIfNeeded() {
    for (final group in [_pageMarkNoteMap?.values, _pageIndependentNoteMap?.values]) {
      if (group == null) continue;
      for (final tuple in group) {
        final note = tuple.item1;
        if (note == null) return;
        note.saveIfNeeded();
      }
    }
  }

  IndependentNotePage? getOrLoadIndependentNotePage(int index, Size recommendedSize) {
    final noteTuple = _pageIndependentNoteMap![index];

    if (noteTuple?.item1 == null) {
      // note not ready
      if (noteTuple == null) {
        // if not loading, load it first
        final reading = _reading!;
        _pageIndependentNoteMap![index] = Tuple2(
            null,
            NotePage.open(NoteType.note, reading, index, recommendedSize, null).then((note) {
              if (_reading != reading) return note as IndependentNotePage;
              _pageIndependentNoteMap![index] = Tuple2(note as IndependentNotePage, null);
              notifyListeners();
              return note;
            }));
      }
      return null;
    }

    return noteTuple!.item1!;
  }

  // fixme: merge implementation vs getOrLoadIndependentNotePage
  MarkNotePage? getOrLoadMarkNotePage(int pageNumber, Future<NotePage> Function() load) {
    final noteTuple = _pageMarkNoteMap![pageNumber];

    if (noteTuple?.item1 == null) {
      // note not ready
      if (noteTuple == null) {
        // if not loading, load it first
        final reading = _reading!;
        _pageMarkNoteMap![pageNumber] = Tuple2(
            null,
            load().then((note) {
              if (reading != _reading) return note as MarkNotePage;
              _pageMarkNoteMap![pageNumber] = Tuple2(note as MarkNotePage, null);
              notifyListeners();
              return note;
            }));
      }
      return null;
    }

    return noteTuple!.item1!;
  }

  void waitNotePage(NoteType noteType, int pageNumber, void Function(NotePage) callback) {
    final map = noteType == NoteType.note ? _pageIndependentNoteMap : _pageMarkNoteMap;
    final noteTuple = map![pageNumber];
    assert(noteTuple != null);
    if (noteTuple!.item1 != null) {
      callback(noteTuple.item1!);
      return;
    }
    noteTuple.item2!.then(callback);
  }

  set reading(File? file) {
    _reading = file;
    _pageIndependentNoteMap = {};
    _pageMarkNoteMap = {};
  }

  bool get ready => _ready;

  NoteType get interacting => _interacting;

  int get notePageIndex => userPreferences.notePageOf(reading!) ?? 0;

  int get bookPageNumber => userPreferences.bookPageOf(reading!) ?? 1;

  int get pageNumber => interacting == NoteType.book ? bookPageNumber : notePageIndex;

  set notePageIndex(int index) {
    userPreferences.setNotePage(reading!, index);
    notifyListeners();
  }

  set bookPageNumber(int pageNumber) => userPreferences.setBookPage(reading!, pageNumber);

  List<Pen> get penList => [_mattingOrMattePositionerPen, ...normalPenList];

  List<Pen> get normalPenList => _penManager.list;

  NotePage? get currentPage {
    if (_reading == null) {
      logWarn("_reading == null");
      return null;
    }
    final map = interacting == NoteType.note ? _pageIndependentNoteMap : _pageMarkNoteMap;
    final i = pageNumber;
    final noteTuple = map![i];
    return noteTuple?.item1;
  }

  final historyStack = HistoryStack(); // todo: move to page?

  Pen get usingPen {
    if (_reading != null) {
      final i = pageNumber;
      if (_selectingMode[_interacting.index][i] == true) {
        return _selectPen[_interacting.index][i] ??= SelectPen();
      }
    }
    if (_mattingOrPuttingMatte) {
      return _mattingOrMattePositionerPen;
    }
    return _penManager.currentPenOf(interacting);
  }

  void toggleSelectingMode() {
    final i = pageNumber;
    _selectingMode[_interacting.index][i] = !(_selectingMode[_interacting.index][i] == true);
    notifyListeners();
  }

  Pen get _mattingOrMattePositionerPen {
    _mattingPen ??= Pen(-1, PenType.mattingMarkPen, CupertinoColors.systemYellow.withAlpha(125), 10.0);
    _mattePlacePen ??= MattePositionerPen();
    return _interacting == NoteType.note ? _mattePlacePen! : _mattingPen!;
  }

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
    if (offset == 0) return;
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
