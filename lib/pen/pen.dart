import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:reading_note/pen/matting_mark_generator.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import '../note_page/note_page.dart';
import '../user_preferences.dart';
import 'path_generator.dart';
import 'pen_stroke_tracker.dart';

enum PenType {
  ballPointPen, // = PT_BALL_POINT_PEN = 0, DO NOT CHANGE ORDER - INDEX IS USED!
  markPen, // = PT_MARK_PEN = 1, DO NOT CHANGE ORDER - INDEX IS USED!
  mattingMarkPen, // = 2, DO NOT CHANGE ORDER - INDEX IS USED!
  mattePositionerPen, // = 3, DO NOT CHANGE ORDER - INDEX IS USED!
}

class Pen {
  final int _id;
  PenType _type;
  Color _color;
  double _lineWidth;
  PenStrokeTracker? _tracker;

  Pen(this._id, this._type, this._color, this._lineWidth);

  int get id => _id;

  PenType get type => _type;

  Color get color => _color;

  double get lineWidth => _lineWidth;

  set type(PenType value) {
    _type = value;
    userPreferences.setPenTypeOf(_id, value);
  }

  set color(Color value) {
    _color = value;
    userPreferences.setPenColorO(_id, value);
  }

  set lineWidth(double value) {
    _lineWidth = value;
    userPreferences.setPenLineWidthOf(_id, value);
  }

  PenStrokeTracker? get ongoingTracker => _tracker;

  PenStrokeTracker beginPaint(Offset position, NotePage page, int pageNumber) {
    late final PenStrokeTracker tracker;
    switch (_type) {
      case PenType.ballPointPen:
      case PenType.markPen:
        tracker = PathGenerator(this, position, page);
        break;
      case PenType.mattingMarkPen:
        tracker = MattingMarkGenerator(this, position, page);
        break;
      case PenType.mattePositionerPen:
        assert(false, "Should deliver to MattePlacePen");
        break;
    }
    assert(_tracker == null);
    return _tracker = tracker;
  }

  void endPaint() => _tracker = null;
}
