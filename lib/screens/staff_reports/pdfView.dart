import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PdfViewPage extends StatelessWidget {
  final String url;
  const PdfViewPage(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    final String googleUrl = "https://docs.google.com/gview?embedded=true&url=$url";

    return Scaffold(
      appBar: AppBar(title: const Text("View PDF")),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(googleUrl)),
      ),
    );
  }
}
