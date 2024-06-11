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
    const leftPadding = 20.0;
    const padding = EdgeInsets.symmetric(vertical: 5, horizontal: leftPadding);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      () {
        final enable = widget.pen.selected.isNotEmpty;
        final moving = widget.pen.moving;
        assert(enable || !moving);
        return c.buildButton(enable ? () => setState(() => widget.pen.moving = !widget.pen.moving) : null,
            moving ? material.Icons.select_all : material.Icons.open_with_sharp, CupertinoColors.activeBlue,
            heightFactor: 0.7, padding: const EdgeInsets.only(left: leftPadding));
      }(),
      c.buildButton(widget.pen.selected.isEmpty ? null : () => setState(() => widget.pen.delete()), material.Icons.delete_forever,
          CupertinoColors.systemRed,
          heightFactor: 0.2),
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
      Row(
        children: [
          c.buildButton(widget.pen.selected.isEmpty ? null : () => setState(() => widget.pen.refresh()), material.Icons.refresh,
              CupertinoColors.activeBlue,
              widthFactor: 0.248, heightFactor: 0.5, padding: const EdgeInsets.only(left: leftPadding)),
          c.buildConfirmButton(() => setState(() => widget.pen.finish()), widthFactor: 0.7, heightFactor: 0.5),
        ],
      ),
    ]);
  }
}
