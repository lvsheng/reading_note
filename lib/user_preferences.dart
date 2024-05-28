import 'dart:io';

import 'package:reading_note/document_proxy.dart';
import 'package:reading_note/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

final UserPreferences userPreferences = UserPreferences._();

class UserPreferences {
  late Future<Null> ready;
  SharedPreferences? _sharedPreferences;

  static const _keyLastOpenedFilePath = "lastOpenedFilePath";
  static const _keyPrefixLastPage = "lastPageOf";
  static const _keyPrefixLastNotePage = "lastNotePageOf";

  UserPreferences._() {
    ready = SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  Future<File?> get lastOpenedFile async {
    await Future.wait([
      ready,
      documentProxy.rootDirectoryReady,
    ]);

    final path = _sharedPreferences!.getString(_keyLastOpenedFilePath);
    if (path == null) {
      logWarn("no lastOpenedFilePath");
      return null;
    }

    final file = File("${documentProxy.rootDirectory!.path}$path");
    if (!await file.exists()) {
      return null;
    }

    return file;
  }

  setLastOpenedFile(File? file) async {
    await Future.wait([ready, documentProxy.rootDirectoryReady]);
    if (file == null) {
      return _removeIfNeeded(_keyLastOpenedFilePath);
    }

    final path = p.relative(file.path, from: documentProxy.rootDirectory!.path);
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

  bool get _allReady {
    if (_sharedPreferences == null) {
      logError("sharedPreference load slowly!");
      return false;
    }
    if (documentProxy.rootDirectory == null) {
      logError("documentProxy load slowly!");
      return false;
    }
    return true;
  }

  /// must [_allReady] to use this
  String _keyOfLastPage(File file) => "$_keyPrefixLastPage:${p.relative(file.path, from: documentProxy.rootDirectory!.path)}";
  String _keyOfLastNotePage(File file) => "$_keyPrefixLastNotePage:${p.relative(file.path, from: documentProxy.rootDirectory!.path)}";

  /// must [ready] to use this
  _removeIfNeeded(String key) {
    if (_sharedPreferences!.containsKey(key)) {
      _sharedPreferences!.remove(key);
    }
  }
}
