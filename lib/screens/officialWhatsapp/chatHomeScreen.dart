import 'package:flutter/material.dart';
import 'package:login2/screens/officialWhatsapp/campaignsChatScreen.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import 'package:login2/screens/officialWhatsapp/components/campaignsBubble.dart';
import 'package:login2/screens/officialWhatsapp/components/chat_list_item.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/common.dart';
import '../../models/officialWhatsapp/ChatListModel.dart';
import '../../models/officialWhatsapp/campaignsListModel.dart';
import '../../models/officialWhatsapp/officialWhatsappConfigureModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';
import '../settings/whatsappSettings.dart';
import 'add_contact.dart';
import 'colorConst.dart';
import 'components/tab_bar.dart';

// ignore: must_be_immutable
class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({Key? key}) : super(key: key);

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  bool isSearch = false;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<ChatData> items = [];
  int page = 1;
  int pageSize = 20;
  TextEditingController nameTextController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController numberTextController = TextEditingController();
  ChatListModel? chatListModel;
  CampaignsListModel? campaignsListModel;
  OfficialWhatsappConfigeModel? officialWhatsAppConfigure;

  String token = '';
  int add = 1;

  @override
  void initState() {
    chats('');
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    chatCampaignsList('');
    getOfficialConfigaration();
    super.initState();
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      chats('');
      add++;
    }
  }

  getOfficialConfigaration() async {
    officialWhatsAppConfigure = await HttpService.officialWhatsAppConfigure();
    if (officialWhatsAppConfigure != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        token = await Common.getSharedPref("token");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(token),
            ));
        return true;
      },
      child: SafeArea(
          child: officialWhatsAppConfigure != null
              ? DefaultTabController(
                  length: 2,
                  child: officialWhatsAppConfigure!.data == true
                      ? Scaffold(
                          key: scaffoldKey,
                          floatingActionButton: FloatingActionButton(
                            onPressed: () {
                              addContactPopUp(context, nameTextController,
                                  numberTextController);
                              // // print(auth.currentUser!.uid);
                              // Get.to(() => const ComposeScreen(),
                              //     transition: Transition.downToUp);
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(),));
                            },
                            backgroundColor: ColorConstant.barGreen,
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.grey.shade100,
                          body: chatListModel != null &&
                                  campaignsListModel != null
                              ? Container(
                                  color: Colors.white,
                                  child: SafeArea(
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                                color: ColorConstant.barGreen),
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            height: 60,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 12,
                                                right: 12,
                                                top: 12,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.75,
                                                            child:
                                                                TextFormField(
                                                              autofocus: true,
                                                              controller:
                                                                  searchController,
                                                              onChanged:
                                                                  (value) {
                                                                page = 1;
                                                                add = 1;
                                                                items.clear();
                                                                chats(
                                                                    searchController
                                                                        .text);
                                                                setState(() {});
                                                              },
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top: 5,
                                                                        bottom:
                                                                            5),
                                                                prefixIcon:
                                                                    const Icon(Icons
                                                                        .search),
                                                                hintText:
                                                                    'Search',
                                                                fillColor:
                                                                    ColorConstant
                                                                        .white,
                                                                filled: true,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : RichText(
                                                            text:
                                                                const TextSpan(
                                                              text: 'WhatsApp',
                                                              style: TextStyle(
                                                                fontSize: 22,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
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
                                          Expanded(
                                            child: TabBarView(
                                              children: [
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 5),
                                                    child: RefreshIndicator(
                                                      onRefresh: () async {
                                                        page = 1;
                                                        add = 1;
                                                        items.clear();
                                                        chats("");
                                                      },
                                                      child:
                                                          ScrollablePositionedList
                                                              .builder(
                                                        initialScrollIndex: 0,
                                                        itemScrollController:
                                                            itemScrollController,
                                                        itemPositionsListener:
                                                            itemPositionsListener,
                                                        itemCount: items
                                                                .length +
                                                            (items.length +
                                                                        20 ==
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
                                                                    ),
                                                                  )).then((v) {
                                                                page = 1;
                                                                add = 1;
                                                                items.clear();
                                                                chats("");
                                                              });
                                                            },
                                                            child: chatListItem(
                                                                context,
                                                                items[index]),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                  ),
                                                  child: StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child: RefreshIndicator(
                                                        onRefresh: () async {
                                                          await Future.delayed(
                                                              const Duration(
                                                                  milliseconds:
                                                                      200));
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
                                                          itemCount:
                                                              campaignsListModel!
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
                                                                              .data![index]
                                                                              .groupId
                                                                              .toString(),
                                                                          nav:
                                                                              '',
                                                                        ),
                                                                      )).then((v) {
                                                                    chatCampaignsList(
                                                                        '');
                                                                  });
                                                                },
                                                                child: campaignsBubble(
                                                                    context,
                                                                    campaignsListModel!
                                                                            .data![
                                                                        index]));
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : buildLoaderListItem())
                      : Scaffold(
                          body: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.1),
                                    child: Card(
                                      // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      // Set the clip behavior of the card
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      // Define the child widgets of the card
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
                                          Image.asset(
                                            'assets/main/packageimage.png',
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          // Add a container with padding that contains the card's title, text, and buttons
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 15, 15, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                const Text(
                                                  'Configuration Failed',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.red,
                                                  ),
                                                ),

                                                // Add a row with two buttons spaced apart and aligned to the right side of the card
                                                Row(
                                                  children: <Widget>[
                                                    // Add a spacer to push the buttons to the right side of the card
                                                    const Spacer(),
                                                    // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text

                                                    // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                                                    TextButton(
                                                      child: const Text(
                                                        "Settings",
                                                      ),
                                                      onPressed: () async {
                                                        String token =
                                                            await Common
                                                                .getSharedPref(
                                                                    "token");
                                                        if (mounted) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    WhatsappSettings(
                                                                        token)),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Add a small space between the card and the next widget
                                          Container(height: 5),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
              : Scaffold(
                  body: buildLoaderListItem(),
                )),
    );
  }

  chats(search) async {
    chatListModel = await HttpService.fetchChatList(search, page, pageSize);
    if (chatListModel != null) {
      setState(() {
        items.addAll(chatListModel!.data);
        page++;
        isLoading = false;
      });
    }
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
