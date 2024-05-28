import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:protobuf/protobuf.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;

// todo-p4: 考虑文件io失败
class _NoteBook {
  static final Map<String, _NoteBook> _cacheForBookMark = {};
  static final Map<String, _NoteBook> _cacheForIndependent = {};

  static _NoteBook getOrCreate(File book, bool isBookMark) {
    final Map<String, _NoteBook> cache = isBookMark ? _cacheForBookMark : _cacheForIndependent;
    var result = cache[book.path];
    result ??= cache[book.path] = _NoteBook._(book, isBookMark);
    // todo: unload file ?
    return result;
  }

  String getNotePageFilePath(int pageId) => "${_getNoteDirectory(_book, _isBookMark)}$pageId.pb";

  static String _getNoteDirectory(File book, bool isBookMark) => "${_getBaseDirectory(book)}${_getMiddleDirectory(isBookMark)}";

  static String _getMetaFilePath(File book, bool isBookMark) => "${_getBaseDirectory(book)}${_getMiddleDirectory(isBookMark)}meta.pb";

  static String _getBaseDirectory(File book) => "${p.dirname(book.path)}/${p.basename(book.path)}.note/";

  static String _getMiddleDirectory(bool isBookMark) => isBookMark ? "book_mark/" : "";

  late Future<void> ready;
  final bool _isBookMark; // true: book mark note, false: independent note
  late final File _book;
  late File _file;
  pb.NoteBookMeta? _data;

  _NoteBook._(this._book, this._isBookMark) {
    _file = File(_getMetaFilePath(_book, _isBookMark));
    ready = _load();
  }

  _load() async {
    if (!await _file.exists()) {
      await _file.create(recursive: true);
      _data = pb.NoteBookMeta();
      _save();
      return;
    }

    // todo: read时保留只读，用户用笔修改时再deepCopy
    _data = pb.NoteBookMeta.fromBuffer(await _file.readAsBytes()).deepCopy();
  }

  _save() async {
    await _file.writeAsBytes(_data!.writeToBuffer());
  }

  int? noteIdOf(int pageNumber) {
    return _data!.pages[pageNumber];
  }

  Future<File> addBookMarkPage(int pageNumber) {
    int pageId = _data!.lastPageId++;
    return _createPageFile(pageId, () => _data!.pages[pageNumber] = pageId);
  }

  Future<File> _createPageFile(int pageId, VoidCallback updateMeta) async {
    final pageFile = File(getNotePageFilePath(pageId));
    assert(!await pageFile.exists());
    await pageFile.create(recursive: true);
    updateMeta();
    await _save();
    return pageFile;
  }
}

abstract class NotePage extends ChangeNotifier {
  static Future<NotePage> open(bool isBookMark, File book, int pageNumber, Size desiredSize) async {
    final noteBook = _NoteBook.getOrCreate(book, isBookMark);
    await noteBook.ready;

    int? noteId = noteBook.noteIdOf(pageNumber);

    if (noteId == null) {
      // 无旧数据，暂不创建磁盘文件，必要时再创建
      return _create(isBookMark: isBookMark, pageNumber: pageNumber, noteBook: noteBook, size: desiredSize);
    }

    final file = File(noteBook.getNotePageFilePath(noteId));

    pb.NotePage? data;
    if (await file.exists()) {
      // fixme: only do deepCopy when begin edit
      data = pb.NotePage.fromBuffer(await file.readAsBytes()).deepCopy();
    } else {
      logError("page file disappeared: $file");
    }

    return _create(isBookMark: isBookMark, pageNumber: pageNumber, noteBook: noteBook, size: desiredSize, data: data, file: file);
  }

  static NotePage _create(
      {required bool isBookMark, required int pageNumber, required _NoteBook noteBook, required Size size, pb.NotePage? data, File? file}) {
    data ??= pb.NotePage()
      ..width = size.width
      ..height = size.height;
    if (isBookMark) {
      data.markNoteData = pb.MarkNotePageData();
      return MarkNotePage._(pageNumber, noteBook, data, file);
    } else {
      return IndependentNotePage._(pageNumber, noteBook, data, file);
    }
  }

  final int _pageNumber;
  final _NoteBook _noteBook;
  File? _file;
  final pb.NotePage _data;
  bool _dataChanged = false;
  pb.Path? _drawingPath;

  @protected
  NotePage(int pageNumber, _NoteBook noteBook, pb.NotePage data, File? file)
      : _pageNumber = pageNumber,
        _noteBook = noteBook,
        _data = data,
        _file = file;

  Map<int, pb.Pen> get _penPool => _data.penPool;

  List<pb.NotePageItem> get _items => _data.items;

  void startDraw() {
    assert(_drawingPath == null);

    const penId = 0; // todo: custom pen
    _penPool[penId] ??= pb.Pen()..strokeWidth = 3.0;
    _items.add(pb.NotePageItem()..path = _drawingPath = (pb.Path()..penId = penId));
  }

  void endDraw() {
    assert(_drawingPath != null);
    assert(_items.last.path == _drawingPath);

    if (_drawingPath!.points.isNotEmpty) {
      _dataChanged = true;
    } else {
      _items.removeLast();
    }
    _drawingPath = null;
  }

  void saveIfNeeded() async {
    if (!_dataChanged) return;
    _dataChanged = false;
    _file ??= await _noteBook.addBookMarkPage(_pageNumber);
    await _file!.writeAsBytes(_data.writeToBuffer());
  }

  void addPoint(Offset positionOnPage) {
    assert(_drawingPath != null);
    if (!_check(positionOnPage)) return;
    _drawingPath!.points.add(pb.Point(x: positionOnPage.dx, y: positionOnPage.dy));
    _triggerRepaint();
  }

  void forEachPageItem(void Function(pb.NotePageItem item) action) {
    _items.forEach(action);
  }

  int get defaultPenId => 0;
  pb.Pen getPen(int penId) {
    if (penId == defaultPenId) {
      return pb.Pen()
        ..strokeWidth = _defaultPenWidth
        ..color = Colors.black.value;
    }

    final result = _penPool[penId];
    assert(result != null);
    return result!;
  }

  @protected
  double get _defaultPenWidth;

  bool _check(Offset p);

  void _triggerRepaint() {
    notifyListeners();
  }
}

class MarkNotePage extends NotePage {
  MarkNotePage._(super.pageNumber, super.noteBook, super.data, super.file);

  Offset canvasPositionToPagePosition(Offset localPosition, Rect pageRect) {
    Offset result = Offset(localPosition.dx / pageRect.width, localPosition.dy / pageRect.height);
    return result = Offset(result.dx * _data.width, result.dy * _data.height);
  }

  Offset pagePositionToCanvasPosition(pb.Point pagePosition, Rect pageRect) {
    Offset result = Offset(pagePosition.x / _data.width, pagePosition.y / _data.height);
    return result = Offset(result.dx * pageRect.width, result.dy * pageRect.height);
  }

  double pageWidthToCanvasWidth(double v, Rect pageRect) {
    return v / _data.width * pageRect.width;
  }

  @override
  bool _check(Offset p) => p > const Offset(0, 0) && p < Offset(_data.width, _data.height);

  @override
  double get _defaultPenWidth => 1.0;
}

class IndependentNotePage extends NotePage {
  IndependentNotePage._(super.pageNumber, super.noteBook, super.data, super.file);

  Size get size => Size(_data.width, _data.height);

  double get _defaultPixelDensity => 1.0;

  Offset canvasPositionToPagePosition(Offset localPosition, double scale) => localPosition / _defaultPixelDensity / scale;

  Offset pagePositionToCanvasPosition(pb.Point pagePosition, double scale) =>
      Offset(pagePosition.x, pagePosition.y) * _defaultPixelDensity * scale;

  double pageWidthToCanvasWidth(double v, double scale) => v * _defaultPixelDensity * scale;

  @override
  bool _check(Offset p) => p > const Offset(0, 0) && p.dy < _data.height;

  @override
  double get _defaultPenWidth => 2.0;
}
