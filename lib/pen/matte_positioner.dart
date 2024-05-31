import 'dart:ui';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/pen/pen_stroke_tracker.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/util/log.dart';

import '../status_manager/matting_manager.dart';
import 'matte_positioner_pen.dart';

enum PlaceMatteStatus {
  placing,
  movingTogether,
  movingSeparately,
  done,
}

/// todo: 选择已有matte并移动时，从[MattePositioner]分离出子类
class MattePositioner extends PenStrokeTracker {
  final List<pb.Matte> _mattes = [];
  PlaceMatteStatus _status = PlaceMatteStatus.placing;

  late List<pb.NotePageItem> _pageItems;

  // late final Map<pb.NotePageItem, pb.Matte> _itemToMatte;
  late List<Offset> _pageItemShifts;

  MattePositioner(super.pen, super.startPosition, super.page, super.pbPage);

  MattePositionerPen get _pen => pen as MattePositionerPen;

  @override
  void start(Offset position) {
    switch (_status) {
      case PlaceMatteStatus.placing:
        _startOnPlacing(position);
        break;
      case PlaceMatteStatus.movingTogether:
      // TODO: Handle this case.
      case PlaceMatteStatus.movingSeparately:
      // TODO: Handle this case.
      case PlaceMatteStatus.done:
      // TODO: Handle this case.
    }
  }

  void _startOnPlacing(Offset position) {
    final mattingStatus = mattingManager.status;
    if (mattingStatus == MattingStatus.ing) {
      // todo: render loading
      return;
    }

    assert(mattingStatus != MattingStatus.isEmpty);
    final newMattes = mattingManager.takeAwayResults();
    assert(newMattes != null);
    _mattes.addAll(newMattes!);

    // _itemToMatte = {};
    var nextShift = const Offset(0, 0);
    pbPage.items.addAll(_pageItems = _mattes.map((matte) {
      // todo: 估计得放pen上。
      if (matte.bookPath == fileSystemProxy.localPath(statusManager.reading!)) {
        logDebug("same book, clear: ${matte.bookPath}");
        matte.clearBookPath(); // same book, save space
      }

      final id = ++pbPage.independentNoteData.lastMatteId;
      pbPage.independentNoteData.mattePool[id] = matte;
      final result = pb.NotePageItem()
        ..x = position.dx
        ..y = position.dy + nextShift.dy
        ..matteId = id;
      if (_pen.scale != 1.0) {
        result.scale = _pen.scale;
      }

      nextShift += Offset(0, matte.imageHeight.toDouble());

      // _itemToMatte[result] = matte;
      return result;
    }).toList(growable: false));

    _pageItemShifts = _pageItems.map((item) => Offset(item.x, item.y) - position).toList(growable: false);
  }

  @override
  void move(Offset position) {
    switch (_status) {
      case PlaceMatteStatus.placing:
        _moveOnPlacing(position);
        break;
      case PlaceMatteStatus.movingTogether:
      // TODO: Handle this case.
      case PlaceMatteStatus.movingSeparately:
      // TODO: Handle this case.
      case PlaceMatteStatus.done:
      // TODO: Handle this case.
    }
  }

  void _moveOnPlacing(Offset position) {
    for (int i = 0; i < _pageItems.length; ++i) {
      final item = _pageItems[i];
      final relativePositionReferStart = _pageItemShifts[i];
      item.x = position.dx + relativePositionReferStart.dx;
      item.y = position.dy + relativePositionReferStart.dy;
    }
  }

  @override
  bool stop() {
    statusManager.finishPlaceMatte(); // todo: change status
    return true;
  }
}
