import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:protobuf/protobuf.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;

// todo-p4: 考虑文件io失败
class _NoteBook {
  static final Map<String, _NoteBook> cacheForBookMark = {};
  static final Map<String, _NoteBook> cacheForIndependent = {};

  static _NoteBook getOrCreate(File book, bool isBookMark) {
    final Map<String, _NoteBook> cache = isBookMark ? cacheForBookMark : cacheForIndependent;
    var result = cache[book.path];
    result ??= cache[book.path] = _NoteBook._(book, isBookMark);
    // todo: unload file ?
    return result;
  }

  static String getNoteDirectory(File book, bool isBookMark) => "${getBaseDirectory(book)}${getMiddleDirectory(isBookMark)}";

  static String getMetaFilePath(File book, bool isBookMark) => "${getBaseDirectory(book)}${getMiddleDirectory(isBookMark)}meta.pb";

  static String getBaseDirectory(File book) => "${p.dirname(book.path)}/${p.basename(book.path)}.note/";

  static String getMiddleDirectory(bool isBookMark) => isBookMark ? "book_mark/" : "";

  String getNotePageFilePath(int pageId) => "${getNoteDirectory(book, isBookMark)}$pageId.pb";

  bool isBookMark;
  late File book;
  late File file;
  late Future<void> ready;
  pb.NoteBookMeta? data;

  _NoteBook._(this.book, this.isBookMark) {
    file = File(getMetaFilePath(book, isBookMark));
    ready = load();
  }

  load() async {
    if (!await file.exists()) {
      await file.create(recursive: true);
      data = pb.NoteBookMeta();
      if (isBookMark) {
        data!.bookMarkNoteBookMeta = pb.BookMarkNoteBookMeta();
      } else {
        data!.independentNoteBookMeta = pb.IndependentNoteBookMeta();
      }
      save();
      return;
    }

    data = pb.NoteBookMeta.fromBuffer(await file.readAsBytes()).deepCopy();
  }

  save() async {
    await file.writeAsBytes(data!.writeToBuffer());
  }

  int? noteIdOf(int pageNumber) {
    if (isBookMark) {
      return data!.bookMarkNoteBookMeta.pages[pageNumber];
    } else {
      throw "TODO";
    }
  }

  Future<File> addBookMarkPage(int pageNumber) async {
    assert(isBookMark);
    int pageId = data!.bookMarkNoteBookMeta.lastPageId++;
    final pageFile = File(getNotePageFilePath(pageId));
    assert(!await pageFile.exists());
    await pageFile.create(recursive: true);
    data!.bookMarkNoteBookMeta.pages[pageNumber] = pageId;
    await save();
    return pageFile;
  }
}

class BookMarkNotePage extends ChangeNotifier {
  static Future<BookMarkNotePage> open(File book, int pageNumber, Size size) async {
    final noteBook = _NoteBook.getOrCreate(book, true);
    await noteBook.ready;

    int? noteId = noteBook.noteIdOf(pageNumber);

    if (noteId == null) {
      return BookMarkNotePage._(pageNumber, size, noteBook, pb.NotePage(), null /*暂不创建磁盘文件*/);
    }

    final file = File(noteBook.getNotePageFilePath(noteId));

    if (!await file.exists()) {
      logError("page file disappeared: $file");
      return BookMarkNotePage._(pageNumber, size, noteBook, pb.NotePage(), file);
    }

    return BookMarkNotePage._(pageNumber, size, noteBook, pb.NotePage.fromBuffer(await file.readAsBytes()).deepCopy(), file);
  }

  int pageNumber;
  final _NoteBook _noteBook;
  File? _file;
  final Size _size;
  final pb.NotePage _data;
  bool _dataChanged = false;
  pb.Path? _drawingPath;

  BookMarkNotePage._(this.pageNumber, this._size, this._noteBook, this._data, this._file) {
    _data.width = _size.width;
    _data.height = _size.height;
  }

  void startDraw() {
    assert(_drawingPath == null);

    const penId = 0;
    if (_data.penPool[penId] == null) {
      _data.penPool[penId] = pb.Pen()..strokeWidth = 3.0;
    }
    _data.items.add(pb.NotePageItem()..path = _drawingPath = (pb.Path()..penId = penId));
  }

  void endDraw() {
    assert(_drawingPath != null);
    if (_drawingPath!.points.isEmpty) {
      assert(_data.items.last == _drawingPath);
      _data.items.removeLast();
    } else {
      _dataChanged = true;
    }
    _drawingPath = null;
  }

  void saveIfNeeded() async {
    if (!_dataChanged) return;
    _dataChanged = false;
    _file ??= await _noteBook.addBookMarkPage(pageNumber);
    await _file!.writeAsBytes(_data.writeToBuffer());
  }

  void addPoint(Offset p) {
    assert(_drawingPath != null);
    if (!_check(p)) return;
    _drawingPath!.points.add(pb.Point(x: p.dx, y: p.dy));
    _triggerRepaint();
  }

  static Offset canvasPositionToPagePosition(Offset localPosition, Rect pageRect, Size pageSize) {
    Offset result = Offset(localPosition.dx / pageRect.width, localPosition.dy / pageRect.height);
    return result = Offset(result.dx * pageSize.width, result.dy * pageSize.height);
  }

  static Offset pagePositionToCanvasPosition(pb.Point pagePosition, Rect pageRect, Size pageSize) {
    Offset result = Offset(pagePosition.x / pageSize.width, pagePosition.y / pageSize.height);
    return result = Offset(result.dx * pageRect.width, result.dy * pageRect.height);
  }

  void forEachPageItem(void Function(pb.NotePageItem item) action) {
    _data.items.forEach(action);
  }

  bool _check(Offset p) {
    return p > const Offset(0, 0) && p < Offset(_size.width, _size.height);
  }

  void _triggerRepaint() {
    notifyListeners();
  }
}
