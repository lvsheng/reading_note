import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reading_note/log.dart';
import 'package:path/path.dart' as path;

final DocumentProxy documentProxy = DocumentProxy._();

class DocumentProxy {
  static const MethodChannel _channel = MethodChannel('document_proxy');

  static const supportedFileTypes = {".pdf"};
  static bool support(FileSystemEntity file) => file is File &&
      supportedFileTypes.contains(path.extension(file.path));

  late Future<Directory> rootDirectoryReady;
  Directory? rootDirectory;

  DocumentProxy._() {
    rootDirectoryReady =
        _fetchRootDirUri().then((value) => rootDirectory = value);
  }

  Future<File?> get firstFile async {
    await rootDirectoryReady;
    final notFound = File("./");
    final result = (await rootDirectory!.list(recursive: true).firstWhere((file) {
      return support(file);
    }, orElse: () => notFound)) as File;
    return result.hashCode == notFound.hashCode ? null : result;
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

    logWarn(
        "Could not get iCloud document directory, using ApplicationDocumentDirectory as fallback.");
    return getApplicationDocumentsDirectory();
  }
}
