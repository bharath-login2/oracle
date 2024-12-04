import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'common.dart';

class Config {
  static getUrl() async {
    String? url = await Common.getSharedPref("url");
    String baseUrl;
    String? api = '/v6/Api/';
    if (url != null) {
      baseUrl = url.toString() + api;
    } else {
      baseUrl = 'https://myaccount.login2.in/index.php/v6/Api/';
    }
    return baseUrl;
  }

  static requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }
}
