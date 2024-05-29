import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';
import 'package:quiver/collection.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';
import 'package:archive/archive.dart';

import 'log.dart';
import 'debug_util.dart' as debug;

// todo: promise reject handle

const _pdfPageCaptureSizeMultiple = 3;
final _pageCapturedImageMap = LruMap<String, Tuple2<img.Image?, Future<img.Image?>?>>(maximumSize: 5);
final _mattingDecodeResultMap = LruMap<pb.MattingResult, Tuple2<ByteData?, Future<ByteData?>?>>(maximumSize: 200);

Future<pb.MattingResult> matting(File file, PdfDocument document, int pageNumber, pb.MattingMark mark, int markId) async {
  debug.setCurrentPdf(file);
  img.Image? pageImage = await _capture(file, document.pages[pageNumber]);
  if (pageImage == null) {
    throw ("_capture fail: $file, $pageNumber, $document");
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
  debug.saveImage(cropResult, "4.copyCrop");

  // todo: background
  final bytes = cropResult.buffer.asUint8List();
  debug.saveBytes(bytes, "5.cropResult.buffer");
  final compressed = const ZLibEncoder().encode(bytes, level: 6);
  debug.saveIntList(compressed, "6.compressed");
  final result = pb.MattingResult()
    ..bookPageNumber = pageNumber
    ..bookPageMattingMarkId = markId
    ..imageWidth = width
    ..imageHeight = height
    ..imageData = compressed;
  debug.saveGeneratedMessage(result, "7.MattingResult");

  imageOfMattingResult(result, cropResult); // just trigger, no wait

  return result;
}

Future<ByteData?> imageOfMattingResult(pb.MattingResult mattingResult, [img.Image? image]) async {
  final tuple = _mattingDecodeResultMap[mattingResult];
  if (tuple != null) {
    if (tuple.item1 != null) {
      return tuple.item1!;
    }
    return tuple.item2!;
  }

  // // fixme: remove testing
  // image = null;

  if (image == null) {
    final decompressed = const ZLibDecoder().decodeBytes(mattingResult.imageData);
    debug.saveIntList(decompressed, "8.decompressed");
    image = img.Image.fromBytes(
      bytes: Uint8List.fromList(decompressed).buffer,
      width: mattingResult.imageWidth,
      height: mattingResult.imageHeight,
      format: img.Format.uint2,
      numChannels: 1,
    );
    debug.saveImage(image, "9.image.fromBytes");
  }

  assert(() {
    final future = _convertImageToFlutterUi(image!).then((uiImage) {
      debug.saveUIImage(uiImage, "10.opt2.1.uiImage");
      return uiImage.toByteData(format: ui.ImageByteFormat.png);
    }).then((byteData) {
      if (byteData == null) {
        logError("uiImage.toByteData fail: $mattingResult");
        // _mattingDecodeResultMap.remove(mattingResult);
      } else {
        // _mattingDecodeResultMap[mattingResult] = Tuple2(byteData, null);
      }
      debug.saveByteData(byteData!, "10.opt2.2.toByteData");
    });
    // _mattingDecodeResultMap[mattingResult] = Tuple2(null, future);
    // return future;

    return true;
  }());

  final pngBytes = img.encodePng(image);
  debug.savePng(pngBytes, "10.opt1.1.encodePng");

  // 这里buffer长度比实际用到的要多4倍+ todo：考虑realloc，释放一部分内存？ todo: 异步线程拷贝时只拷贝有效长度？
  final byteData = pngBytes.buffer.asByteData(0, pngBytes.lengthInBytes);
  debug.saveByteData(byteData, "10.opt1.2.asByteData");

  _mattingDecodeResultMap[mattingResult] = Tuple2(byteData, null); // todo: async, save future

  return byteData;
}

String _genKey(File file, int pageNumber) => "${file.path}:$pageNumber";

Future<img.Image?> _capture(File pdfFile, PdfPage page) async {
  final pageImageKey = _genKey(pdfFile, page.pageNumber);
  final tuple = _pageCapturedImageMap[pageImageKey];
  img.Image? result;
  if (tuple != null) {
    result = tuple.item1;
    result ??= await tuple.item2;
    if (result != null) {
      return result;
    }
  }
  logInfo("begin capture pdf page: $pdfFile, p${page.pageNumber}");

  final future = page
      .render(fullWidth: page.width * _pdfPageCaptureSizeMultiple, fullHeight: page.height * _pdfPageCaptureSizeMultiple)
      .then((renderResult) {
    if (renderResult == null) {
      throw "page.render fail: $pageImageKey";
    }
    debug.saveBytes(renderResult.pixels, "1.page.render");
    return renderResult;
  }).then((pdfImage) {
    logDebug(
        "_capture got pdfImage. format:${pdfImage.format} size:${pdfImage.width}*${pdfImage.height} pixels.length:${pdfImage.pixels.length}");
    final image = img.Image.fromBytes(
        width: pdfImage.width,
        height: pdfImage.height,
        bytes: pdfImage.pixels.buffer,
        format: img.Format.uint8,
        numChannels: 4,
        order: (const {
          ui.PixelFormat.rgba8888: img.ChannelOrder.rgba,
          ui.PixelFormat.bgra8888: img.ChannelOrder.bgra,
          ui.PixelFormat.rgbaFloat32: img.ChannelOrder.rgba
        })[pdfImage.format]);
    pdfImage.dispose();
    debug.saveImage(image, "2.image.fromBytes");
    return _encodeForMatting(image);
  }).then((result) {
    debug.saveImage(result, "3.encodeForMatting");
    _pageCapturedImageMap[pageImageKey] = Tuple2(result, null);
    return result;
  }).catchError((error) {
    _pageCapturedImageMap.remove(pageImageKey);
    logError("_capture fail: $pageImageKey");
    return null; // fixme
  });

  _pageCapturedImageMap[pageImageKey] = Tuple2(null, future);
  return future;
}

img.Image _encodeForMatting(img.Image src) {
  // fixme: async, background service
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

