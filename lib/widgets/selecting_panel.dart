import 'package:flutter/cupertino.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/widgets/pen_selector.dart';
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
    final isNotEmpty = widget.pen.selected.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      () {
        final moving = widget.pen.moving;
        assert(isNotEmpty || !moving);
        return c.buildButton(isNotEmpty ? () => setState(() => widget.pen.moving = !moving) : null,
            moving ? material.Icons.select_all : material.Icons.open_with_sharp, CupertinoColors.activeBlue,
            heightFactor: 0.7, padding: const EdgeInsets.only(left: leftPadding));
      }(),
      () {
        final changingPen = widget.pen.changingPen;
        const buttonHeightFactor = 0.2;
        const height = c.buttonHeight * buttonHeightFactor;
        const penButtonMargin = 3.0;
        return changingPen
            ? Padding(
                padding: const EdgeInsets.only(left: leftPadding),
                child: Row(
                  children: statusManager.normalPenList
                      .map((pen) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.pen.changePen(pen),
                            child: Container(
                                height: height + c.buttonPadding * 2 - penButtonMargin,
                                padding: const EdgeInsets.symmetric(horizontal: c.buttonPadding),
                                margin: const EdgeInsets.only(right: 5, top: penButtonMargin),
                                decoration: BoxDecoration(
                                    color: material.Colors.black.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                                child: Center(child: PenSelectorState.buildPenIcon(pen))),
                          ) as Widget)
                      .toList()
                    ..add(Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => setState(() => widget.pen.changingPen = false),
                        child: const Icon(material.Icons.cancel),
                      ),
                    )),
                ),
              )
            : c.buildButton(isNotEmpty ? () => setState(() => widget.pen.changingPen = true) : null, CupertinoIcons.pencil_circle_fill,
                CupertinoColors.systemYellow,
                heightFactor: buttonHeightFactor);
      }(),
      c.buildButton(isNotEmpty ? () => setState(() => widget.pen.delete()) : null, material.Icons.delete_forever, CupertinoColors.systemRed,
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
          c.buildButton(isNotEmpty ? () => setState(() => widget.pen.refresh()) : null, material.Icons.refresh, CupertinoColors.activeBlue,
              widthFactor: 0.248, heightFactor: 0.5, padding: const EdgeInsets.only(left: leftPadding)),
          c.buildConfirmButton(() => setState(() => widget.pen.finish()), widthFactor: 0.7, heightFactor: 0.5),
        ],
      ),
    ]);
  }
}
