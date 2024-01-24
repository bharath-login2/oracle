import 'dart:io';

import 'common.dart';

class Config {
  static  getUrl() async {
    String? url = await Common.getSharedPref("url");
    String baseUrl;
    String? api= Platform.isIOS?'/Mobile_app_api_ios_v4/':'/Mobile_app_api_v4/';
    if(url!=null)
    {
      baseUrl=url.toString()+api;
    }
    else{
      baseUrl='https://myaccount.login2.in/index.php/MobileApi/';
    }
    print(baseUrl);
    return baseUrl;
  }

}