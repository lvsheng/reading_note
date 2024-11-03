import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:reading_note/custom_painter/select_pen_painter.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/pen/selector_pen/select_pen.dart';
import 'package:tuple/tuple.dart';
import 'package:vector_math/vector_math_64.dart';

import '../custom_painter/coordinate_converter.dart';
import '../custom_painter/matte_positioner_pen_painter.dart';
import '../custom_painter/page_items_painter.dart';
import '../note_page/independent_note_page.dart';
import '../pen/matte_positioner_pen.dart';
import '../status_manager/global_modal_manager.dart';
import '../status_manager/status_manager.dart';
import '../util/log.dart';
import 'selector_magnent.dart';
import 'stylus_gesture_detector.dart';

class NotePageWidget extends StatefulWidget {
  final int index;
  final File? reading;
  final void Function(bool)? onZoomUpdate;
  final String? title;
  final ModalCreator? modalCreator;

  const NotePageWidget({super.key, required this.index, this.reading, this.onZoomUpdate, this.title, this.modalCreator});

  @override
  State<StatefulWidget> createState() => _NotePageState();
}

class _NotePageState extends State<NotePageWidget> {
  final _controller = TransformationController();
  bool _firstBuild = true;
  bool _needRefreshMinimumScale = true;
  late double _minimumScale;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    super.dispose();
  }

  final _parentKey = GlobalKey();
  final _childKey = GlobalKey();

  void _onControllerChange() {
    if (widget.onZoomUpdate == null) return;
    if (_parentKey.currentContext == null) return;
    final scale = _controller.value.zoom;
    final parentSize = (_parentKey.currentContext!.findRenderObject() as RenderBox).size;
    final childSize = (_childKey.currentContext!.findRenderObject() as RenderBox).size;
    final scaledChildSize = childSize * scale;
    bool cannotShrinkAnymore = scaledChildSize.width <= parentSize.width || scaledChildSize.height <= parentSize.height;
    widget.onZoomUpdate!(cannotShrinkAnymore);
  }

  late double _oldScale;
  Tuple2<Offset, Offset>? _doubleTapOffset;

  @override
  Widget build(BuildContext context) {
    final margin = Size(3.0, MediaQuery.of(context).viewPadding.top);
    final contextSize = MediaQuery.of(context).size;
    final note = statusManager.getOrLoadIndependentNotePage(
        widget.index, Size(contextSize.width - margin.width * 2, contextSize.width / 210 * 297 /*A4 page*/));

    if (note == null) {
      return SizedBox(width: contextSize.width, height: contextSize.height, child: const Center(child: Text("loading")));
    }
    // IndexableArea.forPage(note); // fixme: remove, for test

    if (_needRefreshMinimumScale) {
      _minimumScale =
          max(contextSize.width / (note.size.width + margin.width * 2), contextSize.height / (note.size.height + margin.height * 2));
      _controller.value = Matrix4.copy(_controller.value)..scale(_minimumScale);
      _needRefreshMinimumScale = false;
    }
    if (_firstBuild) {
      _oldScale = _minimumScale * 2;
      _firstBuild = false;
    }

    final coordConverter = NoteCoordConverter(note);
    final interactingWithSelectPen = statusManager.interacting == NoteType.note && statusManager.usingPen is SelectPen;

    return InteractiveViewer(
      // fixme: should InteractiveViewer expose AnimationController to stop the scrolling animation when user touch?
      key: _parentKey,
      minScale: 0.1,
      maxScale: 10,
      constrained: false,
      interactionEndFrictionCoefficient: 0.0000135 * 10000,
      transformationController: _controller,
      child: GestureDetector(
        key: _childKey,
        supportedDevices: const {PointerDeviceKind.touch},
        // avoid pencil tap SelectorMagnent wait "is this double tap?"
        onDoubleTapDown: (detail) {
          _doubleTapOffset = Tuple2(detail.globalPosition, detail.localPosition);
          logDebug("onDoubleTapDown: $_doubleTapOffset");
        },
        onDoubleTap: () {
          const logging = false;
          final matrix = Matrix4.copy(_controller.value);
          assert(matrix[15] == 1.0);
          assert(matrix[0] == matrix[5] && matrix[5] == matrix[10]);

          final oldScale = matrix.zoom;
          late final double newScale;
          if (oldScale <= _minimumScale) {
            newScale = _oldScale;
          } else {
            _oldScale = oldScale;
            newScale = _minimumScale;
          }

          final globalPosition = _doubleTapOffset!.item1;
          final localPosition = _doubleTapOffset!.item2;
          var xTranslate = globalPosition.dx - localPosition.dx * newScale;
          var yTranslate = globalPosition.dy - localPosition.dy * newScale;
          if (logging) logDebug("onDoubleTap newScale: $newScale");
          if (logging) logDebug("onDoubleTap: $xTranslate, $yTranslate");
          xTranslate = min(0, xTranslate);
          yTranslate = min(0, yTranslate);
          if (logging) logDebug("onDoubleTap: $xTranslate, $yTranslate");
          xTranslate = max(-((note.size.width + margin.width * 2) * newScale - MediaQuery.of(context).size.width), xTranslate);
          yTranslate = max(-((note.size.height + margin.height * 2) * newScale - MediaQuery.of(context).size.height), yTranslate);
          if (logging) logDebug("onDoubleTap: $xTranslate, $yTranslate");

          matrix.setDiagonal(Vector4(newScale, newScale, newScale, 1.0));
          matrix.setEntry(0, 3, xTranslate);
          matrix.setEntry(1, 3, yTranslate);
          _controller.value = matrix;
        },
        child: Container(
          width: note.size.width,
          height: note.size.height,
          margin: EdgeInsets.symmetric(vertical: margin.height, horizontal: margin.width),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: CupertinoColors.white,
            boxShadow: [BoxShadow(color: CupertinoColors.inactiveGray, spreadRadius: 3, blurRadius: 3)],
          ),
          child: Stack(
            children: [
              Positioned(
                  right: 4,
                  top: 0,
                  child: Text(
                    "${widget.index + 1}",
                    style: const TextStyle(fontSize: 10, color: CupertinoColors.systemGrey),
                  )),
              if (widget.title != null && !statusManager.screenshotMode)
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Center(
                        child: Text("${widget.title}",
                            style: const TextStyle(fontSize: 24, color: CupertinoColors.black, fontWeight: FontWeight.bold)))),
              ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: IgnorePointer(child: RepaintBoundary(child: CustomPaint(painter: PageItemsPainter(note, coordConverter))))),
              if (statusManager.usingPen is MattePositionerPen)
                ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: IgnorePointer(
                        child: RepaintBoundary(
                            child: CustomPaint(
                                painter: MattePositionerPenPainter(
                                    statusManager.usingPen as MattePositionerPen, widget.index, coordConverter))))),
              if (interactingWithSelectPen)
                ConstrainedBox(
                    constraints: const BoxConstraints.expand(),
                    child: IgnorePointer(
                        child: RepaintBoundary(
                            child: CustomPaint(painter: SelectPenPainter(statusManager.usingPen as SelectPen, coordConverter, note))))),
              PencilGestureDetector(
                onDown: (details) => note.penDown(note.canvasPositionToPage(details.localPosition, 1.0)),
                onMove: (localPosition) => note.penMove(note.canvasPositionToPage(localPosition, 1.0)),
                onUp: (details) {
                  final position = note.canvasPositionToPage(details.localPosition, 1.0);
                  note.penMove(position);
                  note.penUp(position);
                },
                onCancel: (details) => note.penUp(note.canvasPositionToPage(details.localPosition, 1.0)),
              ),
              if (interactingWithSelectPen)
                ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: SelectorMagnet(pen: statusManager.usingPen as SelectPen),
                ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  supportedDevices: const {PointerDeviceKind.touch},
                  onLongPress: () => _expand(note, false),
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: 20,
                    // color: CupertinoColors.activeOrange,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  supportedDevices: const {PointerDeviceKind.touch},
                  onLongPress: () => _expand(note, true),
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    height: 20,
                    // color: CupertinoColors.activeOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _expand(IndependentNotePage capturedNote, bool isHeightNotWidth) {
    final oldValue = isHeightNotWidth ? capturedNote.data.height : capturedNote.data.width;
    final newValue = oldValue * 1.5;
    update(double value) {
      if (isHeightNotWidth) {
        capturedNote.data.height = value;
      } else {
        capturedNote.data.width = value;
      }
      if (mounted) {
        setState(() {
          _needRefreshMinimumScale = true;
        });
      }
    }

    statusManager.historyStack.doo(() => update(newValue), () => update(oldValue));
  }
}
