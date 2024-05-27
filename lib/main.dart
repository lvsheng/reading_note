import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:reading_note/custom_painter.dart';
import 'package:reading_note/document_proxy.dart';
import 'package:reading_note/deep_link.dart';
import 'package:reading_note/note_page.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/stylus_gesture_detector.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:tuple/tuple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reading Note',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  Directory? _rootDirectory;

  File? _reading;
  int _initialPageNumber = 1;
  int _pageNumber = 1;
  Map<int, Tuple2<BookMarkNotePage?, bool /*begin load*/ >>? _pageMarkNoteMap; // todo: 考虑清理不在用的文件？
  PdfDocument? _document;
  PdfViewerController? _controller;
  Matrix4? _transformation;

  String? _errorTip;
  bool _debugShowIndicator = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
    fetchData();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      saveIfNeeded();
    });
  }

  saveIfNeeded() {
    if (_pageMarkNoteMap == null) return;
    logDebug("begin saveIfNeeded: ${_pageMarkNoteMap!.values.length}");
    for (final tuple in _pageMarkNoteMap!.values) {
      final note = tuple.item1;
      if (note == null) return;
      note.saveIfNeeded();
    }
    logDebug("end saveIfNeeded");
  }

  void fetchData() async {
    final rootDirectory = await documentProxy.rootDirectoryReady;
    setState(() {
      _rootDirectory = rootDirectory;
    });

    {
      var file = await userPreferences.lastOpenedFile;
      file ??= await documentProxy.firstFile;
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
    _linkSubscription?.cancel();
    _timer.cancel();
    saveIfNeeded();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      logInfo("receive importing file");

      open(await importFile(uri));

      logInfo("imported done");
    });
  }

  open(File file) {
    userPreferences.setLastOpenedFile(file);
    setState(() {
      _reading = file;
      _initialPageNumber = userPreferences.lastPageOf(_reading!) ?? 1;
      _pageNumber = _initialPageNumber;
      _pageMarkNoteMap = {};
      _document = null;
      _controller = PdfViewerController()..addListener(() {
        setState(() {
          if (!mounted) return;
          _transformation = _controller!.value;
        });
      });
      _transformation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Stack(
          children: [
            if (_reading != null)
              Positioned.fill(child: PdfViewer.file(
                _reading!.path,
                key: Key(_reading!.path),
                controller: _controller,
                initialPageNumber: _initialPageNumber,
                params: PdfViewerParams(
                    onDocumentChanged: (document) {
                      if (!mounted) return;
                      setState(() => _document = document);
                    },
                    onPageChanged: (int? pageNumber) {
                      if (!mounted || pageNumber == null) return;
                      setState(() => _pageNumber = pageNumber);
                      userPreferences.setLastPage(_reading!, pageNumber);
                    },
                    pagePaintCallbacks: _debugShowIndicator ? [paintPageIndicator] : const [],

                    // page mark note
                    pageOverlaysBuilder: (context, pageRect, page) {
                      var noteTuple = _pageMarkNoteMap![page.pageNumber];

                      // note not ready
                      if (noteTuple?.item1 == null) {
                        // if not loading, load it first
                        if (noteTuple == null) {
                          BookMarkNotePage.open(_reading!, page.pageNumber, page.size).then((note) {
                            if (!mounted) return;
                            setState(() => _pageMarkNoteMap![page.pageNumber] = Tuple2(note, true));
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
                                painter: PDFOverlayPainter(pageRect, page, note),
                                isComplex: true, // fixme
                              ),
                            ))),
                        GestureDetector(onDoubleTap: () => setState(() => _debugShowIndicator = !_debugShowIndicator)),
                        PencilGestureDetector(
                          onDown: (details) {
                            note.startDraw();
                            note.addPoint(BookMarkNotePage.canvasPositionToPagePosition(details.localPosition, pageRect, page.size));
                          },
                          onMove: (localPosition) {
                            note.addPoint(BookMarkNotePage.canvasPositionToPagePosition(localPosition, pageRect, page.size));
                          },
                          onUp: (details) {
                            note.addPoint(BookMarkNotePage.canvasPositionToPagePosition(details.localPosition, pageRect, page.size));
                            note.endDraw();
                          },
                          onCancel: (detail) {
                            note.endDraw();
                          },
                        ),
                      ];
                    }),
              )),
            if (_errorTip != null)
              Center(
                  child: Text(_errorTip!,
                      style: const TextStyle(color: Colors.red, fontSize: 20))),
            IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Text(
                  'root: $_rootDirectory\n'
                  'reading: $_reading\n'
                  'pdf               : ${_document?.sourceName}\n'
                  'pages: ${_document?.pages.length}\n'
                  'curPage: $_pageNumber\n'
                  'curPageSize: ${_document?.pages[_pageNumber].size}\n'
                  'controller:\n$_transformation\n',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void paintPageIndicator(ui.Canvas canvas, Rect pageRect, PdfPage page) {
    logDebug("${page.pageNumber}: $pageRect, $page, $canvas");

    final paint = Paint()..strokeWidth = 3;

    // 当前页
    paint.color = Colors.red;
    canvas.drawLine(Offset(pageRect.left, pageRect.top),
        Offset(pageRect.right, pageRect.bottom), paint);
    // 后续页
    paint.color = Colors.green;
    canvas.drawLine(
        const Offset(0, 0), Offset(pageRect.right, pageRect.bottom), paint);
    // 前续页
    paint.color = Colors.blue;
    final screenSize = MediaQuery.of(context).size;
    canvas.drawLine(
        Offset(pageRect.right, pageRect.top),
        Offset(-(screenSize.width - pageRect.width) / 2,
            pageRect.top + screenSize.height * 2),
        paint);
    // 借此可以看出PdfViewer的lazy渲染策略
  }
}
