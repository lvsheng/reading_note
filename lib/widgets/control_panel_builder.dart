import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/pen.dart';
import 'package:reading_note/widgets/PenSelector.dart';
import '../pen/matte_positioner_pen.dart';
import '../status_manager/status_manager.dart';
import '../note_page/note_page.dart';

class ControlPanelBuilder {
  ControlPanelBuilder._();

  // todo: 只允许手指交互，手写笔只用于✍️？
  static Widget build() {
    assert(statusManager.ready);

    late Widget mainArea;
    {
      if (statusManager.drawingPen?.type == PenType.mattingMarkPen) {
        // todo: 高度调整器
        mainArea = Text("TODO: 高度调整器");
      } else if (statusManager.usingPen is MattePositionerPen) {
        mainArea = _buildOnPlacingMatte();
      } else {
        switch (statusManager.interactingNoteType) {
          case NoteType.book:
            mainArea = _buildOnReadingBook();
            break;
          case NoteType.note:
            mainArea = _buildOnNoting();
            break;
        }
      }
    }

    return Positioned(
        bottom: 0,
        left: 0,
        child: Stack(children: [
          Column(children: [
            PenSelector(), // fixme
            mainArea,
          ])
        ]));
  }

  static Widget _buildOnReadingBook() => _buildMainButton(statusManager.switchToNote, material.Icons.edit_note_rounded, 80);

  static Widget _buildOnNoting() => _buildMainButton(statusManager.switchToBook, material.Icons.menu_book_rounded, 60);

  static Widget _buildOnPlacingMatte() {
    return Text("TODO: _buildOnPlacingMatte");
  }

  static Widget _buildMainButton(VoidCallback onPressed, IconData icon, double iconSize) {
    const margin = 30.0;

    return Padding(
      padding: const EdgeInsets.only(left: margin, right: margin, bottom: margin),
      child: material.FloatingActionButton.large(onPressed: onPressed, child: Icon(icon, size: iconSize)),
    );
  }
}
