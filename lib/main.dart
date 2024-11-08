import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:reading_note/custom_painter/page_items_painter.dart';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/deep_link.dart';
import 'package:reading_note/status_manager/global_modal_manager.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/util/log.dart';
import 'package:reading_note/widgets/note_page_widget.dart';
import 'package:reading_note/widgets/stylus_gesture_detector.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:pdfrx/pdfrx.dart';
import 'custom_painter/coordinate_converter.dart';
import 'custom_painter/select_pen_painter.dart';
import 'note_page/note_book.dart';
import 'pen/selector_pen/select_pen.dart';
import 'widgets/control_panel_builder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const CupertinoApp(title: 'Reading Note', theme: CupertinoThemeData(), home: MyHomePage(), debugShowCheckedModeBanner: false);
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Directory? _rootDirectory;

  File? _reading;
  int _initialPageNumber = 1;
  int _initialNotePageIndex = 1;
  int _pageNumber = 1;
  PdfDocument? _document;
  PdfViewerController? _controller;
  Matrix4? _transformation;
  PageController? _pageViewController;
  NoteBook? _noteBook;
  int _notePageCount = 1;

  String? _errorTip;
  late Timer _timerSaveFile;
  bool _enablePageViewPager = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    _fetchData();
    _timerSaveFile = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) return;
      _saveIfNeeded();
    });
    statusManager.addListener(_statusListener);
    globalModalManager.addListener(_statusListener);
  }

  _saveIfNeeded() => statusManager.saveIfNeeded();

  void _fetchData() async {
    final rootDirectory = await fileSystemProxy.rootDirectoryReady;
    setState(() {
      _rootDirectory = rootDirectory;
    });

    {
      var file = await userPreferences.readingBook;
      file ??= await fileSystemProxy.firstFile;
      if (file != null) {
        open(file);
      } else {
        logInfo("TODO: tip import/open");
        setState(() {
          _errorTip = "未发现可打开的文件，可从其他处打开文档后点击“共享”-“导入到阅读笔记”以导入文档";
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    _timerSaveFile.cancel();
    _saveIfNeeded();
    statusManager.removeListener(_statusListener);
    globalModalManager.removeListener(_statusListener);
    super.dispose();
  }

  void _statusListener() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      logInfo("receive importing file");

      open(await importFile(uri));

      logInfo("imported done");
    });
  }

  void open(File file) {
    _saveIfNeeded();
    userPreferences.setReadingBook(file);
    setState(() {
      _reading = file;
      statusManager.reading = file; // fixme
      _initialPageNumber = userPreferences.bookPageOf(_reading!) ?? 1;
      _pageNumber = _initialPageNumber;
      _initialNotePageIndex = statusManager.notePageIndex;
      _document = null;
      _controller = PdfViewerController()
        ..addListener(() {
          setState(() {
            if (!mounted) return;
            _transformation = _controller!.value;
          });
        });
      _transformation = null;
      _pageViewController = PageController(initialPage: _initialNotePageIndex);
      _noteBook = NoteBook.getOrCreate(_reading!, NoteType.note)
        ..ready.then((_) {
          if (!mounted) return;
          _updateNotePageCount();
        });
    });
  }

  void _updateNotePageCount() {
    setState(() {
      _notePageCount = (_noteBook?.maxPageIndex ?? -1) + 2; // keep one additional last empty page
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          if (_reading != null)
            Positioned.fill(
                child: PdfViewer.file(_reading!.path,
                    key: Key(_reading!.path),
                    controller: _controller,
                    initialPageNumber: _initialPageNumber,
                    params: PdfViewerParams(
                        pageDropShadow: null,
                        viewerOverlayBuilder: (context, size) => [
                              PdfViewerScrollThumb(
                                  controller: _controller!, orientation: ScrollbarOrientation.right, thumbSize: const Size(45, 30))
                            ],
                        onDocumentChanged: (document) {
                          if (!mounted) return;
                          setState(() => _document = document);
                        },
                        onPageChanged: (int? pageNumber) {
                          if (!mounted || pageNumber == null) return;
                          setState(() => _pageNumber = pageNumber);
                          statusManager.bookPageNumber = pageNumber;
                        },
                        pageOverlaysBuilder: (context, pageRect, page) {
                          final note = statusManager.getOrLoadMarkNotePage(
                              page.pageNumber, () => NotePage.open(NoteType.book, _reading!, page.pageNumber, page.size, page));
                          if (note == null) return const [];

                          final coordConverter = BookCoordConverter(pageRect, note);

                          return [
                            ConstrainedBox(
                                constraints: const BoxConstraints.expand(),
                                child: IgnorePointer(
                                    child: RepaintBoundary(child: CustomPaint(painter: PageItemsPainter(note, coordConverter))))),
                            if (statusManager.interacting == NoteType.book &&
                                statusManager.bookPageNumber == page.pageNumber &&
                                statusManager.usingPen is SelectPen)
                              ConstrainedBox(
                                  constraints: const BoxConstraints.expand(),
                                  child: IgnorePointer(
                                      child: RepaintBoundary(
                                          child: CustomPaint(
                                              painter: SelectPenPainter(statusManager.usingPen as SelectPen, coordConverter, note))))),
                            PencilGestureDetector(
                                onDown: (details) => note.penDown(note.canvasPositionToPagePosition(details.localPosition, pageRect)),
                                onMove: (localPosition) => note.penMove(note.canvasPositionToPagePosition(localPosition, pageRect)),
                                onUp: (details) {
                                  final position = note.canvasPositionToPagePosition(details.localPosition, pageRect);
                                  note.penMove(position);
                                  note.penUp(position);
                                },
                                onCancel: (details) => note.penUp(note.canvasPositionToPagePosition(details.localPosition, pageRect)))
                          ];
                        }))),
          if (_reading != null)
            Positioned.fill(
                child: IgnorePointer(
                    ignoring: statusManager.interacting != NoteType.note && !statusManager.screenshotMode,
                    child: Opacity(
                        opacity: statusManager.screenshotMode ? 1.0 : (statusManager.interacting == NoteType.note ? 0.85 : 0),
                        // fixme: 是否能既用visibility代替，又完全保留状态如滚动位置等
                        child: DecoratedBox(
                            decoration: const BoxDecoration(color: CupertinoColors.white),
                            child: Scrollbar(
                                controller: _pageViewController,
                                scrollbarOrientation: ScrollbarOrientation.top,
                                child: PageView.builder(
                                    key: Key(_reading!.path),
                                    controller: _pageViewController,
                                    physics: _enablePageViewPager ? null : const NeverScrollableScrollPhysics(),
                                    onPageChanged: (index) {
                                      statusManager.notePageIndex = index;
                                      _updateNotePageCount();
                                    },
                                    itemCount: _notePageCount,
                                    itemBuilder: (context, index) {
                                      return NotePageWidget(
                                        index: index,
                                        onZoomUpdate: (cannotShrinkAnymore) {
                                          if (cannotShrinkAnymore) {
                                            if (!_enablePageViewPager) setState(() => _enablePageViewPager = true);
                                          } else {
                                            if (_enablePageViewPager) setState(() => _enablePageViewPager = false);
                                          }
                                        },
                                        title: NoteBook.getOrCreate(_reading!, NoteType.note).getTitleOf(index),
                                      );
                                    })))))),
          if (statusManager.ready) const ControlPanelBuilder(),
          if (globalModalManager.isNotEmpty) globalModalManager.build(),
          if (_errorTip != null)
            Center(child: Text(_errorTip!, style: const TextStyle(color: CupertinoColors.destructiveRed, fontSize: 20))),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logDebug("didChangeAppLifecycleState: $state");
    if (state == AppLifecycleState.inactive) {
      _saveIfNeeded();
    }
  }
}
