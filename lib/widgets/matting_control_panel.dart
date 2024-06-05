import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/status_manager/status_manager.dart';
import '../pen/matting_mark_generator.dart';
import 'common.dart' as c;

class MattingControlPanel extends StatefulWidget {
  const MattingControlPanel({super.key});

  @override
  State<StatefulWidget> createState() => _MattingControlPanelState();
}

class _MattingControlPanelState extends State<MattingControlPanel> {
  bool _horizontalDragging = false;
  bool _verticalDragging = false;
  Offset? _startOffset;

  bool get _dragging => _horizontalDragging || _verticalDragging;

  MattingMarkGenerator? _tracker;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(vertical: 5, horizontal: 20);
    return _tracker?.frozen != true
        ? Column(children: [
            Padding(
              padding: padding,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragDown: (detail) => setState(() => _horizontalDragging = true),
                onHorizontalDragStart: (detail) {
                  _startOffset = detail.localPosition;
                  _tracker = statusManager.drawingPen!.ongoingTracker! as MattingMarkGenerator;
                  _tracker!.startAdjustLeft();
                },
                onHorizontalDragUpdate: (detail) => _tracker!.adjustLeft((detail.localPosition - _startOffset!).dx),
                onHorizontalDragCancel: () => setState(() => _horizontalDragging = false),
                onHorizontalDragEnd: (_) => setState(() => _horizontalDragging = false),
                onVerticalDragDown: (detail) => setState(() => _verticalDragging = true),
                onVerticalDragStart: (detail) {
                  _startOffset = detail.localPosition;
                  _tracker = statusManager.drawingPen!.ongoingTracker! as MattingMarkGenerator;
                  _tracker!.startAdjustHeight();
                },
                onVerticalDragUpdate: (detail) => _tracker!.adjustHeight((_startOffset! - detail.localPosition).dy),
                onVerticalDragCancel: () => setState(() => _verticalDragging = false),
                onVerticalDragEnd: (_) => setState(() => _verticalDragging = false),
                child: Transform.scale(
                  scale: _dragging ? 1.1 : 1.0,
                  child: Container(
                    width: c.operatingAreaSize,
                    height: c.operatingAreaSize,
                    alignment: Alignment.center,
                    decoration: c.borderDecoration,
                    child: Icon(material.Icons.open_with, color: CupertinoColors.black, size: _dragging ? 40 : 30),
                  ),
                ),
              ),
            ),
            c.buildConfirmButton(
                () => setState(() => (_tracker = statusManager.drawingPen!.ongoingTracker! as MattingMarkGenerator).froze())),
          ])
        : Container();
  }
}
