import 'package:flutter/cupertino.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:flutter/material.dart' as material;
import '../note_page/note_book.dart';

class Menu extends StatefulWidget {
  final int pageNumber;
  final NoteType type;
  final VoidCallback dismiss;

  Menu({required this.pageNumber, required this.type, required this.dismiss}) : super(key: Key("$pageNumber"));

  @override
  State<StatefulWidget> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final controller = TextEditingController();
  late final NoteBook book;

  @override
  void initState() {
    book = NoteBook.getOrCreate(statusManager.reading!, widget.type);
    controller.value = TextEditingValue(text: book.getTitleOf(widget.pageNumber));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            SizedBox(width: 200,child: CupertinoTextField(controller: controller, onSubmitted: _confirmTitle)),
            GestureDetector(
              onTap: () => _confirmTitle(controller.value.text),
              child: const Icon(material.Icons.check),
            ),
          ],
        )
      ],
    );
  }

  void _confirmTitle(value) {
    statusManager.updateCurrentPageTitle(value);
    widget.dismiss();
  }

  Widget _buildMenuItem(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Text(text),
      ),
    );
  }
}
