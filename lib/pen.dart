
import 'dart:ui';

import 'user_preferences.dart';

enum PenType {
  ballPointPen, // = PT_BALL_POINT_PEN = 0, DO NOT CHANGE ORDER - INDEX IS USED!
  markPen, // = PT_MARK_PEN = 1, DO NOT CHANGE ORDER - INDEX IS USED!
  mattingMarkPen, // = 2, DO NOT CHANGE ORDER - INDEX IS USED!
}

class Pen {
  final int _id;
  PenType _type;
  Color _color;
  double _lineWidth;

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
}
