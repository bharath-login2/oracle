// ignore_for_file: file_names

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:call_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/service/service.dart';
import 'package:phone_state/phone_state.dart';
// import 'package:system_alert_window/system_alert_window.dart';
import '../core/common.dart';
import '../models/backgroundModel.dart';
import '../models/callLogUploadPermissionModel.dart';
import '../models/callLogs/callLogUploadModel.dart';

PhoneState status1 = PhoneState.nothing();

Future<void> initService() async {
  // OverlayController controller =
  //     Get.put(OverlayController());
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
    log("Failed to invoke setAsBackgroundService: ${e.message}");
  }
}

@pragma("vm:entry-point")
void onStart(ServiceInstance service) async {
  if (Platform.isAndroid) {}
  DartPluginRegistrant.ensureInitialized();
  setStream();
  // SystemAlertWindow.registerOnClickListener(callBack);
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
    if (service is AndroidServiceInstance) {}
    showWindow();
    isWindowActive();

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
      // SystemAlertWindow.closeSystemWindow(
      //     prefMode: SystemWindowPrefMode.OVERLAY);
      break;
    case "close_button":
      await Common.saveSharedPref("openAppLeadId", '0');
      // SystemAlertWindow.closeSystemWindow(
      //     prefMode: SystemWindowPrefMode.OVERLAY);

      break;
    default:
      log("OnClick event of $tag");
  }
}

bool isActive = false;
bool uploadCall = false;
bool doUpload = true;
int fromTime = 0;
int toTime = 0;
List<Map<String, dynamic>> history = [];

void isWindowActive() async {
  switch (status1.status) {
    case PhoneStateStatus.NOTHING:
      isActive = false;
      doUpload = true;

      // showTextFieldWindow = false;
      break;

    case PhoneStateStatus.CALL_INCOMING:
    case PhoneStateStatus.CALL_STARTED:
      isActive = true;
      uploadCall = false;
      doUpload = true;
      fromTime = DateTime.now().millisecondsSinceEpoch;
      toTime = DateTime.now().millisecondsSinceEpoch;

      // showTextFieldWindow = true;

      break;

    case PhoneStateStatus.CALL_ENDED:
      isActive = false;

      break;

    default:
      isActive = false;
      doUpload = true;
    // showTextFieldWindow = false;
  }
}

void showWindow() async {
  if (!isActive) {
    switch (status1.status) {
      case PhoneStateStatus.NOTHING:
        break;

      case PhoneStateStatus.CALL_INCOMING:
        Map<String, dynamic> body1 = {
          "token": await Common.getSharedPref("token"),
          'phoneNumber': status1.number,
        };

        BackgroundModel object = await HttpService.backgroundData(body1);

        log('openAppLeadId${object.data.callMasterId}');
        await Common.saveSharedPref(
            "openAppLeadId", object.data.callMasterId.toString());

        if (await FlutterOverlayWindow.isActive()) return;
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Login2 Pro",
          overlayContent: 'Overlay Enabled',
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: 500,
          width: WindowSize.matchParent,
          startPosition: const OverlayPosition(0, 0),
        );

        break;

      case PhoneStateStatus.CALL_ENDED:
        log('~~ CALL_ENDED ~~~');
        if (uploadCall == false && doUpload == true) {
          log('~~~~~~~~~~ UPLOADING ~~~~~~~~~~~');
          doUpload = false;

          Map<String, dynamic> body2 = {
            "token": await Common.getSharedPref("token"),
          };
          CallLogUploadPermissionModel perm =
              await HttpService.callLogUploadPermission(body2);
          if (perm.status == true) {
            log('permission :${perm.data!.outgoing}');
            var callLogs = await CallLog.get();
            var logsForNumber =
                callLogs.where((log) => log.number == status1.number);
            var sortedLogs = logsForNumber.toList()
              ..sort((a, b) => b.timestamp!.compareTo(a.timestamp as num));
            if (sortedLogs.isNotEmpty) {
              var lastCall = sortedLogs.first;
              var callType = lastCall.callType
                  .toString()
                  .substring(lastCall.callType.toString().indexOf('.') + 1);
              //  log(callType);
              if (perm.data!.outgoing == true && callType == 'outgoing') {
                log(await Common.getSharedPref("token"));
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
                CallLogUploadModel object1 =
                    await HttpService.callLogUpload(body);
                if (object1.data == true) {
                  log('success');
                  PhoneStateStatus.NOTHING;
                } else {
                  log('failure');
                }
              } else if (perm.data!.incoming == true) {
                if (callType == 'incoming' || callType == 'missed') {
                  history.add({
                    "name": lastCall.name,
                    "phone_number": lastCall.number,
                    "callTypes": lastCall.callType.toString().substring(
                        lastCall.callType.toString().indexOf('.') + 1),
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
                  CallLogUploadModel object1 =
                      await HttpService.callLogUpload(body);
                  if (object1.data == true) {
                    log('success');
                  } else {
                    log('failed');
                  }
                }
              }
            } else {
              log('No call logs found for ${status1.number}');
            }
          }
        }
        uploadCall = true;
        break;

      default:
    }
  }
}

void onDeviceReboot() {
  log('Device has rebooted!');
}
