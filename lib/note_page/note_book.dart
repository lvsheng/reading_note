import 'dart:io';
import 'dart:ui';
import 'package:path/path.dart' as p;
import 'package:quiver/iterables.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:protobuf/protobuf.dart';
import 'package:reading_note/util/log.dart';
import 'note_page.dart';

class NoteBook {
  static final Map<String, NoteBook> _cacheForBookMark = {};
  static final Map<String, NoteBook> _cacheForIndependent = {};

  static NoteBook getOrCreate(File book, NoteType type) {
    final Map<String, NoteBook> cache = (type == NoteType.book) ? _cacheForBookMark : _cacheForIndependent;
    var result = cache[book.path];
    result ??= cache[book.path] = NoteBook._(book, type);
    // todo: unload file ?
    return result;
  }

  String getNotePageFilePath(int pageId) => "${_getNoteDirectory(book, _noteType)}$pageId.pb";

  static bool isNoteDirectory(String path) => path.endsWith(_notePostfix);

  static String _getNoteDirectory(File book, NoteType noteType) => "${_getBaseDirectory(book)}${_getMiddleDirectory(noteType)}";

  static String _getMetaFilePath(File book, NoteType noteType) => "${_getBaseDirectory(book)}${_getMiddleDirectory(noteType)}meta.pb";

  static const _notePostfix = ".note";

  static String _getBaseDirectory(File book) => "${p.dirname(book.path)}/${p.basename(book.path)}$_notePostfix/";

  static String _getMiddleDirectory(NoteType noteType) => noteType == NoteType.book ? "book_mark/" : "";

  late Future<void> ready;
  late final File book;
  late final File metaFile;
  final NoteType _noteType;
  pb.NoteBookMeta? _data;

  NoteBook._(this.book, this._noteType) {
    metaFile = File(_getMetaFilePath(book, _noteType));
    ready = _load();
  }

  _load() async {
    if (!await metaFile.exists()) {
      await metaFile.create(recursive: true);
      _data = pb.NoteBookMeta();
      _save();
      return;
    }

    // todo: read时保留只读，用户用笔修改时再deepCopy
    _data = pb.NoteBookMeta.fromBuffer(await metaFile.readAsBytes()).deepCopy();
  }

  _save() async {
    await metaFile.writeAsBytes(_data!.writeToBuffer());
  }

  int? noteIdOf(int pageNumber) {
    return _data!.pages[pageNumber]?.pageId;
  }

  int? get maxPageIndex => max(_data?.pages.keys ?? const []);

  Future<File> addNotePage(int pageNumber) {
    int pageId = ++_data!.lastPageId;
    return _createPageFile(
        pageId,
        () => _data!.pages[pageNumber] = pb.PageInfo()
          ..pageId = pageId
          ..createTimeInMinute = (DateTime.now().millisecondsSinceEpoch / 1000 / 60).round());
  }

  String getTitleOf(int pageNumber) => _data?.pages[pageNumber]?.title ?? "";

  String setTitleOf(int pageNumber, String title) {
    final page = _data!.pages[pageNumber];
    if (page == null) {
      logError("can't get page: $page");
      return "";
    }

    if (title == page.title) {
      return title;
    }

    page.title = title;
    _save();
    return title;
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
