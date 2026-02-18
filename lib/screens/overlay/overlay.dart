// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/backgroundModel.dart';
import 'package:login2/service/service.dart';
import 'package:phone_state/phone_state.dart';

class TrueCallerOverlay extends StatefulWidget {
  final String number;
  const TrueCallerOverlay({super.key, required this.number});

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
      setState(() {});
    });
  }

  void setStream() {
    PhoneState.stream.listen((event) {
      status1 = event;
      if (status1.number != null) {
        number1 = status1.number.toString();
        getOverlayDetails(number1);
      }
    });
  }

  getOverlayDetails(number) async {
    Map<String, dynamic> body1 = {
      "token": await Common.getSharedPref("token"),
      'phoneNumber': number,
    };

    BackgroundModel object = await HttpService.backgroundData(body1);
    name = object.data.clientName;
    category = object.data.leadCategory;
    lastcall = object.data.lastCalledDate;
    number1 = number;
    setState(() {});
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
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          height: 150, // Fixed height to ensure visibility
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name.isEmpty ? "Unknown Caller" : name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    number1.isEmpty ? widget.number : number1,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18.0,
                    ),
                  ),
                  if (category.isNotEmpty)
                    Text(
                      category,
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    log("Closing overlay");
                    await FlutterOverlayWindow.closeOverlay();
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 16,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
