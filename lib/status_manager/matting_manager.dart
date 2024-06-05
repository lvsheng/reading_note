import 'package:flutter/cupertino.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reading_note/pdf_matting_performer.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';
import 'package:tuple/tuple.dart';

final mattingManager = MattingManager._();

enum MattingStatus {
  isEmpty,
  ing,
  allDone,
}

class MattingManager extends ChangeNotifier {
  final Map<pb.MattingMark, Tuple2<pb.Matte?, Future<pb.Matte?>?>> _caching = {};

  MattingManager._();

  MattingStatus get status => _caching.isEmpty ? MattingStatus.isEmpty : (_allDone ? MattingStatus.allDone : MattingStatus.ing);

  bool get isNotEmpty => _caching.isNotEmpty;

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

  List<pb.Matte> getMattes() {
    final result = _caching.values.where((each) => each.item1 != null).map((each) => each.item1);
    return result.toList(growable: false).cast();
  }

  void removeAll(List<pb.Matte> mattes) {
    for (final matte in mattes) {
      remove(matte, false);
    }
    notifyListeners();
  }

  void remove(pb.Matte matte, [bool notify = true]) {
    pb.MattingMark? key;
    // pb.Matte is not a valid Map key (after field change, map.contains will return false), so iterate to delete
    for (final entry in _caching.entries) {
      if (entry.value.item1 == matte) {
        key = entry.key;
        break;
      }
    }
    if (key != null) {
      _caching.remove(key);
    } else {
      logWarn("remove unexist matte: $matte");
    }
    if (notify) notifyListeners();
  }

  bool get _allDone => _caching.values.every((tuple) => tuple.item1 != null);
}
