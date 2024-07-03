// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/core/common.dart';
import 'package:login2/service/service.dart';
import 'package:phone_state/phone_state.dart';
import '../../models/backgroundModel.dart';

class TrueCallerOverlay extends StatefulWidget {
  String number;
  TrueCallerOverlay({Key? key, required this.number}) : super(key: key);

  @override
  State<TrueCallerOverlay> createState() => _TrueCallerOverlayState();
}

class _TrueCallerOverlayState extends State<TrueCallerOverlay> {
  String name = "";
  String category = "";
  String lastcall = "";
  String number1 = "";
  final blueColors = const [Color(0xFF2a86c9), Color(0xFF406dbe)];
  void sendData(String? isDarkModeString, String? address, String? flavors) {
    final data =
        '{"isDarkModeString": "$isDarkModeString", "address": "$address", "flavors": "$flavors"}';
    FlutterOverlayWindow.shareData(data);
  }
PhoneState status1 = PhoneState.nothing();
  @override
  void initState() {
    super.initState();
     setStream();
    FlutterOverlayWindow.overlayListener.listen((event) {
    log(widget.number);
      setState(() {
      });
    });
   
  }
 void setStream() {
  PhoneState.stream.listen((event) {
    if (event != null) {
      status1 = event;
      if(status1.number != null){
        number1 = status1.number.toString();
        getOverlayDetails(number1);
      }
    }
  });
}

  getOverlayDetails(number) async {
    Map<String, dynamic> body1 = {
      "token": await Common.getSharedPref("token"),
      'phoneNumber': number,
    };

    BackgroundModel object = await HttpService.backgroundData(body1);
    if (object.status == true) {
      name = object.data.clientName;
      category = object.data.leadCategory;
      lastcall = object.data.lastCalledDate;
      number1 = number;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: blueColors,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: GestureDetector(
            onTap: () {
              FlutterOverlayWindow.getOverlayPosition().then((value) {
                log("Overlay Position: $value");
              });
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    ListTile(
                      leading: Container(
                        height: 80.0,
                        width: 80.0,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: const DecorationImage(
                            image: AssetImage("assets/main/logo.png"),
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Divider(color: Colors.white54),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                number1,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Last call - $lastcall",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            "Login2 Pro",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: () async {
                      await FlutterOverlayWindow.closeOverlay();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
