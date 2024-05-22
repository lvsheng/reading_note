import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:reading_note/util/log.dart';

/// [originUri]: e.g: lsreadingnoteapp:///import-file?url=file%3A%2F%2F%2Fprivate...952539.pdf
String? parseImportedFileUri(Uri originUri) {
  if (originUri.scheme != "lsreadingnoteapp") {
    logWarn("unknown scheme: ${originUri}");
    return null;
  }

  if (originUri.path != "/import-file") {
    logWarn("unknown path: ${originUri}");
    return null;
  }

  var fileUrl = originUri.queryParameters["url"];
  if (fileUrl == null) {
    logWarn("no file url: ${originUri}");
    return null;
  }

  fileUrl = Uri.decodeComponent(fileUrl);
  if (!fileUrl.startsWith("file:///")) {
    logWarn("Invalid file path: ${originUri}");
    return null;
  }

  return fileUrl;
}

Future<File> copySharedFileToLocal(String fileUriString) async {
  final fileUri = Uri.parse(fileUriString);
  final filePath = fileUri.path;

  final directory = await getApplicationDocumentsDirectory();
  final String fileName = filePath.split('/').last;
  final String newFilePath = '${directory.path}/$fileName';

  final file = File(filePath);
  logInfo("fileUriString: ${fileUriString}");
  logInfo("filePath: ${filePath}");
  logInfo("file exist: ${file.existsSync()}");

  final File newFile = await File(filePath).copy(newFilePath);

  logInfo('File copied to: $newFilePath');

  return newFile;
}