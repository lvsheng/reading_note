import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'dart:ui';

import '../note_page/independent_note_page.dart';
import '../note_page/mark_note_page.dart';
import '../note_page/note_page.dart';
import '../pdf_matting_performer.dart';

abstract class CoordConverter {
  final NotePage note;

  CoordConverter(this.note);

  double pageWidthToCanvas(double v);

  double penWidthToCanvas(double v);

  Offset pagePositionToCanvas(pb.Point pagePosition);

  Rect pageRectToCanvas(Rect rect);

  Offset pageOffsetToCanvas(Offset offset);

  Size pageSizeToCanvas(Size size) {
    final result = pageOffsetToCanvas(Offset(size.width, size.height));
    return Size(result.dx, result.dy);
  }
}

class NoteCoordConverter extends CoordConverter {
  double _scale;

  NoteCoordConverter(super.note, [this._scale = 1.0]);

  set scale(double value) => _scale = value;

  @override
  Offset pagePositionToCanvas(pb.Point pagePosition) => (note as IndependentNotePage).pagePositionToCanvas(pagePosition, _scale);

  @override
  double pageWidthToCanvas(double v) => (note as IndependentNotePage).pageLengthToCanvas(v, _scale);

  @override
  Rect pageRectToCanvas(Rect rect) => (note as IndependentNotePage).pageRectToCanvas(rect, _scale);

  @override
  Offset pageOffsetToCanvas(Offset offset) => (note as IndependentNotePage).pageOffsetToCanvas(offset, _scale);

  @override
  double penWidthToCanvas(double v) => pageWidthToCanvas(v);
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
  Offset pageOffsetToCanvas(Offset offset) => (note as MarkNotePage).pageOffsetToCanvas(offset, _pageRect);

  @override
  double penWidthToCanvas(double v) => pageWidthToCanvas(v) / pdfPageCaptureSizeMultiplier;
}
