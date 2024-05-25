import 'dart:io';

import 'package:reading_note/document_proxy.dart';
import 'package:reading_note/log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;

final UserPreferences userPreferences = UserPreferences._();

class UserPreferences {
  late Future<Null> ready;
  SharedPreferences? _sharedPreferences;

  static const _key_lastOpenedFilePath = "lastOpenedFilePath";

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

    final path = _sharedPreferences!.getString(_key_lastOpenedFilePath);
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

  setLastOpenedFile(File? value) async {
    await Future.wait([ready, documentProxy.rootDirectoryReady]);
    if (value == null) {
      if (_sharedPreferences!.containsKey(_key_lastOpenedFilePath)) {
        _sharedPreferences!.remove(_key_lastOpenedFilePath);
      }
      return;
    }

    final path = p.relative(value.path, from: documentProxy.rootDirectory!.path);
    logInfo("[userPreferences]: $_key_lastOpenedFilePath: $path");
    if (path == _sharedPreferences!.getString(_key_lastOpenedFilePath)) {
      return;
    }
    _sharedPreferences!.setString(_key_lastOpenedFilePath, path);
  }
}
