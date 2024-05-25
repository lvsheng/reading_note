import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:reading_note/custom_painter.dart';
import 'package:reading_note/document_proxy.dart';
import 'package:reading_note/deep_link.dart';
import 'package:reading_note/log.dart';
import 'package:reading_note/user_preferences.dart';
import 'package:pdfrx/pdfrx.dart';

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
  String? _errorTip;
  bool _debugShowIndicator = true;

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
      // todo: page jump / global state change
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
                params: PdfViewerParams(
                    pagePaintCallbacks: [
                      if (_debugShowIndicator) paintPageIndicator,
                    ],
                    pageOverlaysBuilder: (context, pageRect, page) {
                      return [
                        ConstrainedBox(
                            constraints: const BoxConstraints.expand(),
                            child: IgnorePointer(
                                child: CustomPaint(
                                    painter:
                                        PDFOverlayPainter(pageRect, page)))),
                        GestureDetector(
                            onDoubleTap: () => setState(() =>
                                _debugShowIndicator = !_debugShowIndicator)),
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
                  'reading: $_reading\n', style: TextStyle(color: Colors.blue.shade50),),
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
