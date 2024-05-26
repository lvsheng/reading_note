import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reading_note/log.dart';

class PencilGestureDetector extends StatelessWidget {
  final Widget? child;
  final GesturePencilDrawDownCallback? onDown;
  final GesturePencilDrawMoveCallback? onMove;
  final GesturePencilDrawUpCallback? onUp;
  final GesturePencilDrawCancelCallback? onCancel;

  const PencilGestureDetector({super.key, this.child, this.onDown, this.onMove, this.onUp, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures = <Type, GestureRecognizerFactory>{};
    final DeviceGestureSettings? gestureSettings = MediaQuery.maybeGestureSettingsOf(context);

    gestures[StylusGestureRecognizer] = GestureRecognizerFactoryWithHandlers<StylusGestureRecognizer>(
          () => StylusGestureRecognizer(),
          (StylusGestureRecognizer instance) {
        instance
          ..onDown = onDown
          ..onMove = onMove
          ..onUp = onUp
          ..onCancel = onCancel
          ..gestureSettings = gestureSettings;
      },
    );

    return RawGestureDetector(
      gestures: gestures,
      behavior: HitTestBehavior.translucent,
      excludeFromSemantics: true,
      child: child,
    );
  }
}

typedef GesturePencilDrawDownCallback = void Function(PointerDownEvent details);
typedef GesturePencilDrawMoveCallback = void Function(PointerMoveEvent details);
typedef GesturePencilDrawUpCallback = void Function(PointerUpEvent details);
typedef GesturePencilDrawCancelCallback = void Function(PointerCancelEvent details);

/// 出现stylus事件时，eager accept事件，同时阻止后续的所有非stylus事件
class StylusGestureRecognizer extends OneSequenceGestureRecognizer {
  GesturePencilDrawDownCallback? onDown;
  GesturePencilDrawMoveCallback? onMove;
  GesturePencilDrawUpCallback? onUp;
  GesturePencilDrawCancelCallback? onCancel;
  int? trackingStylusPointer;

  @override
  String get debugDescription => "PencilDrawGestureRecognizer";

  StylusGestureRecognizer(): super();

  @override
  void didStopTrackingLastPointer(int pointer) {
    logDebug("[StylusGesture] didStopTrackingLastPointer $pointer");
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event.pointer != trackingStylusPointer) {
      logDebug("[StylusGesture] non-tracking pointer event, ignore: $event");
      return;
    }
    if (event is PointerDownEvent && onDown != null) {
      onDown!(event);
    } else if (event is PointerMoveEvent && onMove != null) {
      onMove!(event);
    } else if (event is PointerUpEvent && onUp != null) {
      onUp!(event);
      trackingStylusPointer = null;
    } else if (event is PointerCancelEvent && onCancel != null) {
      onCancel!(event);
      trackingStylusPointer = null;
    }
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    if (event.kind == PointerDeviceKind.stylus) {
      assert(trackingStylusPointer == null, '[StylusGesture] TODO: Support multi-stylus');
      trackingStylusPointer = event.pointer;
      resolve(GestureDisposition.accepted);
    } else if (trackingStylusPointer != null) {
      logDebug("[StylusGesture] Eat other pointer event when tracking stylus pointer");
      resolve(GestureDisposition.accepted);
    }
  }
}
