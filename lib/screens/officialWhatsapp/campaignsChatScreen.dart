import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:login2/screens/officialWhatsapp/chatHomeScreen.dart';
import 'package:login2/screens/officialWhatsapp/viewerScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../models/officialWhatsapp/campaignsOfficialMessageModel.dart';
import '../../models/officialWhatsapp/mediaModel.dart';
import '../../models/officialWhatsapp/official_message_model.dart';
import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../models/officialWhatsapp/sendTemplateMesaageModel.dart';
import '../../models/officialWhatsapp/templateContentModel.dart';
import '../../models/officialWhatsapp/templateModel.dart';
import '../../service/service.dart';
import 'colorConst.dart';
import 'components/imageHelper.dart';
import 'imageViewScreen.dart';


import 'listFileManager.dart';

class CampaignsChatScreen extends StatefulWidget {
  const CampaignsChatScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  final String groupId;

  @override
  State<CampaignsChatScreen> createState() => _CampaignsChatScreenState();
}

class _CampaignsChatScreenState extends State<CampaignsChatScreen> {
  List list = [];
  String? userImage;
  CampaignsOfficialMessageModel? officialMessageModel;
  MediaModel? mediaDetails;
  bool isTyped = false;
  bool isLoading = true;
  TemplateModel? templateModel;
  String selectedTemp = '';
  String selectTemplate = '';
  String templateImage = '';
  double dropDownHeight = 70;
  bool templateSelected = false;
  TemplateContentModel? templateContentModel;
  SendTemplateMesaageModel? sendTemplateMessageModel;
  bool buttonStatus = false;
  SendMesaageModel? sendMessageModel;
  bool isImage = false;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  File? _video;
  bool listFiles = false;

  @override
  void initState() {
    getchat(widget.groupId);

    super.initState();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  final imageHelper = ImageHelper();

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatHomeScreen(),
            ));
        return true;
      },
      child: Scaffold(
        appBar: officialMessageModel == null && templateModel == null
            ? null
            : AppBar(
          titleSpacing: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatHomeScreen(),
                  ));
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: Container(
            padding: EdgeInsets.zero, // Set padding to zero
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: NetworkImage(
                             '')),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ChatingScreen(),
                    //   ),
                    // );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: SizedBox(
                                  height: 220,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          image: const DecorationImage(
                                            image: NetworkImage(
                                                ''),
                                          ),
                                          color: ColorConstant.grey,
                                          borderRadius:
                                          BorderRadius.circular(60),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 22,
                                      ),
                                      const Text(
                                       '',
                                        style: TextStyle(
                                          color: ColorConstant.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                       '',
                                        style: TextStyle(
                                          color: ColorConstant.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      const Text(
                                        "Created By :",
                                        style: TextStyle(
                                          color: ColorConstant.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      const Text(
                                        "Created Date : ",
                                        style: TextStyle(
                                          color: ColorConstant.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                         'Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: ColorConstant.barGreen,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  showMenu(
                    color: ColorConstant.white,
                    context: context,
                    position: const RelativeRect.fromLTRB(
                        1000.0, 0.0, 1000.0, 0.0),
                    items: [
                      const PopupMenuItem<String>(
                        value: '1',
                        child: Text('Profile'),
                      ),
                      const PopupMenuItem<String>(
                        value: '2',
                        child: Text('Refresh'),
                      ),
                    ],
                  ).then((value) {
                    if (value != null) {
                      if (value == '1') {

                      } else if (value == '2') {
                        getchat(widget.groupId);
                        setState(() {});
                      }
                    }
                  });
                },
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: officialMessageModel == null && templateModel == null
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          decoration: const BoxDecoration(
            color: ColorConstant.backgroundColor,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/main/officialBackground.png'),
            ),
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: officialMessageModel!.messages!.length,
                  itemBuilder: (context, index) {
                    _controller = VideoPlayerController.networkUrl(
                      Uri.parse(
                        officialMessageModel!
                            .messages![index].messageText!.url.toString(),
                      ),
                    );

                    _initializeVideoPlayerFuture =
                        _controller.initialize();
                    return Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (officialMessageModel!.messages![index]
                                  .messageText!.format ==
                                  'VIDEO' ||
                                  officialMessageModel!.messages![index]
                                      .messageText!.format ==
                                      'DOCUMENT') {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewerScreen(
                                        myUrl: officialMessageModel!
                                            .messages![index]
                                            .messageText!
                                            .url.toString(),
                                        type: officialMessageModel!
                                            .messages![index]
                                            .messageText!
                                            .format.toString(),
                                        title: officialMessageModel!
                                            .messages![index]
                                            .messageText!
                                            .format.toString(),
                                      ),
                                    ));
                              } else {}
                            },
                            child: Row(
                              mainAxisAlignment: officialMessageModel!
                                  .messages![index].fromMe ==
                                  true
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 12,
                                      right: 12,
                                      bottom: 4,
                                      top: 12),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        Colors.grey.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(-1, 1),
                                      )
                                    ],
                                    color: officialMessageModel!
                                        .messages![index].fromMe ==
                                        false
                                        ? ColorConstant.white
                                        : ColorConstant.greenChat,
                                    // doc['uid'] == auth.currentUser!.uid
                                    //     ? const Color.fromARGB(255, 184, 236, 123)
                                    //     :

                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  constraints: const BoxConstraints(maxWidth: 240,),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      officialMessageModel!
                                          .messages![index]
                                          .messageText!
                                          .format ==
                                          'IMAGE'
                                          ? GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewerScreen(
                                                      myUrl:
                                                      officialMessageModel!
                                                          .messages![
                                                      index]
                                                          .messageText!
                                                          .url.toString(),
                                                      type: officialMessageModel!
                                                          .messages![
                                                      index]
                                                          .messageText!
                                                          .format.toString(),
                                                      title:
                                                      officialMessageModel!
                                                          .messages![
                                                      index]
                                                          .messageText!
                                                          .format.toString(),
                                                    ),
                                              ));
                                        },
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 1),
                                          child: Container(
                                            height: MediaQuery.of(
                                                context)
                                                .size
                                                .height *
                                                0.35,
                                            decoration:
                                            BoxDecoration(
                                              image:
                                              DecorationImage(
                                                fit: BoxFit
                                                    .fitHeight,
                                                image: NetworkImage(
                                                    officialMessageModel!
                                                        .messages![
                                                    index]
                                                        .messageText!
                                                        .url.toString()),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          : officialMessageModel!
                                          .messages![index]
                                          .messageText!
                                          .format ==
                                          'VIDEO'
                                          ? Padding(
                                        padding:
                                        const EdgeInsets
                                            .only(
                                            bottom: 10),
                                        child: Container(
                                          margin:
                                          const EdgeInsets
                                              .only(
                                              left: 8,
                                              right: 8,
                                              bottom: 8),
                                          //height: MediaQuery.of(context).size.height * 0.38,
                                          width:
                                          double.infinity,
                                          decoration:
                                          const BoxDecoration(
                                              color: Colors
                                                  .white),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              FutureBuilder(
                                                future:
                                                _initializeVideoPlayerFuture,
                                                builder: (context,
                                                    snapshot) {
                                                  if (snapshot
                                                      .connectionState ==
                                                      ConnectionState
                                                          .done) {
                                                    // If the VideoPlayerController has finished initialization, use
                                                    // the data it provides to limit the aspect ratio of the video.
                                                    return AspectRatio(
                                                      aspectRatio: _controller
                                                          .value
                                                          .aspectRatio,
                                                      // Use the VideoPlayer widget to display the video.
                                                      child:
                                                      Stack(
                                                        children: [
                                                          VideoPlayer(
                                                              _controller),
                                                          const Center(
                                                            child:
                                                            Icon(
                                                              Icons.play_circle,
                                                              color: Colors.white,
                                                              size: 50.0,
                                                              semanticLabel: 'Play',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  } else {
                                                    // If the VideoPlayerController is still initializing, show a
                                                    // loading spinner.
                                                    return const Center(
                                                      child:
                                                      CircularProgressIndicator(),
                                                    );
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                          : officialMessageModel!
                                          .messages![index]
                                          .messageText!
                                          .format ==
                                          'DOCUMENT'
                                          ? Container(
                                          width: MediaQuery.of(context).size.width *
                                              0.6,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),color: Colors.grey.withOpacity(0.2)),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .only(
                                              right: 10,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 8,bottom: 8,left: 4),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 70,
                                                    width: 40,
                                                    decoration:
                                                    const BoxDecoration(
                                                      image:
                                                      DecorationImage(
                                                        fit: BoxFit
                                                            .fitWidth,
                                                        image: AssetImage(
                                                            'assets/icons/doc.png'),
                                                      ),
                                                    ),
                                                    // Add your image widget here
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Center(
                                                      child: SizedBox(
                                                        width:120,
                                                        child: Text(officialMessageModel!
                                                            .messages![
                                                        index]
                                                            .messageText!
                                                            .fileName.toString(),overflow: TextOverflow.ellipsis,),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ))
                                          : officialMessageModel!
                                          .messages![
                                      index]
                                          .messageText!
                                          .format ==
                                          'TEXT'
                                          ? officialMessageModel!
                                          .messages![index]
                                          .messageText!
                                          .url ==
                                          ''
                                          ? const SizedBox()
                                          : Padding(
                                        padding: const EdgeInsets
                                            .only(
                                            bottom:
                                            4),
                                        child: Text(
                                          officialMessageModel!
                                              .messages![
                                          index]
                                              .messageText!
                                              .url.toString(),
                                          style:
                                          const TextStyle(
                                            fontSize:
                                            14,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      )
                                          : const SizedBox(),
                                      Text(
                                        officialMessageModel!
                                            .messages![index]
                                            .messageText!
                                            .messageBody.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      officialMessageModel!
                                          .messages![index]
                                          .messageText!
                                          .footer ==
                                          ""
                                          ? const SizedBox()
                                          : Padding(
                                        padding:
                                        const EdgeInsets.only(
                                            top: 5, bottom: 3),
                                        child: Text(
                                          officialMessageModel!
                                              .messages![index]
                                              .messageText!
                                              .footer.toString(),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: ColorConstant
                                                  .grey),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            officialMessageModel!
                                                .messages![index].sentTime.toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          officialMessageModel!
                                              .messages![index]
                                              .fromMe ==
                                              true
                                              ? officialMessageModel!
                                              .messages![index]
                                              .status ==
                                              'send'
                                              ? const Icon(
                                            Icons.check,
                                            color: ColorConstant
                                                .grey,
                                            size: 18,
                                          )
                                              : officialMessageModel!
                                              .messages![
                                          index]
                                              .status ==
                                              'delivered'
                                              ? const Icon(
                                            Icons
                                                .done_all_sharp,
                                            color:
                                            ColorConstant
                                                .grey,
                                            size: 18,
                                          )
                                              : officialMessageModel!
                                              .messages![
                                          index]
                                              .status ==
                                              'read'
                                              ? const Icon(
                                            Icons
                                                .done_all_sharp,
                                            color: ColorConstant
                                                .messageSeen,
                                            size: 18,
                                          )
                                              : officialMessageModel!
                                              .messages![index]
                                              .status ==
                                              'failed'
                                              ? const Icon(
                                            Icons
                                                .access_time_rounded,
                                            color: ColorConstant
                                                .grey,
                                            size:
                                            18,
                                          )
                                              : const Icon(
                                            Icons
                                                .check,
                                            color: ColorConstant
                                                .grey,
                                            size:
                                            18,
                                          )
                                              : const SizedBox()
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 5, right: 8, left: 8, top: 5),
                            child: officialMessageModel!.messages![index]
                                .messageText!.buttons!.length ==
                                2
                                ? Row(
                              mainAxisAlignment:
                              officialMessageModel!
                                  .messages![index]
                                  .fromMe ==
                                  true
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (officialMessageModel!
                                        .messages![index]
                                        .messageText!
                                        .buttons![1]
                                        .type ==
                                        "URL") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewerScreen(
                                                myUrl: officialMessageModel!
                                                    .messages![
                                                index]
                                                    .messageText!
                                                    .buttons![
                                                1]
                                                    .btnUrl.toString(),
                                                type: officialMessageModel!
                                                    .messages![
                                                index]
                                                    .messageText!
                                                    .format.toString(),
                                                title:
                                                officialMessageModel!
                                                    .messages![
                                                index]
                                                    .messageText!
                                                    .format.toString(),
                                              ),
                                        ),
                                      );
                                    } else if (officialMessageModel!
                                        .messages![index]
                                        .messageText!
                                        .buttons![1]
                                        .type ==
                                        "PHONE_NUMBER") {
                                      await launch(
                                        "tel:/${officialMessageModel!.messages![index].messageText!.buttons![1].btnUrl}",
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.3,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey
                                                .withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 2,
                                            offset:
                                            const Offset(1, 1),
                                          )
                                        ],
                                        borderRadius:
                                        BorderRadius.circular(5),
                                        color: Colors.white),
                                    child: Center(
                                      child: Text(
                                        officialMessageModel!
                                            .messages![index]
                                            .messageText!
                                            .buttons![1]
                                            .text.toString(),
                                        style: const TextStyle(
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (officialMessageModel!
                                        .messages![index]
                                        .messageText!
                                        .buttons![0]
                                        .type ==
                                        "URL") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ViewerScreen(
                                                myUrl: officialMessageModel!
                                                    .messages![
                                                index]
                                                    .messageText!
                                                    .buttons![
                                                0]
                                                    .btnUrl.toString(),
                                                type: officialMessageModel!
                                                    .messages![
                                                index]
                                                    .messageText!
                                                    .format.toString(),
                                                title:
                                                officialMessageModel!
                                                    .messages![
                                                index]
                                                    .messageText!
                                                    .format.toString(),
                                              ),
                                        ),
                                      );
                                    } else if (officialMessageModel!
                                        .messages![index]
                                        .messageText!
                                        .buttons![0]
                                        .type ==
                                        "PHONE_NUMBER") {
                                      await launch(
                                        "tel:/${officialMessageModel!.messages![index].messageText!.buttons![0].btnUrl}",
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 40,
                                    width: MediaQuery.of(context)
                                        .size
                                        .width *
                                        0.3,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey
                                                .withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 2,
                                            offset:
                                            const Offset(1, 1),
                                          )
                                        ],
                                        borderRadius:
                                        BorderRadius.circular(5),
                                        color: Colors.white),
                                    child: Center(
                                      child: Text(
                                        officialMessageModel!
                                            .messages![index]
                                            .messageText!
                                            .buttons![0]
                                            .text.toString(),
                                        style: const TextStyle(
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                                : Row(
                              mainAxisAlignment:
                              officialMessageModel!
                                  .messages![index]
                                  .fromMe ==
                                  true
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width *
                                      0.644,
                                  child: ListView.builder(
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: officialMessageModel!
                                        .messages![index]
                                        .messageText!
                                        .buttons!
                                        .length,
                                    itemBuilder: (context, indexC) {
                                      return GestureDetector(
                                        onTap: () async {
                                          if (officialMessageModel!
                                              .messages![index]
                                              .messageText!
                                              .buttons![indexC]
                                              .type ==
                                              "URL") {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ViewerScreen(
                                                      myUrl: officialMessageModel!
                                                          .messages![
                                                      index]
                                                          .messageText!
                                                          .buttons![
                                                      indexC]
                                                          .btnUrl.toString(),
                                                      type: officialMessageModel!
                                                          .messages![
                                                      index]
                                                          .messageText!
                                                          .format.toString(),
                                                      title:
                                                      officialMessageModel!
                                                          .messages![
                                                      index]
                                                          .messageText!
                                                          .format.toString(),
                                                    ),
                                              ),
                                            );
                                          } else if (officialMessageModel!
                                              .messages![index]
                                              .messageText!
                                              .buttons![indexC]
                                              .type ==
                                              "PHONE_NUMBER") {
                                            await launch(
                                              "tel:/${officialMessageModel!.messages![index].messageText!.buttons![indexC].btnUrl}",
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.all(
                                              5.0),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(
                                                context)
                                                .size
                                                .width *
                                                0.5,
                                            decoration:
                                            BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(
                                                      0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 2,
                                                  offset:
                                                  const Offset(
                                                      1, 1),
                                                ),
                                              ],
                                              borderRadius:
                                              BorderRadius
                                                  .circular(5),
                                              color: Colors.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                officialMessageModel!
                                                    .messages![index]
                                                    .messageText!
                                                    .buttons![indexC]
                                                    .text.toString(),
                                                style: const TextStyle(
                                                    fontWeight:
                                                    FontWeight
                                                        .bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                )
              ],
            ),
          ),
        ),
        bottomSheet: officialMessageModel == null && templateModel == null
            ? null
            : Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child:  GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            content: SizedBox(
                              height: dropDownHeight,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    templateModel == null
                                        ? const Center(
                                        child:
                                        CircularProgressIndicator())
                                        : DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        isExpanded: true,
                                        value: selectedTemp == ''
                                            ? null
                                            : selectedTemp,
                                        borderRadius:
                                        BorderRadius.circular(
                                            8),
                                        autofocus: false,
                                        items: templateModel!.data
                                            .map<
                                            DropdownMenuItem<
                                                String>>((e) {
                                          return DropdownMenuItem<
                                              String>(
                                            onTap: () {
                                              selectTemplate =
                                                  e.name;
                                            },
                                            value: e.id,
                                            child: SizedBox(
                                              width: MediaQuery.of(
                                                  context)
                                                  .size
                                                  .width *
                                                  0.35,
                                              child: Text(
                                                e.name,
                                                overflow:
                                                TextOverflow
                                                    .ellipsis,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (res) async {
                                          selectedTemp =
                                              res.toString();

                                          await getTemplateContents(
                                              selectedTemp);
                                          await getTemplateMedia(
                                              templateContentModel!
                                                  .data.format);
                                          setState(() {});
                                        },
                                        hint: const Text(
                                          'Select template',
                                          textAlign:
                                          TextAlign.left,
                                          style: TextStyle(
                                            fontWeight:
                                            FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    templateSelected == true
                                        ? Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        const SizedBox(
                                            height: 10),
                                        templateContentModel!.data
                                            .format ==
                                            'VIDEO'
                                            ? Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context:
                                                  context,
                                                  builder:
                                                      (BuildContext
                                                  context) {
                                                    return StatefulBuilder(builder:
                                                        (context,
                                                        setState) {
                                                      return AlertDialog(
                                                        scrollable:
                                                        true,
                                                        title:
                                                        const Text('Select Source'),
                                                        content:
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () async {
                                                                // Get.back();
                                                                Navigator.pop(context);
                                                                await pickTemplateImage(context, ImageSource.camera);
                                                                dropDownHeight = 510;
                                                                setState(() {});
                                                              },
                                                              child: const Text("Camera"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                // Get.back();
                                                                Navigator.pop(context);
                                                                await pickTemplateImage(context, ImageSource.gallery);
                                                                dropDownHeight = 510;
                                                                setState(() {});
                                                              },
                                                              child: const Text("Gallery"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                // Get.back();
                                                              },
                                                              child: const Text("Cancel"),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                                  },
                                                );
                                              },
                                              child:
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                    0.7,
                                                decoration:
                                                BoxDecoration(
                                                  border: Border
                                                      .all(),
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      5),
                                                ),
                                                child:
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(
                                                      8),
                                                  child:
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                        MediaQuery.of(context).size.width * 0.2,
                                                        child: templateImage == ''
                                                            ? const Text('Upload ')
                                                            : Container(
                                                          height: 80,
                                                          width: 100,
                                                          decoration: BoxDecoration(
                                                            color: ColorConstant.white,
                                                            image: DecorationImage(
                                                              image: FileImage(
                                                                File(templateImage),
                                                              ),
                                                            ),
                                                          ),
                                                          // Add your image widget here
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: ColorConstant.grey,
                                                              borderRadius: BorderRadius.circular(3),
                                                            ),
                                                            child: const Padding(
                                                              padding: EdgeInsets.all(4.0),
                                                              child: Text(
                                                                'Choose file',
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            templateImage == '' ? '*No file selected' : '',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            mediaDetails !=
                                                null
                                                ? SizedBox(
                                              height:
                                              110,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  shrinkWrap: true,
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  itemCount: mediaDetails!.data!.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        templateImage = mediaDetails!.data![i].url.toString();
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        constraints: const BoxConstraints(
                                                          maxHeight: 81,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              constraints: const BoxConstraints(
                                                                minHeight: 60,
                                                                minWidth: 60,
                                                                maxHeight: 70,
                                                                maxWidth: 70,
                                                              ),
                                                              decoration: const BoxDecoration(
                                                                shape: BoxShape.rectangle,
                                                                image: DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/icons/mp4.png')),
                                                                // image: AssetImage(
                                                                //     'assets/images/img.jpeg')),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            SizedBox(
                                                              width: 60,
                                                              child: Text(
                                                                mediaDetails!.data![i].fileName.toString(),
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                                : SizedBox()
                                          ],
                                        )
                                            : templateContentModel!
                                            .data
                                            .format ==
                                            'IMAGE'
                                            ? Column(
                                          children: [
                                            GestureDetector(
                                              onTap:
                                                  () {
                                                showDialog(
                                                  context:
                                                  context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(builder:
                                                        (context, setState) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text('Select Source'),
                                                        content: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () async {
                                                                // Get.back();
                                                                Navigator.pop(context);
                                                                await pickTemplateImage(context, ImageSource.camera);
                                                                dropDownHeight = 510;
                                                                setState(() {});
                                                              },
                                                              child: const Text("Camera"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                // Get.back();
                                                                Navigator.pop(context);
                                                                await pickTemplateImage(context, ImageSource.gallery);
                                                                dropDownHeight = 510;
                                                                setState(() {});
                                                              },
                                                              child: const Text("Gallery"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                // Get.back();
                                                              },
                                                              child: const Text("Cancel"),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                                  },
                                                );
                                              },
                                              child:
                                              Container(
                                                width: MediaQuery.of(context).size.width *
                                                    0.7,
                                                decoration:
                                                BoxDecoration(
                                                  border:
                                                  Border.all(),
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                ),
                                                child:
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(
                                                      8),
                                                  child:
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.2,
                                                        child: templateImage == ''
                                                            ? const Text('Upload ')
                                                            : Container(
                                                          height: 80,
                                                          width: 100,
                                                          decoration: BoxDecoration(
                                                            color: ColorConstant.white,
                                                            image: DecorationImage(
                                                              image: FileImage(
                                                                File(templateImage),
                                                              ),
                                                            ),
                                                          ),
                                                          // Add your image widget here
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: ColorConstant.grey,
                                                              borderRadius: BorderRadius.circular(3),
                                                            ),
                                                            child: const Padding(
                                                              padding: EdgeInsets.all(4.0),
                                                              child: Text(
                                                                'Choose file',
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            templateImage == '' ? '*No file selected1' : '',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                              10,
                                            ),
                                            mediaDetails !=
                                                null
                                                ? SizedBox(
                                              height:
                                              110,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  shrinkWrap: true,
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  itemCount: mediaDetails!.data!.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        templateImage = mediaDetails!.data![i].url.toString();
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        constraints: const BoxConstraints(
                                                          maxHeight: 81,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              constraints: const BoxConstraints(
                                                                minHeight: 60,
                                                                minWidth: 60,
                                                                maxHeight: 70,
                                                                maxWidth: 70,
                                                              ),
                                                              decoration: const BoxDecoration(
                                                                shape: BoxShape.rectangle,
                                                                image: DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/icons/picture.png')),
                                                                // image: AssetImage(
                                                                //     'assets/images/img.jpeg')),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Container(
                                                              width: 60,
                                                              child: Text(
                                                                mediaDetails!.data![i].fileName.toString(),
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                                : SizedBox()
                                          ],
                                        )
                                            : templateContentModel!
                                            .data
                                            .format ==
                                            'DOCUMENT'?
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap:
                                                  () {
                                                showDialog(
                                                  context:
                                                  context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return StatefulBuilder(builder:
                                                        (context, setState) {
                                                      return AlertDialog(
                                                        scrollable: true,
                                                        title: const Text('Select Source'),
                                                        content: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () async {
                                                                // Get.back();
                                                                Navigator.pop(context);
                                                                await pickTemplateImage(context, ImageSource.camera);
                                                                dropDownHeight = 510;
                                                                setState(() {});
                                                              },
                                                              child: const Text("Camera"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () async {
                                                                // Get.back();
                                                                Navigator.pop(context);
                                                                await pickTemplateImage(context, ImageSource.gallery);
                                                                dropDownHeight = 510;
                                                                setState(() {});
                                                              },
                                                              child: const Text("Gallery"),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                // Get.back();
                                                              },
                                                              child: const Text("Cancel"),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                                  },
                                                );
                                              },
                                              child:
                                              Container(
                                                width: MediaQuery.of(context).size.width *
                                                    0.7,
                                                decoration:
                                                BoxDecoration(
                                                  border:
                                                  Border.all(),
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                ),
                                                child:
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .all(
                                                      8),
                                                  child:
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(context).size.width * 0.2,
                                                        child: templateImage == ''
                                                            ? const Text('Upload ')
                                                            : Container(
                                                          height: 80,
                                                          width: 100,
                                                          decoration: BoxDecoration(
                                                            color: ColorConstant.white,
                                                            image: DecorationImage(
                                                              image: FileImage(
                                                                File(templateImage),
                                                              ),
                                                            ),
                                                          ),
                                                          // Add your image widget here
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: ColorConstant.grey,
                                                              borderRadius: BorderRadius.circular(3),
                                                            ),
                                                            child: const Padding(
                                                              padding: EdgeInsets.all(4.0),
                                                              child: Text(
                                                                'Choose file',
                                                                style: TextStyle(
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            templateImage == '' ? '*No file selected1' : '',
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.black,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height:
                                              10,
                                            ),
                                            mediaDetails !=
                                                null
                                                ? SizedBox(
                                              height:
                                              110,
                                              child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  shrinkWrap: true,
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  itemCount: mediaDetails!.data!.length,
                                                  itemBuilder: (BuildContext context, int i) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        templateImage = mediaDetails!.data![i].url.toString();
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        constraints: const BoxConstraints(
                                                          maxHeight: 81,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              constraints: const BoxConstraints(
                                                                minHeight: 60,
                                                                minWidth: 60,
                                                                maxHeight: 70,
                                                                maxWidth: 70,
                                                              ),
                                                              decoration: const BoxDecoration(
                                                                shape: BoxShape.rectangle,
                                                                image: DecorationImage(fit: BoxFit.fill, image: AssetImage('assets/icons/doc.png')),
                                                                // image: AssetImage(
                                                                //     'assets/images/img.jpeg')),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Container(
                                                              width: 60,
                                                              child: Text(
                                                                mediaDetails!.data![i].fileName.toString(),
                                                                overflow: TextOverflow.ellipsis,
                                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                                : SizedBox()
                                          ],
                                        ):
                                        templateContentModel!
                                            .data
                                            .format ==
                                            'TEXT'
                                            ? SizedBox(
                                          child:
                                          Text(
                                            templateContentModel!
                                                .data
                                                .header,
                                            style:
                                            const TextStyle(
                                              fontSize:
                                              16,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        )
                                            : const SizedBox(),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 250,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(
                                                  8),
                                              color: ColorConstant
                                                  .white),
                                          child:
                                          SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(8.0),
                                              child: Text(
                                                templateContentModel!
                                                    .data
                                                    .messageBody,
                                                textAlign:
                                                TextAlign
                                                    .left,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          templateContentModel!
                                              .data.footer,
                                          style: const TextStyle(
                                            color: ColorConstant
                                                .grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        templateContentModel!.data
                                            .buttons.isEmpty
                                            ? const SizedBox()
                                            : SizedBox(
                                          height: 50,
                                          width:
                                          MediaQuery.of(
                                              context)
                                              .size
                                              .width,
                                          child: ListView
                                              .builder(
                                            scrollDirection:
                                            Axis.horizontal,
                                            shrinkWrap:
                                            true,
                                            itemCount:
                                            templateContentModel!
                                                .data
                                                .buttons
                                                .length,
                                            itemBuilder:
                                                (context,
                                                index) {
                                              return Padding(
                                                padding:
                                                const EdgeInsets
                                                    .all(
                                                    8.0),
                                                child:
                                                Container(
                                                  decoration:
                                                  BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color:
                                                        Colors.grey.withOpacity(0.2),
                                                        spreadRadius:
                                                        1,
                                                        blurRadius:
                                                        1,
                                                        offset:
                                                        const Offset(1, 1),
                                                      )
                                                    ],
                                                    color: ColorConstant
                                                        .white,
                                                    borderRadius:
                                                    BorderRadius.circular(3),
                                                  ),
                                                  child:
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top:
                                                        8,
                                                        left:
                                                        8,
                                                        right:
                                                        8),
                                                    child:
                                                    Text(
                                                      templateContentModel!
                                                          .data
                                                          .buttons[index]
                                                          .text,
                                                      style:
                                                      const TextStyle(
                                                        fontSize:
                                                        12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    )
                                        : const SizedBox()
                                  ],
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              buttonStatus == false
                                  ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  ColorConstant.black,
                                ),
                                onPressed: () async {
                                  if (templateContentModel!
                                      .data.format ==
                                      'TEXT' &&
                                      templateSelected == true) {
                                    buttonStatus = true;
                                    await sendingTemplateMessage(
                                        widget.groupId,
                                        templateContentModel!
                                            .data.format,
                                        selectTemplate,
                                        templateContentModel!
                                            .data.language,
                                        selectedTemp,
                                        templateImage,
                                        false,
                                        'normal');
                                    setState(() {});
                                  } else {
                                    await sendingTemplateMessage(
                                        widget.groupId,
                                        templateContentModel!
                                            .data.format,
                                        selectTemplate,
                                        templateContentModel!
                                            .data.language,
                                        selectedTemp,
                                        templateImage,
                                        true,
                                        'file_manager');
                                    //---------------------------   //Next video and image sending fuction call here ----------------------------------------------
                                  }
                                },
                                child: const Text(
                                  'Send',
                                  style: TextStyle(
                                    color: ColorConstant.white,
                                  ),
                                ),
                              )
                                  : Container(
                                decoration: BoxDecoration(
                                    color: ColorConstant.black,
                                    borderRadius:
                                    BorderRadius.circular(
                                        10)),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Sending...',
                                    style: TextStyle(
                                        color:
                                        ColorConstant.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                );
              },
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: ColorConstant.white,
                        border: Border.all(
                            color: ColorConstant.barGreen,
                            width: 2.5),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sticky_note_2_outlined,
                          color: ColorConstant.barGreen,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Send Template',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorConstant.barGreen),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  pickTemplateImage(context, source) async {
    final image1 =
    await ImagePicker().pickImage(source: source, imageQuality: 80);

    try {
      if (image1 != null) {
        setState(() {
          templateImage = image1.path;
        });
        print('Template Image Path after setState: $templateImage');
      }
    } on PlatformException catch (e) {
      // Get.snackbar('Permission Denied',
      //     'Please grant access to the gallery to pick an image.');
    }
  }

  pickTemplateVideo(context, source) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);

    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
    }
  }

  pickedImage(context, source) async {
    final image1 =
    await ImagePicker().pickImage(source: source, imageQuality: 80);

    try {
      if (image1 != null) {
        userImage = image1.path;
      }
    } on PlatformException catch (e) {
      // Get.snackbar('Permission Denied',
      //     'Please grant access to the gallery to pick an image.');
    }
  }

  selectMultiImage(
      ImageSource? source,
      ) async {
    if (source != null) {
      final XFile? selectedImages =
      await ImagePicker().pickImage(source: source);
      if (selectedImages != null) {
        list.add(selectedImages);
        // isLoading.value = true;
        // isLoading.value = false;
      }
      return list;
    } else {
      final List<XFile> images = await ImagePicker().pickMultiImage();
      if (images.isNotEmpty) {
        list.addAll(images);
        // isLoading.value = true;
        // isLoading.value = false;
      }
      return list;
    }
  }

  getTemplates() async {
    templateModel = await HttpService.getTemplate();
    if (templateModel != null) {
      isLoading = false;
      setState(() {});
    }
  }

  getchat(groupId) async {
    isLoading = true;
    officialMessageModel = await HttpService.officialMessageCampaigns(groupId);
    if (officialMessageModel != null) {
      getTemplates();
      setState(() {});
    }
  }

  getTemplateContents(templateId) async {
    templateContentModel = await HttpService.getTemplateContent(templateId);
    if (templateContentModel != null) {
      if (templateContentModel!.data.format == 'VIDEO') {
        setState(() {
          dropDownHeight = 470;
          templateSelected = true;
        });
      } else if (templateContentModel!.data.format == 'IMAGE') {
        setState(() {
          dropDownHeight = 470;
          templateSelected = true;
        });
      } else if (templateContentModel!.data.format == 'TEXT') {
        setState(() {
          dropDownHeight = 400;
          templateSelected = true;
        });
      }
      else if (templateContentModel!.data.format == 'DOCUMENT') {
        setState(() {
          dropDownHeight = 470;
          templateSelected = true;
        });
      }
    } else {
      setState(() {});
    }
  }

  getTemplateMedia(format) async {
    mediaDetails = await HttpService.getTemplateMedia(format);
    if (mediaDetails != null) {
      setState(() {});
    } else {
      setState(() {});
    }
  }

  sendingTemplateMessage(groupId, format, templateName, language, template,
      fileName, isFile, type) async {
    sendTemplateMessageModel = await HttpService.sendTemplateMessage(groupId,
        format, templateName, language, template, fileName, isFile, type);
    if (sendTemplateMessageModel != null &&
        sendTemplateMessageModel!.status == true) {
      await getchat(groupId);
      Navigator.pop(context);
    }
  }


}
