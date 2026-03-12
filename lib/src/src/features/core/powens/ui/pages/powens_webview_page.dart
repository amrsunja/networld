// powens_webview_screen.dart
import 'package:flutter/material.dart' hide debugPrint;
import 'package:networld/src/src/core/utils/debug_print.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PowensWebviewScreen extends StatefulWidget {
  final String url;
  final Function(String code) onSuccess;
  
  const PowensWebviewScreen({
    required this.url,
    required this.onSuccess,
    super.key,
  });

  @override
  State<PowensWebviewScreen> createState() => _PowensWebviewScreenState();
}

class _PowensWebviewScreenState extends State<PowensWebviewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          debugPrint('NAVIGATION: ${request.url}');
          if (request.url.startsWith('networld://powens-callback')) {
            final uri = Uri.parse(request.url);
            final connectionId = uri.queryParameters['connection_id'];
            if (connectionId != null) {
              Navigator.pop(context);
              widget.onSuccess(connectionId); // передаём connection_id
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (url) => debugPrint('PAGE STARTED: $url'), // ← и это
        onPageFinished: (url) => debugPrint('PAGE FINISHED: $url'), // ← и это
      ))
      ..loadRequest(Uri.parse(widget.url));
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connecter ma banque')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
