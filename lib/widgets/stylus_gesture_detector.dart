import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:reading_note/util/log.dart';

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
typedef GesturePencilDrawMoveCallback = void Function(Offset localPosition);
typedef GesturePencilDrawUpCallback = void Function(PointerUpEvent details);
typedef GesturePencilDrawCancelCallback = void Function(PointerCancelEvent details);

/// 出现stylus事件时，eager accept事件，同时阻止后续的所有非stylus事件
class StylusGestureRecognizer extends OneSequenceGestureRecognizer {
  GesturePencilDrawDownCallback? onDown;
  GesturePencilDrawMoveCallback? onMove;
  GesturePencilDrawUpCallback? onUp;
  GesturePencilDrawCancelCallback? onCancel;
  int? trackingStylusPointer;
  Offset? lastReportedOffset;

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
      logDebug(
          "[StylusGesture] non-tracking pointer event, ignore: $event event.pointer:${event.pointer} trackingStylusPointer:$trackingStylusPointer");
      return;
    }
    if (event is PointerDownEvent && onDown != null) {
      onDown!(event);
      lastReportedOffset = event.localPosition;
    } else if (event is PointerMoveEvent && onMove != null) {
      assert(lastReportedOffset != null);
      final distanceFromLast = (event.localPosition - lastReportedOffset!).distance;
      if (distanceFromLast > 0.1) { // iPad Air 5上试验：典型为0.0
        onMove!(event.localPosition);
        lastReportedOffset = event.localPosition;
      } else {
        // logDebug("eat move event: $distanceFromLast $event");
      }
    } else if (event is PointerUpEvent && onUp != null) {
      onUp!(event);
      trackingStylusPointer = null;
      lastReportedOffset = null;
    } else if (event is PointerCancelEvent && onCancel != null) {
      onCancel!(event);
      trackingStylusPointer = null;
      lastReportedOffset = null;
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
