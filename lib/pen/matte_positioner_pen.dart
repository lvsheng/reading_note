import 'dart:ui';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';
import '../note_page/note_page.dart';
import '../user_preferences.dart';
import 'matte_positioner.dart';
import 'pen.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;

import 'pen_stroke_tracker.dart';

/// not visible to [PenManager], added automatically by [StatusManager] if needed
class MattePositionerPen extends Pen {
  late double _scale;
  MattePositioner? _mattePositioner; // generated at pen's first land on page

  MattePositionerPen() : super(-1, PenType.mattePositionerPen, material.Colors.transparent, 0) {
    _scale = userPreferences.matteScaleOf(statusManager.reading!);
  }

  static const _errorNotAllowed = "MattePlacePen id not allowed!"; // fixme: divorce not allowed behavior from base Pen
  @override
  get id => throw _errorNotAllowed;

  @override
  set type(PenType value) => throw _errorNotAllowed;

  @override
  set color(Color value) => throw _errorNotAllowed;

  @override
  set lineWidth(double value) => throw _errorNotAllowed;

  set scale(double value) {
    _scale = value;
    userPreferences.setMatteScale(statusManager.reading!, value);
  }

  double get scale => _scale;

  @override
  PenStrokeTracker beginPaint(pb.NotePage pbPage, Offset position, NotePage page) {
    if (_mattePositioner == null) {
      return _mattePositioner = MattePositioner(this, position, page, pbPage);
    }

    if (_mattePositioner!.page != page) {
      logError("TODO: tip different page, can't place matte again?");
    }

    return _mattePositioner!;
  }
}
