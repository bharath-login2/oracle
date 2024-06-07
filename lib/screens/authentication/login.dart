import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:login2/main.dart';
import 'package:login2/models/userPermissionModel.dart';
import 'package:login2/screens/authentication/forgotPasswordPhoneNumber.dart';
import 'package:login2/service/backgroundService.dart';
import 'package:lottie/lottie.dart';
import 'package:workmanager/workmanager.dart';
import '../../core/common.dart';
import '../../models/loginModel.dart';
import '../../models/updateModel.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../service/service.dart';
import '../../widgets/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../widgets/size_config.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  String? firebaseToken;
  bool _loading = false;
  bool timeOut = false;
  bool obSecure = true;
  bool? result = true;
  UpdateModel? updatedata;
  bool serverChoose = false;
  final MethodChannel _channel =
      const MethodChannel('onreBootInitFunctionChannel');

  handleAsync() async {
    firebaseToken = await FirebaseMessaging.instance.getToken();
    if (kDebugMode) {
      print("Firebase token : $firebaseToken");
    }
  }

  getData() async {
    setState(() {
      timeOut = false;
    });
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        result = true;
      } else {
        result = false;
      }
      updatedata = await HttpService.forceUpdate();
      setState(() {
        if (updatedata!.data!.server!.length == 1) {
          Common.saveSharedPref(
              "url", updatedata!.data!.server![0].url.toString());
          serverChoose = true;
        }
      });
    } catch (e) {
      setState(() {
        timeOut = true;
        _loading = false;
      });
    }
  }

  login() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        if (username.text.isEmpty) {
          Common.toastMessaage('Username cannot be empty', Colors.red);
        } else if (password.text.isEmpty) {
          Common.toastMessaage('Password cannot be empty', Colors.red);
        } else if (serverChoose == false) {
          Common.toastMessaage('Choose any one server', Colors.red);
        } else {
          setState(() {
            _loading = true;
          });

          LoginModel object = await HttpService.login(
              username.text, password.text, firebaseToken);
          if (object.status == true) {
            UserPermissionModel object1 =
                await HttpService.userPermissionCheck(object.data!.token);
            if (object1.status == true) {
              Common.saveSharedPref("isVisible", 'true');
              Common.saveSharedPref(
                  "createLeadPermission", object1.data!.createLead.toString());
              Common.saveSharedPref(
                  "viewLeadPermission", object1.data!.viewLead.toString());
              Common.saveSharedPref(
                  "updateLeadPermission", object1.data!.updateLead.toString());
              Common.saveSharedPref(
                  "deleteLeadPermission", object1.data!.deleteLead.toString());
              Common.saveSharedPref("phoneCallLogPermission",
                  object1.data!.phoneCallLog.toString());
              Common.saveSharedPref("accessCallHistoryPermission",
                  object1.data!.accessCallHistory.toString());
              Common.saveSharedPref("viewLeadCategoryPermission",
                  object1.data!.viewLeadCategory.toString());
              Common.saveSharedPref(
                  "cloudCallPermission", object1.data!.cloudCall.toString());
              Common.saveSharedPref("createLeadCategory",
                  object1.data!.createLeadCategory.toString());
              Common.saveSharedPref("updateLeadCategory",
                  object1.data!.updateLeadCategory.toString());
              Common.saveSharedPref("deleteLeadCategory",
                  object1.data!.deleteLeadCategory.toString());
              Common.saveSharedPref("accessCallRecordingPermission",
                  object1.data!.accessCallRecording.toString());
              Common.saveSharedPref("createStaffPermission",
                  object1.data!.createStaff.toString());
              Common.saveSharedPref(
                  "viewStaffPermission", object1.data!.viewStaff.toString());
              Common.saveSharedPref("updateStaffPermission",
                  object1.data!.updateStaff.toString());
              Common.saveSharedPref("deleteStaffPermission",
                  object1.data!.deleteStaff.toString());
              Common.saveSharedPref("viewStaffReportPermission",
                  object1.data!.viewStaffReport.toString());
              Common.saveSharedPref("createStaffDesignationPermission",
                  object1.data!.viewStaffReport.toString());
              Common.saveSharedPref("createStaffDesignationPermission",
                  object1.data!.createStaffDesignation.toString());
              Common.saveSharedPref("viewStaffDesignationPermission",
                  object1.data!.viewStaffDesignation.toString());
              Common.saveSharedPref("updateStaffDesignationPermission",
                  object1.data!.updateStaffDesignation.toString());
              Common.saveSharedPref("deleteStaffDesignationPermission",
                  object1.data!.deleteStaffDesignation.toString());
              Common.saveSharedPref("updateStaffPasswordPermission",
                  object1.data!.updateStaffPassword.toString());
              Common.saveSharedPref("officialWhatsApp",
                  object1.data!.whatsappOfficial.toString());
              Common.saveSharedPref("unofficialWhatsApp",
                  object1.data!.whatsappUnofficial.toString());
            }

            Common.saveSharedPref("sound", 'slow_spring_board');
            Common.saveSharedPref("token", object.data!.token.toString());
            Common.saveSharedPref(
                "name", object.data!.name.toString().toUpperCase());
            Common.saveSharedPref("userId", object.data!.userId.toString());
            Common.saveSharedPref("role", object.data!.role.toString());
            Common.saveSharedPref("roleId", object.data!.roleId.toString());
            Common.saveSharedPref(
                "multiBranch", object.data!.isMultiBranch.toString());
            Common.saveSharedPref("callLogPermission", 'false');

            if (object.status == true) {
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          Dashboard(object.data!.token.toString())),
                );
              }
            } else {}

            Common.toastMessaage(object.message, Colors.green);
          } else {
            setState(() {
              _loading = false;
              Common.toastMessaage(object.message, Colors.red);
            });
          }
        }
      } else {
        setState(() {
          _loading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No Network Found..Try Again Later..'),
              backgroundColor: Colors.redAccent,
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(10),
            ),
          );
        });
      }
      // if (Platform.isAndroid) {
      //   _channel.setMethodCallHandler((call) async {
      //     if (call.method == 'setAsBackgroundService') {
      //       initService();
      //       FlutterBackgroundService().invoke('setAsBackground');
      //     }
      //   });
      //   Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      // }
    } catch (e) {
      setState(() {
        timeOut = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    handleAsync();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return result == true && timeOut == false
        ? Scaffold(
            backgroundColor: Colors.white,
            body: updatedata != null
                ? SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            // Colors.purple,
                            Colors.white,
                            Colors.white,
                          ])),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 50, right: 20),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: updatedata!.data!.server!.length > 1
                                  ? PopupMenuButton(
                                      child: const Icon(
                                          Icons.miscellaneous_services),
                                      itemBuilder: (context) {
                                        return updatedata!.data!.server!
                                            .map((data) {
                                          return PopupMenuItem<String>(
                                            value: data.url,
                                            child: Text(data.name.toString()),
                                          );
                                        }).toList();
                                      },
                                      onSelected: (value) {
                                        Common.saveSharedPref("url", value);
                                        serverChoose = true;
                                        setState(() {});
                                      })
                                  : SizedBox(),
                            ),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Center(
                                child: Lottie.asset(
                                  'assets/main/splash.json',
                                  fit: BoxFit.fill,
                                ),
                              )),
                          Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(50),
                                      topRight: Radius.circular(50))),
                              margin: const EdgeInsets.only(top: 60),
                              child: Column(
                                children: [
                                  const Text("Login",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                      )),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text("Enter your login details",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      )),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: TextFormField(
                                      controller: username,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Username',
                                        contentPadding: EdgeInsets.all(10),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: TextFormField(
                                      obscureText: obSecure,
                                      controller: password,
                                      decoration: InputDecoration(
                                        hintText: 'Enter Password',
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              obSecure = !obSecure;
                                            });
                                          },
                                          icon: Icon(
                                            obSecure == true
                                                ? Icons.remove_red_eye_outlined
                                                : Icons.visibility_off,
                                            color: const Color(0xFF454B60),
                                            size: 22,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.all(10),
                                        border: const OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  // Container(
                                  //     width: double.infinity,
                                  //     height: 60,
                                  //     margin: const EdgeInsets.symmetric(
                                  //         horizontal: 20, vertical: 20),
                                  //     padding: const EdgeInsets.symmetric(
                                  //         horizontal: 15, vertical: 5),
                                  //     decoration: BoxDecoration(
                                  //         border: Border.all(color: Colors.white, width: 0),
                                  //         boxShadow: const [
                                  //           BoxShadow(
                                  //               color: Colors.grey,
                                  //               blurRadius: 5,
                                  //               offset: Offset(1, 1)),
                                  //         ],
                                  //         color: Colors.white,
                                  //         borderRadius:
                                  //             const BorderRadius.all(Radius.circular(10))),
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.start,
                                  //       children: [
                                  //         const Icon(Icons.email_outlined),
                                  //         Expanded(
                                  //           child: Container(
                                  //             margin: const EdgeInsets.only(left: 10),
                                  //             child: TextFormField(
                                  //               maxLines: 1,
                                  //               controller: username,
                                  //               decoration: const InputDecoration(
                                  //                 hintText: "Username",
                                  //                 border: InputBorder.none,
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     )),
                                  // Container(
                                  //     width: double.infinity,
                                  //     height: 60,
                                  //     margin: const EdgeInsets.symmetric(
                                  //         horizontal: 20, vertical: 20),
                                  //     padding: const EdgeInsets.symmetric(
                                  //         horizontal: 15, vertical: 5),
                                  //     decoration: BoxDecoration(
                                  //         border: Border.all(color: Colors.white, width: 0),
                                  //         boxShadow: const [
                                  //           BoxShadow(
                                  //               color: Colors.grey,
                                  //               blurRadius: 5,
                                  //               offset: Offset(1, 1)),
                                  //         ],
                                  //         color: Colors.white,
                                  //         borderRadius:
                                  //             const BorderRadius.all(Radius.circular(10))),
                                  //     child: Row(
                                  //       mainAxisAlignment: MainAxisAlignment.start,
                                  //       children: [
                                  //         const Icon(Icons.password_outlined),
                                  //         Expanded(
                                  //           child: Container(
                                  //             margin: const EdgeInsets.only(left: 10),
                                  //             child: TextFormField(
                                  //               maxLines: 1,
                                  //               obscureText: true,
                                  //               controller: password,
                                  //               decoration: const InputDecoration(
                                  //                 hintText: "Password",
                                  //                 border: InputBorder.none,
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     )),

                                  InkWell(
                                    onTap: () async {
                                      login();
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      height: 45,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.black),
                                      child: Center(
                                        child: _loading == true
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              )
                                            : const Text("Login",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordNumber()),
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  // ElevatedButton(
                                  //   onPressed: () async {
                                  //     Navigator.of(context).pushAndRemoveUntil(
                                  //         MaterialPageRoute(
                                  //             builder: (context) => CreditHomePageView()),
                                  //             (Route<dynamic> route) => false);
                                  //
                                  //     // Navigator.of(context).pushAndRemoveUntil(
                                  //     //     MaterialPageRoute(builder: (context) => Dashboard()),
                                  //     //         (Route<dynamic> route) => false);
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //       onPrimary: Colors.orangeAccent,
                                  //       shadowColor: Colors.orange,
                                  //       elevation: 15,
                                  //       padding: EdgeInsets.zero,
                                  //       shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(15))),
                                  //   child: Ink(
                                  //     decoration: BoxDecoration(
                                  //         gradient: const LinearGradient(colors: [
                                  //           Colors.orangeAccent,
                                  //           Colors.orange
                                  //         ]),
                                  //         borderRadius: BorderRadius.circular(15)),
                                  //     child: Container(
                                  //       width: 200,
                                  //       height: 50,
                                  //       alignment: Alignment.center,
                                  //       child: _loading == true
                                  //           ? Center(
                                  //         child: CircularProgressIndicator(
                                  //           color: Colors.white,
                                  //         ),
                                  //       )
                                  //           : const Text(
                                  //         'credit',
                                  //         style: TextStyle(
                                  //           fontSize: 20,
                                  //           color: Colors.white,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(
                                  //   height: 20,
                                  // ),
                                  // ElevatedButton(
                                  //   onPressed: () async {
                                  //     Navigator.of(context).pushAndRemoveUntil(
                                  //         MaterialPageRoute(
                                  //             builder: (context) => InsuranceHomePageView()),
                                  //             (Route<dynamic> route) => false);
                                  //
                                  //     // Navigator.of(context).pushAndRemoveUntil(
                                  //     //     MaterialPageRoute(builder: (context) => Dashboard()),
                                  //     //         (Route<dynamic> route) => false);
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //       onPrimary: Colors.orangeAccent,
                                  //       shadowColor: Colors.orange,
                                  //       elevation: 15,
                                  //       padding: EdgeInsets.zero,
                                  //       shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(15))),
                                  //   child: Ink(
                                  //     decoration: BoxDecoration(
                                  //         gradient: const LinearGradient(colors: [
                                  //           Colors.orangeAccent,
                                  //           Colors.orange
                                  //         ]),
                                  //         borderRadius: BorderRadius.circular(15)),
                                  //     child: Container(
                                  //       width: 200,
                                  //       height: 50,
                                  //       alignment: Alignment.center,
                                  //       child: _loading == true
                                  //           ? Center(
                                  //         child: CircularProgressIndicator(
                                  //           color: Colors.white,
                                  //         ),
                                  //       )
                                  //           : const Text(
                                  //         'Insurance',
                                  //         style: TextStyle(
                                  //           fontSize: 20,
                                  //           color: Colors.white,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(
                                  //   height: 20,
                                  // ),
                                  // ElevatedButton(
                                  //   onPressed: () async {
                                  //     Navigator.of(context).pushAndRemoveUntil(
                                  //         MaterialPageRoute(
                                  //             builder: (context) => ReminderManagementHomePageView()),
                                  //             (Route<dynamic> route) => false);
                                  //
                                  //     // Navigator.of(context).pushAndRemoveUntil(
                                  //     //     MaterialPageRoute(builder: (context) => Dashboard()),
                                  //     //         (Route<dynamic> route) => false);
                                  //   },
                                  //   style: ElevatedButton.styleFrom(
                                  //       onPrimary: Colors.orangeAccent,
                                  //       shadowColor: Colors.orange,
                                  //       elevation: 15,
                                  //       padding: EdgeInsets.zero,
                                  //       shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(15))),
                                  //   child: Ink(
                                  //     decoration: BoxDecoration(
                                  //         gradient: const LinearGradient(colors: [
                                  //           Colors.orangeAccent,
                                  //           Colors.orange
                                  //         ]),
                                  //         borderRadius: BorderRadius.circular(15)),
                                  //     child: Container(
                                  //       width: 200,
                                  //       height: 50,
                                  //       alignment: Alignment.center,
                                  //       child: _loading == true
                                  //           ? Center(
                                  //         child: CircularProgressIndicator(
                                  //           color: Colors.white,
                                  //         ),
                                  //       )
                                  //           : const Text(
                                  //         'Reminder System',
                                  //         style: TextStyle(
                                  //           fontSize: 20,
                                  //           color: Colors.white,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // const SizedBox(
                                  //   height: 20,
                                  // ),
                                  // Padding(
                                  //   padding: EdgeInsets.fromLTRB(
                                  //       SizeConfig.screenWidth!/20.55,
                                  //       SizeConfig.screenHeight!/136.6,
                                  //       SizeConfig.screenWidth!/20.55,
                                  //       0
                                  //   ),
                                  //   child: Row(
                                  //     mainAxisAlignment: MainAxisAlignment.center,
                                  //     children: [
                                  //       Text("Don't have an account?", style: TextStyle(color: texthint),),
                                  //       GestureDetector(
                                  //         onTap: (){
                                  //           // Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                                  //         },
                                  //         child: Text(
                                  //           "Register",
                                  //           style: TextStyle(
                                  //               color: buttonColor,
                                  //               fontWeight: FontWeight.w600,
                                  //               fontSize: SizeConfig.screenHeight!/45.54          /// 15
                                  //           ),
                                  //         ),
                                  //       )
                                  //     ],
                                  //   ),
                                  // ),
                                  // const SizedBox(
                                  //   height: 10,
                                  // ),
                                ],
                              ))
                        ],
                      ),
                    ),
                  )
                : const SizedBox())
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    timeOut == true
                        ? "There seems to be a temporary issue !, \n Please retry to continue"
                        : 'No Network Found !',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
