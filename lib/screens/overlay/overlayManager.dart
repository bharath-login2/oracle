import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/core/common.dart';
import 'package:login2/models/backgroundModel.dart';
import 'package:login2/service/service.dart';

class OverlayManager extends StatefulWidget {
  const OverlayManager({super.key});

  @override
  State<OverlayManager> createState() => _OverlayManagerState();
}

class _OverlayManagerState extends State<OverlayManager> {
  String name = "Unknown";
  String phoneNumber = "";
  String category = "";
  String? lastcall;

  @override
  void initState() {
    super.initState();
    // Listen for data sent from the background service
    FlutterOverlayWindow.overlayListener.listen((event) {
      log("Overlay received event: $event");
      if (event is String) {
        // Assuming event is the phone number
        setState(() {
          phoneNumber = event;
        });
        _fetchLeadDetails(event);
      }
    });
  }

  Future<void> _fetchLeadDetails(String number) async {
    try {
      final token = await Common.getSharedPref("token");
      if (token == null) return;

      Map<String, dynamic> body = {
        "token": token,
        'phoneNumber': number,
      };

      BackgroundModel object = await HttpService.backgroundData(body);
      if (mounted) {
        setState(() {
          name = object.data.clientName;
          category = object.data.leadCategory;
          lastcall = object.data.lastCalledDate;
        });
      }
    } catch (e) {
      log("Error fetching overlay details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildLeadCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCard() {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.call, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Incoming Calls',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await FlutterOverlayWindow.closeOverlay();
                  },
                  child: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            phoneNumber,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (category.isNotEmpty) Text('Category: $category'),
                if (lastcall != null && lastcall!.isNotEmpty)
                  Text('Last Call: $lastcall'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
