import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
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
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    // todo: 理想交互：
    //  1.只手指可交互，笔不行（以此保证对应位置笔都可以写。但其实如果不是透明，那也没意义。而且有些小icon用笔点会更合适些）
    //  2.touchstart时出现其他可选笔，移动手指选择
    //  其他方式：切换魔术笔🪄与普通笔在一个按钮，点击切换。横向滑动切换其他笔，向上滑动切换橡皮，向下滑动切换选择，长按时提示/增删笔列表？
    // todo: 增加全局遮罩层，显示切换动画
    return GestureDetector(
      onTap: statusManager.switchMattingOrPuttingMatte,
      onHorizontalDragStart: (detail) {
        _dragStart = detail.localPosition;
        setState(() => _dragging = true);
      },
      onHorizontalDragEnd: (detail) {
        final diff = detail.localPosition.dx - _dragStart.dx;
        if (diff > 0) {
          statusManager.nextPen();
        } else if (diff < 0) {
          statusManager.previousPen();
        } else {
          statusManager.switchMattingOrPuttingMatte();
        }
        setState(() => _dragging = false);
      },
      onHorizontalDragCancel: () => setState(() => _dragging = false),
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: _dragging ? 1.3 : 1.0,
        child: Container(
          constraints: const BoxConstraints(minWidth: c.mainButtonSize, maxWidth: c.mainButtonSize, minHeight: c.mainButtonSize),
          margin: const EdgeInsets.only(left: c.panelPadding),
          decoration: c.borderDecoration,
          child: Wrap(
            children: statusManager.penList.map(_buildPenItem).toList(growable: false),
          ),
        ),
      ),
    );
  }

  Widget _buildPenItem(Pen pen) {
    return Transform.scale(
      scale: pen == statusManager.usingPen ? 2.5 : 1.0,
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
              ])[pen.type.index],
              color: pen.color,
              size: 20,
              shadows: pen == statusManager.usingPen ? [
                BoxShadow(
                  color: pen.color,
                  blurRadius: 15,
                  blurStyle: BlurStyle.outer
                )
              ] : null,
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
