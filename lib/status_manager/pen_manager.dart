import 'package:flutter/cupertino.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/user_preferences.dart';

import '../pen.dart';

/// Used by [StatusManager], initialized referring to [UserPreferences] and syncing data to [UserPreferences]
class PenManager {
  List<List<Pen>>? _penListPair;
  List<Pen>? _currentPenPair;

  PenManager() {
    _load();
  }

  List<Pen> penListOf(NoteType noteType) => _penListPair![noteType.index];

  Pen currentPenOf(NoteType noteType) => _currentPenPair![noteType.index];

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
        noteType == NoteType.bookMarkNote
            ? [
                addNewPen(PenType.mattingMarkPen, CupertinoColors.systemOrange, 8),
                addNewPen(PenType.ballPointPen, CupertinoColors.black, 1),
                addNewPen(PenType.markPen, CupertinoColors.systemYellow, 10),
              ]
            : [
                addNewPen(PenType.ballPointPen, CupertinoColors.black, 2),
                addNewPen(PenType.ballPointPen, CupertinoColors.systemBlue, 3),
                addNewPen(PenType.ballPointPen, CupertinoColors.systemRed, 3),
                addNewPen(PenType.markPen, CupertinoColors.systemYellow, 10),
              ]);
    if (!initializingPenListPair) {
      _penListPair![noteType.index] = result;
    }
    return result;
  }

  void _load() async {
    await userPreferences.readyFuture;
    // [userPreferences]只在初始化时读取一次，后续只读取本对象内的内存缓存、写入时再同步至[userPreferences]
    _penListPair = List.generate(2, (i) {
      final noteType = NoteType.values[i];
      final result = userPreferences
          .penListOf(noteType)
          ?.map((id) => Pen(id, userPreferences.penTypeOf(id), userPreferences.penColorOf(id), userPreferences.penLineWidthOf(id)));
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
