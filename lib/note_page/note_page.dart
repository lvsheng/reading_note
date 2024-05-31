import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:protobuf/protobuf.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import '../pen/pen_stroke_tracker.dart';
import 'independent_note_page.dart';
import 'mark_note_page.dart';
import 'note_book.dart';

enum NoteType {
  // fixme: change name
  book, // = 0. DO NOT CHANGE ORDER - INDEX IS USED!
  note, // = 1. DO NOT CHANGE ORDER - INDEX IS USED!
}

// todo-p4: 考虑文件io失败
/// Main data model, based above local file
abstract class NotePage extends ChangeNotifier {
  static Future<NotePage> open(NoteType noteType, File book, PdfDocument document, int pageNumber, Size desiredSize) async {
    final noteBook = NoteBook.getOrCreate(book, noteType, document);
    await noteBook.ready;

    int? noteId = noteBook.noteIdOf(pageNumber);

    if (noteId == null) {
      // 无旧数据，暂不创建磁盘文件，必要时再创建
      return _create(noteType: noteType, pageNumber: pageNumber, noteBook: noteBook, size: desiredSize);
    }

    final file = File(noteBook.getNotePageFilePath(noteId));

    pb.NotePage? data;
    if (await file.exists()) {
      // fixme: only do deepCopy when begin edit
      data = pb.NotePage.fromBuffer(await file.readAsBytes()).deepCopy();
      assert(noteType == NoteType.book
          ? data.whichContent() == pb.NotePage_Content.markNoteData
          : data.whichContent() == pb.NotePage_Content.independentNoteData);
    } else {
      logError("page file disappeared: $file");
    }

    return _create(noteType: noteType, pageNumber: pageNumber, noteBook: noteBook, size: desiredSize, data: data, file: file);
  }

  static NotePage _create(
      {required NoteType noteType,
      required int pageNumber,
      required NoteBook noteBook,
      required Size size,
      pb.NotePage? data,
      File? file}) {
    if (data == null) {
      data = pb.NotePage()
        ..width = size.width
        ..height = size.height;
      if (noteType == NoteType.book) {
        data.markNoteData = pb.MarkNotePageData();
      } else {
        data.independentNoteData = pb.IndependentNotePageData();
      }
    }

    if (noteType == NoteType.book) {
      return MarkNotePage(pageNumber, noteBook, data, file);
    } else {
      return IndependentNotePage(pageNumber, noteBook, data, file);
    }
  }

  final NoteBook noteBook;

  @protected
  final pb.NotePage data;
  final int pageNumber;

  File? _file;
  bool _dataChanged = false;
  PenStrokeTracker? _drawing;

  @protected
  NotePage(this.pageNumber, this.noteBook, this.data, File? file) : _file = file;

  void penDown(Offset positionOnPage) {
    assert(_drawing == null);
    _drawing = statusManager.usingPen.beginPaint(data, positionOnPage, this);
    triggerRepaint();
  }

  void penMove(Offset positionOnPage) {
    assert(_drawing != null);
    if (!check(positionOnPage)) return;
    _drawing!.move(positionOnPage);
    triggerRepaint();
  }

  bool penUp() {
    assert(_drawing != null);
    final effective = _drawing!.end();
    _dataChanged = _dataChanged || effective;
    _drawing = null;
    return effective;
  }

  void saveIfNeeded() async {
    if (!_dataChanged) return;
    _dataChanged = false;
    _file ??= await noteBook.addNotePage(pageNumber);
    await _file!.writeAsBytes(data.writeToBuffer());
  }

  void forEachPageItem(void Function(pb.NotePageItem item, int index, int length) action) {
    final length = data.items.length;
    for (final (index, item) in data.items.indexed) {
      action(item, index, length);
    }
  }

  int get defaultPenId => 0;

  pb.Pen getPen(int penId) {
    if (penId == defaultPenId) {
      return pb.Pen()
        ..lineWidth = defaultPenWidth
        ..color = CupertinoColors.black.value;
    }

    final result = data.penPool[penId];
    assert(result != null);
    return result!;
  }

  @protected
  double get defaultPenWidth;

  @protected
  bool check(Offset p);

  void triggerRepaint() {
    notifyListeners();
  }
}
