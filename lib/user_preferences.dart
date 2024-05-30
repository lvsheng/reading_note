import 'dart:io';
import 'dart:ui';

import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/pen.dart';
import 'package:reading_note/util/log.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

final UserPreferences userPreferences = UserPreferences._();

class UserPreferences {
  late Future<Null> readyFuture;
  SharedPreferences? _sharedPreferences;

  static const _keyLastOpenedFilePath = "lOFP";
  static const _keyPrefixLastPage = "lP";
  static const _keyPrefixLastNotePage = "lNP";
  static const _keyLastPenId = "lPI";
  static const _keyPrefixPenColor = "pC";
  static const _keyPrefixPenType = "pT";
  static const _keyPrefixPenLineWidth = "pW";
  static const _keyPenList = ["pLB", "pLI"];
  static const _keyCurrentPenId = ["cPIB", "cPII"];

  UserPreferences._() {
    readyFuture = SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  get ready => _sharedPreferences != null;

  Future<File?> get lastOpenedFile async {
    await Future.wait([readyFuture, fileSystemProxy.rootDirectoryReady]);

    final path = _sharedPreferences!.getString(_keyLastOpenedFilePath);
    if (path == null) {
      logInfo("no lastOpenedFilePath");
      return null;
    }

    final file = File("${fileSystemProxy.rootDirectory!.path}$path");
    if (!await file.exists()) {
      return null;
    }

    return file;
  }

  void setLastOpenedFile(File? file) async {
    await Future.wait([readyFuture, fileSystemProxy.rootDirectoryReady]);
    if (file == null) {
      _removeIfNeeded(_keyLastOpenedFilePath);
      return;
    }

    final path = p.relative(file.path, from: fileSystemProxy.rootDirectory!.path);
    logInfo("[userPreferences]: $_keyLastOpenedFilePath: $path");
    if (path == _sharedPreferences!.getString(_keyLastOpenedFilePath)) {
      return;
    }
    _sharedPreferences!.setString(_keyLastOpenedFilePath, path);
  }

  int? lastPageOf(File file) {
    if (!_allReady) return null;
    return _sharedPreferences!.getInt(_keyOfLastPage(file));
  }

  int? lastNotePageOf(File file) {
    if (!_allReady) return null;
    return _sharedPreferences!.getInt(_keyOfLastNotePage(file));
  }

  void setLastPage(File file, int? page) {
    if (!_allReady) return;
    _setInt(_keyOfLastPage(file), page);
  }

  void setLastNotePage(File file, int? page) {
    if (!_allReady) return;
    _setInt(_keyOfLastNotePage(file), page);
  }

  int get nextPenId => _sharedPreferences!.getInt(_keyLastPenId) ?? 0;

  set nextPenId(int value) => _setInt(_keyLastPenId, value);

  List<int>? penListOf(NoteType noteType) => _sharedPreferences!.getStringList(_keyPenList[noteType.index])?.map((string) => int.parse(string)).toList(growable: false);

  List<Pen> setPenList(NoteType noteType, List<Pen> list) {
    _sharedPreferences!.setStringList(_keyPenList[noteType.index], list.map((e) => "${e.id}").toList(growable: false));
    return list;
  }

  Color penColorOf(int id) => Color(_sharedPreferences!.getInt("$_keyPrefixPenColor$id") ?? 0);

  void setPenColorO(int id, Color value) => _setInt("$_keyPrefixPenColor$id", value.value);

  PenType penTypeOf(int id) => PenType.values[_sharedPreferences!.getInt("$_keyPrefixPenType$id") ?? 0];

  void setPenTypeOf(int id, PenType value) => _setInt("$_keyPrefixPenType$id", value.index);

  double penLineWidthOf(int id) => _sharedPreferences!.getDouble("$_keyPrefixPenLineWidth$id") ?? 1.0;

  void setPenLineWidthOf(int id, double value) => _setDouble("$_keyPrefixPenLineWidth$id", value);

  int currentPenIdOf(NoteType noteType) => _sharedPreferences!.getInt(_keyCurrentPenId[noteType.index]) ?? 0;

  void setCurrentPen(NoteType noteType, Pen pen) => _setInt(_keyCurrentPenId[noteType.index], pen.id);

  void _setInt(String key, int? value) {
    if (value == _sharedPreferences!.getInt(key)) {
      return;
    }
    if (value == null) {
      _removeIfNeeded(key);
      return;
    }
    logInfo("[userPreferences]: $key: $value");
    _sharedPreferences!.setInt(key, value);
  }

  void _setDouble(String key, double? value) {
    if (value == _sharedPreferences!.getDouble(key)) {
      return;
    }
    if (value == null) {
      _removeIfNeeded(key);
      return;
    }
    logInfo("[userPreferences]: $key: $value");
    _sharedPreferences!.setDouble(key, value);
  }

  bool get _allReady {
    if (_sharedPreferences == null) {
      logError("sharedPreference load slowly!");
      return false;
    }
    if (fileSystemProxy.rootDirectory == null) {
      logError("documentProxy load slowly!");
      return false;
    }
    return true;
  }

  /// must [_allReady] to use this
  String _keyOfLastPage(File file) => "$_keyPrefixLastPage:${p.relative(file.path, from: fileSystemProxy.rootDirectory!.path)}";

  String _keyOfLastNotePage(File file) => "$_keyPrefixLastNotePage:${p.relative(file.path, from: fileSystemProxy.rootDirectory!.path)}";

  /// must [readyFuture] to use this
  _removeIfNeeded(String key) {
    if (_sharedPreferences!.containsKey(key)) {
      _sharedPreferences!.remove(key);
    }
  }
}
