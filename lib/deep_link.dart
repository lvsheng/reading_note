import 'dart:io';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/util/log.dart';

import 'note_page/note_book.dart';

/// [originUri]: e.g: lsreadingnoteapp:///import-file?path=%2Fprivate...952539.pdf
String? _parseUri(Uri uri) {
  if (uri.scheme != "lsreadingnoteapp") {
    logWarn("unknown scheme: $uri");
    return null;
  }

  if (uri.path != "/import-file") {
    logWarn("unknown path: $uri");
    return null;
  }

  var filePath = uri.queryParameters["path"];
  if (filePath == null) {
    logWarn("no file path: $uri");
    return null;
  }

  return filePath;
}

String _getFileName(String importingFilePath) {
  final String fileName =
      (importingFilePath.split('/').last.split("_")..removeLast()).join("_"); // 去除[ActionViewController.swift:copyPDF]中所加的时间戳后缀
  var pieces = fileName.split(".");
  final String post = pieces.removeLast();
  final String pre = pieces.join(".");
  return "$pre.$post";
}

Future<File> _findOrCreateDestFile(String rootPath, String destFileName, String importingFilePath) async {
  File? destFile;

  final directory = Directory(rootPath);
  if (await directory.exists()) {
    destFile = await _find(directory, destFileName, NoteBook.isNoteDirectory);
  }

  if (destFile != null) {
    logInfo("file already exist: $destFile");
  } else {
    destFile = File("$rootPath$destFileName");
    assert(!await destFile.exists());
    await destFile.create(recursive: true);
    await destFile.writeAsBytes(await File(importingFilePath).readAsBytes(), flush: true);
    logDebug("write done to $destFile");
  }

  return destFile;
}

Future<File?> _find(Directory directory, String targetFileName, bool Function(String directoryName) skip) async {
  await for (var entity in directory.list()) {
    if (entity is Directory) {
      if (skip(entity.path)) continue;
      final subResult = await _find(entity, targetFileName, skip);
      if (subResult != null) return subResult;
    }

    if (entity is File && entity.uri.pathSegments.last == targetFileName) {
      return entity;
    }
  }

  return null;
}

/// [deepLinkUri] example: "/private/var/mobile/Containers/Shared/AppGroup/xxx/importing/xxx"
Future<File> importFile(Uri deepLinkUri) async {
  final importingFilePath = _parseUri(deepLinkUri);
  if (importingFilePath == null) throw Error();

  String rootPath = (await fileSystemProxy.rootDirectoryReady).path;
  if (rootPath[rootPath.length - 1] != "/") rootPath += "/";

  return _findOrCreateDestFile(rootPath, _getFileName(importingFilePath), importingFilePath);
}
