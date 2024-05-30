import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:pdfrx/pdfrx.dart';
import 'package:protobuf/protobuf.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/matte_transfer_station.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';

// todo-p4: 考虑文件io失败
class _NoteBook {
  static final Map<String, _NoteBook> _cacheForBookMark = {};
  static final Map<String, _NoteBook> _cacheForIndependent = {};

  static _NoteBook getOrCreate(File book, bool isBookMark, PdfDocument document) {
    final Map<String, _NoteBook> cache = isBookMark ? _cacheForBookMark : _cacheForIndependent;
    var result = cache[book.path];
    result ??= cache[book.path] = _NoteBook._(book, isBookMark, document);
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
  late final PdfDocument _document;
  pb.NoteBookMeta? _data;

  _NoteBook._(this._book, this._isBookMark, this._document) {
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
    int pageId = ++_data!.lastPageId;
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
  static Future<NotePage> open(bool isBookMark, File book, PdfDocument document, int pageNumber, Size desiredSize) async {
    final noteBook = _NoteBook.getOrCreate(book, isBookMark, document);
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
    if (data == null) {
      data = pb.NotePage()
        ..width = size.width
        ..height = size.height;
      if (isBookMark) {
        data.markNoteData = pb.MarkNotePageData();
      } else {
        data.independentNoteData = pb.IndependentNotePageData();
      }
    }

    if (isBookMark) {
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
  pb.NotePageItem? _drawing;

  @protected
  NotePage(int pageNumber, _NoteBook noteBook, pb.NotePage data, File? file)
      : _pageNumber = pageNumber,
        _noteBook = noteBook,
        _data = data,
        _file = file;

  Map<int, pb.Pen> get _penPool => _data.penPool;

  List<pb.NotePageItem> get _items => _data.items;

  void startDraw(Offset positionOnPage) {
    assert(_drawing == null);

    const penId = 0; // todo: custom pen
    _penPool[penId] ??= pb.Pen()..strokeWidth = 3.0;
    _items.add(_drawing = pb.NotePageItem()
      ..x = positionOnPage.dx
      ..y = positionOnPage.dy
      ..path = (pb.Path()..penId = penId));
  }

  bool endDraw() {
    assert(_drawing != null);
    assert(_items.last == _drawing);

    bool success = _drawing!.path.points.isNotEmpty;
    if (success) {
      _dataChanged = true;
    } else {
      _items.removeLast();
    }
    _drawing = null;
    return success;
  }

  void saveIfNeeded() async {
    if (!_dataChanged) return;
    _dataChanged = false;
    _file ??= await _noteBook.addBookMarkPage(_pageNumber);
    await _file!.writeAsBytes(_data.writeToBuffer());
  }

  void addPoint(Offset positionOnPage) {
    assert(_drawing != null);
    if (!_check(positionOnPage)) return;
    _drawing!.path.points.add(pb.Point(x: positionOnPage.dx - _drawing!.x, y: positionOnPage.dy - _drawing!.y));
    triggerRepaint();
  }

  void forEachPageItem(void Function(pb.NotePageItem item) action) {
    _items.forEach(action);
  }

  int get defaultPenId => 0;
  pb.Pen getPen(int penId) {
    if (penId == defaultPenId) {
      return pb.Pen()
        ..strokeWidth = _defaultPenWidth
        ..color = CupertinoColors.black.value;
    }

    final result = _penPool[penId];
    assert(result != null);
    return result!;
  }

  @protected
  double get _defaultPenWidth;

  bool _check(Offset p);

  void triggerRepaint() {
    notifyListeners();
  }
}

class MarkNotePage extends NotePage {
  MarkNotePage._(super.pageNumber, super.noteBook, super.data, super.file);

  Offset canvasPositionToPagePosition(Offset localPosition, Rect pageRect) {
    Offset result = Offset(localPosition.dx / pageRect.width, localPosition.dy / pageRect.height);
    return result = Offset(result.dx * _data.width, result.dy * _data.height);
  }

  Offset pagePositionToCanvas(pb.Point pagePosition, Rect pageRect) {
    Offset result = Offset(pagePosition.x / _data.width, pagePosition.y / _data.height);
    return result = Offset(result.dx * pageRect.width, result.dy * pageRect.height);
  }

  double pageWidthToCanvas(double v, Rect pageRect) => v / _data.width * pageRect.width;

  double _pageHeightToCanvas(double v, Rect pageRect) => v / _data.height * pageRect.height;

  Rect pageRectToCanvas(Rect rect, Rect pageRect) => Rect.fromLTRB(pageWidthToCanvas(rect.left, pageRect),
      _pageHeightToCanvas(rect.top, pageRect), pageWidthToCanvas(rect.right, pageRect), _pageHeightToCanvas(rect.bottom, pageRect));

  pb.MattingMark? mattingMarkOfId(int id) => _data.markNoteData.mattingMarkPool[id];

  @visibleForTesting
  get mattingMarkPool => _data.markNoteData.mattingMarkPool;

  @override
  bool endDraw() {
    if (!super.endDraw()) return false;

    final tuple = _addMattingMark();
    MattingManager.instanceOf(_noteBook._book).startOne(tuple.item2, tuple.item1, _noteBook._document, _pageNumber);

    return true;
  }

  Tuple2<int, pb.MattingMark> _addMattingMark() {
    final drawingItem = _data.items.last;
    final endPoint = drawingItem.path.points.last; // fixme
    final id = ++_data.markNoteData.lastMattingMarkId;
    final startX = drawingItem.x;
    final endX = drawingItem.x + endPoint.x;
    final result = _data.markNoteData.mattingMarkPool[id] = pb.MattingMark()
      ..horizontal = (pb.MattingMarkHorizontal()
        ..left = min(startX, endX)
        ..right = max(startX, endX)
        ..y = drawingItem.y + endPoint.y / 2
        ..height = (endPoint.y).abs());
    _data.items.add(pb.NotePageItem()..mattingMarkId = id);
    triggerRepaint();
    return Tuple2(id, result);
  }

  @override
  bool _check(Offset p) => p > const Offset(0, 0) && p < Offset(_data.width, _data.height);

  @override
  double get _defaultPenWidth => 1.0;
}

class IndependentNotePage extends NotePage {
  IndependentNotePage._(super.pageNumber, super.noteBook, super.data, super.file) {
    MattingManager.instanceOf(_noteBook._book).addListener(_mattingStatusListener);
  }

  @override
  void dispose() {
    MattingManager.instanceOf(_noteBook._book).removeListener(_mattingStatusListener);
    super.dispose();
  }

  @override
  void startDraw(Offset positionOnPage) {
    _tryPlaceMatte(positionOnPage);
    return super.startDraw(positionOnPage);
  }

  void _tryPlaceMatte(Offset positionOnPage) {
    final newMattes = MattingManager.instanceOf(_noteBook._book).takeAwayResults();
    if (newMattes == null) return;
    for (final matte in newMattes) {
      final id = ++_data.independentNoteData.lastMatteId;
      _data.independentNoteData.mattePool[id] = matte;
      _data.items.add(pb.NotePageItem()
        ..x = positionOnPage.dx
        ..y = positionOnPage.dy
        ..matteId = id);
    }
    triggerRepaint();
  }

  Size get size => Size(_data.width, _data.height);

  double get _defaultPixelDensity => 1.0;

  Offset canvasPositionToPage(Offset localPosition, double scale) => localPosition / _defaultPixelDensity / scale;

  Offset pagePositionToCanvas(pb.Point pagePosition, double scale) => pageOffsetToCanvas(Offset(pagePosition.x, pagePosition.y), scale);

  Offset pageOffsetToCanvas(Offset pageOffset, double scale) => pageOffset * _defaultPixelDensity * scale;

  double pageWidthToCanvas(double v, double scale) => v * _defaultPixelDensity * scale;

  pb.Matte? matteOfId(int id) => _data.independentNoteData.mattePool[id];

  @override
  bool _check(Offset p) => p > const Offset(0, 0) && p.dy < _data.height;

  @override
  double get _defaultPenWidth => 2.0;

  void _mattingStatusListener() {
    // todo: 改变状态?
  }
}
