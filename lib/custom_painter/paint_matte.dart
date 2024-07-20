import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/widgets/selecting_panel.dart';

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
    bool forPenPainter = false,
    bool isSelected = false}) {
  final position = coordinateConverter.pageOffsetToCanvas(Offset(item.position.dx, item.position.dy));

  // if (isSelected) {
  //   final rect = Rect.fromLTWH(position.dx, position.dy, item.matte.imageWidth * item.scale, item.matte.imageHeight * item.scale);
  //   // canvas.drawRect(rect, _selectedPainter);
  //   canvas.drawRect(rect, Paint()..color = material.Colors.grey.withAlpha(125));
  //   return;
  // }

  switch (item.status) {
    case MatteStatus.done:
      void paint() {
        _paintImage(
            canvas: canvas,
            matte: item.matte,
            position: position,
            triggerRepaint: triggerRepaint,
            scale: item.scale,
            isSelected: isSelected);
      }

      if (item.matte.hasDecoration()) {
        switch (item.matte.decoration.value ~/ 10) {
          case 0:
            _paintBackground(
                canvas: canvas,
                coordConverter: coordinateConverter,
                rect: coordinateConverter.pageRectToCanvas(
                    Rect.fromLTWH(position.dx, position.dy, item.matte.imageWidth.toDouble(), item.matte.imageHeight.toDouble())),
                scale: item.scale,
                color: decorationColor(item.matte.decoration));
            paint();
            break;
          case 1:
            paint();
            _paintUnderline(
                canvas: canvas,
                coordConverter: coordinateConverter,
                rect: coordinateConverter.pageRectToCanvas(
                    Rect.fromLTWH(position.dx, position.dy, item.matte.imageWidth.toDouble(), item.matte.imageHeight.toDouble())),
                scale: item.scale,
                color: decorationColor(item.matte.decoration));
            break;
          case 2:
            throw "TODO";
          default:
            throw "invalid decoration: ${item.matte.decoration.value}";
        }
      } else {
        paint();
      }
      break;
    case MatteStatus.adjusting:
      if (!forPenPainter) {
        _paintImage(
            canvas: canvas,
            matte: item.matte,
            position: position,
            triggerRepaint: triggerRepaint,
            scale: item.scale,
            isSelected: isSelected);
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
      _paintImage(
          canvas: canvas,
          matte: item.matte,
          position: position,
          triggerRepaint: triggerRepaint,
          scale: item.scale,
          opacity: 0.5,
          isSelected: isSelected);
      _paintBorder(
          canvas: canvas,
          coordConverter: coordinateConverter,
          rect: coordinateConverter.pageRectToCanvas(
              Rect.fromLTWH(position.dx, position.dy, item.matte.imageWidth.toDouble(), item.matte.imageHeight.toDouble())),
          scale: item.scale,
          opacity: 0.5);
      break;
    case MatteStatus.waiting:
      _paintImage(
          canvas: canvas,
          matte: item.matte,
          position: position,
          triggerRepaint: triggerRepaint,
          scale: item.scale,
          opacity: 0.2,
          isSelected: isSelected);
      break;
  }
}

void _paintBackground(
    {required Canvas canvas, required CoordConverter coordConverter, required Rect rect, required double scale, required Color color}) {
  if (scale != 1.0) {
    rect = Rect.fromLTWH(rect.left, rect.top, rect.width * scale, rect.height * scale);
  }
  canvas.drawRect(
      rect,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill);
}

void _paintUnderline(
    {required Canvas canvas, required CoordConverter coordConverter, required Rect rect, required double scale, required Color color}) {
  if (scale != 1.0) {
    rect = Rect.fromLTWH(rect.left, rect.top, rect.width * scale, rect.height * scale);
  }
  canvas.drawLine(
      rect.bottomLeft,
      rect.bottomRight,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5);
}

void _paintImage(
    {required Canvas canvas,
    required pb.Matte matte,
    required Offset position,
    required VoidCallback triggerRepaint,
    required double scale,
    double? opacity,
    required bool isSelected}) {
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
  if (isSelected) {
    paint.colorFilter = const ColorFilter.mode(material.Colors.grey, BlendMode.srcATop);
  }

  if (scale == 1.0) {
    canvas.drawImage(image, Offset(position.dx, position.dy), paint);
  } else {
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(position.dx, position.dy, image.width * scale, image.height * scale),
      image: image,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.none,
      opacity: opacity ?? 1.0,
      colorFilter: paint.colorFilter,
    );
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
