import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/common.dart';
import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../service/service.dart';
import 'colorConst.dart';

class FileSendingScreen extends StatefulWidget {
  String? documentUrl;
  String? title;
  String? extension;
  String? groupId;// The URL of the document to view

  FileSendingScreen({super.key, this.documentUrl, this.title, this.extension,this.groupId});

  @override
  State<FileSendingScreen> createState() => _FileSendingScreenState();
}

class _FileSendingScreenState extends State<FileSendingScreen> {

  bool isLoading=true;
  TextEditingController messageController = TextEditingController();

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

                ],
              ),
            ),
          ),
        ),
        body:  Stack(
          children: [
            Stack(
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(1, 1),
                                    )
                                  ],
                                  // color: Colors.white,
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextFormField(
                                onChanged: (value) {
                                 // isTyped = true;
                                  setState(() {});
                                },
                                style: const TextStyle(
                                  color: ColorConstant.black,
                                ),
                                controller: messageController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(12),
                                  hintStyle:
                                  const TextStyle(color: Colors.grey),
                                  hintText: 'Message',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide
                                        .none, // Set the border color to none
                                  ),
                            
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: ColorConstant.barGreen,
                            child: IconButton(
                                color:
                                const Color.fromARGB(255, 255, 255, 255),
                                onPressed: () async {

                                  Common.showProgressDialog(
                                      context, "Loading..");
                                  SendMesaageModel object = await HttpService.sendMessageFile(widget.groupId,messageController.text,widget.documentUrl);
                                  if (object.status == true) {
                                    Navigator.of(context).pop();
                                    Common.toastMessaage(
                                        object.message, Colors.green);
                                    if(mounted){

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatScreen( groupId:widget.groupId.toString(), nav: '',)),
                                        );
                                        Navigator.pop(context);
                                    }
                                  }
                                  else {
                                    Common.toastMessaage(
                                        object.message, Colors.red);
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                    }
                                  }

                                },
                                icon: const Icon(Icons.send)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
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


}