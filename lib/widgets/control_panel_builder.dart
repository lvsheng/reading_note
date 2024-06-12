import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/pen.dart';
import 'package:reading_note/pen/selector_pen/select_pen.dart';
import 'package:reading_note/widgets/pen_selector.dart';
import 'package:reading_note/widgets/matting_control_panel.dart';
import 'package:reading_note/widgets/matte_positioner_panel.dart';
import 'package:reading_note/widgets/selecting_panel.dart';
import '../pen/matte_positioner_pen.dart';
import '../status_manager/status_manager.dart';
import '../note_page/note_page.dart';
import 'common.dart' as c;
import 'menu.dart';

class ControlPanelBuilder extends StatefulWidget {
  const ControlPanelBuilder({super.key});

  @override
  State<StatefulWidget> createState() => _ControlPanelBuilderState();
}

class _ControlPanelBuilderState extends State<ControlPanelBuilder> {
  bool showingMenu = false;

  @override
  void initState() {
    statusManager.historyStack.addListener(_refresh);
    statusManager.addListener(_refresh);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    statusManager.historyStack.removeListener(_refresh);
    statusManager.removeListener(_refresh);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    assert(statusManager.ready);

    Widget? bottom;
    if (statusManager.drawingPen?.type == PenType.mattingMarkPen) {
      bottom = const MattingControlPanel();
    } else {
      final usingPen = statusManager.usingPen;
      switch (usingPen.type) {
        case PenType.ballPointPen:
        case PenType.markPen:
        case PenType.mattingMarkPen:
          break;

        case PenType.mattePositionerPen:
          bottom = MattePositionerPanel(usingPen as MattePositionerPen);
          break;

        case PenType.selectPen:
          bottom = SelectingPanel(pen: usingPen as SelectPen);
          break;
      }
    }

    late Widget mainButton;
    switch (statusManager.interacting) {
      case NoteType.book:
        mainButton = _buildMainButton(statusManager.switchToNote, material.Icons.edit_note_rounded);
        break;
      case NoteType.note:
        mainButton = _buildMainButton(statusManager.switchToBook, material.Icons.menu_book_rounded);
        break;
    }

    final undoable = statusManager.historyStack.undoable;
    final redoable = statusManager.historyStack.redoable;

    return Positioned(
        top: 0,
        bottom: 0,
        left: 0,
        right: 0,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                mainButton,
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GestureDetector(
                          onTap: undoable
                              ? () {
                                  statusManager.historyStack.undo();
                                }
                              : null,
                          child: Icon(
                            material.Icons.undo,
                            color: undoable ? CupertinoColors.black : CupertinoColors.systemGrey,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: GestureDetector(
                          onTap: redoable
                              ? () {
                                  statusManager.historyStack.redo();
                                }
                              : null,
                          child: Icon(
                            material.Icons.redo,
                            color: redoable ? CupertinoColors.black : CupertinoColors.systemGrey,
                          )),
                    ),
                    if (showingMenu)
                      Menu(
                        pageNumber: statusManager.pageNumber,
                        type: statusManager.interacting,
                        dismiss: () => setState(() => showingMenu = false),
                      ),
                    if (!showingMenu)
                      GestureDetector(
                        onTap: () => setState(() => showingMenu = true),
                        child: const Icon(material.Icons.more_horiz),
                      ),
                    const SizedBox(width: 30),
                  ],
                ))
              ],
            ),
            const PenSelector(),
          ]),
          Expanded(child: Container()),
          if (bottom != null) bottom
        ]));
  }

  Widget _buildMainButton(VoidCallback onPressed, IconData icon, [double iconSize = c.mainButtonSize]) {
    // return material.MaterialButton(
    return CupertinoButton(
      onPressed: onPressed,
      child: SizedBox(
          width: c.mainButtonSize,
          height: c.mainButtonSize,
          child: Icon(
            icon,
            size: iconSize,
            color: CupertinoColors.black,
          )),
    );
  }
}
