import 'dart:io';

import 'package:reading_note/document_proxy.dart';
import 'package:reading_note/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences sharedInstance = UserPreferences();

  late Future<Null> ready;
  SharedPreferences? _sharedPreferences;

  UserPreferences() {
    ready = SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
    });
  }

  Future<File?> get lastOpenedFile async {
    await Future.wait([
      ready,
      DocumentProxy.sharedInstance.rootDirectoryReady,
    ]);

    final path = _sharedPreferences!.getString("lastOpenedFilePath");
    if (path == null) {
      logWarn("no lastOpenedFilePath");
      return null;
    }

    final file = File("${DocumentProxy.sharedInstance.rootDirectory!.path}$path");
    if (!await file.exists()) {
      return null;
    }

    return file;
  }
}