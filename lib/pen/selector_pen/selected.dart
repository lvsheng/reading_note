import 'package:reading_note/pen/selector_pen/indexable_area.dart';

import '../../protobuf/note.pb.dart' as pb;

class Selected {
  final List<Object /*pb.NotePageItem or IndexableArea*/ > _list = [];

  void addAll(Iterable<Object> iterable) => _list.addAll(iterable);

  void addAnother(Selected another) {
    _list.addAll(another._list);
  }

  static int _iterateId =
      0; // As the selection area expands, a child IndexableArea might be selected before its parent. To avoid yielding duplicates within a single iteration, use iterateId.
  Iterable<pb.NotePageItem> iterateAllItems() sync* {
    ++_iterateId;
    for (final each in _list) {
      if (each is pb.NotePageItem) {
        assert(each.iterateId <= _iterateId);
        each.iterateId = _iterateId;
        yield each;
      } else {
        assert(each is IndexableArea);
        yield* (each as IndexableArea).iterateAllItems(_iterateId);
      }
    }
  }

  void clear() {
    for (final each in _list) {
      if (each is pb.NotePageItem) {
        assert(each.selected);
        each.selected = false;
      } else {
        assert(each is IndexableArea && each.allSelected);
        (each as IndexableArea).allSelected = false;
      }
    }
    _list.clear();
  }

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  int get length => _list.length;
}
