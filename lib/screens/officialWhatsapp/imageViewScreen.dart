import 'dart:io';
import 'package:flutter/material.dart';

import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../service/service.dart';
import 'chatScreen.dart';
import 'colorConst.dart';


class ImageViewScreen extends StatefulWidget {
  ImageViewScreen(
      {super.key,
        this.listImages,
        this.image,
        required this.val,
        required this.groupId});

  final listImages;
  String? image;
  final val;
  final groupId;

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  bool isImage = true;
  var currentPic = 0;
  String? viewImage;
  String imagePath = "";
  String messageData = '';
  SendMesaageModel? sendMessageModel;

  @override
  void initState() {
    if (widget.val == '2') {
      final xFile = widget.listImages[0];
      viewImage = xFile.path;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.listImages[currentPic]);
    if (widget.val == '1') {
      viewImage = widget.image;
    }
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        widget.image = '';
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(groupId: widget.groupId,),));
      },
      child: Scaffold(
        bottomSheet: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            color: Colors.transparent, // Set the color to transparent
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: ColorConstant.barGreen,
                  child: IconButton(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    onPressed: () {
                      sendingMessage(
                          widget.groupId, messageData,viewImage, isImage);
                      viewImage = '';
                      widget.image = '';

                    },
                    icon: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              widget.image = '';
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(groupId: widget.groupId,),));
            },
            icon: const Icon(
              Icons.close,
              color: ColorConstant.white,
            ),
          ),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    // await cropImage(viewImage);
                  },
                  icon: const Icon(
                    Icons.crop_rotate_sharp,
                    color: ColorConstant.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.label_important_outline,
                    color: ColorConstant.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.text_fields,
                    color: ColorConstant.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.mode_edit_outline_outlined,
                    color: ColorConstant.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(
                      File(viewImage!),
                    )),
              ),
            ),
            SizedBox(
              height: 70,
              child: Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: widget.val == '2'
                      ? ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.listImages.length,
                    itemBuilder: (context, index) {
                      final xFile = widget.listImages[index];

                      // print("image name ${widget.listImages[index]}");
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: GestureDetector(
                          onTap: () {
                            viewImage = xFile.path;
                            currentPic = index;
                            setState(() {});
                          },
                          child: Container(
                            height: 68,
                            width: 76,
                            decoration: BoxDecoration(
                              border: currentPic == index
                                  ? Border.all(
                                color: ColorConstant.white,
                              )
                                  : Border.all(
                                color: Colors.black,
                              ),
                              image: DecorationImage(
                                image: FileImage(File(xFile.path)),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                      : const SizedBox()),
            )
          ],
        ),
      ),
    );
  }

  sendingMessage(groupId, messageData, fileName, isImage) async {
    sendMessageModel =
    await HttpService.sendMessage(groupId, messageData, fileName, isImage);
    if (sendMessageModel != null && sendMessageModel!.status == true) {

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(groupId: widget.groupId,),
          ));
    }
  }
}
