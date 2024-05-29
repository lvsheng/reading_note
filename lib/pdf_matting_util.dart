import 'dart:io';
import 'dart:math';
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
final _mattingDecodeResultMap = LruMap<pb.MattingResult, Tuple2<ui.Image?, Future<ui.Image?>?>>(maximumSize: 200);

Future<pb.MattingResult> matting(File file, PdfDocument document, int pageNumber, pb.MattingMark mark, int markId) async {
  final page = document.pages[pageNumber - 1];
  img.Image? pageImage = await _capture(file, page);
  if (pageImage == null) {
    throw ("_capture fail: $file, $pageNumber, $document");
  }

  late Tuple4<int, int, int, int> xywh;
  {
    switch (mark.whichContent()) {
      case pb.MattingMark_Content.horizontal:
        final markContent = mark.horizontal;
        xywh = Tuple4(
            (markContent.left / page.width * pageImage.width).round(),
            ((markContent.y - markContent.height / 2.0) / page.height * pageImage.height).round(),
            ((markContent.right - markContent.left) / page.width * pageImage.width).round(),
            (markContent.height / page.height * pageImage.height).round());
        break;

      case pb.MattingMark_Content.vertical:
      case pb.MattingMark_Content.line:
      case pb.MattingMark_Content.rectangle:
        throw "TODO";

      case pb.MattingMark_Content.notSet:
        logError("INVALID MattingMark $mark");
    }
  }

  final cropResult = img.copyCrop(pageImage, x: xywh.item1, y: xywh.item2, width: xywh.item3, height: xywh.item4);
  debug.saveImage(cropResult, "4.copyCrop");

  // todo: background thread?
  final bytes = cropResult.buffer.asUint8List();
  debug.saveBytes(bytes, "5.cropResult.buffer");
  final compressed = const ZLibEncoder().encode(bytes, level: 6);
  debug.saveIntList(compressed, "6.compressed");
  final result = pb.MattingResult()
    ..bookPageNumber = pageNumber
    ..bookPageMattingMarkId = markId
    ..imageWidth = xywh.item3
    ..imageHeight = xywh.item4
    ..imageData = compressed;
  debug.saveGeneratedMessage(result, "7.MattingResult");

  imageOfMattingResult(result, cropResult); // just trigger, no wait

  return result;
}

/// @return: tuple.item1或item2至少一个非null
Tuple2<ui.Image?, Future<ui.Image?>?> imageOfMattingResult(pb.MattingResult mattingResult, [img.Image? image]) {
  final tuple = _mattingDecodeResultMap[mattingResult];
  if (tuple != null) {
    assert(tuple.item1 != null || tuple.item2 != null);
    return tuple;
  }

  logDebug("[image.convert] 1. imageOfMattingResult");
  const paletteStep = 255 / 4.0;
  image = img.Image.fromBytes(
    bytes: image?.buffer ??
        Uint8List.fromList(() {
          final decompressed = const ZLibDecoder().decodeBytes(mattingResult.imageData);
          debug.saveIntList(decompressed, "8.decompressed");
          return decompressed;
        }())
            .buffer,
    width: mattingResult.imageWidth,
    height: mattingResult.imageHeight,
    format: img.Format.uint2,
    numChannels: 1,

    // use palette to convert the 2bit(4 level) color per pixel
    withPalette: true,
    palette: img.PaletteUint8(4, 4)
      ..setRgba(0, 0, 0, 0, 255)
      ..setRgba(1, paletteStep, paletteStep, paletteStep, 255)
      ..setRgba(2, paletteStep * 2, paletteStep * 2, paletteStep * 2, 255)
      ..setRgba(3, 0, 0, 0, 0), // 白色以透明代替
  );
  debug.saveImage(image, "9.image.fromBytes");

  final future = _convertImageToFlutterUi(image).then((uiImage) {
    _mattingDecodeResultMap[mattingResult] = Tuple2(uiImage, null);
    debug.saveUIImage(uiImage, "11.uiImage");
    logDebug("[image.convert] 3. got uiImage");
    return uiImage;
  });

  return _mattingDecodeResultMap[mattingResult] = Tuple2(null, future);
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
  final ts = DateTime.now().millisecondsSinceEpoch;
  // fixme: async, background thread?
  assert(!src.hasPalette);
  final result = img.Image(
    width: src.width,
    height: src.height,

    // for lowest memory, and no obvious jagged, use 4 bit per pixel
    format: img.Format.uint2,
    numChannels: 1,
  );
  assert(src.frames.length == 1);

  const thresholds = [0.4/*more black for showing text clearly*/, 0.6, 0.8, 1.0];
  for (final p in src.frames.first) {
    final y = 0.3 * p.rNormalized + 0.59 * p.gNormalized + 0.11 * p.bNormalized; // from [img.luminanceThreshold]
    int y2 = thresholds.length;
    for (int i = 0; i < thresholds.length; ++i) {
      if (y <= thresholds[i]) {
        y2 = i;
        break;
      }
    }

    result.getPixel(p.x, p.y).r = y2;
  }

  logInfo("encodeForMatting cost:${DateTime.now().millisecondsSinceEpoch - ts}ms"); // (about 40ms)
  return result;
}

/// from [https://github.com/brendan-duncan/image/blob/main/doc/flutter.md]
Future<ui.Image> _convertImageToFlutterUi(img.Image image) async {
// /*
  // todo: 解码结果放在本地文件缓存中，下次直接读取？，而不用从raw数据中现场解码
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final cmd = img.Command()
      ..image(image)
      ..convert(format: img.Format.uint8, numChannels: 4);
    logDebug("[image.convert] 2. begin await cmd.convert $image");

    // fixme: why thread so slow? (200～300ms per interval)
    // final rgba8 = await cmd.getImageThread();
    final rgba8 = await cmd.getImage();
    if (rgba8 != null) {
      image = rgba8;
    }
    logInfo("[image.convert] image.convert done: $image cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }
  debug.saveImage(image, "10.image.convert.4channel");
  final bytes = image.toUint8List();
// */
  // final bytes = img.encodePng(image, level: Deflate.NO_COMPRESSION, singleFrame: true, filter: img.PngFilter.none);
  // debug.savePng(bytes, "10.opt1.1.encodePng");
  // final bytes = img.encodeBmp(image);
  // debug.saveBytes(bytes, "10.img.encode.bmp");
  // final bytes = img.encodeJpg(image);
  // debug.saveBytes(bytes, "10.img.encode.jpg");
  // final bytes = img.encodeCur(image, singleFrame: true);
  // debug.saveBytes(bytes, "10.img.encode.jpg");
  // final bytes = img.encodeTga(image);
  // debug.saveBytes(bytes, "10.img.encode.jpg");

  ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(bytes);

  ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer, height: image.height, width: image.width, pixelFormat: ui.PixelFormat.rgba8888);

  ui.Codec codec = await id.instantiateCodec(targetHeight: image.height, targetWidth: image.width);

  ui.FrameInfo fi = await codec.getNextFrame();
  ui.Image uiImage = fi.image;

  return uiImage;
}
