import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reading_note/util/log.dart';

class DocumentProxy {
  static const MethodChannel _channel = MethodChannel('document_proxy');
  static final DocumentProxy sharedInstance = DocumentProxy();

  late Future<Directory> rootDirUri;

  DocumentProxy() {
    rootDirUri = _rootDirUri;
  }

  Future<Directory> get _rootDirUri async {
    String? result;
    try {
      result = await _channel.invokeMethod('getRootDirUri');
    } catch (e) {
      logError("getRootDirUri fail: $e");
    }

    if (result != null) {
      try {
        return Directory(Uri.parse(result).path);
      } catch (e) {
        logError("$e");
      }
    }

    logWarn("Could not get iCloud document directory, using ApplicationDocumentDirectory as fallback.");
    return getApplicationDocumentsDirectory();
  }
}