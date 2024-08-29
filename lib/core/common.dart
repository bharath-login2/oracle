import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Common {
  static toastMessaage(message, color) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static String trimPlus91(String mobileNumber) {
    if (mobileNumber.length == 13) {
      return mobileNumber.substring(3);
    } else if (mobileNumber.length == 12) {
      return mobileNumber.substring(2);
    } else {
      return mobileNumber;
    }
  }

  static addPlus(String number) async {
    if (number.length == 12) {
      return "+$number";
    } else {
      return number;
    }
  }

  static directCall(String number) async {
    if (number.length == 12) {
      await FlutterPhoneDirectCaller.callNumber('+$number');
    } else {
      await FlutterPhoneDirectCaller.callNumber(number);
    }
  }

  static dialPad(String number) async {
    String url = 'tel:+$number';
    await launchUrl(Uri.parse(url));
  }

  static saveSharedPref(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, val);
  }

  static getSharedPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    print('$key:${prefs.get(key)}');
    return prefs.get(key);
  }

  static showProgressDialog(BuildContext context, String title) {
    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              content: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const Padding(
                    padding: EdgeInsets.only(left: 15),
                  ),
                  title.isEmpty
                      ? Container()
                      : Flexible(
                          flex: 8,
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )),
                ],
              ),
            );
          });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}

RegExp regex = RegExp(PatterStrings.email);

class PatterStrings {
  static const String email =
      // r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
}
