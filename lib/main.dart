import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
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
              )),
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
}
