import 'package:flutter/cupertino.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reading_note/pdf_matting_performer.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:tuple/tuple.dart';

final mattingManager = MattingManager._();

enum MattingStatus {
  isEmpty,
  ing,
  allDone,
}

class MattingManager extends ChangeNotifier {
  Map<pb.MattingMark, Tuple2<pb.Matte?, Future<pb.Matte?>?>> _caching = {};

  MattingManager._();

  bool get isNotEmpty => !isEmpty;
  bool get isEmpty => _caching.isEmpty;
  MattingStatus get status => isEmpty ? MattingStatus.isEmpty : (_allDone ? MattingStatus.allDone : MattingStatus.ing);

  void startOne(pb.MattingMark mark, int markId, PdfDocument document, int pageNumber) {
    _caching[mark] = Tuple2(
        null,
        performMatting(statusManager.reading!, document, pageNumber, mark, markId).then((result) {
          _caching[mark] = Tuple2(result, null);
          notifyListeners();
          return result;
        }));

    notifyListeners();
  }

  /// @return
  ///   null: 当前无matting项，或还有未截图完成项需要等一等
  Iterable<pb.Matte>? takeAwayResults() {
    if (_caching.isEmpty) return null;
    if (!_allDone) return null;

    final result = _caching.values.map((each) => each.item1);
    _caching = {};
    notifyListeners();
    return result.cast();
  }

  bool get _allDone => _caching.values.every((tuple) => tuple.item1 != null);
}
