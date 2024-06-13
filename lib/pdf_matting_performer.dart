import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:pdfrx/pdfrx.dart';
import 'package:quiver/collection.dart';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';
import 'package:archive/archive.dart';

import 'util/log.dart';
import 'util/debug.dart' as debug;

// todo: promise reject handle

const pdfPageCaptureSizeMultiplier = 3;
final _pageScreenshotMap = LruMap<String, Tuple2<img.Image?, Future<img.Image?>?>>(maximumSize: 5);
final _matteDecodeImageMap = LruMap<pb.Matte, Tuple2<ui.Image?, Future<ui.Image?>?>>(maximumSize: 5000);

Future<pb.Matte> performMatting(File book, PdfPage page, pb.MattingMark mark, int markId) async {
  final pageImage = await _capture(book, page);
  if (pageImage == null) throw ("_capture fail: $book, $page");

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
  final bytes = cropResult.buffer.asUint8List();
  assert(cropResult.lengthInBytes == bytes.lengthInBytes);
  debug.saveBytes(bytes, "5.cropResult.buffer");
  final compressed = const ZLibEncoder().encode(bytes); // todo: background thread?
  debug.saveIntList(compressed, "6.compressed");

  final result = pb.Matte()
    ..bookPageNumber = page.pageNumber
    ..bookPageMattingMarkId = markId
    ..imageWidth = xywh.item3
    ..imageHeight = xywh.item4
    ..imageData = compressed
    ..bookPath = fileSystemProxy.localPath(book);
  debug.saveGeneratedMessage(result, "7.Matte");

  imageOfMatte(result, cropResult); // just trigger, no wait

  return result;
}

/// @return: tuple.item1或item2至少一个非null
Tuple2<ui.Image?, Future<ui.Image?>?> imageOfMatte(pb.Matte matte, [img.Image? image]) {
  final tuple = _matteDecodeImageMap[matte];
  if (tuple != null) {
    assert(tuple.item1 != null || tuple.item2 != null);
    return tuple;
  }

  logDebug("[image.convert] 1. imageOfMatte");
  const paletteStep = 255 / 4.0;
  image = img.Image.fromBytes(
    bytes: image?.buffer ??
        Uint8List.fromList(() {
          final decompressed = const ZLibDecoder().decodeBytes(matte.imageData);
          debug.saveIntList(decompressed, "8.decompressed");
          return decompressed;
        }())
            .buffer,
    width: matte.imageWidth,
    height: matte.imageHeight,
    format: img.Format.uint2,
    numChannels: 1,

    // use palette to convert 2-bit per pixel to color
    withPalette: true,
    palette: img.PaletteUint8(4, 4)
      ..setRgba(0, 0, 0, 0, 255)
      ..setRgba(1, paletteStep, paletteStep, paletteStep, 255)
      ..setRgba(2, paletteStep * 2, paletteStep * 2, paletteStep * 2, 255)
      ..setRgba(3, 0, 0, 0, 0), // 白色以透明代替
  );
  debug.saveImage(image, "9.image.fromBytes");

  final future = _convertImageToFlutterUi(image).then((uiImage) {
    _matteDecodeImageMap[matte] = Tuple2(uiImage, null);
    debug.saveUIImage(uiImage, "11.uiImage");
    logDebug("[image.convert] 3. got uiImage");
    return uiImage;
  });

  return _matteDecodeImageMap[matte] = Tuple2(null, future);
}

String _genKey(File book, int pageNumber) => "${fileSystemProxy.localPath(book)}:$pageNumber";

Future<img.Image?> _capture(File book, PdfPage page) async {
  final key = _genKey(book, page.pageNumber);
  final tuple = _pageScreenshotMap[key];
  if (tuple != null) {
    img.Image? result = tuple.item1;
    result ??= await tuple.item2;
    if (result != null) {
      return result;
    } else {
      logWarn("last capture fail, will try again");
    }
  }
  logInfo("begin capture pdf page: $book, p${page.pageNumber}");

  final future = page
      .render(fullWidth: page.width * pdfPageCaptureSizeMultiplier, fullHeight: page.height * pdfPageCaptureSizeMultiplier)
      .then((pdfImage) {
    if (pdfImage == null) throw "page.render fail: $key";
    logDebug("got screenshot. ${pdfImage.width}*${pdfImage.height} ${pdfImage.pixels.buffer.lengthInBytes}bytes");
    debug.saveBytes(pdfImage.pixels, "1.page.render");

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

    final result = _encodeTextMatte(image);
    debug.saveImage(result, "3.encodeTextMatte");
    _pageScreenshotMap[key] = Tuple2(result, null);
    return result;
  }).catchError((error) {
    _pageScreenshotMap.remove(key);
    throw error;
  });

  _pageScreenshotMap[key] = Tuple2(null, future);
  return future;
}

/// For lowest memory usage and no obvious jagged edges, use 2 bits per pixel (4 levels from black to white)
img.Image _encodeTextMatte(img.Image src) {
  final ts = DateTime.now().millisecondsSinceEpoch;
  // fixme: background thread?
  assert(!src.hasPalette);
  final result = img.Image(
    width: src.width,
    height: src.height,
    format: img.Format.uint2,
    numChannels: 1,
  );
  assert(src.frames.length == 1);

  const thresholds = [0.4 /*more black for showing text clearly*/, 0.6, 0.8, 1.0];
  for (final pixel in src.frames.first) {
    final luminance = 0.3 * pixel.rNormalized + 0.59 * pixel.gNormalized + 0.11 * pixel.bNormalized; // from [img.luminanceThreshold]
    int level = thresholds.length;
    for (int i = 0; i < thresholds.length; ++i) {
      if (luminance <= thresholds[i]) {
        level = i;
        break;
      }
    }
    result.getPixel(pixel.x, pixel.y).r = level;
  }

  logInfo("_encodeTextMatte cost:${DateTime.now().millisecondsSinceEpoch - ts}ms"); // (about 40ms)
  return result;
}

/// from [https://github.com/brendan-duncan/image/blob/main/doc/flutter.md]
Future<ui.Image> _convertImageToFlutterUi(img.Image image) async {
  if (image.format != img.Format.uint8 || image.numChannels != 4) {
    logDebug("[image.convert] 2. begin await cmd.convert $image");
    final ts = DateTime.now().millisecondsSinceEpoch;
    final cmd = img.Command()
      ..image(image)
      ..convert(format: img.Format.uint8, numChannels: 4);

    // fixme: why thread so slow? (200～300ms per interval)
    // final rgba8 = await cmd.getImageThread();
    final rgba8 = await cmd.getImage();
    if (rgba8 != null) image = rgba8;
    logInfo("[image.convert] image.convert done: $image cost:${DateTime.now().millisecondsSinceEpoch - ts}ms");
  }
  debug.saveImage(image, "10.image.convert.4channel");

  final ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(image.toUint8List());
  final ui.ImageDescriptor id =
      ui.ImageDescriptor.raw(buffer, height: image.height, width: image.width, pixelFormat: ui.PixelFormat.rgba8888);
  final ui.Codec codec = await id.instantiateCodec(targetHeight: image.height, targetWidth: image.width);
  final ui.FrameInfo fi = await codec.getNextFrame();
  final ui.Image uiImage = fi.image;
  return uiImage;
}
