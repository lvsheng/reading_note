import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:app_links/app_links.dart';
import 'package:reading_note/custom_painter/page_items_painter.dart';
import 'package:reading_note/file_system_proxy.dart';
import 'package:reading_note/deep_link.dart';
import 'package:reading_note/status_manager/status_manager.dart';
import 'package:reading_note/note_page/note_page.dart';
import 'package:reading_note/util/log.dart';
import 'package:reading_note/widgets/stylus_gesture_detector.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tuple/tuple.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'custom_painter/coordinate_converter.dart';
import 'util/debug.dart' as debug;
import 'note_page/independent_note_page.dart';
import 'note_page/mark_note_page.dart';
import 'widgets/control_panel_builder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoApp(title: 'Reading Note', theme: CupertinoThemeData(), home: MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  static final int _maxInt = double.maxFinite.round();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Directory? _rootDirectory;

  File? _reading;
  int _initialPageNumber = 1;
  int _initialNotePageNumber = 1;
  int _pageNumber = 1;
  Map<int, Tuple2<MarkNotePage?, bool /*begin load*/ >>? _pageMarkNoteMap; // todo: 考虑清理不在用的文件？ todo: dispose on clean?
  Map<int, Tuple2<IndependentNotePage?, bool /*begin load*/ >>? _pageIndependentNoteMap; // todo: map移走？
  PdfDocument? _document;
  PdfViewerController? _controller;
  Matrix4? _transformation;

  String? _errorTip;
  bool _debugShowIndicator = false;
  late Timer _timerSaveFile;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _initDeepLinks();
    _fetchData();
    _timerSaveFile = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      _saveIfNeeded();
    });
    statusManager.addListener(_statusListener);
  }

  _saveIfNeeded() {
    for (final group in [_pageMarkNoteMap?.values, _pageIndependentNoteMap?.values]) {
      if (group == null) continue;
      for (final tuple in group) {
        final note = tuple.item1;
        if (note == null) return;
        note.saveIfNeeded();
      }
    }
  }

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

  open(File file) {
    _saveIfNeeded();
    userPreferences.setReadingBook(file);
    setState(() {
      _reading = file;
      _initialPageNumber = userPreferences.bookPageOf(_reading!) ?? 1;
      _pageNumber = _initialPageNumber;
      _initialNotePageNumber = userPreferences.notePageOf(_reading!) ?? 1;
      _pageMarkNoteMap = {};
      _pageIndependentNoteMap = {};
      _document = null;
      _controller = PdfViewerController()
        ..addListener(() {
          setState(() {
            if (!mounted) return;
            _transformation = _controller!.value;
          });
        });
      _transformation = null;
    });

    debug.setCurrentPdf(file);
    statusManager.reading = file; // fixme
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: Stack(
        children: [
          if (_reading != null)
            // todo: 缩放
            // todo: 可简单选笔（可加笔：颜色、粗细）
            Positioned.fill(
                child: PdfViewer.file(
              _reading!.path,
              key: Key(_reading!.path),
              controller: _controller,
              initialPageNumber: _initialPageNumber,
              params: PdfViewerParams(
                  pageDropShadow: null,
                  onDocumentChanged: (document) {
                    if (!mounted) return;
                    setState(() => _document = document);
                  },
                  onPageChanged: (int? pageNumber) {
                    if (!mounted || pageNumber == null) return;
                    setState(() => _pageNumber = pageNumber);
                    userPreferences.setBookPage(_reading!, pageNumber);
                  },
                  pagePaintCallbacks: _debugShowIndicator ? [paintPageIndicator] : const [],

                  // page mark note
                  pageOverlaysBuilder: (context, pageRect, page) {
                    final noteTuple = _pageMarkNoteMap![page.pageNumber];

                    // note not ready
                    if (noteTuple?.item1 == null) {
                      // if not loading, load it first
                      if (noteTuple == null) {
                        NotePage.open(NoteType.book, _reading!, _document!, page.pageNumber, page.size).then((note) {
                          if (!mounted) return;
                          setState(() => _pageMarkNoteMap![page.pageNumber] = Tuple2(note as MarkNotePage, true));
                        });
                      }

                      return const [];
                    }

                    final note = noteTuple!.item1!;

                    return [
                      ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          child: IgnorePointer(
                              child: RepaintBoundary(
                            child: CustomPaint(
                              painter: PageItemsPainter(note, BookCoordConverter(pageRect, note)),
                              isComplex: true, // fixme
                            ),
                          ))),
                      GestureDetector(onDoubleTap: () => setState(() => _debugShowIndicator = !_debugShowIndicator)),
                      PencilGestureDetector(
                        onDown: (details) {
                          note.penDown(note.canvasPositionToPagePosition(details.localPosition, pageRect));
                        },
                        onMove: (localPosition) {
                          note.penMove(note.canvasPositionToPagePosition(localPosition, pageRect));
                        },
                        onUp: (details) {
                          note.penMove(note.canvasPositionToPagePosition(details.localPosition, pageRect));
                          note.penUp();
                        },
                        onCancel: (detail) {
                          note.penUp();
                        },
                      ),
                    ];
                  }),
            )),
          if (_reading != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: statusManager.interacting != NoteType.note,
                child: Opacity(
                  opacity: statusManager.interacting == NoteType.note ? 0.85 : 0,
                  // fixme: 是否能既用visibility代替，又完全保留状态如滚动位置等
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: CupertinoColors.white),
                    child: ScrollablePositionedList.builder(
                      itemCount: _maxInt,
                      initialScrollIndex: _initialNotePageNumber,
                      itemBuilder: (BuildContext context, int index) {
                        const margin = Size(10.0, 20.0);
                        final size = MediaQuery.of(context).size;
                        final noteTuple = _pageIndependentNoteMap![index];

                        // note not ready
                        if (noteTuple?.item1 == null) {
                          // if not loading, load it first
                          if (noteTuple == null && _document != null) {
                            NotePage.open(
                                    NoteType.note,
                                    _reading!,
                                    _document!,
                                    index,
                                    Size(
                                        size.width - margin.width * 2, max(_document!.pages.firstOrNull?.height ?? 0, size.width / 9 * 16)))
                                .then((note) {
                              if (!mounted) return;
                              setState(() => _pageIndependentNoteMap![index] = Tuple2(note as IndependentNotePage, true));
                            });
                          }

                          return SizedBox(width: size.width, height: size.height, child: const Center(child: Text("loading")));
                        }

                        final note = noteTuple!.item1!;

                        return VisibilityDetector(
                          key: Key(index.toString()),
                          onVisibilityChanged: (info) {
                            if (info.visibleFraction > 0) {
                              assert(_reading != null);
                              userPreferences.setNotePage(_reading!, index);
                            }
                          },
                          child: Container(
                            height: note.size.height,
                            margin: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top, left: margin.width, right: margin.width),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              color: CupertinoColors.white,
                              boxShadow: [
                                BoxShadow(color: CupertinoColors.inactiveGray, spreadRadius: 3, blurRadius: 3),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Text("第 ${index + 1} 页"),
                                ConstrainedBox(
                                    constraints: const BoxConstraints.expand(),
                                    child: IgnorePointer(
                                        child: RepaintBoundary(
                                      child: CustomPaint(
                                        painter: PageItemsPainter(note, NoteCoordConverter(note)),
                                        isComplex: true, // fixme
                                      ),
                                    ))),
                                GestureDetector(onDoubleTap: () => setState(() => _debugShowIndicator = !_debugShowIndicator)),
                                PencilGestureDetector(
                                  onDown: (details) {
                                    note.penDown(note.canvasPositionToPage(details.localPosition, 1.0));
                                  },
                                  onMove: (localPosition) {
                                    note.penMove(note.canvasPositionToPage(localPosition, 1.0));
                                  },
                                  onUp: (details) {
                                    note.penMove(note.canvasPositionToPage(details.localPosition, 1.0));
                                    note.penUp();
                                  },
                                  onCancel: (detail) {
                                    note.penUp();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (statusManager.ready) ControlPanelBuilder.build(context),
          if (_errorTip != null)
            Center(child: Text(_errorTip!, style: const TextStyle(color: CupertinoColors.destructiveRed, fontSize: 20))),
          if (_debugShowIndicator)
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Text(
                  'root: $_rootDirectory\n'
                  'reading: $_reading\n'
                  'pdf               : ${_document?.sourceName}\n'
                  'pages: ${_document?.pages.length}\n'
                  'curPage: $_pageNumber\n'
                  'curPageSize: ${_document?.pages[_pageNumber - 1].size}\n'
                  'controller:\n$_transformation\n',
                  style: const TextStyle(color: CupertinoColors.black),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void paintPageIndicator(ui.Canvas canvas, Rect pageRect, PdfPage page) {
    logDebug("${page.pageNumber}: $pageRect, $page, $canvas");

    final paint = Paint()..strokeWidth = 3;

    // 当前页
    paint.color = CupertinoColors.systemRed;
    canvas.drawLine(Offset(pageRect.left, pageRect.top), Offset(pageRect.right, pageRect.bottom), paint);
    // 后续页
    paint.color = CupertinoColors.systemGreen;
    canvas.drawLine(const Offset(0, 0), Offset(pageRect.right, pageRect.bottom), paint);
    // 前续页
    paint.color = CupertinoColors.systemBlue;
    final screenSize = MediaQuery.of(context).size;
    canvas.drawLine(Offset(pageRect.right, pageRect.top),
        Offset(-(screenSize.width - pageRect.width) / 2, pageRect.top + screenSize.height * 2), paint);
    // 借此可以看出PdfViewer的lazy渲染策略
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logDebug("didChangeAppLifecycleState: $state");
    if (state == AppLifecycleState.inactive) {
      _saveIfNeeded();
    }
  }
}
