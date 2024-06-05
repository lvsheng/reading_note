import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:protobuf/protobuf.dart';
import 'package:reading_note/status_manager/status_manager.dart';

const _writeToFile = false;

void saveBytes(Uint8List bytes, String name) async {
  if (!_writeToFile) return;
  if (!kDebugMode) return;
  final file = File("${p.dirname(statusManager.reading!.path)}/debug/$name");
  await file.create(recursive: true);
  await file.writeAsBytes(bytes);
}

void savePng(Uint8List bytes, String name) async {
  if (!_writeToFile) return;
  if (!kDebugMode) return;
  saveBytes(bytes, "$name.png");
}

void saveUIImage(ui.Image image, String name) async {
  if (!_writeToFile) return;
  if (!kDebugMode) return;
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  savePng(byteData!.buffer.asUint8List(), name);
}

void saveImage(img.Image image, String name) async {
  if (!_writeToFile) return;
  if (!kDebugMode) return;
  savePng(img.encodePng(image), name);
}

void saveIntList(List<int> list, String name) async {
  if (!_writeToFile) return;
  if (!kDebugMode) return;
  saveBytes(Uint8List.fromList(list).buffer.asUint8List(), name);
}

void saveGeneratedMessage(GeneratedMessage message, String name) async {
  if (!_writeToFile) return;
  if (!kDebugMode) return;
  saveBytes(message.writeToBuffer(), name);
}

void saveByteData(ByteData byteData, String name) async {
  if (!_writeToFile) return;
  if (!kDebugMode) return;
  saveBytes(byteData.buffer.asUint8List(0, byteData.lengthInBytes), name);
}
