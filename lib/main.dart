import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:reading_note/custom_painter.dart';
import 'package:reading_note/document_proxy.dart';
import 'package:reading_note/deep_link.dart';
import 'package:reading_note/drawing_data.dart';
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
  Map<int, Tuple2<DrawingData, GlobalKey>>? _drawingMap;
  PdfDocument? _document;
  PdfViewerController? _controller;
  Matrix4? _transformation;

  String? _errorTip;
  bool _debugShowIndicator = false;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
    fetchData();
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
      _drawingMap = {}; // todo: load from file, pre-load possible pages
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
                    pagePaintCallbacks: [if (_debugShowIndicator) paintPageIndicator],
                    pageOverlaysBuilder: (context, pageRect, page) {
                      Tuple2<DrawingData, GlobalKey>? drawing = _drawingMap![page.pageNumber];
                      if (drawing == null) {
                        _drawingMap![page.pageNumber] = drawing =
                            Tuple2(DrawingData(page.size), GlobalKey()); // todo: load async
                      }
                      final drawingData = drawing.item1;
                      triggerRepaint() => setState(() => (_drawingMap![page.pageNumber] = drawing = Tuple2(drawingData, GlobalKey())));

                      return [
                        if (drawing != null) ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: IgnorePointer(
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                      painter:
                                          PDFOverlayPainter(pageRect, page, drawingData, drawing!.item2),
                                      isComplex: drawingData.pathList.length > 5 ? true : false,
                                  ),
                                ))),
                        GestureDetector(
                            onDoubleTap: () => setState(() =>
                                _debugShowIndicator = !_debugShowIndicator)),
                        PencilGestureDetector(
                          onDown: (details) {
                            drawingData.startDraw();
                            triggerRepaint();
                          },
                          onMove: (details) {
                            drawingData.addPoint(DrawingData.canvasPositionToPagePosition(details.localPosition, pageRect, page.size));
                            triggerRepaint();
                          },
                          onUp: (details) {
                            drawingData.addPoint(DrawingData.canvasPositionToPagePosition(details.localPosition, pageRect, page.size));
                            drawingData.endDraw();
                            triggerRepaint();
                          },
                          onCancel: (detail) {
                            drawingData.endDraw();
                          },
                        ),
                      ];
                    }),
              )),
            if (_errorTip != null)
              Center(
                  child: Text(_errorTip!,
                      style: const TextStyle(color: Colors.red, fontSize: 20))),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 10),
              child: Text('root: $_rootDirectory\n'
                  'reading: $_reading\n'
                  'pdf               : ${_document?.sourceName}\n'
                  'pages: ${_document?.pages.length}\n'
                  'curPage: $_pageNumber\n'
                  'curPageSize: ${_document?.pages[_pageNumber].size}\n'
                  'controller:\n$_transformation\n'
                , style: const TextStyle(color: Colors.black),),
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
