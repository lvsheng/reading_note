import 'package:flutter/cupertino.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:reading_note/util/log.dart';
import '../pen/matte_positioner_pen.dart';
import '../pen/pen.dart';

/// Used by [StatusManager], initialized referring to [UserPreferences] and syncing data to [UserPreferences]
class PenManager {
  List<List<Pen>>? _penListPair;
  List<Pen>? _currentPenPair;
  late final Future<void> readyFuture;

  PenManager() {
    readyFuture = _load();
  }

  /// 不包括特殊的[PenType.mattingMarkPen]和[PenType.mattePositionerPen]
  // List<Pen> penListOf(NoteType noteType) => _penListPair![noteType.index]; // todo: 两类使用同一份penList，只是currentPen不同？
  List<Pen> penListOf(NoteType noteType) => _penListPair![NoteType.note.index]; // todo: 两类使用同一份penList，只是currentPen不同？

  Pen currentPenOf(NoteType noteType) => _currentPenPair![noteType.index];

  Pen? _mattingPen;
  Pen get mattingPen {
    // todo
    logWarn("TODO: mattingPen");
    return _mattingPen ??= Pen(-1, PenType.mattingMarkPen, CupertinoColors.systemYellow.withAlpha(125), 10.0);
  }

  Pen? _mattePlacePen;
  Pen get mattePlacePen {
    // todo
    logWarn("TODO: mattePlacePen");
    // return _mattePlacePen ??= Pen(-1, PenType.mattePositionerPen, const Color(0x00000000), 1.0);
    return _mattePlacePen ??= MattePositionerPen();
  }

  bool get mattingWhenBook {
    // todo
    logWarn("TODO: mattingWhenBook preference");
    return true; // todo preference
  }

  bool get puttingMatteWhenNote {
    // todo
    logWarn("TODO: puttingMatteWhenBook preference");
    return true; // todo preference
  }

  set puttingMatteWhenNote(bool value) {
    // todo
  }

  void setCurrentPen(NoteType noteType, Pen pen) {
    userPreferences.setCurrentPen(noteType, _currentPenPair![noteType.index] = pen);
  }

  Pen addNewPen(PenType type, Color color, double lineWidth) {
    final pen = Pen(userPreferences.nextPenId++, type, color, lineWidth);
    userPreferences.setPenTypeOf(pen.id, pen.type);
    userPreferences.setPenColorO(pen.id, pen.color);
    userPreferences.setPenLineWidthOf(pen.id, pen.lineWidth);
    return pen;
  }

  List<Pen> resetPenList(NoteType noteType, [bool initializingPenListPair = false]) {
    final result = userPreferences.setPenList(
        noteType,
        noteType == NoteType.book
            ? [
                addNewPen(PenType.mattingMarkPen, CupertinoColors.systemOrange, 8),
                addNewPen(PenType.ballPointPen, CupertinoColors.black, 1),
                addNewPen(PenType.markPen, CupertinoColors.systemYellow.withAlpha(125), 10),
              ]
            : [
                addNewPen(PenType.ballPointPen, CupertinoColors.black, 2),
                addNewPen(PenType.ballPointPen, CupertinoColors.systemBlue, 3),
                addNewPen(PenType.ballPointPen, CupertinoColors.systemRed, 3),
                addNewPen(PenType.markPen, CupertinoColors.systemYellow.withAlpha(125), 10),
                // addNewPen(PenType.markPen, CupertinoColors.systemYellow.withAlpha(125), 10),
                // addNewPen(PenType.markPen, CupertinoColors.systemYellow.withAlpha(125), 10),
              ]);
    if (!initializingPenListPair) {
      _penListPair![noteType.index] = result;
    }
    return result;
  }

  Future<void> _load() async {
    await userPreferences.readyFuture;
    // [userPreferences]只在初始化时读取一次，后续只读取本对象内的内存缓存、写入时再同步至[userPreferences]
    _penListPair = List.generate(2, (i) {
      final noteType = NoteType.values[i];
      final result = userPreferences
          .penListOf(noteType)
          ?.map((id) => Pen(id, userPreferences.penTypeOf(id), userPreferences.penColorOf(id), userPreferences.penLineWidthOf(id)));
      // final result = null;
      if (result == null || result.isEmpty) return resetPenList(noteType, true);
      return result.toList(growable: false);
    });
    _currentPenPair = List.generate(2, (i) {
      final list = penListOf(NoteType.values[i]);
      assert(list.isNotEmpty, "_penListPair just initialized, should not empty");
      final id = userPreferences.currentPenIdOf(NoteType.values[i]);
      return list.firstWhere((e) => e.id == id, orElse: () => list.first);
    });
  }
}
