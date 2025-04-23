import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/models/officialWhatsapp/campaigns_official_message_model.dart';
import 'package:login2/screens/officialWhatsapp/chat_home_screen.dart';
import 'package:login2/screens/officialWhatsapp/status_view.dart';
import 'package:login2/screens/officialWhatsapp/viewerScreen.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../core/common.dart';
import '../../models/officialWhatsapp/mediaModel.dart';
import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../models/officialWhatsapp/sendTemplateMesaageModel.dart';
import '../../models/officialWhatsapp/template_content_model.dart';
import '../../models/officialWhatsapp/templateModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';
import 'whatsapp_profile.dart';
import 'colorConst.dart';
import 'components/imageHelper.dart';

class CampaignsChatScreen extends StatefulWidget {
  const CampaignsChatScreen({
    super.key,
    required this.groupId,
    required this.nav,
  });

  final String nav;
  final String groupId;

  @override
  State<CampaignsChatScreen> createState() => _CampaignsChatScreenState();
}

class _CampaignsChatScreenState extends State<CampaignsChatScreen> {
  List list = [];
  final imageHelper = ImageHelper();
  final messageController = TextEditingController();
  final argumentController = <TextEditingController>[];

  void onTextChanged(String value, int index) {
    int newIntex = index - 1;
    argList[newIntex] = value;
    _handleArgChange(value, index);
  }

  List<CampaignMessage> items = [];
  List argList = [];
  int page = 1;
  int pageSize = 30;
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
  bool templateLoading = false;
  bool isFilemanager = false;
  String isDownloading = "";
  TemplateContentModel? templateContentModel;
  SendTemplateMesaageModel? sendTemplateMessageModel;
  bool buttonStatus = false;
  SendMesaageModel? sendMessageModel;
  bool isImage = false;
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;
  File? video;
  bool listFiles = false;
  int add = 1;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  String token = "";
  int argCount = 0;
  bool _isValid = false; // Flag for validation state

  @override
  void initState() {
    // messageListner();
    getchat(widget.groupId);
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    getTemplates();
    super.initState();
  }

  void _handleArgChange(String value, int index) {
    setState(() {
      argList[index] = value;
      _isValid =
          argList.every((element) => element.isNotEmpty); // Check all elements
    });
  }

  messageListner() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String navigation = message.data['navigation'];
      if (navigation == 'whatsapp') {
        page = 1;
        add = 1;
        items.clear();
        getchat(widget.groupId);
      }
    });
  }

  void _onLoadMore() {
    if (items.length + 30 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      getchat(widget.groupId);
      add++;
    }
  }

  getchat(groupId) async {
    isLoading = true;
    officialMessageModel =
        await HttpService.officialMessageCampaigns(groupId, page, pageSize);
    if (officialMessageModel != null) {
      setState(() {
        items.addAll(officialMessageModel!.messages);
        page++;
      });
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (pop) async {
        if (widget.nav == "Notification") {
          token = await Common.getSharedPref("token");
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(token),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatHomeScreen(),
              ));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Container(
              padding: EdgeInsets.zero, // Set padding to zero
              child: officialMessageModel != null && templateModel != null
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (widget.nav == "Notification") {
                              token = await Common.getSharedPref("token");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Dashboard(token),
                                  ));
                            } else {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatHomeScreen(),
                                  ));
                              Navigator.pop(context);
                            }
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WhatsappProfile(
                                    groupName: officialMessageModel!.groupName,
                                    profilePic:
                                        officialMessageModel!.profilePhoto,
                                    createdBy: officialMessageModel!.createdBy,
                                    createdDate:
                                        officialMessageModel!.createdTime,
                                    contacts: officialMessageModel!.contats,
                                    groupId: officialMessageModel!.groupId,
                                  ),
                                )).then((r) {
                              page = 1;
                              add = 1;
                              items.clear();
                              getchat(widget.groupId);
                              setState(() {});
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(
                                    officialMessageModel!.profilePhoto,
                                  )),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  officialMessageModel!.groupName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox()),
          backgroundColor: ColorConstant.barGreen,
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 16,
              ),
              child: GestureDetector(
                onTap: () {
                  page = 1;
                  add = 1;
                  items.clear();
                  getchat(widget.groupId);
                  setState(() {});
                },
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          decoration: const BoxDecoration(
            color: ColorConstant.backgroundColor,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage('assets/main/officialBackground.png'),
            ),
          ),
          child: items != [] && templateModel == null
              ? buildLoaderListItem()
              : Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: ScrollablePositionedList.builder(
                            reverse: true,
                            physics: const ClampingScrollPhysics(),
                            initialScrollIndex: 0,
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
                            itemCount: items.length +
                                (items.length + 30 == page * pageSize ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < items.length &&
                                  items[index].messageText.format == "VIDEO") {
                                _controller = VideoPlayerController.networkUrl(
                                  Uri.parse(
                                    items[index].messageText.url,
                                  ),
                                );
                                _initializeVideoPlayerFuture =
                                    _controller!.initialize();
                              }

                              if (index == items.length) {
                                return scrollShimmer(index);
                              } else {
                                if (items[index].messageText.format == "LIST" ||
                                    items[index].messageText.format ==
                                        "PRODUCT_LIST" ||
                                    items[index].messageText.format ==
                                        "DOCUMENT" ||
                                    items[index].messageText.format ==
                                        "RENEW") {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index == 0 ? 90.0 : 0.0,
                                        top: 4.0),
                                    child: chatWidget2(index, context),
                                  );
                                } else {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: index == 0 ? 90.0 : 0.0,
                                        top: 4.0),
                                    child: chatWidget1(index, context),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 85.0,
                      right: 5.0,
                      child: GestureDetector(
                        onTap: () {
                          scrollToFirstIndex();
                        },
                        child: const Opacity(
                          opacity: 0.7,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.keyboard_double_arrow_down),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
        bottomSheet: officialMessageModel != null && templateModel != null
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, right: 8.0, top: 8.0, bottom: 20.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: GestureDetector(
                    onTap: () {
                      templateDialog(context);
                    },
                    child: SizedBox(
                      height: 60,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: ColorConstant.white,
                              border: Border.all(
                                  color: ColorConstant.barGreen, width: 2.5),
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
              )
            : Container(
                height: 70,
                color: Colors.grey.shade100,
              ),
      ),
    );
  }

  Align chatWidget1(int index, BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (items[index].messageText.format == 'VIDEO') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewerScreen(
                            myUrl: items[index].messageText.url,
                            type: items[index].messageText.format,
                            title: items[index].messageText.format,
                          ),
                        ));
                  } else if (items[index].messageText.format == 'LOCATION') {
                    double latitude = double.parse(
                        items[index].messageText.latitude.toString());
                    double longitude = double.parse(
                        items[index].messageText.longitude.toString());
                    launchGoogleMaps(latitude, longitude);
                  }
                },
                child: Row(
                  mainAxisAlignment: items[index].fromMe == true
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: items[index].messageText.format == 'TEXT'
                          ? const EdgeInsets.only(
                              left: 12, right: 12, bottom: 4, top: 12)
                          : const EdgeInsets.only(
                              left: 4, right: 4, bottom: 5, top: 4),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(-1, 1),
                          )
                        ],
                        color: items[index].fromMe == false
                            ? ColorConstant.white
                            : ColorConstant.greenChat,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        maxWidth: 240,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          items[index].messageText.format == 'IMAGE'
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewerScreen(
                                            myUrl: items[index].messageText.url,
                                            type:
                                                items[index].messageText.format,
                                            title:
                                                items[index].messageText.format,
                                          ),
                                        ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 1),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.35,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                items[index].messageText.url),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : items[index].messageText.format == 'VIDEO'
                                  ? Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 4,
                                            right: 4,
                                            bottom: 5,
                                            top: 4),
                                        //height: MediaQuery.of(context).size.height * 0.38,
                                        width: double.infinity,
                                        decoration: const BoxDecoration(
                                            color: Colors.white),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            FutureBuilder(
                                              future:
                                                  _initializeVideoPlayerFuture,
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  // If the VideoPlayerController has finished initialization, use
                                                  // the data it provides to limit the aspect ratio of the video.
                                                  return AspectRatio(
                                                    aspectRatio: _controller!
                                                        .value.aspectRatio,
                                                    // Use the VideoPlayer widget to display the video.
                                                    child: Stack(
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: VideoPlayer(
                                                              _controller!),
                                                        ),
                                                        const Center(
                                                          child: Icon(
                                                            Icons.play_circle,
                                                            color: Colors.white,
                                                            size: 50.0,
                                                            semanticLabel:
                                                                'Play',
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
                                  : items[index].messageText.format ==
                                          'DOCUMENT'
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color:
                                                  Colors.grey.withOpacity(0.2)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, bottom: 8, left: 4),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 70,
                                                    width: 40,
                                                    decoration:
                                                        const BoxDecoration(
                                                      image: DecorationImage(
                                                        fit: BoxFit.fitWidth,
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
                                                    width: 120,
                                                    child: Text(
                                                      items[index]
                                                          .messageText
                                                          .fileName,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            ),
                                          ))
                                      : items[index].messageText.format ==
                                              'TEXT'
                                          ? items[index].messageText.url == ''
                                              ? const SizedBox()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4),
                                                  child: Text(
                                                    items[index]
                                                        .messageText
                                                        .url,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                          : const SizedBox(),
                          Padding(
                            padding: items[index].messageText.format == 'TEXT'
                                ? const EdgeInsets.only(left: 0)
                                : const EdgeInsets.only(left: 5),
                            child: items[index].messageText.format == 'LOCATION'
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(36.0),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 80,
                                            color: Colors.red,
                                          ),
                                          Text(
                                            "Tap to view",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Visibility(
                                    visible:
                                        items[index].messageText.messageBody !=
                                            "",
                                    child: Text(
                                      items[index].messageText.messageBody,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                          ),
                          items[index].messageText.footer == ""
                              ? const SizedBox()
                              : Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, bottom: 3),
                                  child: Text(
                                    items[index].messageText.footer,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: ColorConstant.grey),
                                  ),
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                items[index].sentTime.toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade900,
                                ),
                                textAlign: TextAlign.right,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              items[index].fromMe == true
                                  ? items[index].status == 'send'
                                      ? const Icon(
                                          Icons.check,
                                          color: ColorConstant.grey,
                                          size: 18,
                                        )
                                      : items[index].status == 'delivered'
                                          ? const Icon(
                                              Icons.done_all_sharp,
                                              color: ColorConstant.grey,
                                              size: 18,
                                            )
                                          : items[index].status == 'read'
                                              ? const Icon(
                                                  Icons.done_all_sharp,
                                                  color:
                                                      ColorConstant.messageSeen,
                                                  size: 18,
                                                )
                                              : items[index].status == 'failed'
                                                  ? const Icon(
                                                      Icons.access_time_rounded,
                                                      color: ColorConstant.grey,
                                                      size: 18,
                                                    )
                                                  : const Icon(
                                                      Icons.check,
                                                      color: ColorConstant.grey,
                                                      size: 18,
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
                padding:
                    const EdgeInsets.only(bottom: 5, right: 8, left: 8, top: 5),
                child: items[index].messageText.buttons.length == 2
                    ? Row(
                        mainAxisAlignment: items[index].fromMe == true
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                            child: Center(
                              child: Text(
                                items[index].messageText.buttons[1].text,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Container(
                            height: 40,
                            width: MediaQuery.of(context).size.width * 0.3,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                            child: Center(
                              child: Text(
                                items[index].messageText.buttons[0].text,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: items[index].fromMe == true
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.644,
                            child: items[index].messageText.buttons.isEmpty
                                ? const SizedBox()
                                : ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount:
                                        items[index].messageText.buttons.length,
                                    itemBuilder: (context, indexC) {
                                      return GestureDetector(
                                        onTap: () async {},
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Container(
                                            height: 40,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.5,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  spreadRadius: 2,
                                                  blurRadius: 2,
                                                  offset: const Offset(1, 1),
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                            ),
                                            child: Center(
                                              child: Text(
                                                items[index]
                                                    .messageText
                                                    .buttons[indexC]
                                                    .text,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
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
          if (items[index].fromMe == true)
            GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageViewStatus(
                          groupId: widget.groupId,
                          messageId: items[index].messageId,
                        ),
                      ));
                },
                child: const Icon(Icons.more_vert))
        ],
      ),
    );
  }

  Align chatWidget2(int index, BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (items[index].messageText.format == "DOCUMENT") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewerScreen(
                              myUrl: items[index].messageText.url,
                              type: items[index].messageText.format,
                              title: items[index].messageText.format,
                            ),
                          ));
                    }
                  },
                  child: Row(
                    mainAxisAlignment: items[index].fromMe == true
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: const Offset(-1, 1),
                            )
                          ],
                          color: items[index].fromMe == false
                              ? ColorConstant.white
                              : ColorConstant.greenChat,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints: const BoxConstraints(
                          maxWidth: 240,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: items[index].messageText.format ==
                                      "PRODUCT_LIST"
                                  ? Container(
                                      decoration: BoxDecoration(
                                          color: items[index].fromMe == false
                                              ? Colors.grey.shade200
                                              : ColorConstant.greenChatlight,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                .09,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .18,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        items[index]
                                                            .messageText
                                                            .url)),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(8),
                                                  topLeft: Radius.circular(8),
                                                )),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .3,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  items[index]
                                                      .messageText
                                                      .headerText,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  items[index]
                                                      .messageText
                                                      .headerSubText,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : items[index].messageText.format ==
                                          'DOCUMENT'
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color:
                                                  Colors.grey.withOpacity(0.2)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8, bottom: 8, left: 4),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    height: 70,
                                                    width: 40,
                                                    decoration:
                                                        const BoxDecoration(
                                                      image: DecorationImage(
                                                        fit: BoxFit.fitWidth,
                                                        image: AssetImage(
                                                            'assets/icons/doc.png'),
                                                      ),
                                                    ),
                                                    // Add your image widget here
                                                  ),
                                                  Center(
                                                      child: SizedBox(
                                                    width: 120,
                                                    child: Text(
                                                      items[index]
                                                          .messageText
                                                          .fileName,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  )),
                                                  isDownloading == "true"
                                                      ? const CircularProgressIndicator(
                                                          color: Colors.black,
                                                        )
                                                      : isDownloading == "false"
                                                          ? const Icon(
                                                              Icons.download)
                                                          : const SizedBox(
                                                              width: 15,
                                                            )
                                                ],
                                              ),
                                            ),
                                          ))
                                      : items[index].messageText.format == ""
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: items[index].fromMe ==
                                                          false
                                                      ? Colors.grey.shade200
                                                      : ColorConstant
                                                          .greenChatlight,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            .09,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .18,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(8),
                                                              topLeft: Radius
                                                                  .circular(8),
                                                            )),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .3,
                                                    child: const Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Header",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          "2 items",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )
                                          : const SizedBox(),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 14.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .5,
                                child: items[index].messageText.format == "paid"
                                    ? const Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 25.0),
                                              child: Text(
                                                "₹18000/-",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 12,
                                                backgroundColor:
                                                    ColorConstant.barGreen,
                                                child: Icon(
                                                  Icons.currency_rupee,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "send to +91 8592894516",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                  Text(
                                                    "Completed",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontSize: 9,
                                                        color: ColorConstant
                                                            .barGreen,
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          items[index]
                                                      .messageText
                                                      .messageBody ==
                                                  ""
                                              ? const SizedBox()
                                              : Text(
                                                  items[index]
                                                      .messageText
                                                      .messageBody,
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                          items[index].messageText.footer == ""
                                              ? const SizedBox()
                                              : Text(
                                                  items[index]
                                                      .messageText
                                                      .footer,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                        ],
                                      ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  items[index].sentTime.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                items[index].fromMe == true
                                    ? items[index].status == 'send'
                                        ? const Icon(
                                            Icons.check,
                                            color: ColorConstant.grey,
                                            size: 18,
                                          )
                                        : items[index].status == 'delivered'
                                            ? const Icon(
                                                Icons.done_all_sharp,
                                                color: ColorConstant.grey,
                                                size: 18,
                                              )
                                            : items[index].status == 'read'
                                                ? const Icon(
                                                    Icons.done_all_sharp,
                                                    color: ColorConstant
                                                        .messageSeen,
                                                    size: 18,
                                                  )
                                                : items[index].status ==
                                                        'failed'
                                                    ? const Icon(
                                                        Icons
                                                            .access_time_rounded,
                                                        color:
                                                            ColorConstant.grey,
                                                        size: 18,
                                                      )
                                                    : const Icon(
                                                        Icons.check,
                                                        color:
                                                            ColorConstant.grey,
                                                        size: 18,
                                                      )
                                    : const SizedBox()
                              ],
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  items[index].messageText.buttons.length,
                              itemBuilder: (context, i) {
                                return Column(
                                  children: [
                                    const Divider(),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        decoration: const BoxDecoration(),
                                        child: Center(
                                            child: Text(
                                          items[index]
                                              .messageText
                                              .buttons[i]
                                              .text,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w800),
                                        )),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(
                              height: 8,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (items[index].fromMe == true)
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MessageViewStatus(
                            groupId: widget.groupId,
                            messageId: items[index].messageId,
                          ),
                        ));
                  },
                  child: const Icon(Icons.more_vert))
          ],
        ),
      ),
    );
  }

  Future<dynamic> templateDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            content: SizedBox(
              height: dropDownHeight,
              width: MediaQuery.of(context).size.width * .8,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    templateLoading == true
                        ? const Center(child: LinearProgressIndicator())
                        : DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                              value: selectedTemp == '' ? null : selectedTemp,
                              borderRadius: BorderRadius.circular(8),
                              autofocus: false,
                              items: templateModel!.data
                                  .map<DropdownMenuItem<String>>((e) {
                                return DropdownMenuItem<String>(
                                  onTap: () {
                                    selectTemplate = e.name;
                                  },
                                  value: e.id,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    child: Text(
                                      e.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (res) async {
                                setState(() {
                                  templateLoading = true;
                                });
                                selectedTemp = res.toString();
                                await getTemplateContents(selectedTemp);
                                await getTemplateMedia(
                                    templateContentModel!.data.format);
                                setState(() {
                                  templateLoading = false;
                                });
                              },
                              hint: const Text(
                                'Select template',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                    templateSelected == true
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              templateContentModel!.data.format == 'VIDEO'
                                  ? Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await selectVideo(context);
                                            setState(() {});
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                    child: templateImage == ''
                                                        ? const Text('Upload ')
                                                        : Container(
                                                            height: 80,
                                                            width: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  ColorConstant
                                                                      .white,
                                                              image:
                                                                  DecorationImage(
                                                                image:
                                                                    FileImage(
                                                                  File(
                                                                      templateImage),
                                                                ),
                                                              ),
                                                            ),
                                                            // Add your image widget here
                                                          ),
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color: ColorConstant
                                                              .grey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                        ),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Text(
                                                            'Choose file',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        templateImage == ''
                                                            ? '*No file selected'
                                                            : '',
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
                                        mediaDetails != null
                                            ? SizedBox(
                                                height: 110,
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    shrinkWrap: true,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5,
                                                        vertical: 1),
                                                    itemCount: mediaDetails!
                                                        .data!.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int i) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          isFilemanager = true;
                                                          templateImage =
                                                              mediaDetails!
                                                                  .data![i].url
                                                                  .toString();
                                                          setState(() {});
                                                        },
                                                        child: Container(
                                                          constraints:
                                                              const BoxConstraints(
                                                            maxHeight: 81,
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  minHeight: 60,
                                                                  minWidth: 60,
                                                                  maxHeight: 70,
                                                                  maxWidth: 70,
                                                                ),
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .rectangle,
                                                                  image: DecorationImage(
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      image: AssetImage(
                                                                          'assets/icons/mp4.png')),
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
                                                                  mediaDetails!
                                                                      .data![i]
                                                                      .fileName
                                                                      .toString(),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              )
                                            : const SizedBox()
                                      ],
                                    )
                                  : templateContentModel!.data.format == 'IMAGE'
                                      ? Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () async {
                                                await selectImage(context);
                                                setState(() {});
                                              },
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                decoration: BoxDecoration(
                                                  border: Border.all(),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        child:
                                                            templateImage == ''
                                                                ? const Text(
                                                                    'Upload ')
                                                                : Container(
                                                                    height: 80,
                                                                    width: 100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: ColorConstant
                                                                          .white,
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            FileImage(
                                                                          File(
                                                                              templateImage),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Add your image widget here
                                                                  ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  ColorConstant
                                                                      .grey,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3),
                                                            ),
                                                            child:
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4.0),
                                                              child: Text(
                                                                'Choose file',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            templateImage == ''
                                                                ? '*No file selected1'
                                                                : '',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.black,
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
                                            mediaDetails != null
                                                ? SizedBox(
                                                    height: 110,
                                                    child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        shrinkWrap: true,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 5,
                                                                vertical: 1),
                                                        itemCount: mediaDetails!
                                                            .data!.length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int i) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              isFilemanager =
                                                                  true;

                                                              templateImage =
                                                                  mediaDetails!
                                                                      .data![i]
                                                                      .url
                                                                      .toString();
                                                              setState(() {});
                                                            },
                                                            child: Container(
                                                              constraints:
                                                                  const BoxConstraints(
                                                                maxHeight: 81,
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                      minHeight:
                                                                          60,
                                                                      minWidth:
                                                                          60,
                                                                      maxHeight:
                                                                          70,
                                                                      maxWidth:
                                                                          70,
                                                                    ),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .rectangle,
                                                                      image: DecorationImage(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              AssetImage('assets/icons/picture.png')),
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
                                                                      mediaDetails!
                                                                          .data![
                                                                              i]
                                                                          .fileName
                                                                          .toString(),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                  )
                                                : const SizedBox()
                                          ],
                                        )
                                      : templateContentModel!.data.format ==
                                              'DOCUMENT'
                                          ? Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () async {
                                                    await selectDocument(
                                                        context);
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.7,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                            child: templateImage ==
                                                                    ''
                                                                ? const Text(
                                                                    'Upload ')
                                                                : Container(
                                                                    height: 80,
                                                                    width: 100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: ColorConstant
                                                                          .white,
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            FileImage(
                                                                          File(
                                                                              templateImage),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    // Add your image widget here
                                                                  ),
                                                          ),
                                                          Column(
                                                            children: [
                                                              Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      ColorConstant
                                                                          .grey,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3),
                                                                ),
                                                                child:
                                                                    const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4.0),
                                                                  child: Text(
                                                                    'Choose file',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                templateImage ==
                                                                        ''
                                                                    ? '*No file selected1'
                                                                    : '',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black,
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
                                                mediaDetails != null
                                                    ? SizedBox(
                                                        height: 110,
                                                        child: ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        5,
                                                                    vertical:
                                                                        1),
                                                            itemCount:
                                                                mediaDetails!
                                                                    .data!
                                                                    .length,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int i) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  isFilemanager =
                                                                      true;

                                                                  templateImage =
                                                                      mediaDetails!
                                                                          .data![
                                                                              i]
                                                                          .url
                                                                          .toString();
                                                                  setState(
                                                                      () {});
                                                                },
                                                                child:
                                                                    Container(
                                                                  constraints:
                                                                      const BoxConstraints(
                                                                    maxHeight:
                                                                        81,
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        constraints:
                                                                            const BoxConstraints(
                                                                          minHeight:
                                                                              60,
                                                                          minWidth:
                                                                              60,
                                                                          maxHeight:
                                                                              70,
                                                                          maxWidth:
                                                                              70,
                                                                        ),
                                                                        decoration:
                                                                            const BoxDecoration(
                                                                          shape:
                                                                              BoxShape.rectangle,
                                                                          image: DecorationImage(
                                                                              fit: BoxFit.fill,
                                                                              image: AssetImage('assets/icons/doc.png')),
                                                                          // image: AssetImage(
                                                                          //     'assets/images/img.jpeg')),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            4,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            60,
                                                                        child:
                                                                            Text(
                                                                          mediaDetails!
                                                                              .data![i]
                                                                              .fileName
                                                                              .toString(),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                      )
                                                    : const SizedBox()
                                              ],
                                            )
                                          : templateContentModel!.data.format ==
                                                  'TEXT'
                                              ? SizedBox(
                                                  child: Text(
                                                    templateContentModel!
                                                        .data.header,
                                                    style: const TextStyle(
                                                      fontSize: 16,
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
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: ColorConstant.white),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      templateContentModel!.data.messageBody,
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Visibility(
                                visible: argCount > 0,
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text("Arguments :-"),
                                      ],
                                    ),
                                    for (int i = 1; i < argCount + 1; i++)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2.0),
                                        child: TextFormField(
                                          onChanged: (value) {
                                            onTextChanged(value, i);
                                            print(argList);
                                          },
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 10,
                                                      top: 2,
                                                      bottom: 2),
                                              labelText: "$i",
                                              fillColor: Colors.white,
                                              filled: true,
                                              prefixIcon: const Icon(
                                                  Icons.arrow_right,
                                                  color: Colors.grey),
                                              border:
                                                  const OutlineInputBorder(),
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: const TextStyle(
                                                  color: Colors.grey)),
                                        ),
                                      ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    // Container(
                                    //   height: 40,
                                    //   width: 40,
                                    //   decoration: BoxDecoration(
                                    //       color: Colors.green,
                                    //       borderRadius:
                                    //           BorderRadius.circular(12)),
                                    //   child: const Center(
                                    //     child: Text(
                                    //       "Add",
                                    //       style: TextStyle(color: Colors.white),
                                    //     ),
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                templateContentModel!.data.footer,
                                style: const TextStyle(
                                  color: ColorConstant.grey,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              templateContentModel!.data.buttons.isEmpty
                                  ? const SizedBox()
                                  : SizedBox(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: templateContentModel!
                                            .data.buttons.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.2),
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: const Offset(1, 1),
                                                  )
                                                ],
                                                color: ColorConstant.white,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8, left: 8, right: 8),
                                                child: Text(
                                                  templateContentModel!
                                                      .data.buttons[index].text,
                                                  style: const TextStyle(
                                                    fontSize: 12,
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
                  argList.clear();
                  _isValid = false;
                  argList = List.generate(argCount, (index) => '');
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              buttonStatus == false
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.black,
                      ),
                      onPressed: () async {
                        if (_isValid == false && argList.isNotEmpty) {
                          Common.toastMessaage(
                              "Arguments canot be empty", Colors.red);
                        } else {
                          if (mounted) {
                            setState(() {
                              buttonStatus = true;
                            });
                          }
                          if (templateContentModel!.data.format == 'TEXT' ||
                              templateContentModel!.data.format == '' &&
                                  templateSelected == true) {
                            await sendingTemplateMessage(false, 'normal');
                          } else {
                            await sendingTemplateMessage(
                                true,
                                isFilemanager == true
                                    ? 'file_manager'
                                    : 'normal');
                          }
                          if (mounted) {
                            setState(() {
                              buttonStatus = false;
                            });
                          }
                        }
                      },
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          color: ColorConstant.white,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstant.black,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Sending...',
                        style: TextStyle(color: ColorConstant.white),
                      ),
                    ),
            ],
          );
        });
      },
    );
  }

  pickTemplateImage(BuildContext context, ImageSource source) async {
    final image1 =
        await ImagePicker().pickImage(source: source, imageQuality: 80);

    try {
      if (image1 != null) {
        setState(() {
          templateImage = image1.path;
        });
        print('Template Image Path after setState: $templateImage');
      }
    } catch (e) {
      // log(e.toString());
      // Get.snackbar('Permission Denied',
      //     'Please grant access to the gallery to pick an image.');
    }
  }

  pickTemplateVideo(context, source) async {
    final pickedFile = await ImagePicker().pickVideo(source: source);

    if (pickedFile != null) {
      setState(() {
        video = File(pickedFile.path);
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
    } on PlatformException {
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
      }
      return list;
    } else {
      final List<XFile> images = await ImagePicker().pickMultiImage();
      if (images.isNotEmpty) {
        list.addAll(images);
      }
      return list;
    }
  }

  getTemplates() async {
    setState(() {
      templateLoading = true;
    });
    templateModel = await HttpService.getTemplate();
    if (templateModel != null) {
      isLoading = false;
      setState(() {
        templateLoading = false;
      });
    }
  }

  getTemplateContents(templateId) async {
    templateContentModel = await HttpService.getTemplateContent(templateId);
    if (templateContentModel != null) {
      argCount = templateContentModel!.data.paramCount;
      argList = List.generate(argCount, (index) => '');
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
      } else if (templateContentModel!.data.format == 'DOCUMENT') {
        setState(() {
          dropDownHeight = 470;
          templateSelected = true;
        });
      } else {
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

  sendingTemplateMessage(isFile, type) async {
    sendTemplateMessageModel = await HttpService.sendTemplateMessage(
        widget.groupId,
        templateContentModel!.data.format,
        selectTemplate,
        templateContentModel!.data.language,
        selectedTemp,
        templateImage,
        isFile,
        type,
        argList);
    if (sendTemplateMessageModel != null &&
        sendTemplateMessageModel!.status == true) {
      page = 1;
      add = 1;
      items.clear();
      await getchat(widget.groupId);
      if (mounted) {
        Navigator.pop(context);
        Common.toastMessaage(sendTemplateMessageModel!.message, Colors.green);

        setState(() {
          selectTemplate = "";
          selectedTemp = "";
          templateImage = "";
        });
      }
      argList.clear();
      _isValid = false;
      argList = List.generate(argCount, (index) => '');
    } else {
      Common.toastMessaage("Something went wrong", Colors.red);
    }
  }

  Widget buildLoaderListItem() {
    return Shimmer.fromColors(
        enabled: true,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child: ListView.builder(
                      itemCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 250.0,
                                    height: 150.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 250.0,
                                    height: 115.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ));
  }

  Widget scrollShimmer(int i) {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.only(bottom: i == 0 ? 90.0 : 0),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 250.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 250.0,
                  height: 115.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 250.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 250.0,
                  height: 115.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> launchGoogleMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch Google Maps.';
    }
  }

  void scrollToFirstIndex() {
    itemScrollController.jumpTo(
        index: 0, alignment: 0.1); // Jump to position 0.0 (first item)
  }

  Future<dynamic> selectDocument(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Select Source'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () async {
                    // Get.back();
                    await pickTemplateImage(context, ImageSource.camera);
                    dropDownHeight = 510;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Camera"),
                ),
                TextButton(
                  onPressed: () async {
                    // Get.back();
                    await pickTemplateImage(context, ImageSource.gallery);
                    dropDownHeight = 510;
                    isFilemanager = false;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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
  }

  Future<dynamic> selectImage(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Select Source'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () async {
                    await pickTemplateImage(context, ImageSource.camera);
                    dropDownHeight = 510;
                    isFilemanager = false;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Camera"),
                ),
                TextButton(
                  onPressed: () async {
                    // Get.back();
                    await pickTemplateImage(context, ImageSource.gallery);
                    dropDownHeight = 510;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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
  }

  Future<dynamic> selectVideo(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Select Source'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () async {
                    await pickTemplateImage(context, ImageSource.camera);
                    dropDownHeight = 510;
                    isFilemanager = false;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Camera"),
                ),
                TextButton(
                  onPressed: () async {
                    // Get.back();
                    await pickTemplateImage(context, ImageSource.gallery);
                    dropDownHeight = 510;
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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
  }
}
