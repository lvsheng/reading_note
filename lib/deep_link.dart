import 'dart:io';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/util/log.dart';

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

Future<File> importFile(Uri deepLinkUri) async {
  final importingFilePath = _parseUri(deepLinkUri);
  if (importingFilePath == null) {
    throw Error();
  }

  final fileContent = await File(importingFilePath).readAsBytes();

  late final String destFileName;
  {
    final String fileName = (importingFilePath.split('/').last
        // 去除[ActionViewController.swift:copyPDF]中所加的时间戳后缀
        .split("_")..removeLast()).join("_");
    var pieces = fileName.split(".");
    final String post = pieces.removeLast();
    final String pre = pieces.join(".");
    destFileName = "$pre.$post";
  }

  String rootPath = (await fileSystemProxy.rootDirectoryReady).path;
  if (rootPath[rootPath.length - 1] != "/") {
    logWarn("rootPath is not endwith /: $rootPath");
    rootPath += "/";
  }
  final destFile = File("$rootPath$destFileName");
  if (!await destFile.exists()) {
    // todo: 由DocumentProxy通知platform后再进行创建写入等操作
    await destFile.create(recursive: true);
    await destFile.writeAsBytes(fileContent, flush: true);
    logDebug("write done to $destFile (size:${fileContent.length})");
  } else {
    // todo:去后缀md5，不加一层中间目录
    logInfo("file already exist");
    // todo: 通知用户当前目录已有此文件？询问是否重新导入？
  }

  // todo: clean importing files

  return destFile;
}
