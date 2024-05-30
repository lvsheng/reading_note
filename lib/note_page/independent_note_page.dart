import 'dart:ui';

import 'package:reading_note/protobuf/note.pb.dart' as pb;

import '../status_manager/matting_manager.dart';
import 'note_page.dart';

class IndependentNotePage extends NotePage {
  IndependentNotePage(super.pageNumber, super.noteBook, super.data, super.file);

  @override
  void startDraw(Offset positionOnPage) {
    _tryPlaceMatte(positionOnPage);
    return super.startDraw(positionOnPage);
  }

  void _tryPlaceMatte(Offset positionOnPage) {
    final newMattes = MattingManager.instanceOf(noteBook.book).takeAwayResults();
    if (newMattes == null) return;
    for (final matte in newMattes) {
      final id = ++data.independentNoteData.lastMatteId;
      data.independentNoteData.mattePool[id] = matte;
      data.items.add(pb.NotePageItem()
        ..x = positionOnPage.dx
        ..y = positionOnPage.dy
        ..matteId = id);
    }
    triggerRepaint();
  }

  Size get size => Size(data.width, data.height);

  double get _defaultPixelDensity => 1.0;

  Offset canvasPositionToPage(Offset localPosition, double scale) => localPosition / _defaultPixelDensity / scale;

  Offset pagePositionToCanvas(pb.Point pagePosition, double scale) => pageOffsetToCanvas(Offset(pagePosition.x, pagePosition.y), scale);

  Offset pageOffsetToCanvas(Offset pageOffset, double scale) => pageOffset * _defaultPixelDensity * scale;

  double pageWidthToCanvas(double v, double scale) => v * _defaultPixelDensity * scale;

  pb.Matte? matteOfId(int id) => data.independentNoteData.mattePool[id];

  @override
  bool check(Offset p) => p > const Offset(0, 0) && p.dy < data.height;

  @override
  double get defaultPenWidth => 2.0;
}
