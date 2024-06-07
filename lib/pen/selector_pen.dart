import 'dart:ui';

import 'package:reading_note/pen/pen.dart';
import 'package:flutter/material.dart' as material;

import '../note_page/note_page.dart';
import '../protobuf/note.pb.dart' as pb;
import 'pen_stroke_tracker.dart';

/// not visible to [PenManager], added automatically by [StatusManager] if needed
class SelectPen extends Pen {
  final int _pageIndex;
  pb.NotePage? _page;

  SelectPen(this._pageIndex) : super(-1, PenType.selectPen, material.Colors.black, 0);

  static const _errorNotAllowed = "MattePlacePen id not allowed!"; // fixme: divorce not allowed behavior from base Pen
  @override
  get id => throw _errorNotAllowed;

  @override
  set type(PenType value) => throw _errorNotAllowed;

  @override
  set color(Color value) => throw _errorNotAllowed;

  @override
  set lineWidth(double value) => throw _errorNotAllowed;

  @override
  PenStrokeTracker beginPaint(Offset position, NotePage page, int pageNumber) {
    return PositionTracker(this, position, page, (_) {});
  }

  void _constructIndex() {

  }
}
