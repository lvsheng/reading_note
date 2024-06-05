import 'dart:io';
import 'dart:ui';
import 'package:pdfrx/pdfrx.dart';
import 'package:path/path.dart' as p;
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:protobuf/protobuf.dart';
import 'note_page.dart';

class NoteBook {
  static final Map<String, NoteBook> _cacheForBookMark = {};
  static final Map<String, NoteBook> _cacheForIndependent = {};

  static NoteBook getOrCreate(File book, NoteType type, PdfDocument document) {
    final Map<String, NoteBook> cache = (type == NoteType.book) ? _cacheForBookMark : _cacheForIndependent;
    var result = cache[book.path];
    result ??= cache[book.path] = NoteBook._(book, type, document);
    // todo: unload file ?
    return result;
  }

  String getNotePageFilePath(int pageId) => "${_getNoteDirectory(book, _noteType)}$pageId.pb";

  static String _getNoteDirectory(File book, NoteType noteType) => "${_getBaseDirectory(book)}${_getMiddleDirectory(noteType)}";

  static String _getMetaFilePath(File book, NoteType noteType) => "${_getBaseDirectory(book)}${_getMiddleDirectory(noteType)}meta.pb";

  static String _getBaseDirectory(File book) => "${p.dirname(book.path)}/${p.basename(book.path)}.note/";

  static String _getMiddleDirectory(NoteType noteType) => noteType == NoteType.book ? "book_mark/" : "";

  late Future<void> ready;
  late final File book;
  late final PdfDocument document;
  final NoteType _noteType;
  late File _file;
  pb.NoteBookMeta? _data;

  NoteBook._(this.book, this._noteType, this.document) {
    _file = File(_getMetaFilePath(book, _noteType));
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
    return _data!.pages[pageNumber]?.pageId;
  }

  Future<File> addNotePage(int pageNumber) {
    int pageId = ++_data!.lastPageId;
    return _createPageFile(pageId, () => _data!.pages[pageNumber] = pb.PageInfo()..pageId = pageId..createTimeInMinute = (DateTime.now().millisecondsSinceEpoch / 1000 / 60).round());
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
