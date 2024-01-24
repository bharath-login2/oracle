import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;
  const WebViewPage(this.title, this.url, {super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  bool isLoading=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor:Colors.white,
        title: Text(widget.title,style:const TextStyle(color: Colors.black),),
      ),
      body:  Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,

          ),
          isLoading==true ?  Center(
            child: Lottie.asset('assets/main/loading.json',
                fit: BoxFit.fill),
          )
              : const Stack(),
        ],
      ),
    );


  }
}


