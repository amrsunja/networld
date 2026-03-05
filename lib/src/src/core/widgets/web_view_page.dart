import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../design_system/app_ui.dart';

class WebViewPage extends HookConsumerWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);

    return Scaffold(
			backgroundColor: UIColorsToken.white,
      body: Stack(
        alignment: .center,
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(url),
            ),
            initialSettings: InAppWebViewSettings(
              underPageBackgroundColor: Colors.white,
              sharedCookiesEnabled: true,
              domStorageEnabled: true,
              javaScriptEnabled: true,
              cacheEnabled: true,
              useHybridComposition: true,
              disableContextMenu: true,
              supportZoom: false,
              verticalScrollBarEnabled: false 
            ),
            onWebViewCreated: (controller) {
            },
            onLoadStart: (controller, url) {
            },
            onLoadStop: (controller, url) async {
              isLoading.value = false;
            },
          ),

          if (isLoading.value)
            UICircularProgressBar().animate().fade()
        ],
      ),
    );
  }
}
