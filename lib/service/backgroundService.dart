import 'dart:async';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:login2/service/service.dart';
import 'package:phone_state/phone_state.dart';
import 'package:system_alert_window/system_alert_window.dart';
import '../core/common.dart';
import '../models/backgroundModel.dart';
import '../models/callLogUploadPermissionModel.dart';
import '../models/callLogs/callLogUploadModel.dart';


PhoneState status1 = PhoneState.nothing();

Future<void> initService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
    ),
  );
}

void setStream() {
  PhoneState.stream.listen((event) {
    if (event != null) {
      status1 = event;
    }
  });
}

// platform channel
const MethodChannel _channel = MethodChannel('onreBootInitFunctionChannel');

Future<void> setAsBackgroundService() async {
  try {
    await _channel.invokeMethod('setAsBackgroundService');
  } on PlatformException catch (e) {
    print("Failed to invoke setAsBackgroundService: ${e.message}");
  }
}

@pragma("vm:entry-point")
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  setStream();
  SystemAlertWindow.registerOnClickListener(callBack);
  if (service is AndroidServiceInstance) {
    service.on('reboot').listen((event) {
      onDeviceReboot();
      service.setAsBackgroundService();
    });

    service.on('setAsForeground').listen((event) {
     // service.setAsForegroundService();
      service.setAsBackgroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
      //service.setAsForegroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      // ! to show notification
      // service.setForegroundNotificationInfo(
      //   title: 'TEST NAME',
      //   content: 'Listen for calls..',
      // );
    }
    showWindow();
    isWindowActive();
    // callBackFunction(tag)
    // SystemAlertWindow.registerOnClickListener(callBackFunction);
    service.invoke('update');
  });
}

@pragma('vm:entry-point')
Future<void> callBack(String tag) async {
  WidgetsFlutterBinding.ensureInitialized();
  const MethodChannel _appChannel = MethodChannel('app_channel');

  switch (tag) {
    case "open_button":
      // navigate to to a specific app screen
      // openAppAndNavigate();
      final intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull('example1://gizmos1/'),
          package: 'com.android.chrome');
      intent.launch();
      SystemAlertWindow.closeSystemWindow(
          prefMode: SystemWindowPrefMode.OVERLAY);
      break;
    case "close_button":
      await Common.saveSharedPref("openAppLeadId", '0');
      SystemAlertWindow.closeSystemWindow(
          prefMode: SystemWindowPrefMode.OVERLAY);

      break;
    default:
      print("OnClick event of $tag");
  }
}

bool isActive = false;
bool uploadCall = false;
int fromTime = 0;
int toTime = 0;
List<Map<String, dynamic>> history = [];


void isWindowActive() async {
  switch (status1.status) {
    case PhoneStateStatus.NOTHING:
      isActive = false;

      // showTextFieldWindow = false;
      break;

    case PhoneStateStatus.CALL_INCOMING:
    case PhoneStateStatus.CALL_STARTED:
      isActive = true;
      uploadCall = false;
      fromTime = DateTime.now().millisecondsSinceEpoch;
      toTime = DateTime.now().millisecondsSinceEpoch;

      // showTextFieldWindow = true;

      break;

    case PhoneStateStatus.CALL_ENDED:
      isActive = false;

      break;

    default:
      isActive = false;
    // showTextFieldWindow = false;
  }
}

void showWindow() async {

  if (!isActive) {
    switch (status1.status) {
      case PhoneStateStatus.NOTHING:
        break;

      case PhoneStateStatus.CALL_INCOMING:
      case PhoneStateStatus.CALL_STARTED:
        // Show overlay
        //   if (await FlutterOverlayWindow.isActive()) return;
      Map<String, dynamic> body1 = {
        "token": await Common.getSharedPref("token"),
        'phoneNumber': status1.number!.replaceAll(RegExp('[^0-9]'), ''),
      };

          BackgroundModel object = await HttpService.backgroundData(body1);
          print('openAppLeadId${object.data!.callMasterId}');
      await Common.saveSharedPref("openAppLeadId", object.data!.callMasterId.toString());
          SystemWindowHeader header = SystemWindowHeader(
              title: SystemWindowText(
                  text: "Incoming Call", fontSize: 12, textColor: Colors.black45),
              padding: SystemWindowPadding.setSymmetricPadding(12, 12),
              subTitle: SystemWindowText(
                  text: "${status1.number}",
                  fontSize: 16,
                  fontWeight: FontWeight.BOLD,
                  textColor: Colors.black87),
              decoration: SystemWindowDecoration(startColor: Colors.blue),
              button: SystemWindowButton(
                  text: SystemWindowText(
                      text: object.data!.clientName.toString(),
                      fontSize: 16,
                      textColor: Colors.black,
                  fontWeight: FontWeight.BOLD),
                  tag: "personal_btn",
              decoration: SystemWindowDecoration(startColor: Colors.blue) ),
              buttonPosition: ButtonPosition.TRAILING);

          SystemWindowFooter footer = SystemWindowFooter(
              buttons: [
                SystemWindowButton(
                  text: SystemWindowText(
                      text: object.data!.createdDate.toString(), fontSize: 11, textColor: Colors.black),
                  tag: "date",
                  width: 0,
                  padding: SystemWindowPadding(right: 10, bottom: 10, top: 10),
                  height: SystemWindowButton.WRAP_CONTENT,
                  decoration: SystemWindowDecoration(
                      startColor:Colors.grey.shade200,
                      endColor: Colors.grey.shade200,),
                  margin: SystemWindowMargin(right: 25),
                ),
                SystemWindowButton(
                  text: SystemWindowText(
                      text: "Close", fontSize: 12, textColor: Colors.white),
                  tag: "close_button",
                  width: 0,
                  padding: SystemWindowPadding(
                      left: 10, right: 10, bottom: 7, top: 7),
                  height: 40,
                  decoration: SystemWindowDecoration(
                      startColor: Colors.red,
                      endColor: Colors.red,
                      borderWidth: 0,
                      borderRadius: 10),
                  margin: SystemWindowMargin(right: 10),
                ),
                SystemWindowButton(
                  text: SystemWindowText(
                      text: "Open", fontSize: 12, textColor: Colors.white),
                  tag: "open_button",
                  width: 0,
                  padding: SystemWindowPadding(
                      left: 10, right: 10, bottom: 7, top: 7),
                  height: 40,
                  decoration: SystemWindowDecoration(
                      startColor: Colors.green,
                      endColor: Colors.green,
                      borderWidth: 0,
                      borderRadius: 10),
                ),

              ],
              padding: SystemWindowPadding(right: 16, bottom: 12,top: 10),
              decoration:
              SystemWindowDecoration(startColor: Colors.grey.shade200),
              buttonsPosition: ButtonPosition.CENTER);

          SystemWindowBody body = SystemWindowBody(
            rows: [
              EachRow(
                columns: [
                  EachColumn(
                    text: SystemWindowText(
                        text: "Category",
                        fontSize: 14,
                        textColor: Colors.black,),
                    padding: SystemWindowPadding(
                        right: 70),
                  ),
                  EachColumn(
                    text: SystemWindowText(
                        text: object.data!.leadCategory.toString(),
                        fontSize: 14,
                        textColor: Colors.black,
                        fontWeight: FontWeight.BOLD),
                  ),
                ],
                gravity: ContentGravity.LEFT,
              ),
              EachRow(
                columns: [
                  EachColumn(
                    text: SystemWindowText(
                        text: "Last Update Date",
                        fontSize: 14,
                        textColor: Colors.black,),
                    padding: SystemWindowPadding(
                        right: 20),
                  ),
                  EachColumn(
                    text: SystemWindowText(
                        text: object.data!.lastCalledDate.toString(),
                        fontSize: 14,
                        textColor: Colors.black,
                        fontWeight: FontWeight.BOLD),
                  ),
                ],
                gravity: ContentGravity.LEFT,
                padding: SystemWindowPadding(
                    top: 10),
              ),
              EachRow(
                columns: [
                  EachColumn(
                    text: SystemWindowText(
                      text: "Last Remark",
                      fontSize: 14,
                      textColor: Colors.black,),
                    padding: SystemWindowPadding(
                        right: 50),
                  ),
                  EachColumn(
                    text: SystemWindowText(
                        text: object.data!.remark.toString(),
                        fontSize: 14,
                        textColor: Colors.black,
                        fontWeight: FontWeight.BOLD),
                  ),
                ],
                gravity: ContentGravity.LEFT,
                padding: SystemWindowPadding(
                    top: 10),
              ),
              EachRow(
                columns: [
                  EachColumn(
                    text: SystemWindowText(
                        text: "Last Status",
                        fontSize: 14,
                        textColor: Colors.black,),
                    padding: SystemWindowPadding(
                        right: 50),
                  ),
                  EachColumn(
                    text: SystemWindowText(
                        text: object.data!.status.toString(),
                        fontSize: 14,
                        textColor: Colors.black,
                        fontWeight: FontWeight.BOLD),
                  ),
                ],
                gravity: ContentGravity.LEFT,
                padding: SystemWindowPadding(
                    top: 10),
              ),
            ],
            padding:
            SystemWindowPadding(left: 16, right: 16, bottom: 5, top: 12),
            decoration: SystemWindowDecoration(startColor: Colors.grey.shade200),
          );
          SystemAlertWindow.showSystemWindow(
              height: 250,
              width: 340,
              header: header,
              body: body,
              footer: footer,
              margin: SystemWindowMargin(top: 100, bottom: 0),
              gravity: SystemWindowGravity.TOP,
              notificationTitle: "Incoming Call",
              notificationBody: "+1 646 980 4741",
              prefMode: SystemWindowPrefMode.OVERLAY);

      break;

      case PhoneStateStatus.CALL_ENDED:
        if (uploadCall == false ) {
          Map<String, dynamic> body2 = {
            "token": await Common.getSharedPref("token"),
          };
          CallLogUploadPermissionModel perm = await HttpService.callLogUploadPermission(body2);
          if(perm.status==true)
            {
            print('permission :${perm.data!.outgoing}');
              var callLogs = await CallLog.get();
              var logsForNumber =
              callLogs.where((log) => log.number == status1.number);
              var sortedLogs = logsForNumber.toList()
                ..sort((a, b) => b.timestamp!.compareTo(a.timestamp as num));
              if (sortedLogs.isNotEmpty) {
                var lastCall = sortedLogs.first;
                var callType=lastCall.callType
                    .toString()
                    .substring(lastCall.callType.toString().indexOf('.') + 1);
              //  print(callType);
                if(perm.data!.outgoing==true && callType=='outgoing') {
                  print('abc');
                  history.add({
                  "name": lastCall.name,
                  "phone_number": lastCall.number,
                  "callTypes": lastCall.callType.toString().substring(lastCall.callType.toString().indexOf('.') + 1),
                  "time":
                  '${DateTime.fromMillisecondsSinceEpoch(lastCall.timestamp!)}',
                  "duration": lastCall.duration,
                  "simName": lastCall.simDisplayName,
                  "timeStamp": lastCall.timestamp,
                });

                  Map<String, dynamic> body = {
                    "token": await Common.getSharedPref("token"),
                    'log': history,
                  };
                  CallLogUploadModel object1 = await HttpService.callLogUpload(body);
                  if (object1.data == true) {

                    print('success');
                  } else {
                    print('failure');
                  }
                }
                else if(perm.data!.incoming==true) {
                  if(callType=='incoming'|| callType=='missed') {
                    history.add({
                    "name": lastCall.name,
                    "phone_number": lastCall.number,
                    "callTypes": lastCall.callType
                        .toString()
                        .substring(lastCall.callType.toString().indexOf('.') + 1),
                    "time":
                    '${DateTime.fromMillisecondsSinceEpoch(lastCall.timestamp!)}',
                    "duration": lastCall.duration,
                    "simName": lastCall.simDisplayName,
                    "timeStamp": lastCall.timestamp,
                  });
                    Map<String, dynamic> body = {
                      "token": await Common.getSharedPref("token"),
                      'log': history,
                    };
                    CallLogUploadModel object1 = await HttpService.callLogUpload(body);
                    if (object1.data == true) {

                      print('success');
                    } else {
                      print('failure');
                    }
                  }
                }
              } else {
                print('No call logs found for ${status1.number}');

              }
            }





        }
        uploadCall = true;

        break;

      default:
    }
  }
}

// void showFormWindow() async {
//   //  if (await FlutterOverlayWindow.isActive()) return;
//   await FlutterOverlayWindow.showOverlay(
//     enableDrag: true,
//     overlayTitle: "X-SLAYER",
//     overlayContent: 'Overlay Enabled',
//     flag: OverlayFlag.defaultFlag,
//     visibility: NotificationVisibility.visibilityPublic,
//     positionGravity: PositionGravity.auto,
//     height:800,
//     width: WindowSize.matchParent,
//   );
// }

void onDeviceReboot() {
  print('Device has rebooted!');
}

// void openAppAndNavigate() async {
//   try {
//     await platform.invokeMethod('openAppAndNavigate');
//   } on PlatformException catch (e) {
//     print("Error: ${e.message}");
//   }
// }
