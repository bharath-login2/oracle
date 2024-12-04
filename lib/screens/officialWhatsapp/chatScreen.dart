// ignore_for_file: file_names, use_build_context_synchronously

// import 'dart:developer';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/officialWhatsapp/socket_chat_model.dart';
import 'package:login2/screens/leadManagement/dashboard.dart';
import 'package:login2/screens/officialWhatsapp/chat_home_screen.dart';
import 'package:login2/screens/officialWhatsapp/view_Items.dart';
import 'package:login2/screens/officialWhatsapp/viewerScreen.dart';
import 'package:login2/screens/officialWhatsapp/whatsapp_profile.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
// import 'package:socket_io_client/socket_io_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/officialWhatsapp/mediaModel.dart';
import '../../models/officialWhatsapp/official_message_model.dart';
import '../../models/officialWhatsapp/sendMesaageModel.dart';
import '../../models/officialWhatsapp/sendTemplateMesaageModel.dart';
import '../../models/officialWhatsapp/template_content_model.dart';
import '../../models/officialWhatsapp/templateModel.dart';
import '../../service/service.dart';
import 'colorConst.dart';
import 'components/imageHelper.dart';
import 'imageViewScreen.dart';
import 'listFileManager.dart';
// import 'package:web_socket_channel/status.dart' as status;

// const String _serverUrl = 'wss://websocket.login2.co.in:8080';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.groupId,
    required this.nav,
  }) : super(key: key);

  final String groupId;
  final String nav;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List list = [];
  final imageHelper = ImageHelper();
  final messageController = TextEditingController();
  final argumentController = <TextEditingController>[];

  // Socket? socket;

  void onTextChanged(String value, int index) {
    int newIntex = index - 1;
    argList[newIntex] = value;
    _handleArgChange(value, index);
  }

  List<ChatMessage> items = [];
  List argList = [];
  int page = 1;
  int pageSize = 30;
  String? userImage;
  OfficialMessageModel? officialMessageModel;
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
  bool _isValid = false;
  late final WebSocketChannel socket;

  @override
  void initState() {
    // messageListner();
    getchat(widget.groupId);
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    getTemplates();
    socketStream();
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    socket.sink.close();
    super.dispose();
  }

  void _handleArgChange(String value, int index) {
    setState(() {
      argList[index] = value;
      _isValid =
          argList.every((element) => element.isNotEmpty); // Check all elements
    });
  }

  socketStream() async {
    final String userId = await Common.getSharedPref("userId");
    // log("userId: $userId");
    final wsProtocol =
        (Uri.parse('https://dummy').scheme == 'https') ? 'wss://' : 'ws://';
    const wsHost = 'websocket.login2.co.in';
    const wsPort = '8080';

    socket = WebSocketChannel.connect(
      Uri.parse('$wsProtocol$wsHost:$wsPort'),
    );
    socket.sink.add(jsonEncode({'type': 'register', 'userId': "#$userId"}));
    socket.stream.listen((response) async {
      try {
        // log("response :$response");
        WebsocketResponseModel res =
            WebsocketResponseModel.fromJson(jsonDecode(response));
        // log("res :$res");
        final value = trimString(res.fromUser);
        if (value == widget.groupId) {
          log("socket success $value");
          await Future.delayed(const Duration(seconds: 5));
          getSocketMerssages();
        }
      } catch (e) {
        log(e.toString());
      }
    });
  }

  // void _sendMessage() {
  //   try {
  //     socket.sink.add("Ansar-login2");
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }

  void _onLoadMore() {
    if (items.length + 30 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      getchat(widget.groupId);
      add++;
    }
  }

  getchat(groupId) async {
    officialMessageModel =
        await HttpService.officialMessage(groupId, page, pageSize);
    if (officialMessageModel != null) {
      setState(() {
        items.addAll(officialMessageModel!.messages);
        page++;
      });
    }
  }

  getSocketMerssages() async {
    try {
      final socketMessage = await HttpService.socketChat(widget.groupId);
      if (socketMessage != null) {
        // log(socketMessage!["messages"].toString());
        FlutterRingtonePlayer().playNotification();
        final List<dynamic> messagesJson = socketMessage['messages'];
        final List<ChatMessage> newMessages =
            messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
        setState(() {
          items.insertAll(0, newMessages);
        });
      }
    } catch (e) {
      log(e.toString());
    }
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
        } else if (widget.nav == "Notification") {
          Navigator.pop(context);
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatHomeScreen(),
              ));
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatHomeScreen(),
                                  ));
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
                                    number: officialMessageModel!.phoneNumber,
                                    profilePic:
                                        officialMessageModel!.profilePhoto,
                                    createdBy: officialMessageModel!.createdBy,
                                    createdDate: officialMessageModel!
                                        .createdTime
                                        .toString(),
                                    groupId: officialMessageModel!.groupId,
                                  ),
                                )).then((v) {
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
                                          officialMessageModel!.profilePhoto)),
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
                  // getSocketMerssage();
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
                  child: officialMessageModel!.canSend == true
                      ? SizedBox(
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
                                      if (messageController.text != "") {
                                        isTyped = true;
                                      } else {
                                        isTyped = false;
                                      }
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
                                      suffixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                attachDialog(context);
                                              },
                                              child: const Icon(
                                                Icons.attach_file,
                                                color: ColorConstant.grey,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      scrollable: true,
                                                      title: const Text(
                                                          'Select Source'),
                                                      content: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              await pickedImage(
                                                                  context,
                                                                  ImageSource
                                                                      .camera);
                                                              if (userImage ==
                                                                  null) {
                                                              } else {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              ImageViewScreen(
                                                                        image:
                                                                            userImage,
                                                                        val:
                                                                            '1',
                                                                        groupId:
                                                                            widget.groupId,
                                                                      ),
                                                                    )).then((t) {
                                                                  page = 1;
                                                                  add = 1;
                                                                  items.clear();
                                                                  getchat(widget
                                                                      .groupId);
                                                                });
                                                              }
                                                            },
                                                            child: const Text(
                                                                "Camera"),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              await pickedImage(
                                                                  context,
                                                                  ImageSource
                                                                      .gallery);
                                                              if (userImage ==
                                                                  null) {
                                                              } else {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              ImageViewScreen(
                                                                        image:
                                                                            userImage,
                                                                        val:
                                                                            '1',
                                                                        groupId:
                                                                            widget.groupId,
                                                                      ),
                                                                    )).then((t) {
                                                                  page = 1;
                                                                  add = 1;
                                                                  items.clear();
                                                                  getchat(widget
                                                                      .groupId);
                                                                });
                                                              }
                                                            },
                                                            child: const Text(
                                                                "Gallery"),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                                "Cancel"),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: const Icon(
                                                Icons.camera_alt,
                                                color: ColorConstant.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Visibility(
                                visible: isTyped == true,
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: ColorConstant.barGreen,
                                  child: buttonStatus != true
                                      ? IconButton(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          onPressed: () async {
                                            if (list.isNotEmpty) {
                                              isImage = true;
                                            }
                                            await sendingMessage(
                                                widget.groupId,
                                                messageController.text,
                                                list,
                                                isImage);
                                            messageController.clear();
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.send))
                                      : const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
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

  Future<Object?> attachDialog(BuildContext context) {
    return showGeneralDialog(
      barrierLabel: "showGeneralDialog",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      context: context,
      pageBuilder: (context, _, __) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Align(
                alignment: Alignment.bottomCenter,
                child: IntrinsicHeight(
                  child: Container(
                    width: double.maxFinite,
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Material(
                        color: Colors.white,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ListFileManager(
                                              'document', widget.groupId),
                                        ),
                                      ).then((r) {
                                        page = 1;
                                        add = 1;
                                        items.clear();
                                        getchat(widget.groupId);
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40.0,
                                          width: 40.0,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/icons/doc.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: const Center(
                                            child: Text(
                                              'Docs',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ListFileManager(
                                              'video', widget.groupId),
                                        ),
                                      ).then((r) {
                                        page = 1;
                                        add = 1;
                                        items.clear();
                                        getchat(widget.groupId);
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40.0,
                                          width: 40.0,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/icons/mp4.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: const Center(
                                            child: Text(
                                              'Video',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ListFileManager(
                                              'image', widget.groupId),
                                        ),
                                      ).then((r) {
                                        page = 1;
                                        add = 1;
                                        items.clear();
                                        getchat(widget.groupId);
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40.0,
                                          width: 40.0,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/icons/picture.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: const Center(
                                            child: Text(
                                              'Gallery',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ListFileManager(
                                              'audio', widget.groupId),
                                        ),
                                      ).then((r) {
                                        page = 1;
                                        add = 1;
                                        items.clear();
                                        getchat(widget.groupId);
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40.0,
                                          width: 40.0,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/icons/audio.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: const Center(
                                            child: Text(
                                              'Audio',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      templateDialog(context);
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40.0,
                                          width: 40.0,
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/icons/template.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 3,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          child: const Center(
                                            child: Text(
                                              'Template',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )),
                  ),
                ));
          },
        );
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
  }

  Align chatWidget1(int index, BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Column(
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
                double latitude =
                    double.parse(items[index].messageText.latitude.toString());
                double longitude =
                    double.parse(items[index].messageText.longitude.toString());
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
                                        type: items[index].messageText.format,
                                        title: items[index].messageText.format,
                                      ),
                                    ));
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Container(
                                    height: MediaQuery.of(context).size.height *
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
                                        left: 4, right: 4, bottom: 5, top: 4),
                                    //height: MediaQuery.of(context).size.height * 0.38,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                        color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        FutureBuilder(
                                          future: _initializeVideoPlayerFuture,
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
                                                          BorderRadius.circular(
                                                              8),
                                                      child: VideoPlayer(
                                                          _controller!),
                                                    ),
                                                    const Center(
                                                      child: Icon(
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
                              : items[index].messageText.format == 'DOCUMENT'
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey.withOpacity(0.2)),
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
                                                decoration: const BoxDecoration(
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
                                  : items[index].messageText.format == 'TEXT'
                                      ? items[index].messageText.url == ''
                                          ? const SizedBox()
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Text(
                                                items[index].messageText.url,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
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
                                    items[index].messageText.messageBody != "",
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
                              padding: const EdgeInsets.only(top: 5, bottom: 3),
                              child: Text(
                                items[index].messageText.footer,
                                style: const TextStyle(
                                    fontSize: 12, color: ColorConstant.grey),
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            items[index].sentTime,
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
                                              color: ColorConstant.messageSeen,
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                                physics: const NeverScrollableScrollPhysics(),
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
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
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
                                                fontWeight: FontWeight.bold),
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
  }

  Align chatWidget2(int index, BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
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
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    children: [
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .09,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .18,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            image: DecorationImage(
                                                image: NetworkImage(items[index]
                                                    .messageText
                                                    .url)),
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(8),
                                              topLeft: Radius.circular(8),
                                            )),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              items[index]
                                                  .messageText
                                                  .headerText,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              items[index]
                                                  .messageText
                                                  .headerSubText,
                                              overflow: TextOverflow.ellipsis,
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
                              : items[index].messageText.format == 'DOCUMENT'
                                  ? Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey.withOpacity(0.2)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 8, bottom: 8, left: 4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 70,
                                                width: 40,
                                                decoration: const BoxDecoration(
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
                                              color:
                                                  items[index].fromMe == false
                                                      ? Colors.grey.shade200
                                                      : ColorConstant
                                                          .greenChatlight,
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
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(8),
                                                      topLeft:
                                                          Radius.circular(8),
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
                                                child: const Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Header",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      "2 items",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight
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
                                                fontWeight: FontWeight.bold),
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
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                              Text(
                                                "Completed",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    color:
                                                        ColorConstant.barGreen,
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
                                      items[index].messageText.messageBody == ""
                                          ? const SizedBox()
                                          : Text(
                                              items[index]
                                                  .messageText
                                                  .messageBody,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                      items[index].messageText.footer == ""
                                          ? const SizedBox()
                                          : Text(
                                              items[index].messageText.footer,
                                              overflow: TextOverflow.ellipsis,
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
                              items[index].sentTime,
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items[index].messageText.buttons.length,
                          itemBuilder: (context, i) {
                            return Column(
                              children: [
                                const Divider(),
                                GestureDetector(
                                  onTap: () {
                                    if (items[index]
                                            .messageText
                                            .buttons[i]
                                            .text ==
                                        "Product List") {
                                      selectOptionBottomSheet(
                                          items[index]
                                              .messageText
                                              .buttons[i]
                                              .text,
                                          items[index]
                                              .messageText
                                              .buttons[i]
                                              .data);
                                    }
                                    if (items[index]
                                            .messageText
                                            .buttons[i]
                                            .text ==
                                        "View items") {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewItems(
                                              title: items[index]
                                                  .messageText
                                                  .buttons[i]
                                                  .text,
                                              data: items[index]
                                                  .messageText
                                                  .buttons[i]
                                                  .data,
                                              i: items[index].toString(),
                                            ),
                                          ));
                                    }
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(),
                                    child: Center(
                                        child: Text(
                                      items[index].messageText.buttons[i].text,
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
                    const SizedBox(
                      height: 15,
                    ),
                    templateLoading == true
                        ? const Center(child: LinearProgressIndicator())
                        : Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
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
                        if (templateSelected) {
                          if (_isValid == false && argList.isNotEmpty) {
                            Common.toastMessaage(
                                "Arguments canot be empty", Colors.red);
                          } else {
                            templateConfirm(context).then((_) {
                              setState(() {});
                            });
                          }
                        } else {
                          Common.toastMessaage(
                              "Select a template ", Colors.red);
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

  Future<dynamic> templateConfirm(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            scrollable: true,
            title: const Text('Send Template !'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Cancel"),
                ),
                const SizedBox(
                  width: 5,
                ),
                buttonStatus == false
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white),
                        onPressed: () async {
                          if (mounted) {
                            Navigator.pop(context);
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
                        },
                        child: const Text("Confirm"),
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
            ),
          );
        });
      },
    );
  }

  Future<dynamic> selectImage(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
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
      Common.toastMessaage(sendTemplateMessageModel!.message, Colors.red);
    }
    if (mounted) {
      setState(() {
        buttonStatus = false;
      });
    }
  }

  sendingMessage(groupId, messageData, fileName, isImage) async {
    setState(() {
      buttonStatus = true;
    });
    sendMessageModel =
        await HttpService.sendMessage(groupId, messageData, fileName, isImage);
    if (sendMessageModel != null && sendMessageModel!.status == true) {
      page = 1;
      add = 1;
      items.clear();
      await getchat(groupId);
      setState(() {
        buttonStatus = false;
      });
    }
  }

  viewCartBottomSheet(String title, String rowId) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close)),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .22,
                      ),
                      const Text(
                        "Your sent cart",
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 20,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsetsDirectional.zero,
                            leading: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            title: const Text(
                              "Web Development",
                              style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text("Quantity 1"),
                            trailing: const Text("₹ 10000.00"),
                          ),
                          const Divider(),
                          const ListTile(
                            contentPadding: EdgeInsetsDirectional.zero,
                            title: Text(
                              "Estimated Total",
                              style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("February,25,2024, 12:30pm"),
                            trailing: Text(
                              "₹ 10000.00",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontStyle: FontStyle.normal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  selectOptionBottomSheet(String title, List list) {
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close)),
                      Text(
                        title,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 25,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            list[index].sectionName,
                            style: const TextStyle(
                                color: Colors.teal,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: list[index].options.length,
                            itemBuilder: (context, i) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      list[index].options[i].productName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
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
        padding: EdgeInsets.only(bottom: i == 0 ? 80.0 : 0),
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

  trimString(String value) {
    if (value.startsWith('#')) {
      return value.substring(1);
    }
  }
}
