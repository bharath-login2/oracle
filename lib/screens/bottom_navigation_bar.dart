// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:io';
import 'package:login2/core/common.dart';
import 'package:login2/models/expense/expense_post.dart';
import 'package:login2/screens/leadManagement/callHistoryPage.dart';
import 'package:login2/service/service.dart';
import '../../screens/homePage.dart';
import '../../screens/userManagement/viewUsers.dart';
import 'package:flutter/material.dart';
import 'callLogs/callLogs.dart';
import 'officialWhatsapp/chat_home_screen.dart';

class BottomNavigation extends StatefulWidget {
  String token;
  String phoneCallLogPermission;
  String? name;
  String? userId;
  GlobalKey<ScaffoldState>? scaffoldKey;

  BottomNavigation(this.token,
      {required this.phoneCallLogPermission,
      this.name,
      this.userId,
      this.scaffoldKey,
      super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  String whatsappPermissions = "";
  String workWithoutLogin = "";
  bool uploadCallLog = false;
  String viewStaff = "";
  String startAndStopWorkPermission = "";
  CommonResponse? loginOrNot;

  // REMOVE this line - you don't need it here
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getPermissions();
    check();
    super.initState();
  }

  getPermissions() async {
    try {
      workWithoutLogin = await Common.getSharedPref("workWithoutLogin");
      whatsappPermissions = await Common.getSharedPref("officialWhatsApp");
      viewStaff = await Common.getSharedPref("viewStaffPermission");
      var uploadCallLogPref = await Common.getSharedPref("uploadCallLog");
      if (uploadCallLogPref is bool) {
        uploadCallLog = uploadCallLogPref;
      } else if (uploadCallLogPref is String) {
        uploadCallLog = uploadCallLogPref.toLowerCase() == "true";
      } else {
        uploadCallLog = false;
      }
      startAndStopWorkPermission =
          await Common.getSharedPref("startAndStopWorkPermission");
      log(whatsappPermissions);
    } catch (e) {
      log(e.toString());
    }
  }

  check() async {
    try {
      loginOrNot = await HttpService.getLoginorNot(widget.token);
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      // REMOVE this key - it's not needed
      // key: _scaffoldKey,
      height: 55,
      color: const Color(0xFF406dbe),
      shape: const AutomaticNotchedShape(
          RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)))),
      child: Row(
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
                if (!uploadCallLog) {
                  _dialogue(context, 'Call Log');
                  return;
                }
                if (startAndStopWorkPermission == "true") {
                  if (workWithoutLogin != "true") {
                    _dialoguelogin(context, 'Please login to continue');
                  } else {
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
                  }
                } else {
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
                if (whatsappPermissions != 'true') {
                  _dialogue(context, 'whattsApp');
                } else if (startAndStopWorkPermission == "true") {
                  if (workWithoutLogin != "true") {
                    _dialoguelogin(context, 'Please login to continue');
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatHomeScreen()),
                    );
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChatHomeScreen()),
                  );
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
          // const SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: () {
                if (widget.scaffoldKey != null &&
                    widget.scaffoldKey!.currentState != null) {
                  widget.scaffoldKey!.currentState!.openEndDrawer();
                } else {
                  try {
                    Scaffold.of(context).openEndDrawer();
                  } catch (e) {
                    debugPrint("Error opening end drawer: $e");
                  }
                }
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.175,
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24,
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

void _dialoguelogin(BuildContext context, title) {
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Alert !!!'),
          content: const Text('Please Login To Make Any Changes In The App'),
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
