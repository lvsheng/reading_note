import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reading_note/util/log.dart';
import 'package:path/path.dart' as p;

final FileSystemProxy fileSystemProxy = FileSystemProxy._();

class FileSystemProxy {
  static const MethodChannel _channel = MethodChannel('document_proxy');
  static const _supportedFileTypes = {".pdf"};

  static bool _support(FileSystemEntity file) => file is File && _supportedFileTypes.contains(p.extension(file.path));

  late final Future<Directory> rootDirectoryReady;
  Directory? rootDirectory;

  FileSystemProxy._() {
    rootDirectoryReady = _fetchRootDirUri().then((value) => rootDirectory = value);
  }

  Future<File?> get firstFile async {
    await rootDirectoryReady;
    final notFound = File("./");
    final result = (await rootDirectory!.list(recursive: true).firstWhere(_support, orElse: () => notFound)) as File;
    return result.hashCode == notFound.hashCode ? null : result;
  }

  String localPath(File file) {
    return p.relative(file.path, from: rootDirectory!.path);
  }

  Future<Directory> _fetchRootDirUri() async {
    String? result;
    try {
      logDebug("begin invoke channel getRootDirUri");
      result = await _channel.invokeMethod('getRootDirUri');
    } catch (e) {
      logError("getRootDirUri fail: $e", false);
    }

    if (result != null) {
      try {
        final directory = Directory.fromUri(Uri.parse(result));
        if (await directory.exists()) {
          logInfo("Got iCloud directory as root dir: $directory");
          return directory;
        } else {
          logError("iCloud directory not exist: $directory");
        }
      } catch (e) {
        logError("$e");
      }
    }

    logWarn("Could not get iCloud document directory, using ApplicationDocumentDirectory as fallback");
    return getApplicationDocumentsDirectory().then((result) {
      logDebug("getApplicationDocumentsDirectory:$result");
      return result;
    });
  }
}
