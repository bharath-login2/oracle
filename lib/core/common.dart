import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
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

  // static dialPad(String number) async {
  //   if (number.length == 12) {
  //     await FlutterPhoneDirectCaller.callNumber('+$number');
  //   } else {
  //     await FlutterPhoneDirectCaller.callNumber(number);
  //   }
  // }

  static dialPad(String number) async {
    if (number.length == 12) {
      String url = 'tel:+$number';
      await launchUrl(Uri.parse(url));
    } else {
      String url = 'tel:$number';
      await launchUrl(Uri.parse(url));
    }
  }

  static saveSharedPref(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, val);
  }

  static clearSharedPref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
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

Center noResultWidget(BuildContext context, text) {
  return Center(
    child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: text == "Type to search..." ? 250 : 200,
            height: text == "Type to search..." ? 250 : 200,
            child: text == "Type to search..."
                ? Lottie.asset("assets/icons/search_here.json")
                : Image.asset(
                    "assets/icons/nodatafound.png",
                  ),
          ),
          // if (text != "Type to search...")
          Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          // InkWell(
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          //   child: Container(
          //     width: MediaQuery.of(context).size.width * 0.4,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       color: Colors.black,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: const Center(
          //       child: Text('Go Back',
          //           style: TextStyle(
          //               fontSize: 15,
          //               color: Colors.white,
          //               fontWeight: FontWeight.w500)),
          //     ),
          //   ),
          // )
        ],
      ),
    ),
  );
}
