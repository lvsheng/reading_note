import 'dart:ui';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'note_page.dart';

class IndependentNotePage extends NotePage {
  IndependentNotePage(super.pageNumber, super.noteBook, super.data, super.file);

  Size get size => Size(data.width, data.height);

  double get _defaultPixelDensity => 1.0;

  Offset canvasPositionToPage(Offset localPosition, double scale) => localPosition / _defaultPixelDensity / scale;

  Offset pagePositionToCanvas(pb.Point pagePosition, double scale) => pageOffsetToCanvas(Offset(pagePosition.x, pagePosition.y), scale);

  Offset pageOffsetToCanvas(Offset pageOffset, double scale) => pageOffset * _defaultPixelDensity * scale;

  double pageLengthToCanvas(double v, double scale) => v * _defaultPixelDensity * scale;

  Rect pageRectToCanvas(Rect rect, double scale) => Rect.fromLTRB(pageLengthToCanvas(rect.left, scale),
      pageLengthToCanvas(rect.top, scale), pageLengthToCanvas(rect.right, scale), pageLengthToCanvas(rect.bottom, scale));

  pb.Matte? matteOfId(int id) => data.independentNoteData.mattePool[id];

  @override
  bool check(Offset p) => p > const Offset(0, 0) && p.dy < data.height;

  @override
  double get defaultPenWidth => 2.0;
}
