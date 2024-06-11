import 'package:reading_note/pen/selector_pen/indexable_area.dart';

import '../../protobuf/note.pb.dart' as pb;

class Selected {
  final List<Object/*pb.NotePageItem or IndexableArea*/> _list = [];

  void addAll(Iterable<Object> iterable) => _list.addAll(iterable);

  Iterable<pb.NotePageItem> iterateAllItems() sync* {
    for (final each in _list) {
      if (each is pb.NotePageItem) {
        yield each;
      } else {
        assert(each is IndexableArea);
        yield* (each as IndexableArea).iterateAllItems();
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

  int get length => _list.length;
}
