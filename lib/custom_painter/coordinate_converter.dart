import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'dart:ui';

import '../note_page/independent_note_page.dart';
import '../note_page/mark_note_page.dart';
import '../note_page/note_page.dart';

abstract class CoordConverter {
  final NotePage note;

  CoordConverter(this.note);

  double pageWidthToCanvas(double v);

  Offset pagePositionToCanvas(pb.Point pagePosition);

  Rect pageRectToCanvas(Rect rect);

  Offset pageOffsetToCanvas(Offset offset);
}

class NoteCoordConverter extends CoordConverter {
  double _scale = 1.0;

  NoteCoordConverter(super.note);

  set scale(double value) => _scale = value;

  @override
  Offset pagePositionToCanvas(pb.Point pagePosition) => (note as IndependentNotePage).pagePositionToCanvas(pagePosition, _scale);

  @override
  double pageWidthToCanvas(double v) => (note as IndependentNotePage).pageWidthToCanvas(v, _scale);

  @override
  Rect pageRectToCanvas(Rect rect) {
    // TODO: implement pageRectToCanvas
    throw UnimplementedError();
  }

  @override
  Offset pageOffsetToCanvas(Offset offset) => (note as IndependentNotePage).pageOffsetToCanvas(offset, _scale);
}

class BookCoordConverter extends CoordConverter {
  final Rect _pageRect;

  BookCoordConverter(this._pageRect, super.note);

  @override
  double pageWidthToCanvas(double v) => (note as MarkNotePage).pageWidthToCanvas(v, _pageRect);

  @override
  Offset pagePositionToCanvas(pb.Point pagePosition) => (note as MarkNotePage).pagePositionToCanvas(pagePosition, _pageRect);

  @override
  Rect pageRectToCanvas(Rect rect) => (note as MarkNotePage).pageRectToCanvas(rect, _pageRect);

  @override
  Offset pageOffsetToCanvas(Offset offset) {
    // TODO: implement pageOffsetToCanvas
    throw UnimplementedError();
  }
}
