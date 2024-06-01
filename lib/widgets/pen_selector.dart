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
  @override
  Widget build(BuildContext context) {
    // todo: 理想交互：
    //  1.只手指可交互，笔不行（以此保证对应位置笔都可以写。但其实如果不是透明，那也没意义。而且有些小icon用笔点会更合适些）
    //  2.touchstart时出现其他可选笔，移动手指选择
    //  其他方式：切换魔术笔🪄与普通笔在一个按钮，点击切换。横向滑动切换其他笔，向上滑动切换橡皮，向下滑动切换选择，长按时提示
    return GestureDetector(
      child: Container(
        decoration: c.borderDecoration,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Column(
          children:statusManager.interactingPenList.map(_buildPenItem).toList(growable: false),
        ),
      ),
    );
  }

  Widget _buildPenItem(Pen pen) {
    return GestureDetector(
      onTap: () {
        statusManager.usingPen = pen;
      },
      behavior: HitTestBehavior.opaque,
      child: Transform.scale(
        scale: pen == statusManager.usingPen ? 1.5 : 1.0,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                (const [
                  CupertinoIcons.pencil,
                  material.Icons.brush_rounded,
                  material.Icons.auto_fix_high_outlined,
                  // material.Icons.texture_rounded,
                  //CupertinoIcons.pencil_ellipsis_rectangle,
                ])[pen.type.index],
                color: pen.color,
                shadows: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.5),
                    blurRadius: 5,
                    offset: const Offset(1, 1),
                  )
                ],
              ),
            ),
            if (pen.type == PenType.ballPointPen)
              Transform.translate(
                  offset: const Offset(0, -5),
                  child: Center(
                      child: Container(
                          height: pen.lineWidth,
                          width: 15,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(pen.lineWidth)), color: pen.color)))),
          ],
        ),
      ),
    );
  }
}
