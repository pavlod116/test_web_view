import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

enum MenuOptions {
  clearCache,
  clearCookies,
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

late WebViewController _webViewController;

class _MyHomePageState extends State<MyHomePage> {
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          _webViewController.goBack();
        } else {
          debugPrint('Нет записи в истории');
        }
        return null!;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(
            'WebView',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                if (await _webViewController.canGoBack()) {
                  _webViewController.goBack();
                } else {
                  debugPrint('Нет записи в истории');
                }
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            IconButton(
              onPressed: () async {
                if (await _webViewController.canGoForward()) {
                  _webViewController.goForward();
                } else {
                  debugPrint('Нет записи в истории');
                }
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
            IconButton(
              onPressed: () => _webViewController.reload(),
              icon: const Icon(Icons.replay),
            ),
            PopupMenuButton<MenuOptions>(
              onSelected: (value) {
                switch (value) {
                  case MenuOptions.clearCache:
                    _onClearCache(_webViewController, context);
                    break;
                  case MenuOptions.clearCookies:
                    _onClearCookies(context);
                }
              },
              itemBuilder: (context) => <PopupMenuItem<MenuOptions>>[
                const PopupMenuItem(
                  value: MenuOptions.clearCache,
                  child: Text('Удалить кеш'),
                ),
                const PopupMenuItem(
                  value: MenuOptions.clearCache,
                  child: Text('Удалить Cookeis'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              color: Colors.pink,
              backgroundColor: Colors.black,
            ),
            Expanded(
              child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl: 'https://churchonline.com.ua/',
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onProgress: (progress) {
                  this.progress = progress / 100;
                  setState(() {});
                },
                onPageStarted: (url) {
                  debugPrint('Новый сайт: $url');
                },
                onPageFinished: (url) {
                  debugPrint('Сайт полеостью загружен: $url');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onClearCache(
      WebViewController webViewController, BuildContext context) async {
    webViewController.clearCache();
    String message = 'Кеш удален';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onClearCookies(BuildContext context) async {
    final bool hadCookies = await CookieManager().clearCookies();
    String message = 'Cookies удалены';
    if (!hadCookies) {
      message = 'Cookies все были очищены';
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
