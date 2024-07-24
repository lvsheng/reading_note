import 'package:flutter/cupertino.dart';
import '../pen/selector_pen/select_pen.dart';

class SelectorMagnet extends StatefulWidget {
  final SelectPen pen;

  const SelectorMagnet({super.key, required this.pen});

  @override
  State<StatefulWidget> createState() => _SelectorMagnetState();
}

class _SelectorMagnetState extends State<SelectorMagnet> {
  @override
  void initState() {
    super.initState();
    widget.pen.addListener(_update);
  }

  @override
  void didUpdateWidget(SelectorMagnet oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pen != widget.pen) {
      oldWidget.pen.removeListener(_update);
      widget.pen.addListener(_update);
    }
  }


  @override
  void dispose() {
    widget.pen.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final points = <Widget>[];

    if (!widget.pen.moving) {
      if (widget.pen.selected.isNotEmpty) {
        final box = widget.pen.selectedBoundingBox!;
        for (final magnetPos in MagnetPosition.values) {
          points.add(_createMagnetControlPoint(box, magnetPos, (pos) {
            if (widget.pen.magnet != null) {
              widget.pen.magnetToSelected(pos);
            } else {
              widget.pen.magnetFromSelected(pos);
            }
          }));
        }
      }

      if (widget.pen.magnet != null) {
        final (pos, selected, rect) = widget.pen.magnet!;
        points.add(_createMagnetControlPoint(rect, pos, null));
      }
    }

    return Stack(
      children: points,
    );
  }

  Widget _createMagnetControlPoint(Rect boundingBox, MagnetPosition magnetPos, void Function(MagnetPosition pos)? onTap) {
    const size = 10.0;
    const margin = 0.0;
    const offset = -(size / 2 + margin);

    late final Offset pos;
    switch (magnetPos) {
      case MagnetPosition.topLeft:
        pos = boundingBox.topLeft;
        break;
      case MagnetPosition.topCenter:
        pos = boundingBox.topCenter;
        break;
      case MagnetPosition.topRight:
        pos = boundingBox.topRight;
        break;
      case MagnetPosition.centerLeft:
        pos = boundingBox.centerLeft;
        break;
      case MagnetPosition.centerRight:
        pos = boundingBox.centerRight;
        break;
      case MagnetPosition.bottomLeft:
        pos = boundingBox.bottomLeft;
        break;
      case MagnetPosition.bottomCenter:
        pos = boundingBox.bottomCenter;
        break;
      case MagnetPosition.bottomRight:
        pos = boundingBox.bottomRight;
        break;
    }

    Widget child = Container(
      width: size,
      height: size,
      margin: const EdgeInsets.all(margin),
      decoration: BoxDecoration(
          color: onTap == null ? CupertinoColors.black.withOpacity(0.8) : CupertinoColors.systemGreen.withOpacity(0.5), borderRadius: const BorderRadius.all(Radius.circular(size / 2))),
    );
    if (onTap != null) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(magnetPos),
        child: child,
      );
    }
    return Positioned(
        left: pos.dx + offset,
        top: pos.dy + offset,
        child: child);
  }
}
