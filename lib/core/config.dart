import 'dart:io';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';

import 'common.dart';

class Config {
  static getUrl() async {
    String? url = await Common.getSharedPref("url");
    String baseUrl;
    String? api = '/Mobile_app_api_v6/';
    if (url != null) {
      baseUrl = url.toString() + api;
    } else {
      baseUrl = 'https://myaccount.login2.in/index.php/Mobile_app_api_ios_v6/';
    }
    return baseUrl;
  }

  static requestPermission() async {
    final bool? res = await FlutterOverlayWindow.requestPermission();
  }
}
