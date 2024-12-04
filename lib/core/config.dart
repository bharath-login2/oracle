import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'common.dart';

class Config {
  static getUrl() async {
    String? url = await Common.getSharedPref("url");
    String baseUrl;
    String? api = '/v2_0_8/Api/';
    if (url != null) {
      baseUrl = url.toString() + api;
    } else {
      baseUrl = 'https://s1.login2.co.in/index.php/v2_0_8/Api/';
    }
    return baseUrl;
  }

  static requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }
}
