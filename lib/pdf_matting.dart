import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';
import 'package:quiver/collection.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:path/path.dart' as p;
import 'package:tuple/tuple.dart';

import 'log.dart';

// todo: promise reject handle
// todo: async decode/encode

const _pdfPageCaptureSizeMultiple = 3;
final _pageImageMap = LruMap<String, img.Image>(maximumSize: 5); // todo: captureing future tuple
final _mattingDecodeResultMap = LruMap<pb.MattingResult, Tuple2<ByteData?, Future<ByteData?>?>>(maximumSize: 200);

File? testingFile;
Future<pb.MattingResult> matting(File file, PdfDocument document, int pageNumber, pb.MattingMark mark, int markId) async {
  testingFile = file; // fixme

  final page = document.pages[pageNumber];
  final pageImageKey = _genKey(file, pageNumber);

  late img.Image? pageImage;
  {
    pageImage = _pageImageMap[pageImageKey];
    pageImage ??= await _capture(file, page);
    if (pageImage == null) {
      logError("_capture fail: $file, $pageNumber, $document, $page");
      return pb.MattingResult();
    }
    _pageImageMap[pageImageKey] = pageImage;
  }

  late ui.Rect clippedRect;
  {
    switch (mark.whichContent()) {
      case pb.MattingMark_Content.horizontal:
        final halfHeight = mark.horizontal.height / 2;
        clippedRect =
            ui.Rect.fromLTRB(mark.horizontal.startX, mark.horizontal.y - halfHeight, mark.horizontal.endX, mark.horizontal.y + halfHeight);
        break;

      case pb.MattingMark_Content.vertical:
      case pb.MattingMark_Content.line:
      case pb.MattingMark_Content.rectangle:
        throw "TODO";

      case pb.MattingMark_Content.notSet:
        logError("INVALID MattingMark $mark");
    }
    clippedRect = clippedRect * _pdfPageCaptureSizeMultiple.toDouble();
  }

  int width = clippedRect.width.round();
  int height = clippedRect.height.round();
  final cropResult = img
      .copyCrop(pageImage, x: clippedRect.left.round(), y: clippedRect.right.round(), width: width, height: height);

/*
  _saveImageForDebug2(file, cropResult, "cropResult");
*/

  final bytes = cropResult.buffer.asUint8List();
  final result = pb.MattingResult()
    ..bookPageNumber = pageNumber
    ..bookPageMattingMarkId = markId
    ..imageWidth = width
    ..imageHeight = height
    ..imageData = bytes; // todo: zip

/*
  _saveImageForDebug2(file, img.Image.fromBytes(
    width: width,
    height: height,
    bytes: Uint8List.fromList(result.imageData).buffer,
    format: img.Format.uint2,
    numChannels: 1,
  ), "cropResult.decode");
*/

  imageOfMattingResult(result); // just trigger, no wait

  return result;
}

Future<ByteData?> imageOfMattingResult(pb.MattingResult mattingResult) async {
  final tuple = _mattingDecodeResultMap[mattingResult];
  if (tuple != null) {
    if (tuple.item1 != null) {
      return tuple.item1!;
    }
    return tuple.item2!;
  }

  final image = img.Image.fromBytes(
    width: mattingResult.imageWidth,
    height: mattingResult.imageHeight,
    bytes: Uint8List.fromList(mattingResult.imageData).buffer,
    format: img.Format.uint2,
    numChannels: 1,
  );
  _saveImageForDebug2(testingFile!, image, "decode");
  final future = _convertImageToFlutterUi(image).then((uiImage) => uiImage.toByteData(format: ui.ImageByteFormat.png)).then((byteData) {
    if (byteData == null) {
      logError("uiImage.toByteData fail: $mattingResult");
      _mattingDecodeResultMap.remove(mattingResult);
    } else {
      _mattingDecodeResultMap[mattingResult] = Tuple2(byteData, null);
    }
  });

  _mattingDecodeResultMap[mattingResult] = Tuple2(null, future);
  return future;
}

String _genKey(File file, int pageNumber) => "${file.path}:$pageNumber";

Future<img.Image?> _capture(File pdfFile, PdfPage page) async {
  final pdfImage =
      await page.render(fullWidth: page.width * _pdfPageCaptureSizeMultiple, fullHeight: page.height * _pdfPageCaptureSizeMultiple);
  if (pdfImage == null) {
    logError("page.render fail: $page");
    return null;
  }
  logDebug("_capture got pdfImage. format:${pdfImage.format} size:${pdfImage.width}*${pdfImage.height} pixels.length:${pdfImage.pixels.length}");

  const orderMap = {
    ui.PixelFormat.rgba8888: img.ChannelOrder.rgba,
    ui.PixelFormat.bgra8888: img.ChannelOrder.bgra,
    ui.PixelFormat.rgbaFloat32: img.ChannelOrder.rgba
  };

  final encodedForMatting = _encodeForMatting(img.Image.fromBytes(
      width: pdfImage.width,
      height: pdfImage.height,
      bytes: pdfImage.pixels.buffer,
      format: img.Format.uint8,
      numChannels: 4,
      order: orderMap[pdfImage.format]));
  pdfImage.dispose();

  // _saveImageForDebug2(pdfFile, encodedForMatting, "_encodeForMatting.v2");
  return encodedForMatting;
}

img.Image _encodeForMatting(img.Image src) {
  assert(!src.hasPalette);
  final result = img.Image(
    width: src.width,
    height: src.height,
    format: img.Format.uint2,
    numChannels: 1,
  );
  assert(src.frames.length == 1);

  const thresholds = [0.4, 0.6, 0.8, 1.0];
  for (final p in src.frames.first) {
    final y = 0.3 * p.rNormalized + 0.59 * p.gNormalized + 0.11 * p.bNormalized; // see [luminanceThreshold]
    int y2 = thresholds.length;
    for (int i = 0; i < thresholds.length; ++i) {
      if (y <= thresholds[i]) {
        y2 = i;
        break;
      }
    }

    result.getPixel(p.x, p.y).r = y2;
  }
  return result;
}

/// from [https://github.com/brendan-duncan/image/blob/main/doc/flutter.md]
Future<ui.Image> _convertImageToFlutterUi(img.Image image) async {
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    final cmd = img.Command()
      ..image(image)
      ..convert(format: img.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }

  ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

  ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer, height: image.height, width: image.width, pixelFormat: ui.PixelFormat.rgba8888);

  ui.Codec codec = await id.instantiateCodec(targetHeight: image.height, targetWidth: image.width);

  ui.FrameInfo fi = await codec.getNextFrame();
  ui.Image uiImage = fi.image;

  return uiImage;
}

void _saveImageForDebug(File pdfFile, ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return null;
  logDebug("byteData.length: ${byteData.buffer.lengthInBytes}");
  await File("${p.dirname(pdfFile.path)}/debug.png").writeAsBytes(byteData.buffer.asUint8List());
}

void _saveImageForDebug2(File pdfFile, img.Image image, [String namePostfix = ""]) async {
  final png = img.encodePng(image);
  logDebug("png.length ${png.length}");
  await File("${p.dirname(pdfFile.path)}/debug-$namePostfix.png").writeAsBytes(png);
}
