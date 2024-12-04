// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/officialWhatsapp/whatsapp_contact_list.dart';
import 'package:login2/screens/officialWhatsapp/add_contact.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import 'package:login2/screens/officialWhatsapp/colorConst.dart';
import 'package:login2/service/service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';

class WhatsappContactList extends StatefulWidget {
  const WhatsappContactList({
    super.key,
  });
  @override
  State<WhatsappContactList> createState() => _WhatsappContactListState();
}

class _WhatsappContactListState extends State<WhatsappContactList> {
  WhatsappContacts? contacts;
  // CommonResponse? deleteResponse;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  int page = 1;
  int pageSize = 20;
  List<ContactList> items = [];
  int add = 1;
  bool result = true;
  TextEditingController search = TextEditingController();
  String? contactPermission = '';
  TextEditingController nameTextController = TextEditingController();
  TextEditingController numberTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
  }

  getData() async {
    contactPermission = await Common.getSharedPref("getContactPermission");

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        result = true;
      });
    } else {
      setState(() {
        result = false;
      });
    }
    getList();
  }

  void _onLoadMore() {
    if (items.length + 20 == page * pageSize &&
        itemPositionsListener.itemPositions.value.last.index == items.length &&
        page > add) {
      getList();
      add++;
    }
  }

  getList() async {
    contacts =
        await HttpService.getWhatsappContacts(page, pageSize, search.text);
    if (contacts != null && contacts!.status == true) {
      items.addAll(contacts!.data);
      page++;
      setState(() {});
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
              child: Container(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: const BoxDecoration(color: ColorConstant.barGreen),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 10.0, right: 0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.pop(context);
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
                            const Text(
                              "Contacts",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ]),
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                add = 1;
                page = 1;
                items.clear();
                getList();
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 60.0),
                    child: ScrollablePositionedList.builder(
                        shrinkWrap: true,
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                        itemCount: items.length +
                            (items.length + 20 == page * pageSize ? 1 : 0),
                        initialScrollIndex: 0,
                        itemBuilder: (context, index) {
                          if (index == items.length) {
                            return buildLoaderListItem();
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4.0, top: 4.0, left: 8.0, right: 8.0),
                              child: ListTile(
                                onTap: () {
                                  log(items[index].groupId.toString());
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          groupId:
                                              items[index].groupId.toString(),
                                          nav: "",
                                        ),
                                      )).then((r) {
                                    add = 1;
                                    page = 1;
                                    items.clear();
                                    getList();
                                  });
                                },
                                leading: const CircleAvatar(
                                  backgroundColor: ColorConstant.barGreen,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(items[index].groupName),
                                subtitle: Text(items[index].phoneNumber),
                              ),
                            );
                          }
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.grey.shade100,
                            offset: const Offset(5, 5.0),
                          )
                        ],
                      ),
                      child: TextFormField(
                        // autofocus: true,
                        controller: search,
                        onChanged: (value) async {
                          add = 1;
                          page = 1;
                          items.clear();
                          getList();
                        },
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 3, bottom: 3),
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (contactPermission == 'true') {
                  addContactPopUp(
                          context, nameTextController, numberTextController)
                      .then((_) {
                    add = 1;
                    page = 1;
                    items.clear();
                    getList();
                  });
                } else {
                  contactPermissionDialog(context);
                }
              },
              backgroundColor: ColorConstant.barGreen,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Text(
                    'No Network Found !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<dynamic> contactPermissionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Permission",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          // decoration: TextDecoration.none,
                          //fontFamily: Theme.of(context).textTheme,
                        ),
                      ),
                      const Text(
                        "Our app accesses your contact book to help you efficiently manage and organize your contacts. Specifically, we allow you to save or update contact information directly in your device’s contact list.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: const Color(0xffe94040)),
                              child: const Center(
                                child: Text("Deny",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              contactPermission = "true";
                              Common.saveSharedPref(
                                  "getContactPermission", 'true');
                              setState(() {
                                addContactPopUp(context, nameTextController,
                                        numberTextController)
                                    .then((_) {
                                  add = 1;
                                  page = 1;
                                  items.clear();
                                  getList();
                                });
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.35,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.green),
                              child: const Center(
                                child: Text("Allow",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.none,
                                        color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Future<dynamic> deleteDialog(BuildContext context, String expId) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           scrollable: true,
  //           title: const Text('Please Confirm'),
  //           content: const Text('Are you sure to Delete?'),
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: const Text('No')),
  //             TextButton(
  //                 onPressed: () async {
  //                   deleteExpense(expId);
  //                 },
  //                 child: const Text(
  //                   'Yes',
  //                   style: TextStyle(color: Colors.red),
  //                 )),
  //           ],
  //         );
  //       });
  // }
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
              SizedBox(
                height: MediaQuery.of(context).size.height * .37,
                child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            title: Container(
                              height: 15,
                              color: Colors.grey,
                            ),
                            subtitle: Container(
                              height: 10,
                              color: Colors.grey,
                            )),
                      );
                    }),
              ),
            ],
          ),
        ));
  }
}
