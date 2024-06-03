import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/pen.dart';
import 'package:reading_note/widgets/pen_selector.dart';
import 'package:reading_note/widgets/matting_control_panel.dart';
import '../pen/matte_positioner_pen.dart';
import '../status_manager/status_manager.dart';
import '../note_page/note_page.dart';
import 'common.dart' as c;

class ControlPanelBuilder {
  ControlPanelBuilder._();

  static Widget build(BuildContext context) {
    assert(statusManager.ready);

    Widget? bottom;
    if (statusManager.drawingPen?.type == PenType.mattingMarkPen) {
      bottom = const MattingControlPanel();
    } else if (statusManager.usingPen is MattePositionerPen) {
      bottom = const Text("TODO: _buildOnPlacingMatte");
    }

    late Widget mainButton;
    switch (statusManager.interacting) {
      case NoteType.book:
        mainButton = _buildMainButton(statusManager.switchToNote, material.Icons.edit_note_rounded);
        break;
      case NoteType.note:
        mainButton = _buildMainButton(statusManager.switchToBook, material.Icons.menu_book_rounded, 70.0);
        break;
    }

    return Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                mainButton,
                PenSelector() /*fixme*/
              ]),
          Expanded(child: Container()),
          if (bottom != null) bottom
        ]));
  }

  static Widget _buildMainButton(VoidCallback onPressed, IconData icon, [double iconSize = c.mainButtonSize]) {
    // return material.MaterialButton(
    return CupertinoButton(
      onPressed: onPressed,
      child: SizedBox(width: c.mainButtonSize, height: c.mainButtonSize, child: Icon(icon, size: iconSize)),
    );
  }
}
