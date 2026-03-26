import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:login2/screens/leadManagement/dashboardLeadsNewUpdated2.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/officialWhatsapp/campaignsChatScreen.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import 'package:login2/screens/officialWhatsapp/components/campaignsBubble.dart';
import 'package:login2/screens/officialWhatsapp/components/chat_list_item.dart';
import 'package:login2/screens/officialWhatsapp/contact_list.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/common.dart';
import '../../models/officialWhatsapp/chat_list_model.dart';
import '../../models/officialWhatsapp/campaignsListModel.dart';
import '../../models/officialWhatsapp/officialWhatsappConfigureModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';
import 'colorConst.dart';
import 'components/tab_bar.dart';

// ignore: must_be_immutable
class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  bool isSearch = false;
  String whatsAppConfigured = "true";
  late final WebSocketChannel socket;
  String? contactPermission = '';

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<ChatData> items = [];
  int page = 1;
  int pageSize = 20;
  TextEditingController searchController = TextEditingController();
  ChatListModel? chatListModel;
  CampaignsListModel? campaignsListModel;
  OfficialWhatsappConfigeModel? officialWhatsAppConfigure;
  String userId = "";
  String token = '';
  String ProjectDashboardPermission = '';
  String LeadDashboard = '';
  int add = 1;
  bool isConfigered = true;

  @override
  void initState() {
    _initChatData();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    chatCampaignsList('');
    getOfficialConfigaration();
    socketStream();
    super.initState();
  }

  void _initChatData() {
    chats('', reset: true);
  }

  @override
  void dispose() {
    socket.sink.close();
    super.dispose();
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      chats('');
      add++;
    }
  }

  socketStream() async {
    userId = await Common.getSharedPref("userId");
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
        log("socket success");
        if (searchController.text.isNotEmpty) return;
        await Future.delayed(const Duration(seconds: 3));

        var res = await HttpService.fetchChatList("", 1, pageSize);
        if (res != null && mounted) {
          setState(() {
            var newItems = res.data;
            var mergedItems = <ChatData>[];
            mergedItems.addAll(newItems);
            for (var item in items) {
              if (!newItems.any((newItem) => newItem.groupId == item.groupId)) {
                mergedItems.add(item);
              }
            }
            items = mergedItems;
          });
          Common.saveSharedPref(
              "chatList", jsonEncode(items.map((i) => i.toJson()).toList()));
        }
      } catch (e) {
        log(e.toString());
      }
    });
  }

  getOfficialConfigaration() async {
    officialWhatsAppConfigure = await HttpService.officialWhatsAppConfigure();
    if (officialWhatsAppConfigure != null) {
      isConfigered = officialWhatsAppConfigure!.data!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (pop) async {
        token = await Common.getSharedPref("token");
        ProjectDashboardPermission =
            await Common.getSharedPref("ProjectDashboardPermission");
        LeadDashboard = await Common.getSharedPref("LeadDashboard");
        if (context.mounted) {
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => Dashboard(token),
          //     ));
          ProjectDashboardPermission == "true"
              ? Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectDashboard()),
                )
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DashboardLeadNewUpdatedTwo(token)),
                );
        }
      },
      child: SafeArea(
          child: DefaultTabController(
              length: 2,
              child: Scaffold(
                  key: scaffoldKey,
                  floatingActionButton: Visibility(
                    visible: isConfigered,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WhatsappContactList(),
                            ));
                      },
                      backgroundColor: ColorConstant.barGreen,
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  backgroundColor: Colors.grey.shade100,
                  body: Container(
                    color: Colors.white,
                    child: SafeArea(
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  color: ColorConstant.barGreen),
                              padding: const EdgeInsets.only(right: 10),
                              height: 60,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //       builder: (context) =>
                                        //           ClientListScreen(),
                                        //     )).then((v){
                                        //       page = 1;
                                        //           add = 1;
                                        //           items.clear();
                                        //           chats(
                                        //               searchController
                                        //                   .text);
                                        //           setState(() {});
                                        //     });
                                      },
                                      child: isSearch == true
                                          ? SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.75,
                                              child: TextFormField(
                                                autofocus: true,
                                                controller: searchController,
                                                onChanged: (value) async {
                                                  chats(value, reset: true);
                                                },
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          top: 5, bottom: 5),
                                                  prefixIcon:
                                                      const Icon(Icons.search),
                                                  hintText: 'Search',
                                                  fillColor:
                                                      ColorConstant.white,
                                                  filled: true,
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Row(
                                              children: [
                                                InkWell(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Icon(
                                                      Icons.arrow_back,
                                                      color: Colors.white,
                                                    )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                RichText(
                                                  text: const TextSpan(
                                                    text: 'WhatsApp',
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSearch = !isSearch;
                                        });
                                      },
                                      child: const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            tabbar(),
                            isConfigered
                                ? Expanded(
                                    child: TabBarView(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: RefreshIndicator(
                                              onRefresh: () async {
                                                chats("", reset: true);
                                              },
                                              child: whatsAppConfigured ==
                                                      "true"
                                                  ? ScrollablePositionedList
                                                      .builder(
                                                      initialScrollIndex: 0,
                                                      itemScrollController:
                                                          itemScrollController,
                                                      itemPositionsListener:
                                                          itemPositionsListener,
                                                      itemCount: items.length +
                                                          (items.length + 20 ==
                                                                  page *
                                                                      pageSize
                                                              ? 1
                                                              : 0),
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index ==
                                                            items.length) {
                                                          // When reaching the end of the list, show a loader
                                                          return scrollShimmer();
                                                        }
                                                        return GestureDetector(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ChatScreen(
                                                                    groupId: items[
                                                                            index]
                                                                        .groupId,
                                                                    nav: "",
                                                                    // chatType: items[
                                                                    //         index]
                                                                    //     .chatType,
                                                                  ),
                                                                )).then((v) async {
                                                              try {
                                                                userId = await Common
                                                                    .getSharedPref(
                                                                        "userId");
                                                                socket.sink.add(
                                                                    jsonEncode({
                                                                  'type':
                                                                      'register',
                                                                  'userId':
                                                                      "#$userId"
                                                                }));
                                                              } catch (e) {
                                                                log(e
                                                                    .toString());
                                                              }
                                                            });
                                                          },
                                                          child: chatListItem(
                                                              context,
                                                              items[index]),
                                                        );
                                                      },
                                                    )
                                                  : Center(
                                                      child: SizedBox(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.5,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            SizedBox(
                                                              child:
                                                                  Image.asset(
                                                                "assets/icons/nodatafound.png",
                                                              ),
                                                            ),
                                                            const Text(
                                                              "",
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: StatefulBuilder(
                                              builder: (context, setState) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: RefreshIndicator(
                                                onRefresh: () async {
                                                  await Future.delayed(
                                                      const Duration(
                                                          milliseconds: 200));
                                                  CampaignsListModel?
                                                      campaignsListModel =
                                                      await HttpService
                                                          .fetchCampaignsList(
                                                              '');
                                                  if (campaignsListModel !=
                                                      null) {
                                                    setState(() {});
                                                  }
                                                },
                                                child: ListView.builder(
                                                  physics:
                                                      const BouncingScrollPhysics(),
                                                  itemCount: campaignsListModel!
                                                      .data!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CampaignsChatScreen(
                                                                  groupId: campaignsListModel!
                                                                      .data![
                                                                          index]
                                                                      .groupId
                                                                      .toString(),
                                                                  nav: '',
                                                                ),
                                                              )).then((v) {
                                                            // Do not reload the list here to preserve scrolling position
                                                          });
                                                        },
                                                        child: campaignsBubble(
                                                            context,
                                                            campaignsListModel!
                                                                .data![index]));
                                                  },
                                                ),
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            height: 100,
                                            child: Image.asset(
                                              "assets/icons/official_whatsapp.png",
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text(
                                            "Configure whatsapp !",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          // InkWell(
                                          //   onTap: () {
                                          //     Navigator.pop(context);
                                          //   },
                                          //   child: Container(
                                          //     width: MediaQuery.of(context).size.width * 0.4,
                                          //     height: 40,
                                          //     decoration: BoxDecoration(
                                          //       color: Colors.black,
                                          //       borderRadius: BorderRadius.circular(10),
                                          //     ),
                                          //     child: const Center(
                                          //       child: Text('Go Back',
                                          //           style: TextStyle(
                                          //               fontSize: 15,
                                          //               color: Colors.white,
                                          //               fontWeight: FontWeight.w500)),
                                          //     ),
                                          //   ),
                                          // )
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  )))),
    );
  }

  oldChat() async {
    try {
      final jsonString = await Common.getSharedPref("chatList") ?? "";
      if (jsonString.isNotEmpty) {
        final decodeList = jsonDecode(jsonString);
        final List<Map<String, dynamic>> chatDataList =
            decodeList.cast<Map<String, dynamic>>();
        final List<ChatData> jsonList =
            chatDataList.map((json) => ChatData.fromJson(json)).toList();
        if (mounted) {
          setState(() {
            items.addAll(jsonList);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }

  chats(search, {bool reset = false}) async {
    if (reset) {
      page = 1;
      add = 1;
      items.clear();
      setState(() {
        isLoading = true;
      });
    }
    chatListModel = await HttpService.fetchChatList(search, page, pageSize);
    if (chatListModel != null && mounted) {
      setState(() {
        if (page == 1 && items.isNotEmpty) {
          var newItems = chatListModel!.data;
          var mergedItems = <ChatData>[];
          mergedItems.addAll(newItems);
          for (var item in items) {
            if (!newItems.any((newItem) => newItem.groupId == item.groupId)) {
              mergedItems.add(item);
            }
          }
          items = mergedItems;
        } else {
          items.addAll(chatListModel!.data);
        }
        page++;
        isLoading = false;
      });
      final itemsString =
          jsonEncode(items.map((item) => item.toJson()).toList());
      Common.saveSharedPref("chatList", itemsString);
    }
    whatsAppConfigured = await Common.getSharedPref("whatsapp") ?? "true";
  }

  chatCampaignsList(search) async {
    campaignsListModel = await HttpService.fetchCampaignsList(search);
    if (campaignsListModel != null) {
      setState(() {});
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 120.0,
                    color: Colors.white,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child: ListView.builder(
                      itemCount: 10,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: 10.0,
                                      color: Colors.white,
                                      margin:
                                          const EdgeInsets.only(bottom: 8.0),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 10.0,
                                      color: Colors.white,
                                      margin:
                                          const EdgeInsets.only(bottom: 8.0),
                                    ),
                                    Container(
                                      width: 100.0,
                                      height: 10.0,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ));
  }

  Widget scrollShimmer() {
    return Shimmer.fromColors(
        enabled: true,
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: double.infinity,
                          height: 10.0,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 8.0),
                        ),
                        Container(
                          width: 100.0,
                          height: 10.0,
                          color: Colors.white,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ));
  }
}
