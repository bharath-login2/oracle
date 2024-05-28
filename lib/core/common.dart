import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static saveSharedPref(String key, String val) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == 'token') {
      prefs.setString(key, val);
    } else if (key == 'userId') {
      prefs.setString(key, val);
    } else if (key == 'name') {
      prefs.setString(key, val);
    } else if (key == 'role') {
      prefs.setString(key, val);
    } else if (key == 'sound') {
      prefs.setString(key, val);
    } else if (key == 'statusWise') {
      prefs.setString(key, val);
    } else if (key == 'statusWisId') {
      prefs.setString(key, val);
    } else if (key == 'statusCatId') {
      prefs.setString(key, val);
    } else if (key == 'type') {
      prefs.setString(key, val);
    } else if (key == 'callLogPermission') {
      prefs.setString(key, val);
    } else if (key == 'roleId') {
      prefs.setString(key, val);
    } else if (key == 'multiBranch') {
      prefs.setString(key, val);
    } else if (key == 'url') {
      prefs.setString(key, val);
    } else if (key == 'createLeadPermission') {
      prefs.setString(key, val);
    } else if (key == 'viewLeadPermission') {
      prefs.setString(key, val);
    } else if (key == 'updateLeadPermission') {
      prefs.setString(key, val);
    } else if (key == 'deleteLeadPermission') {
      prefs.setString(key, val);
    } else if (key == 'phoneCallLogPermission') {
      prefs.setString(key, val);
    } else if (key == 'accessCallHistoryPermission') {
      prefs.setString(key, val);
    } else if (key == 'viewLeadCategoryPermission') {
      prefs.setString(key, val);
    } else if (key == 'cloudCallPermission') {
      prefs.setString(key, val);
    } else if (key == 'createLeadCategory') {
      prefs.setString(key, val);
    } else if (key == 'updateLeadCategory') {
      prefs.setString(key, val);
    } else if (key == 'deleteLeadCategory') {
      prefs.setString(key, val);
    } else if (key == 'accessCallRecordingPermission') {
      prefs.setString(key, val);
    } else if (key == 'createStaffPermission') {
      prefs.setString(key, val);
    } else if (key == 'updateStaffPermission') {
      prefs.setString(key, val);
    } else if (key == 'deleteStaffPermission') {
      prefs.setString(key, val);
    } else if (key == 'viewStaffReportPermission') {
      prefs.setString(key, val);
    } else if (key == 'viewStaffPermission') {
      prefs.setString(key, val);
    } else if (key == 'createStaffDesignationPermission') {
      prefs.setString(key, val);
    } else if (key == 'viewStaffDesignationPermission') {
      prefs.setString(key, val);
    } else if (key == 'updateStaffDesignationPermission') {
      prefs.setString(key, val);
    } else if (key == 'deleteStaffDesignationPermission') {
      prefs.setString(key, val);
    } else if (key == 'updateStaffPasswordPermission') {
      prefs.setString(key, val);
    } else if (key == 'isVisible') {
      prefs.setString(key, val);
    } else if (key == 'uploadLog') {
      prefs.setString(key, val);
    } else if (key == 'officialWhatsApp') {
      prefs.setString(key, val);
    } else if (key == 'unofficialWhatsApp') {
      prefs.setString(key, val);
    } else if (key == 'openAppLeadId') {
      prefs.setString(key, val);
    }else if (key == 'navToFollowUp') {
      prefs.setString(key, val);
    } else {
      await prefs.clear();
    }
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
