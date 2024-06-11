import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/user_preferences.dart';
import '../pen/pen.dart';

/// Used by [StatusManager], initialized referring to [UserPreferences] and syncing data to [UserPreferences]
class PenManager {
  List<Pen>? _list;
  List</*index:NoteType*/Pen>? _currentPenPair;
  late final Future<void> readyFuture;

  PenManager() {
    readyFuture = _load();
  }

  /// 不包括特殊的[PenType.mattingMarkPen]和[PenType.mattePositionerPen]
  List<Pen> get list => _list!;

  Pen currentPenOf(NoteType noteType) => _currentPenPair![/*noteType.index*/0];

  bool mattingWhenBook = true;

  void setCurrentPen(NoteType noteType, Pen pen) {
    userPreferences.setCurrentPen(noteType, _currentPenPair![/*noteType.index*/0] = pen);
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
        [
          addNewPen(PenType.ballPointPen, CupertinoColors.black, 0),
          addNewPen(PenType.ballPointPen, CupertinoColors.systemRed, 1),
          addNewPen(PenType.ballPointPen, CupertinoColors.black, 2),
          addNewPen(PenType.ballPointPen, material.Colors.blueAccent.shade100, 2),
          addNewPen(PenType.ballPointPen, CupertinoColors.systemRed, 4),
          addNewPen(PenType.ballPointPen, material.Colors.black, 4),
          addNewPen(PenType.ballPointPen, material.Colors.blue.shade800, 4),
          addNewPen(PenType.ballPointPen, material.Colors.green, 4),
          addNewPen(PenType.markPen, CupertinoColors.systemYellow.withAlpha(150), 30),
        ]);
    if (!initializingPenListPair) {
      _list = result;
    }
    return result;
  }

  Future<void> _load() async {
    await userPreferences.readyFuture;
    // [userPreferences]只在初始化时读取一次，后续只读取本对象内的内存缓存、写入时再同步至[userPreferences]
    var result = userPreferences
        .penListOf(NoteType.note)
        ?.map((id) => Pen(id, userPreferences.penTypeOf(id), userPreferences.penColorOf(id), userPreferences.penLineWidthOf(id))).toList(growable: false);
    // result = null;
    if (result == null || result.isEmpty) result = resetPenList(NoteType.note, true);
    _list = result;
    _currentPenPair = List.generate(2, (i) {
      assert(list.isNotEmpty, "_penListPair just initialized, should not empty");
      final id = userPreferences.currentPenIdOf(NoteType.values[i]);
      return list.firstWhere((e) => e.id == id, orElse: () => list.first);
    });
  }
}
