import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/matte_positioner_pen.dart';
import 'package:reading_note/status_manager/matting_manager.dart';
import 'common.dart' as c;

class MattePositionerPanel extends StatefulWidget {
  final MattePositionerPen pen;

  const MattePositionerPanel(this.pen, {super.key});

  @override
  State<StatefulWidget> createState() => _MattePositionerPanelState();
}

class _MattePositionerPanelState extends State<MattePositionerPanel> {
  bool _horizontalDragging = false;
  bool _verticalDragging = false;
  Offset? _startOffset;

  bool get _dragging => _horizontalDragging || _verticalDragging;

  @override
  Widget build(BuildContext context) {
    const paddingSmall = 5.0;
    const paddingLarge = 20.0;
    const padding = EdgeInsets.symmetric(vertical: paddingSmall, horizontal: paddingLarge); // fixme: repeat with MattingControlPanel
    const axisShortEdge = 80.0;
    return mattingManager.status != MattingStatus.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => widget.pen.toggleOneByOne(),
                child: Container(
                  width: c.operatingAreaSize + paddingSmall,
                  height: axisShortEdge,
                  margin: EdgeInsets.only(left: paddingLarge, bottom: paddingSmall),
                  decoration: c.borderDecoration,
                  child: const Center(child: Text("全部/单个")),
                ),
              ),
              GestureDetector(
                onTap: () => widget.pen.changeDirection(Axis.horizontal),
                child: Container(
                  width: c.operatingAreaSize + paddingSmall,
                  height: axisShortEdge,
                  margin: EdgeInsets.only(left: paddingLarge),
                  decoration: c.borderDecoration,
                  child: const Icon(material.Icons.arrow_right_alt_rounded, color: CupertinoColors.black),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: padding.copyWith(right: paddingSmall),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragDown: (detail) => setState(() => _horizontalDragging = true),
                      onHorizontalDragStart: (detail) {
                        _startOffset = detail.localPosition;
                        widget.pen.beginAdjustPadding();
                      },
                      onHorizontalDragUpdate: (detail) => widget.pen.adjustPadding((detail.localPosition - _startOffset!).dx),
                      onHorizontalDragCancel: () => setState(() => _horizontalDragging = false),
                      onHorizontalDragEnd: (_) => setState(() => _horizontalDragging = false),

                      onVerticalDragDown: (detail) => setState(() => _verticalDragging = true),
                      onVerticalDragStart: (detail) {
                        _startOffset = detail.localPosition;
                        widget.pen.beginAdjustScale();
                      },
                      onVerticalDragUpdate: (detail) => widget.pen.adjustScale((detail.localPosition - _startOffset!).dy),
                      onVerticalDragCancel: () => setState(() => _verticalDragging = false),
                      onVerticalDragEnd: (_) => setState(() => _verticalDragging = false),

                      onDoubleTap: () => widget.pen.resetScale(),

                      child: Transform.scale(
                        scale: _dragging ? 1.1 : 1.0,
                        child: Container(
                          width: c.operatingAreaSize - axisShortEdge,
                          height: c.operatingAreaSize - axisShortEdge,
                          alignment: Alignment.center,
                          decoration: c.borderDecoration,
                          child: Icon(material.Icons.open_with, color: CupertinoColors.black, size: _dragging ? 40 : 30),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.pen.changeDirection(Axis.vertical),
                    child: Container(
                      width: axisShortEdge,
                      height: c.operatingAreaSize - axisShortEdge,
                      decoration: c.borderDecoration,
                      child: const Icon(material.Icons.arrow_downward_rounded, color: CupertinoColors.black),
                    ),
                  ),
                ],
              ),
              c.buildConfirmButton(widget.pen.couldConfirm()
                  ? () {
                      widget.pen.ongoingTracker?.froze();
                      widget.pen.onUserConfirm();
                    }
                  : null)
            ],
          )
        : Container();
  }
}
