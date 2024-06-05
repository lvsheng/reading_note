import 'package:flutter/cupertino.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;

import '../pdf_matting_performer.dart';
import '../util/log.dart';
import 'coordinate_converter.dart';

enum MatteStatus {
  done,
  adjusting,
  recommended,
  waiting,
}

typedef MattePaintItem = ({pb.Matte matte, MatteStatus status, Offset position, double scale});

void paintMatte(
    {required Canvas canvas,
    required CoordConverter coordinateConverter,
    required MattePaintItem item,
    required VoidCallback triggerRepaint,
    bool forPenPainter = false}) {
  final position = coordinateConverter.pageOffsetToCanvas(Offset(item.position.dx, item.position.dy));
  switch (item.status) {
    case MatteStatus.done:
      _paintImage(canvas: canvas, matte: item.matte, position: position, triggerRepaint: triggerRepaint, scale: item.scale);
      break;
    case MatteStatus.adjusting:
      if (!forPenPainter) {
        _paintImage(canvas: canvas, matte: item.matte, position: position, triggerRepaint: triggerRepaint, scale: item.scale);
      } else {
        _paintBorder(
            canvas: canvas,
            coordConverter: coordinateConverter,
            rect: coordinateConverter.pageRectToCanvas(
                Rect.fromLTWH(position.dx, position.dy, item.matte.imageWidth.toDouble(), item.matte.imageHeight.toDouble())),
            scale: item.scale);
      }
      break;
    case MatteStatus.recommended:
      _paintImage(canvas: canvas, matte: item.matte, position: position, triggerRepaint: triggerRepaint, scale: item.scale, opacity: 0.5);
      _paintBorder(
          canvas: canvas,
          coordConverter: coordinateConverter,
          rect: coordinateConverter.pageRectToCanvas(
              Rect.fromLTWH(position.dx, position.dy, item.matte.imageWidth.toDouble(), item.matte.imageHeight.toDouble())),
          scale: item.scale,
          opacity: 0.5);
      break;
    case MatteStatus.waiting:
      _paintImage(canvas: canvas, matte: item.matte, position: position, triggerRepaint: triggerRepaint, scale: item.scale, opacity: 0.2);
      break;
  }
}

void _paintImage(
    {required Canvas canvas,
    required pb.Matte matte,
    required Offset position,
    required VoidCallback triggerRepaint,
    required double scale,
    double? opacity}) {
  final tuple = imageOfMatte(matte);
  final image = tuple.item1;
  if (image == null) {
    logWarn("matte image not ready, wait it");
    tuple.item2!.then((_) => triggerRepaint());
    // todo: draw loading?
    return;
  }
  final paint = Paint();
  if (opacity != null) paint.color = Color.fromRGBO(0, 0, 0, opacity);

  if (scale == 1.0) {
    canvas.drawImage(image, Offset(position.dx, position.dy), paint);
  } else {
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(position.dx, position.dy, image.width * scale, image.height * scale),
        image: image,
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
        opacity: opacity ?? 1.0);
  }
}

void _paintBorder(
    {required Canvas canvas, required CoordConverter coordConverter, required Rect rect, required double scale, double opacity = 1.0}) {
  if (scale != 1.0) {
    rect = Rect.fromLTWH(rect.left, rect.top, rect.width * scale, rect.height * scale);
  }
  canvas.drawRect(
      rect,
      Paint()
        ..color = Color.fromRGBO(0, 0, 0, opacity)
        ..style = PaintingStyle.stroke);
}
