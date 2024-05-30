import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/user_preferences.dart';
import 'package:reading_note/widgets/PenSelector.dart';

import '../status_manager/status_manager.dart';

class ControlPanelBuilder {
  ControlPanelBuilder._();

  static bool get ready => userPreferences.ready;

  // todo: 只允许手指交互，手写笔只用于✍️？
  static Widget build() {
    assert(ready);

    Widget mainArea = (const {
      InteractiveMode.bookHandwrite: _buildOnMarkPage,
      InteractiveMode.noteHandwrite: _buildOnWriteNote,
    })[statusManager.currentMode]!();

    return Positioned(
        bottom: 0,
        left: 0,
        child: Stack(children: [
          Column(children: [
            PenSelector(),
            mainArea,
          ]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStatusText(),
          )
        ]));
  }

  static Widget _buildOnMarkPage() => _buildMainButton(statusManager.gotoIndependentNote, material.Icons.edit_note_rounded, 80);

  static Widget _buildOnWriteNote() => _buildMainButton(statusManager.gotoBook, material.Icons.menu_book_rounded, 60);

  static Widget _buildMainButton(VoidCallback onPressed, IconData icon, double iconSize) {
    const margin = 30.0;

    return Padding(
      padding: const EdgeInsets.only(left: margin, right: margin, bottom: margin),
      child: material.FloatingActionButton.large(onPressed: onPressed, child: Icon(icon, size: iconSize)),
    );
  }

  static Widget _buildStatusText() {
    // fixme: 不需要？用图标表示即可
    return Text(
      "当前处于${(const {
        InteractiveMode.bookHandwrite: "手写模式",
        InteractiveMode.bookMatting: "摘抄模式-标记中",
        InteractiveMode.noteHandwrite: "手写模式",
        InteractiveMode.notePlaceMatte: "摘抄模式-放置中",
      })[statusManager.currentMode]!}",
      style: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}
