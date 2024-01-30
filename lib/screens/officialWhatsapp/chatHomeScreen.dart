import 'package:flutter/material.dart';
import 'package:login2/screens/homePage.dart';
import '../../core/common.dart';
import '../../models/officialWhatsapp/ChatListModel.dart';
import '../../models/officialWhatsapp/campaignsListModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';
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
  String token='';

  @override
  void initState() {
    chats('');
    chatCampaignsList('');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        token=await Common.getSharedPref("token");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Dashboard(token),
            ));
        return true;
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: scaffoldKey,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                addContactPopUp(
                    context, nameTextController, numberTextController);
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
            body: chatListModel != null && campaignsListModel !=null
                ? Container(
              color: Colors.white,
              child: SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: ColorConstant.barGreen
                        ),
                        padding: const EdgeInsets.only(right: 10),
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 12, right: 12, top: 8, bottom: 8),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                                child:isSearch == true ? SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width *
                                      0.7,
                                  child: TextFormField(
                                    autofocus: true,
                                    controller: searchController,
                                    onChanged: (value) {
                                      chats(searchController.text);
                                      setState(() {

                                      });
                                    },
                                    decoration:  InputDecoration(
                                      contentPadding: const EdgeInsets.only(top: 5,bottom: 5),
                                      prefixIcon: const Icon(Icons.search),
                                      hintText: 'Search',
                                      fillColor: ColorConstant.white,
                                      filled: true,
                                       border: OutlineInputBorder(
                                         borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(10.0),
                                  ),
                                    ),
                                  ),
                                ) :
                                RichText(
                                  text: const TextSpan(
                                    text: 'WhatsApp',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isSearch =! isSearch;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      tabbar(),
                      tabbarView(chatListModel,campaignsListModel),
                    ],
                  ),
                ),
              ),
            )
                : const Center(child: CircularProgressIndicator())
          ),
        ),
      ),
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
