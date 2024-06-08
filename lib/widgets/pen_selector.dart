import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' as material;
import 'package:reading_note/pen/selector_pen/select_pen.dart';
import 'package:reading_note/status_manager/matting_manager.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import '../pen/pen.dart';
import 'common.dart' as c;

class PenSelector extends StatefulWidget {
  const PenSelector({super.key});

  @override
  State<StatefulWidget> createState() => PenSelectorState();
}

class PenSelectorState extends State<PenSelector> {
  Offset _dragStart = Offset.zero;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    const dragStep = 75.0;
    final usingPen = statusManager.usingPen;
    // todo: 理想交互：
    //  1.只手指可交互，笔不行（以此保证对应位置笔都可以写。但其实如果不是透明，那也没意义。而且有些小icon用笔点会更合适些）
    //  其他方式：切换魔术笔🪄与普通笔在一个按钮，点击切换。横向滑动切换其他笔，向上滑动切换橡皮，向下滑动切换选择，长按时提示/增删笔列表？
    // todo: 增加全局遮罩层，显示切换动画
    return GestureDetector(
      onTap: () {
        final now = DateTime.now();
        if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 200) {
          statusManager.useCommonPen();
        } else {
          statusManager.switchMattingOrPuttingMatte();
        }
        _lastTapTime = now;
      },
      onVerticalDragStart: (detail) {
        _dragStart = detail.localPosition;
        statusManager.beginTurnPen();
      },
      onVerticalDragUpdate: (detail) {
        final diff = detail.localPosition.dy - _dragStart.dy;
        final offsetAbs = (diff.abs() / dragStep).round();
        statusManager.turnPen(diff < 0 ? -offsetAbs : offsetAbs);
      },
      onVerticalDragEnd: (detail) {
        final diff = detail.localPosition.dy - _dragStart.dy;
        if ((diff.abs() / dragStep).round() != 0) return;
        if (diff > 0) {
          statusManager.turnPen(1);
        } else if (diff < 0) {
          statusManager.turnPen(-1);
        }
      },
      onHorizontalDragStart: (detail) => _dragStart = detail.localPosition,
      onHorizontalDragEnd: (detail) {
        final diff = detail.localPosition.dx - _dragStart.dx;
        if (diff > 0) {
          statusManager.toggleSelectingMode();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: c.mainButtonSize, maxWidth: c.mainButtonSize, minHeight: 200),
        margin: const EdgeInsets.only(left: c.panelPadding),
        decoration: c.borderDecoration,
        child: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.center,
          children:
              (usingPen is SelectPen ? [usingPen] : statusManager.penList).map((i) => _buildPenItem(i, usingPen)).toList(growable: false),
        ),
      ),
    );
  }

  Widget _buildPenItem(Pen pen, Pen usingPen) {
    return Transform.scale(
      scale: pen == usingPen ? 2.0 : 1.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              (const [
                CupertinoIcons.pencil,
                material.Icons.brush_rounded,
                material.Icons.format_paint_outlined,
                material.Icons.format_paint,
                material.Icons.select_all,
              ])[pen.type.index],
              color: pen.type != PenType.mattePositionerPen
                  ? pen.color
                  : (mattingManager.isNotEmpty ? pen.color : CupertinoColors.systemGrey4),
              size: 20,
            ),
          ),
          if (pen.type == PenType.ballPointPen)
            Transform.translate(
                offset: const Offset(0, -3),
                child: Container(
                    height: pen.lineWidth,
                    width: 15,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(pen.lineWidth)), color: pen.color))),
        ],
      ),
    );
  }
}
