
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class Config {
  static getUrl() async {
    // String? url = await Common.getSharedPref("url");
    // log("SharedPref URL = $url");
     String baseUrl;
    // String? api = '/v1_1_5/Api/';
    //if (url != null) {
     // baseUrl = url.toString() + api;

       baseUrl = 'https://s1.site720.com/index.php/v1_1_0/Api';
   // } else {
     // baseUrl = '';
   // }
    return baseUrl;
  }

  static requestPermission() async {
    await FlutterOverlayWindow.requestPermission();
  }
}
