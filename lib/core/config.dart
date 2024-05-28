import 'dart:io';

import 'package:system_alert_window/system_alert_window.dart';

import 'common.dart';

class Config {
  static getUrl() async {
    String? url = await Common.getSharedPref("url");
    String baseUrl;
    String? api =
        Platform.isIOS ? '/Mobile_app_api_ios_v2/' : '/Mobile_app_api_v2/';
    if (url != null) {
      baseUrl = url.toString() + api;
    } else {
      baseUrl =
          'https://myaccount.login2.in/app/index.php/Mobile_app_api_v2/';
    }
    return baseUrl;
  }

  static requestPermission() async {
    SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
    await SystemAlertWindow.requestPermissions(prefMode: prefMode);
  }
}
