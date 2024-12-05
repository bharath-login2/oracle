import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'common.dart';

class Config {
  static getUrl() async {
    String? url = await Common.getSharedPref("url");
    String baseUrl;
    String? api = '/v1_1_0/Api/';
    if (url != null) {
      baseUrl = url.toString() + api;
    } else {
      baseUrl = 'https://myaccount.login2.in/index.php/v1_1_0/Api/';
    }
    return baseUrl;
  }

  static requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }
}
