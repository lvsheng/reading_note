import 'package:flutter/cupertino.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'note_page.dart';

class MarkNotePage extends NotePage {
  final PdfPage pdfPage;
  MarkNotePage(super.pageNumber, super.noteBook, super.data, super.file, this.pdfPage);

  Offset canvasPositionToPagePosition(Offset localPosition, Rect pageRect) {
    Offset result = Offset(localPosition.dx / pageRect.width, localPosition.dy / pageRect.height);
    return result = Offset(result.dx * data.width, result.dy * data.height);
  }

  Offset pagePositionToCanvas(pb.Point pagePosition, Rect pageRect) {
    Offset result = Offset(pagePosition.x / data.width, pagePosition.y / data.height);
    return result = Offset(result.dx * pageRect.width, result.dy * pageRect.height);
  }

  Offset pageOffsetToCanvas(Offset offset, Rect pageRect) {
    Offset result = Offset(offset.dx / data.width, offset.dy / data.height);
    return result = Offset(result.dx * pageRect.width, result.dy * pageRect.height);
  }

  double pageWidthToCanvas(double v, Rect pageRect) => v / data.width * pageRect.width;

  double pageHeightToCanvas(double v, Rect pageRect) => v / data.height * pageRect.height;

  Rect pageRectToCanvas(Rect rect, Rect pageRect) => Rect.fromLTRB(pageWidthToCanvas(rect.left, pageRect),
      pageHeightToCanvas(rect.top, pageRect), pageWidthToCanvas(rect.right, pageRect), pageHeightToCanvas(rect.bottom, pageRect));

  pb.MattingMark? mattingMarkOfId(int id) => data.markNoteData.mattingMarkPool[id];

  @override
  bool check(Offset p) => p > const Offset(0, 0) && p < Offset(data.width, data.height);

  @override
  double get defaultPenWidth => 1.0;
}
