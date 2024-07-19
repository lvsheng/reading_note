import 'package:flutter/cupertino.dart';
import 'package:reading_note/protobuf/note.pb.dart' as pb;
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/user_preferences.dart';
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

Color decorationColor(pb.DecorationType type) {
  const opacity = 0.7;
  switch (type) {
    case pb.DecorationType.DT_BG_BLUE:
    case pb.DecorationType.DT_TILDE_BLUE:
    case pb.DecorationType.DT_UNDERLINE_BLUE:
      return material.Colors.blue.withOpacity(opacity);
      break;

    case pb.DecorationType.DT_BG_GREEN:
    case pb.DecorationType.DT_TILDE_GREEN:
    case pb.DecorationType.DT_UNDERLINE_GREEN:
      return material.Colors.green.withOpacity(opacity);
      break;

    case pb.DecorationType.DT_BG_PURPLE:
    case pb.DecorationType.DT_TILDE_PURPLE:
    case pb.DecorationType.DT_UNDERLINE_PURPLE:
      return material.Colors.purple.withOpacity(opacity);
      break;

    case pb.DecorationType.DT_BG_RED:
    case pb.DecorationType.DT_TILDE_RED:
    case pb.DecorationType.DT_UNDERLINE_RED:
      return material.Colors.red.withOpacity(opacity);
      break;

    case pb.DecorationType.DT_BG_YELLOW:
    case pb.DecorationType.DT_TILDE_YELLOW:
    case pb.DecorationType.DT_UNDERLINE_YELLOW:
      return material.Colors.yellow.shade700.withOpacity(opacity);
      break;
  }

  throw "wrong decoration type $type";
}

IconData decorationIcon(pb.DecorationType type) {
  switch (type) {
    case pb.DecorationType.DT_BG_BLUE:
    case pb.DecorationType.DT_BG_GREEN:
    case pb.DecorationType.DT_BG_PURPLE:
    case pb.DecorationType.DT_BG_RED:
    case pb.DecorationType.DT_BG_YELLOW:
      return material.Icons.texture;

    case pb.DecorationType.DT_TILDE_BLUE:
    case pb.DecorationType.DT_TILDE_GREEN:
    case pb.DecorationType.DT_TILDE_PURPLE:
    case pb.DecorationType.DT_TILDE_RED:
    case pb.DecorationType.DT_TILDE_YELLOW:
      return material.Icons.waves;

    case pb.DecorationType.DT_UNDERLINE_BLUE:
    case pb.DecorationType.DT_UNDERLINE_GREEN:
    case pb.DecorationType.DT_UNDERLINE_PURPLE:
    case pb.DecorationType.DT_UNDERLINE_RED:
    case pb.DecorationType.DT_UNDERLINE_YELLOW:
      return material.Icons.text_format;
  }

  throw "wrong decoration type $type";
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
      () {
        final changingDecoration = widget.pen.changingDecoration;
        const buttonHeightFactor = 0.5;
        const penButtonMargin = 3.0;

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (changingDecoration)
            Padding(
                padding: const EdgeInsets.only(left: leftPadding),
                child: Row(
                  children: pb.DecorationType.values.where((type) => type.value < 20).map((type) {
                    bool isRed = type.value % 5 == 0;
                    bool isBg = type.value < 10;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => widget.pen.changeDecoration(type),
                      child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          margin: EdgeInsets.only(right: 2, top: penButtonMargin, left: isRed && type.value > 0 ? 15 : 0),
                          decoration:
                              BoxDecoration(color: isBg ? decorationColor(type) : material.Colors.black.withOpacity(0.1), borderRadius: const BorderRadius.all(Radius.circular(10))),
                          child: Center(
                              child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            child: Icon(
                              decorationIcon(type),
                              color: isBg ? material.Colors.black : decorationColor(type),
                              // color: material.Colors.black,
                              size: 30,
                            ),
                          ))),
                    ) as Widget;
                  }).toList(growable: false),
                )),
          c.buildButton(
              isNotEmpty
                  ? () => setState(() {
                        if (!widget.pen.changingDecoration) {
                          widget.pen.changingDecoration = true;
                          widget.pen.changeDecoration(pb.DecorationType.values[userPreferences.lastDecoration]);
                        } else {
                          widget.pen.changingDecoration = false;
                          widget.pen.changeDecoration(null);
                        }
                      })
                  : null,
              material.Icons.text_format,
              CupertinoColors.systemBlue,
              heightFactor: buttonHeightFactor),
        ]);
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
