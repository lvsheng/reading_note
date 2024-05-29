import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:quiver/collection.dart';
import 'package:reading_note/pdf_matting_util.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:tuple/tuple.dart';

enum MattingTransferStatus {
  empty,
  ing,
  allDone,
}

class MattingTransferStation extends ChangeNotifier {
  static final _cacheByBook = LruMap<String, MattingTransferStation>();

  static MattingTransferStation instanceOf(File book) {
    var result = _cacheByBook[book.path];
    return result ??= _cacheByBook[book.path] = MattingTransferStation._(book);
  }

  final File _book;
  Map<pb.MattingMark, Tuple2<pb.MattingResult?, Future<pb.MattingResult?>?>> _matting = {};

  MattingTransferStation._(this._book);

  MattingTransferStatus get status =>
      _matting.isEmpty ? MattingTransferStatus.empty : (_allDone ? MattingTransferStatus.allDone : MattingTransferStatus.ing);

  bool get _allDone => _matting.values.every((tuple) => tuple.item1 != null);

  void pushMatting(int markId, pb.MattingMark mark, PdfDocument document, int pageNumber) {
    _matting[mark] = Tuple2(
        null,
        matting(_book, document, pageNumber, mark, markId).then((result) {
          _matting[mark] = Tuple2(result, null);
          notifyListeners();
          return result;
        }));

    notifyListeners();
  }

  /// @return
  ///   null: 当前无matting项，或还有未截图完成项需要等一等
  Iterable<pb.MattingResult>? takeAway() {
    if (_matting.isEmpty) return null;
    if (!_allDone) return null;

    final result = _matting.values.map((each) => each.item1);
    _matting = {};
    notifyListeners();
    return result.cast();
  }
}
