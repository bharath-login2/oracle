import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/common.dart';

class DocumentViewerScreen extends StatefulWidget {
   String? documentUrl;
   String? title;
   String? extension;
   String? fileSize;
   String? createdDate;
   String? createdBy;// The URL of the document to view

   DocumentViewerScreen({super.key, this.documentUrl, this.title, this.extension, this.fileSize, this.createdDate, this.createdBy});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  Future<void> downloadFile(String url, String fileName) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      if(mounted)
        {
          Common.showProgressDialog(
              context as BuildContext, "Downloading...");
        }
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get the app's document directory
        final filePath = '/storage/emulated/0/Download/$fileName';

        // Write the file
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        Common.toastMessaage(
            'Download Successfully', Colors.green);

          Navigator.pop(context as BuildContext);
       // print('File downloaded to: $filePath');
      } else {
        Common.toastMessaage(
            'Download Failed', Colors.red);
        Navigator.pop(context as BuildContext);

       // print('Failed to download file. Status code: ${response.statusCode}');
      }
    }
    else{
      //print('no permission');
    }

  }
  bool isLoading=true;
  @override
  Widget build(BuildContext context) {
    //print(widget.documentUrl);

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
                  left: 10.0, top: 10.0, bottom: 10.0, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              shape: BoxShape.circle),
                          child: const Icon(
                            Icons.arrow_back_ios_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                       SizedBox(
                         width: 150,
                         child: Text(
                          widget.title.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 18,overflow: TextOverflow.ellipsis),
                                               ),
                       ),
                    ],
                  ),
                   Row(
                     children: [
                       InkWell(
                        onTap: (){
                          showGeneralDialog(
                            barrierLabel: "showGeneralDialog",
                            barrierDismissible: true,
                            barrierColor: Colors.black.withOpacity(0.6),
                            transitionDuration: const Duration(milliseconds: 400),
                            context: context,
                            pageBuilder: (context, _, __) {
                              return StatefulBuilder(builder: (context, setState) {
                                return Align(
                                  alignment: Alignment.center,
                                  child: IntrinsicHeight(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      child: Container(
                                        width: double.maxFinite,
                                        clipBehavior: Clip.antiAlias,
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child:   Material(
                                          child: Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  icon: const Icon(Icons.close_rounded),
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                              const Text(
                                                'File Information',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              const SizedBox(height: 20),
                                              Padding(
                                               padding: const EdgeInsets.only(left: 20),
                                               child: Column(
                                                 mainAxisAlignment: MainAxisAlignment.start,
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                   Row(
                                                     children: [
                                                       const SizedBox(
                                                           width:100,
                                                           child: Text('File Name :')),
                                                       const SizedBox(width: 10,),
                                                       SizedBox(
                                                           width:170,
                                                           child: Text(widget.title!,style: const TextStyle(overflow: TextOverflow.ellipsis,),)),
                                                     ],
                                                   ),
                                                   const SizedBox(height: 10,),
                                                   Row(
                                                     children: [
                                                       const SizedBox(
                                                           width:100,
                                                           child: Text('File Size :')),
                                                       const SizedBox(width: 10,),
                                                       SizedBox(
                                                           width:170,
                                                           child: Text(widget.fileSize!,style: const TextStyle(overflow: TextOverflow.ellipsis,),)),
                                                     ],
                                                   ),
                                                   const SizedBox(height: 10,),
                                                   Row(
                                                     children: [
                                                       const SizedBox(
                                                           width:100,
                                                           child: Text('Created Date :')),
                                                       const SizedBox(width: 10,),
                                                       SizedBox(
                                                           width:170,
                                                           child: Text(widget.createdDate!,style: const TextStyle(overflow: TextOverflow.ellipsis,),)),
                                                     ],
                                                   ),
                                                   const SizedBox(height: 10,),
                                                   Row(
                                                     children: [
                                                       const SizedBox(
                                                           width:100,
                                                           child: Text('Created By :')),
                                                       const SizedBox(width: 10,),
                                                       SizedBox(
                                                           width:170,
                                                           child: Text(widget.createdBy!,style: const TextStyle(overflow: TextOverflow.ellipsis,),)),
                                                     ],
                                                   ),
                                                 ],
                                               ),
                                             )


                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                            },
                            transitionBuilder: (_, animation1, __, child) {
                              return SlideTransition(
                                position: Tween(
                                  begin: const Offset(0, 1),
                                  end: const Offset(0, 0),
                                ).animate(animation1),
                                child: child,
                              );
                            },
                          );
                        },
                          child: const Icon(Icons.info_outline,color: Colors.white,)),
                       const SizedBox(width: 12,),
                       InkWell(
                           onTap: (){
                             downloadFile(widget.documentUrl.toString(),widget.title.toString());
                             },
                           child: const Icon(Icons.download,color: Colors.white,)),
                       const SizedBox(width: 12,),
                       InkWell(
                           onTap: (){
                             _fileFromImageUrl();
                           },
                           child: const Icon(Icons.share,color: Colors.white,)),
                     ],
                   )
                ],
              ),
            ),
          ),
        ),
      body:  Stack(
        children: [
          WebView(
            initialUrl: widget.extension=='pdf' || widget.extension=='doc' || widget.extension=='docx'||widget.extension=='ppt'||
                widget.extension=='pptx'||widget.extension=='pptm'||widget.extension=='csv'||widget.extension=='xls'||widget.extension=='xlsx'?
            'https://docs.google.com/viewer?url=${widget.documentUrl}':widget.documentUrl,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              isLoading=false;
              setState(() {
              });
              },
            // Enable JavaScript if needed
          ),
          isLoading==true ? Center(
            child: Lottie.asset('assets/main/loading.json',
                fit: BoxFit.fill),
          )
              : const Stack(),

        ],
      )

    );
  }

  Future _fileFromImageUrl() async {
    final response = await http.get(Uri.parse(widget.documentUrl!));
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path,widget.title.toString()));
    file.writeAsBytesSync(response.bodyBytes);
    await Share.shareFiles(
      [file.path],
    );
  }
}