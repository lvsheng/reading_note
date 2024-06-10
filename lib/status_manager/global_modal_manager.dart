import 'package:flutter/cupertino.dart';

final globalModalManager = GlobalModalManager();

typedef ModalCreator = Widget? Function();

class GlobalModalManager extends ChangeNotifier {
  final List<ModalCreator> _list = [];

  void update(ModalCreator item) {
    remove(item);
    _list.add(item);
    notifyListeners();
  }

  void remove(ModalCreator item) {
    _list.remove(item);
    notifyListeners();
  }

  bool get isNotEmpty => _list.isNotEmpty;

  Widget build() {
    return IgnorePointer(
      child: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: Stack(
              children: _list.map((creator) => Positioned.fill(child: Center(child: creator()))).toList(growable: false))),
    );
  }
}
