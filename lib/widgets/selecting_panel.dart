import 'package:flutter/cupertino.dart';
import '../pen/selector_pen/select_pen.dart';
import 'common.dart' as c;
import 'package:flutter/material.dart' as material;

class SelectingPanel extends StatefulWidget {
  final SelectPen pen;

  const SelectingPanel({super.key, required this.pen});

  @override
  State<StatefulWidget> createState() => _SelectingPanelState();
}

class _SelectingPanelState extends State<SelectingPanel> {
  bool _horizontalDragging = false;
  bool _verticalDragging = false;
  Offset? _startOffset;

  bool get _dragging => _horizontalDragging || _verticalDragging;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(vertical: 5, horizontal: 20);
    return Column(children: [
      Padding(
        padding: padding,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragDown: (detail) {
            widget.pen.beginAdjustWidth(); // trigger widget.pen._showingModal
            setState(() => _horizontalDragging = true);
          },
          onHorizontalDragStart: (detail) {
            _startOffset = detail.localPosition;
            widget.pen.beginAdjustWidth();
          },
          onHorizontalDragUpdate: (detail) => widget.pen.adjustWidth((detail.localPosition - _startOffset!).dx),
          onHorizontalDragCancel: () {
            setState(() => _horizontalDragging = false);
            widget.pen.endAdjustWidth();
          },
          onHorizontalDragEnd: (_) {
            setState(() => _horizontalDragging = false);
            widget.pen.endAdjustWidth();
          },
          onVerticalDragDown: (detail) => setState(() => _verticalDragging = true),
          onVerticalDragStart: (detail) {
            _startOffset = detail.localPosition;
            widget.pen.beginAdjustHeight();
          },
          onVerticalDragUpdate: (detail) => widget.pen.adjustHeight((_startOffset! - detail.localPosition).dy),
          onVerticalDragCancel: () {
            widget.pen.endAdjustHeight();
            setState(() => _verticalDragging = false);
          },
          onVerticalDragEnd: (_) {
            widget.pen.endAdjustHeight();
            setState(() => _verticalDragging = false);
          },
          onDoubleTap: () => widget.pen.resetSize(),
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
      c.buildConfirmButton(() => setState(() => widget.pen.finish())),
    ]);
  }
}
