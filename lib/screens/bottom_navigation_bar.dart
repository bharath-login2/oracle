// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:io';
import 'package:login2/core/common.dart';
import 'package:login2/screens/leadManagement/callHistoryPage.dart';
import '../../screens/homePage.dart';
import 'leadManagement/add_leads.dart';
import '../../screens/userManagement/viewUsers.dart';
import 'package:flutter/material.dart';
import 'callLogs/callLogs.dart';
import 'officialWhatsapp/chat_home_screen.dart';

class BottomNavigation extends StatefulWidget {
  String token;
  String phoneCallLogPermission;
  String? name;
  String? userId;

  BottomNavigation(this.token,
      {required this.phoneCallLogPermission,
      this.name,
      this.userId,
      super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  String whatsappPermissions = "";
  String viewStaff = "";
  @override
  void initState() {
    getPermissions();
    super.initState();
  }

  getPermissions() async {
    try {
      whatsappPermissions = await Common.getSharedPref("officialWhatsApp");
      viewStaff = await Common.getSharedPref("viewStaffPermission");

      log(whatsappPermissions);
    } catch (e) {
      log(e.toString());
    }
  }

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
              onTap: () async {
                if (Platform.isAndroid) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CallLogs(
                              widget.token,
                              widget.name,
                              widget.userId,
                            )),
                  );
                } else if (Platform.isIOS) {
                  String accessCallRecordingPermission =
                      await Common.getSharedPref(
                          "accessCallRecordingPermission");
                  String userId = await Common.getSharedPref("userId");
                  String name = await Common.getSharedPref("name");
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CallHistoryPage(
                              widget.token,
                              name,
                              userId,
                              accessCallRecordingPermission == "true"
                                  ? true
                                  : false)),
                    );
                  }
                }
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.call,
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
                if (whatsappPermissions == "true") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChatHomeScreen()),
                  );
                } else {
                  _dialogue(context, 'whattsApp');
                }
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
                if (viewStaff == "true") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewUsers(widget.token),
                    ),
                  );
                } else {
                  _dialogue(context, 'viewStaffPermission');
                }
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

void _dialogue(BuildContext context, title) {
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: const Text(
              'You have no permission to access the feature please contact the support team'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close')),
          ],
        );
      });
}
