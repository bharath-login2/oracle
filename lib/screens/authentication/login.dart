import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/main.dart';
import 'package:login2/models/userPermissionModel.dart';
import 'package:login2/screens/accounts/dashboard/accounts_dashboard.dart';
import 'package:login2/screens/accounts/renewal_mannagement/renewal_dashboard.dart';
import 'package:login2/screens/authentication/face_detection_camera.dart';
import 'package:login2/screens/authentication/forgot_password.dart';
import 'package:login2/screens/homePage.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/leadManagement/quotationDashboard.dart';
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
  String selectedUrl = "";
  final MethodChannel _channel =
      const MethodChannel('onreBootInitFunctionChannel');
  final GlobalKey popupMenuKey = GlobalKey();
  File? _faceImageFile;
  String? _faceBase64;

  handleAsync() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      firebaseToken = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) {
        print("Firebase token : $firebaseToken");
      }
    } catch (error, stackTrace) {
      firebaseToken = '';
      log("Error while get FCM", error: error, stackTrace: stackTrace);
    }
  }

  // getData() async {
  //   setState(() {
  //     timeOut = false;
  //   });
  //   try {
  //     final connectivityResult = await (Connectivity().checkConnectivity());
  //     if (connectivityResult == ConnectivityResult.mobile ||
  //         connectivityResult == ConnectivityResult.wifi) {
  //       result = true;
  //     } else {
  //       result = false;
  //     }
  //     updatedata = await HttpService.forceUpdate();
  //     setState(() {
  //       if (updatedata!.data!.server!.length == 1) {
  //         Common.saveSharedPref(
  //             "url", updatedata!.data!.server![0].url.toString());
  //         serverChoose = true;
  //       }
  //     });
  //   } catch (e) {
  //     setState(() {
  //       timeOut = true;
  //       _loading = false;
  //     });
  //   }
  // }
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
      String? savedUrl = await Common.getSharedPref("url");

      setState(() {
        if (updatedata!.data!.server!.length == 1) {
          Common.saveSharedPref(
              "url", updatedata!.data!.server![0].url.toString());
          selectedUrl = updatedata!.data!.server![0].url.toString();
          serverChoose = true;
        } else if (savedUrl != null && savedUrl.isNotEmpty) {
          selectedUrl = savedUrl;
          serverChoose = true;
        } else {
          serverChoose = false;
        }
      });
    } catch (e) {
      setState(() {
        timeOut = true;
        _loading = false;
      });
    }
  }

// Future<void> captureFace() async {
//   var status = await Permission.camera.request();
// if (!status.isGranted) {
//   Common.toastMessaage('Camera permission denied.', Colors.red);
//   return;
// }
//   final cameras = await availableCameras();
//   final frontCamera = cameras.firstWhere(
//     (camera) => camera.lensDirection == CameraLensDirection.front,
//   );

//   final faceImage = await Navigator.of(context).push<File>(
//     MaterialPageRoute(
//       builder: (context) => Scaffold(
//         backgroundColor: Colors.black,
//         body: FaceDetectionCamera(
//           onFaceCaptured: (File imageFile) {
//             Navigator.of(context).pop(imageFile);
//           },
//         ),
//       ),
//     ),
//   );

//   if (faceImage != null) {
//     final faceDetector = FaceDetector(options: FaceDetectorOptions());
//     final inputImage = InputImage.fromFilePath(faceImage.path);
//     final faces = await faceDetector.processImage(inputImage);

//     if (faces.isNotEmpty) {
//       _faceImageFile = faceImage;
//       final bytes = await _faceImageFile!.readAsBytes();
//       _faceBase64 = base64Encode(bytes);
//       setState(() {});
//     } else {
//       Common.toastMessaage('No face detected. Please try again.', Colors.red);
//     }
//     faceDetector.close();
//   } else {
//     Common.toastMessaage('No image captured', Colors.red);
//   }
// }

  Future<String?> generateFaceHash(File faceImageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: false,
      ),
    );

    final inputImage = InputImage.fromFile(faceImageFile);
    final faces = await faceDetector.processImage(inputImage);

    if (faces.isEmpty) return null;

    final face = faces.first;
    final landmarks = face.landmarks;

    // Serialize key landmarks
    final serialized = [
      landmarks[FaceLandmarkType.leftEye]?.position,
      landmarks[FaceLandmarkType.rightEye]?.position,
      landmarks[FaceLandmarkType.noseBase]?.position,
      landmarks[FaceLandmarkType.leftCheek]?.position,
      landmarks[FaceLandmarkType.rightCheek]?.position,
    ].map((p) => p != null ? '${p.x.round()},${p.y.round()}' : '0,0').join(';');

    // Add lip contours (optional but increases uniqueness)
    final lipPoints = face.contours[FaceContourType.upperLipTop]?.points ?? [];
    final lipData =
        lipPoints.take(3).map((p) => '${p.x.round()},${p.y.round()}').join(';');

    faceDetector.close();

    final combined = '$serialized;$lipData';
    return base64Encode(utf8.encode(combined));
  }

  // Future<void> captureFace() async {
  //   final faceImage = await Navigator.of(context).push<File>(
  //     MaterialPageRoute(
  //       builder: (context) => FaceDetectionCamera(
  //         onFaceCaptured: (File imageFile) {
  //           Navigator.of(context).pop(imageFile);
  //         },
  //       ),
  //     ),
  //   );

  //   if (faceImage != null && mounted) {
  //     final faceHash = await generateFaceHash(faceImage);
  //     if (faceHash == null) {
  //       Common.toastMessaage('Face hash failed', Colors.red);
  //       return;
  //     }
  //     _faceBase64 = faceHash;
  //     setState(() {});
  //   }
  // }

  login() async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        if (username.text.isEmpty) {
          Common.toastMessaage('Username cannot be empty', Colors.red);
        } else if (password.text.isEmpty) {
          Common.toastMessaage('Password cannot be empty', Colors.red);
        } 
        else if (serverChoose == false) {
          Common.toastMessaage('Choose a Server', Colors.red);
          openPopupMenu();
          if (updatedata!.data!.server!.length > 1) {
            Common.toastMessaage('Choose a Server', Colors.red);
            openPopupMenu();
          } 
          else {
            Common.toastMessaage('Server configuration error', Colors.red);
          }
        }
         else {
          setState(() {
            _loading = true;
          });

          //      await captureFace();
          // if (_faceBase64 == null || _faceBase64!.isEmpty) {
          //   Common.toastMessaage('Face capture required for login', Colors.red);
          //   return;
          // }

          LoginModel? object = await HttpService.login(
            username.text,
            password.text,
            firebaseToken!,
            _faceBase64,
          );
          if (object!.status == true) {
            Common.saveSharedPref(
                "accountName", object.data!.accountName.toString());
            Common.saveSharedPref(
                "accountId", object.data!.accountId.toString());
            UserPermissionModel object1 =
                await HttpService.userPermissionCheck(object.data!.token);
            if (object1.status == true) {
              Common.saveSharedPref("isVisible", 'true');
              Common.saveSharedPref(
                  "accPermission", object1.data!.readAccount.toString());
              Common.saveSharedPref(
                  "renewalPermission", object1.data!.readRenewal.toString());
              Common.saveSharedPref(
                  "createLeadPermission", object1.data!.createLead.toString());
              Common.saveSharedPref(
                  "viewLeadPermission", object1.data!.viewLead.toString());
              Common.saveSharedPref(
                  "addWorkPermission", object1.data!.addWorks.toString());
              Common.saveSharedPref("viewAllWorkPermission",
                  object1.data!.viewAllWorks.toString());
              Common.saveSharedPref("viewWorkReportPermission",
                  object1.data!.viewWorkReport.toString());
              Common.saveSharedPref("startAndStopWorkPermission",
                  object1.data!.startAndStopWork.toString());
              Common.saveSharedPref(
                  "adminCheckPermission", object1.data!.adminCheck.toString());
              Common.saveSharedPref(
                  "multipleUsers", object1.data!.multipleUsers.toString());
              Common.saveSharedPref(
                  "multipleWorks", object1.data!.multipleWorks.toString());
              Common.saveSharedPref("hasPhonecallAccess",
                  object1.data!.hasPhonecallAccess.toString());
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
              Common.saveSharedPref("viewTargetReportPermission",
                  object1.data!.viewTargetReport.toString());
              Common.saveSharedPref("createStaffDesignationPermission",
                  object1.data!.viewStaffReport.toString());
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
              Common.saveSharedPref(
                  "transferLeads", object1.data!.transferLead.toString());

              Common.saveSharedPref(
                  "uploadCallLog", object1.data!.uploadCallLog.toString());
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
            Common.saveSharedPref(
                "faceDetection", object1.data!.faceDetection.toString());
            Common.saveSharedPref(
                "companyLocation", object1.data!.companyLocation.toString());
            Common.saveSharedPref(
                "assignWork", object1.data!.assignWork.toString());
            Common.saveSharedPref("ProjectDashboardPermission",
                object1.data!.ProjectDashboard.toString());
            Common.saveSharedPref(
                "LeadDashboard", object1.data!.LeadDashboard.toString());
            Common.saveSharedPref("AccountsDashboardPermission",
                object1.data!.AccountsDashboard.toString());
                  Common.saveSharedPref("QuotationDashboardPermission",
                object1.data!.QuotationDashboard.toString());
                     Common.saveSharedPref("RoomDashboard",
                object1.data!.RoomDashboard.toString());
                //////////////Modules permissions /////////////////////////////////////////
               Common.saveSharedPref("RoomModule",
                object1.data!.roomModule.toString());

                Common.saveSharedPref("quotationModule",
                object1.data!.quotationModule.toString());
                  Common.saveSharedPref("workModule",
                object1.data!.workModule.toString());
                    Common.saveSharedPref("renewalModule",
                object1.data!.renewalModule.toString());
                     Common.saveSharedPref("accountsModule",
                object1.data!.accountsModule.toString());
                      Common.saveSharedPref("leadModule",
                object1.data!.leadModule.toString());

                ///      Modulessss eNDSSSS ///////////////////////////////////////
            Common.saveSharedPref(
                "MenuDashboard", object1.data!.MenuDashboard.toString());
            Common.saveSharedPref("RenewalDashboardPermission",
                object1.data!.RenewalDashboard.toString());
                  Common.saveSharedPref("NewleadDashboardPermission",
                object1.data!.NewleadDashboard.toString());
                  Common.saveSharedPref(
                  "addWorkModule", object1.data!.addWorkModule.toString());
                   Common.saveSharedPref(
                  "viewAttendanceSection", object1.data!.viewAttendanceSection.toString());
                    Common.saveSharedPref(
                  "approvePayroll", object1.data!.approvePayroll.toString());
                    Common.saveSharedPref(
                  "proformaInvoiceMenu", object1.data!.proformaInvoiceMenu.toString());
                    Common.saveSharedPref(
                  "gstInvoiceMenu", object1.data!.gstInvoiceMenu.toString());
                    Common.saveSharedPref(
                  "receiptMenu", object1.data!.receiptMenu.toString());
                    Common.saveSharedPref(
                  "pendingInvoiceMenu", object1.data!.pendingInvoiceMenu.toString());
                   Common.saveSharedPref(
                  "createLeadCategory", object1.data!.createLeadCategory.toString());
                   Common.saveSharedPref(
                  "addLeadSource", object1.data!.addLeadSource.toString());
                    Common.saveSharedPref(
                  "updateDashboard", object1.data!.updateDashboard.toString());
                    Common.saveSharedPref(
                  "viewPendingWorks", object1.data!.viewPendingWorks.toString());
            // Common.saveSharedPref("callLogPermission", 'false');
            //  Common.saveSharedPref(
            //  "callLogPermission", 'true');
            String? projectDash = object1.data!.ProjectDashboard.toString();
            String? leadDash = object1.data!.LeadDashboard.toString();
            String? accountsDash = object1.data!.AccountsDashboard.toString();
            String? menuDash = object1.data!.MenuDashboard.toString();
            String? renewalDash = object1.data!.RenewalDashboard.toString();
              String? quotationDash = object1.data!.QuotationDashboard.toString();
            Widget dashboardToOpen;
            if (projectDash == "true") {
              dashboardToOpen = ProjectDashboard();
            } else if (leadDash == "true") {
              dashboardToOpen = Dashboard(object.data!.token.toString());
            } else if (accountsDash == "true") {
              dashboardToOpen =
                  AccountsDashboard(token: object.data!.token.toString());
            } else if (menuDash == "true") {
              dashboardToOpen = HomePage(object.data!.token.toString());
            } else if (renewalDash == "true") {
              dashboardToOpen = RenewalDashboard();
            } else if (quotationDash == "true") {
              dashboardToOpen = QuotationDashboard();
            } else {
              dashboardToOpen =
                  Dashboard(object.data!.token.toString()); // fallback
            }

            if (object.status == true) {
              if (mounted) {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           Dashboard(object.data!.token.toString())),
                // );
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => dashboardToOpen),
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
      if (Platform.isAndroid) {
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'setAsBackgroundService') {
            initService();
            FlutterBackgroundService().invoke('setAsBackground');
          }
        });
        Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      }
    } catch (e) {
      setState(() {
        timeOut = true;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  void openPopupMenu() {
    final dynamic popupMenuState = popupMenuKey.currentState;
    popupMenuState?.showButtonMenu();
  }

  @override
  void initState() {
    super.initState();
    handleAsync();
    getData();
    HiveUtil.clearAllCallLogs();
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
                          // Container(
                          //   margin: const EdgeInsets.only(top: 50, right: 20),
                          //   child: Align(
                          //     alignment: Alignment.topRight,
                          //     child: updatedata!.data!.server!.length > 1
                          //         ? PopupMenuButton(
                          //             key: popupMenuKey,
                          //             child: const Icon(
                          //                 Icons.miscellaneous_services),
                          //             itemBuilder: (context) {
                          //               return updatedata!.data!.server!
                          //                   .map((data) {
                          //                 return PopupMenuItem<String>(
                          //                   value: data.url,
                          //                   child: Row(
                          //                     mainAxisAlignment:
                          //                         MainAxisAlignment
                          //                             .spaceBetween,
                          //                     children: [
                          //                       Text(data.name.toString()),
                          //                       if (selectedUrl == data.url)
                          //                         const Icon(
                          //                           Icons.check_circle,
                          //                           color: Colors.green,
                          //                           size: 20,
                          //                         )
                          //                     ],
                          //                   ),
                          //                 );
                          //               }).toList();
                          //             },
                          //             onSelected: (value) {
                          //               Common.saveSharedPref("url", value);
                          //               selectedUrl = value;
                          //               serverChoose = true;
                          //               setState(() {});
                          //             })
                          //         : const SizedBox(),
                          //   ),
                          // ),
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
                                 
                                  Container(
                                    child: Align(
                                      child: updatedata!.data!.server!.length >
                                              1
                                          ? PopupMenuButton(
                                              key: popupMenuKey,
                                              child: const Text(
                                                "Select Server",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              itemBuilder: (context) {
                                                return updatedata!.data!.server!
                                                    .map((data) {
                                                  return PopupMenuItem<String>(
                                                    value: data.url,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(data.name
                                                            .toString()),
                                                        if (selectedUrl ==
                                                            data.url)
                                                          const Icon(
                                                            Icons.check_circle,
                                                            color: Colors.green,
                                                            size: 20,
                                                          )
                                                      ],
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                              onSelected: (value) {
                                                Common.saveSharedPref(
                                                    "url", value);
                                                selectedUrl = value;
                                                serverChoose = true;
                                                setState(() {});
                                              },
                                            )
                                          : const SizedBox(),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      FocusScope.of(context).unfocus();
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
                                     // if (serverChoose == true) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPassword()),
                                        );
                                      // } else {
                                      //   Common.toastMessaage(
                                      //       'Choose a server', Colors.red);
                                      //   openPopupMenu();
                                      // }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      // child: Column(
                                      //   crossAxisAlignment:
                                      //       CrossAxisAlignment.start,
                                      //   children: [
                                      //     Container(
                                      //       alignment: Alignment.center,
                                      //       child: Text(
                                      //         "Forgot Password?",
                                      //         style: TextStyle(
                                      //           color: textColor,
                                      //           fontWeight: FontWeight.bold,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     Container(
                                      //       child: Align(
                                      //         child: updatedata!.data!.server!
                                      //                     .length >
                                      //                 1
                                      //             ? PopupMenuButton(
                                      //                 key: popupMenuKey,
                                      //                 child: Text(
                                      //                   "Select Server",
                                      //                   style: TextStyle(
                                      //                     fontWeight:
                                      //                         FontWeight.bold,
                                      //                     color: Colors.blue,
                                      //                   ),
                                      //                 ),
                                      //                 itemBuilder: (context) {
                                      //                   return updatedata!
                                      //                       .data!.server!
                                      //                       .map((data) {
                                      //                     return PopupMenuItem<
                                      //                         String>(
                                      //                       value: data.url,
                                      //                       child: Row(
                                      //                         mainAxisAlignment:
                                      //                             MainAxisAlignment
                                      //                                 .spaceBetween,
                                      //                         children: [
                                      //                           Text(data.name
                                      //                               .toString()),
                                      //                           if (selectedUrl ==
                                      //                               data.url)
                                      //                             const Icon(
                                      //                               Icons
                                      //                                   .check_circle,
                                      //                               color: Colors
                                      //                                   .green,
                                      //                               size: 20,
                                      //                             )
                                      //                         ],
                                      //                       ),
                                      //                     );
                                      //                   }).toList();
                                      //                 },
                                      //                 onSelected: (value) {
                                      //                   Common.saveSharedPref(
                                      //                       "url", value);
                                      //                   selectedUrl = value;
                                      //                   serverChoose = true;
                                      //                   setState(() {});
                                      //                 },
                                      //               )
                                      //             : const SizedBox(),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
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
  // Future<dynamic> staffDialog(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return AlertDialog(
  //             title: const Center(child: Text("Choose Server")),
  //             content: SizedBox(
  //               height: updatedata!.data!.server!.length * 50,
  //               width: MediaQuery.of(context).size.width * .2,
  //               child: ListView.builder(
  //                 itemCount: updatedata!.data!.server!.length,
  //                 physics: const ScrollPhysics(),
  //                 shrinkWrap: true,
  //                 itemBuilder: (context, index) {
  //                   return ListTile(
  //                       onTap: () {
  //                         Common.saveSharedPref(
  //                             "url", updatedata!.data!.server![index].url!);
  //                         serverChoose = true;
  //                         setState(() {});
  //                         if (context.mounted) {
  //                           Navigator.pop(context);
  //                         }
  //                       },
  //                       title: Text(updatedata!.data!.server![index].name!));
  //                 },
  //               ),
  //             ));
  //       });
  //     },
  //   );
  // }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
