import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';
class ViewerScreen extends StatefulWidget {
  const ViewerScreen({
    super.key,
    required this.myUrl,
    required this.type,
    required this.title,
    // required this.share,
  });

  final String myUrl;
  final String type;
  final String title;
  // final bool share;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  bool isLoading = true;



  @override
  Widget build(BuildContext context) {
    print(widget.myUrl);
  return Scaffold(
    appBar: PreferredSize(
      preferredSize:
      Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: const BoxDecoration(
          gradient:
          LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 10.0, top: 10.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                   Text(
                    widget.title,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    ),
      body:
      Stack(
        children: [
          WebView(
              initialUrl: widget.type=='DOCUMENT'?'https://docs.google.com/viewer?url=${widget.myUrl}':widget.myUrl,
              javascriptMode: JavascriptMode.unrestricted,
              zoomEnabled: true,
              onPageFinished: (finish) {
                isLoading = false;
                setState(() {});
              }),
          isLoading == true
              ? Center(
            child: Lottie.asset('assets/main/loading.json', fit: BoxFit.fill),
          )
              : const SizedBox()
        ],
      ),
    );
  }
}

