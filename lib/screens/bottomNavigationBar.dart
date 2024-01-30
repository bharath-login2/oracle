import '../../screens/homePage.dart';
import '../../screens/leadManagement/addLeads.dart';
import '../../screens/settings/whatsappSettings.dart';
import '../../screens/userManagement/viewUsers.dart';
import '../../screens/whatsAppGroup/groupList.dart';
import 'package:flutter/material.dart';

import 'officialWhatsapp/chatHomeScreen.dart';

class BottomNavigation extends StatefulWidget {
  String token;
  bool? whatsappConfigaure;

  BottomNavigation(this.token, this.whatsappConfigaure, {super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 55,
      //bottom navigation bar on scaffold
      color: const Color(0xFF406dbe),
      shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)))),
      //shape of notch

      //notche margin between floating button and bottom appbar
      child: Row(
        //children inside bottom appbar
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => HomePage(widget.token)),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.home,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddLeads(widget.token, page: 'NavigationBar'),
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                showDialog(
                    barrierColor:
                    Colors.grey.withOpacity(.5),
                    context: context,
                    builder: (BuildContext context) {
                      return WillPopScope(
                        onWillPop: () async {
                          return true;
                        },
                        child: Material(
                          type:
                          MaterialType.transparency,
                          child: Padding(
                            padding:
                            const EdgeInsets.only(
                                bottom: 50),
                            child: Center(
                              child: Container(
                                decoration:
                                BoxDecoration(
                                  borderRadius:
                                  BorderRadius
                                      .circular(10),
                                  color: Colors.white,
                                ),
                                width: MediaQuery.of(
                                    context)
                                    .size
                                    .width *
                                    0.9,
                                height: 250,
                                child: Padding(
                                  padding:
                                  const EdgeInsets
                                      .only(
                                      left: 20,
                                      right: 20),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/official_whatsapp.png',
                                        width: 80,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        'Whatsapp',
                                        style: TextStyle(
                                            fontSize:
                                            18,
                                            fontWeight:
                                            FontWeight
                                                .w400),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                        'Choose WhatsApp',
                                        style: TextStyle(
                                            fontSize:
                                            15,
                                            fontWeight:
                                            FontWeight
                                                .w400),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => const ChatHomeScreen()),
                                              );

                                            },
                                            child:
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.35,
                                              //  color: RandomColorModel().getColor(),
                                              decoration: BoxDecoration(
                                                  color: Colors
                                                      .green
                                                      .shade100,
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                              child:
                                              const Padding(
                                                padding:
                                                EdgeInsets.all(5),
                                                child:
                                                Text('Official',
                                                    style: TextStyle(fontSize: 13, color: Colors.black),
                                                    textAlign: TextAlign.center),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              widget.whatsappConfigaure == true
                                                  ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => GroupList(widget.token),
                                                ),
                                              )
                                                  : Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => WhatsappSettings(widget.token),
                                                ),
                                              );
                                            },
                                            child:
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                                  0.35,
                                              decoration: BoxDecoration(
                                                  color: Colors
                                                      .green
                                                      .shade100,
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                              child:
                                              const Padding(
                                                padding:
                                                EdgeInsets.all(5),
                                                child:
                                                Text('Un Official',
                                                    style: TextStyle(fontSize: 13, color: Colors.black),
                                                    textAlign: TextAlign.center),
                                              ),
                                            ),
                                          ),


                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: Image.asset(
                  "assets/main/whatsappIcon.png",
                  width: 21,
                  height: 21,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewUsers(widget.token),
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
