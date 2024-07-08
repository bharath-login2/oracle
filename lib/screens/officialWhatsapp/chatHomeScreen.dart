import 'package:flutter/material.dart';
import '../../core/common.dart';
import '../../models/officialWhatsapp/ChatListModel.dart';
import '../../models/officialWhatsapp/campaignsListModel.dart';
import '../../models/officialWhatsapp/officialWhatsappConfigureModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';
import '../settings/whatsappSettings.dart';
import 'addContact.dart';
import 'clientListScreen.dart';
import 'colorConst.dart';
import 'components/tab_bar.dart';
import 'components/tab_bar_view.dart';

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

  TextEditingController nameTextController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController numberTextController = TextEditingController();
  ChatListModel? chatListModel;
  CampaignsListModel? campaignsListModel;
  OfficialWhatsappConfigeModel? officialWhatsAppConfigure;

  String token = '';

  @override
  void initState() {
    chats('');
    chatCampaignsList('');
    getOfficialConfigaration();
    super.initState();
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
                                            height: 70,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 12,
                                                  right: 12,
                                                  top: 8,
                                                  bottom: 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                ClientListScreen(),
                                                          ));
                                                    },
                                                    child: isSearch == true
                                                        ? SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.7,
                                                            child:
                                                                TextFormField(
                                                              autofocus: true,
                                                              controller:
                                                                  searchController,
                                                              onChanged:
                                                                  (value) {
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
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            isSearch =
                                                                !isSearch;
                                                          });
                                                        },
                                                      ),
                                                      // const SizedBox(
                                                      //   width: 8,
                                                      // ),
                                                      // GestureDetector(
                                                      //   onTap: () {},
                                                      //   child: const Icon(
                                                      //     Icons.more_vert,
                                                      //     color: Colors.white,
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          tabbar(),
                                          tabbarView(chatListModel,
                                              campaignsListModel),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator()))
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
              : const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.grey,)),)),
    );
  }

  chats(search) async {
    chatListModel = await HttpService.fetchChatList(search);
    if (chatListModel != null) {
      setState(() {});
    }
  }

  chatCampaignsList(search) async {
    campaignsListModel = await HttpService.fetchCampaignsList(search);
    if (campaignsListModel != null) {
      setState(() {});
    }
  }
}
