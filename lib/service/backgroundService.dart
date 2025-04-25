// ignore_for_file: file_names, avoid_print

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:call_e_log/call_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/service/service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/common.dart';
import '../models/backgroundModel.dart';
import '../models/callLogUploadPermissionModel.dart';
import '../models/callLogs/callLogUploadModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:login2/main.dart';

PhoneState status11 = PhoneState.nothing();

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
  try {
    PhoneState.stream.listen((event) {
      log('Phone state changed: ${event.status}');
      status1 = event;
      handleCallState(event); 
    });
  } catch (e) {
    log('Error listening to phone state: ${e.toString()}');
  }
}



// Platform channel
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
  if (Platform.isAndroid) {
    DartPluginRegistrant.ensureInitialized();
    requestPermissions();
    // await Hive.initFlutter();  // Initialize Hive
    // await Hive.openBox('callHistoryBox');
    try {
          await HiveUtil.init();
  await HiveUtil.safeOpenBox<HiveCaallHistoryModel>(HiveUtil.CALL_HISTORY_BOX);

    } catch (e) {
      log('error on initializing hive: $e');      
    }
  }

  if (service is AndroidServiceInstance) {
    service.on('reboot').listen((event) {
      onDeviceReboot();
      service.setAsBackgroundService();
    });

    service.on('setAsForeground').listen((event) {
       service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });

    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      showWindow();
      isWindowActive();
    }
    service.invoke('update');
  });
}

Future<void> requestPermissions() async {
  if (await Permission.phone.status.isDenied) {
    await Permission.phone.request();
  }
   if (await Permission.nearbyWifiDevices.isDenied) {
    await Permission.nearbyWifiDevices.request();
  }
  if (await Permission.phone.isGranted) {
    log('Phone permission granted');
    setStream();
  } else {
    log('Phone permission denied');
  }
}

@pragma('vm:entry-point')
Future<void> callBack(String tag) async {
  WidgetsFlutterBinding.ensureInitialized();
  log('callBack event called');
  log("callBack event of $tag");
  // const MethodChannel appChannel = MethodChannel('app_channel'); 

  switch (tag) {
    case "open_button":
      final intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('example1://gizmos1/'),
        package: 'com.android.chrome',
      );
      intent.launch();
      break;
    case "close_button":
      await Common.saveSharedPref("openAppLeadId", '0');
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

final container = ProviderContainer(); // Create a Riverpod container

void isWindowActive() {
  final status = container.read(phoneStateProvider);
  switch (status.status) {
    case PhoneStateStatus.NOTHING:
      isActive = false;
      doUpload = true;
      break;
    case PhoneStateStatus.CALL_INCOMING:
    case PhoneStateStatus.CALL_STARTED:
      isActive = true;
      uploadCall = false;
      doUpload = true;
      fromTime = DateTime.now().millisecondsSinceEpoch;
      toTime = DateTime.now().millisecondsSinceEpoch;
      break;
    case PhoneStateStatus.CALL_ENDED:
      isActive = false;
      break;
  }
}

void showWindow() async {
  final status1 = container.read(phoneStateProvider); // Get latest status1
  log('~~ Updated status: ${status1.status} ~~');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> callTypes = prefs.getStringList('callTypes') ?? [];
  await HiveUtil.init();

  if (!isActive) {
    switch (status1.status) {
      case PhoneStateStatus.NOTHING:
        break;
      case PhoneStateStatus.CALL_INCOMING || PhoneStateStatus.CALL_STARTED:
       log('~~ CALL_INCOMING ~~~');
        Map<String, dynamic> body1 = {
          "token": await Common.getSharedPref("token"),
          'phoneNumber': status1.number,
        };
        log('~~ body1 : $body1 ~~~');

        BackgroundModel object = await HttpService.backgroundData(body1);
        log('openAppLeadId${object.data.callMasterId}');
         log('openAppLeadId : ${object.data.callMasterId}');
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
      // return;
        // log('~~ CALL_ENDED ~~~');
        // log('~~ uploadCall : $uploadCall ~~~');
        // log('~~ uploadCall : $doUpload ~~~');
        //! new logic
        history.clear();
          if (uploadCall == false && doUpload == true) {
           log('~~~~~~~~~~ UPLOADING ~~~~~~~~~~~');
           doUpload = false;

           Map<String, dynamic> body2 = {
            "token": await Common.getSharedPref("token"),
          };
         log('~~ body2 : $body2 ~~~');
         log('~~ body2 : ${Common.getSharedPref("token")} ~~~');

          CallLogUploadPermissionModel perm =  await HttpService.callLogUploadPermission(body2);
          log('sortedLogs data :${perm.data!}');
          log('sortedLogs status :${perm.status!}');

          if (perm.status == true) {
            log('sortedLogs permission :${perm.data!.outgoing}');

            //! get hive last call log
             var callLog = await HiveUtil.getCallLogCount();
            //! get call log from device after filtering
              final String dateTimeFrom = prefs.getString('callLogsStartingTime').toString();
             final DateTime startingTime = DateTime.parse(dateTimeFrom);
             List<CallLogEntry> logs = await getFilteredCallLogs(startingTime);
             for (var log in logs) {
                print('📞 ${log.name} | ${log.number} | ${log.callType} | ${log.phoneAccountId} | ${log.simDisplayName}');
              }


               if (callLog == 0 )  {
                  log('No call logs found in Hive.');
                  log('~~ callLog : $callLog ~~~');
                   String callLogsStartingTime =  prefs.getString('callLogsStartingTime').toString();
                  final DateTime startingTime = DateTime.parse(callLogsStartingTime);
                   List<CallLogEntry> filteredLogs = logs.where((entry) {
                    // Assuming entry.timestamp is in millisecondsSinceEpoch
                    DateTime callTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp!);
                    return callTime.isAfter(startingTime);
                  }).toList();
                  filteredLogs.sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
                    history.clear();
                    for (var log in filteredLogs) {
                      print('logHistory : ${log.name.toString()}  | ${log.number.toString()} | ${log.callType.toString()} | ${log.phoneAccountId.toString()}');
                      history.add({
                        "name": log.name,
                        "phone_number": log.number,
                        "callTypes": log.callType.toString()
                            .substring(log.callType.toString().indexOf('.') + 1),
                        "time": '${DateTime.fromMillisecondsSinceEpoch(log.timestamp!)}',
                        "duration": log.duration,
                        "simName": log.simDisplayName ?? "NIL",
                        "timeStamp": log.timestamp,
                      });
                    }
                } else {
                   log("~ Hive is not null");
                   logs.sort((a, b) => (b.timestamp ?? 0).compareTo(a.timestamp ?? 0));
                   CallLogEntry? latest = logs.isNotEmpty ? logs[0] : null;
                   CallLogEntry? previous = logs.length > 1 ? logs[1] : null;

                    if (latest != null) {
                      print("📞 Latest Call: ${latest.number} at ${DateTime.fromMillisecondsSinceEpoch(latest.timestamp ?? 0)}");
                    }
                    if (previous != null) {
                      print("📞 Previous Call: ${previous.number} at ${DateTime.fromMillisecondsSinceEpoch(previous.timestamp ?? 0)}");
                    }

                     final List<HiveCaallHistoryModel> callLogs = await HiveUtil.getAllCallLogs();
                      log('~~ callLogs : $callLogs ~~~');
                      log('~~ callLogs length : ${callLogs.length} ~~~');
                      log('~~ callLogs : ${callLogs.first.name} ~~~');
                      log('~~ callLogs : ${callLogs.first.phoneNumber} ~~~');
                      log('~~ callLogs : ${callLogs.first.callType} ~~~');
                      log('~~ callLogs : ${callLogs.first.timeStamp} ~~~');

                          final HiveCaallHistoryModel latestHiveCallLog= callLogs.first;
                          log('~~ latestHiveCallLog : ${latestHiveCallLog.name} ~~~');
                          log('~~ latestHiveCallLog : ${latestHiveCallLog.phoneNumber} ~~~');

                     if (previous != null) {
                       DateTime previousTime = DateTime.fromMillisecondsSinceEpoch(previous.timestamp!);

                          
                            final String callTimeString = latestHiveCallLog.timeStamp; //callLog['time'];
                            log('~~ callTimeString : $callTimeString ~~~');

                            // Choose the correct parser based on format
                            DateTime callLogTime;
                            if (callTimeString.contains('-') && callTimeString.contains('PM')) {
                              // Looks like custom format like "06-04-2025 03:09 PM"
                              final DateFormat format = DateFormat("dd-MM-yyyy hh:mm a");
                              callLogTime = format.parse(callTimeString);
                            } else if (callTimeString.contains('-') || callTimeString.contains(':')) {
                              // Standard ISO format like "2025-04-06 16:29:44.555"
                              callLogTime = DateTime.parse(callTimeString);
                            } else {
                              // It's a Unix timestamp in milliseconds
                              callLogTime = DateTime.fromMillisecondsSinceEpoch(int.parse(callTimeString));
                            }

                             log("✅ callLogTime: $callLogTime");

                              log( '~ previous NAME   : ${previous.name}');
                              log( '~ hive NAME       : ${latestHiveCallLog.name}');
                              log( '~ previous number : ${previous.number}');
                              log( '~ Hive number     : ${latestHiveCallLog.phoneNumber}');
                              log( '~ Previous time   : $previousTime');
                              log( '~ Hive time       : $callLogTime');

                              if (previous.number == latestHiveCallLog.phoneNumber && previousTime.isAtSameMomentAs(callLogTime) && latest!= null) {
                                  log( '~ Call log matches with previous call log.');
                                  history.clear();
                                  history.add({
                                      "name": latest.name ,
                                      "phone_number": latest.number,
                                      "callTypes": latest.callType.toString()
                                      .substring(latest.callType.toString().indexOf('.') + 1),
                                      "time": '${DateTime.fromMillisecondsSinceEpoch(latest.timestamp!)}',
                                      "duration": latest.duration,
                                      "simName": latest.simDisplayName ?? "NIL",
                                      "timeStamp": latest.timestamp,
                                    });
                              }else{
                                     log( '~ Call log not matches with previous call log.');
                                     log('latestHiveCallLog time : ${latestHiveCallLog.timeStamp}');
                                    // DateTime callLogTime = DateTime.parse(latestHiveCallLog.timeStamp);
                                    // log("✅ callLogTime: $callLogTime");

                                    List<CallLogEntry> matchingLogs = logs.where((entry) {
                                      if (entry.timestamp == null) return false;

                                      DateTime entryTime = DateTime.fromMillisecondsSinceEpoch(entry.timestamp!);
                                      return entryTime.isAfter(callLogTime);
                                    }).toList();

                                    // log('Matching logs: $matchingLogs');
                                    log('Matching logs length: ${matchingLogs.length}');
                                    log('Matching logs first: ${matchingLogs.first.name}');

                                    history.clear();
                                    for (var log in matchingLogs) {
                                      print('logHistory : ${log.name.toString()}  | ${log.number.toString()} | ${log.callType.toString()} | ${log.timestamp.toString()}');
                                      history.add({
                                        "name": log.name,
                                        "phone_number": log.number,
                                        "callTypes": log.callType.toString().substring(log.callType.toString().indexOf('.') + 1),
                                        "time": DateTime.fromMillisecondsSinceEpoch(log.timestamp!).toString(),
                                        "duration": log.duration,
                                        "simName": log.simDisplayName ?? "NIL",
                                        "timeStamp": log.timestamp,
                                      });
                                    }
                                    log('~~ OUTGOING CALL history : $history ~~~');
                                    log('~~ OUTGOING CALL body : ${history.length} ~~~');


                              }
                     }



                }
                        // log('~~ OUTGOING CALL history : $history ~~~');
                        //   log('~~ OUTGOING CALL body : ${history.length} ~~~');
                        //   Map<String, dynamic> body = {
                        //     "token": await Common.getSharedPref("token"),
                        //     'log': history,
                        //   };
                        //   log('~~ OUTGOING CALL body : $body ~~~');
                        //   log('~~ OUTGOING CALL body length : ${body.length} ~~~');
                        //   // ! upload all call logs

                        //   CallLogUploadModel object1 =
                        //       await HttpService.callLogUpload(body);
                        //   log('~~ OUTGOING CALL object1 : ${object1.data} ~~~');


                          //! save all call logs to hive
                          List<HiveCaallHistoryModel> hiveCallAddList =[];
                          List<String> callTypesQ = prefs.getStringList('callTypes') ?? [];
                          log('callTypes : $callTypesQ');
                          for (var log in history) {
                             bool isAllowed = false ;

                            if (callTypesQ.contains('Incoming') && log['callTypes'].toString().contains('incoming')) {
                              isAllowed = true;
                            } else if (callTypesQ.contains('Outgoing') && log['callTypes'].toString().contains('outgoing')) {
                              isAllowed = true;
                            }

                            print('isAllowed : $isAllowed');

                            final callLog = HiveCaallHistoryModel(
                              id: log['timeStamp'].toString(),
                              name: log['name'].toString(),
                              phoneNumber: log['phone_number'].toString(),
                              callType: log['callTypes'].toString(),
                              duration: log['duration'].toString(),
                              timeStamp: log['timeStamp'].toString(),
                              simSlot: log['simName'].toString(),
                              callRecordFilePath: 'N/A',
                              isUploaded: true,
                              isDeleted:false,
                              isEnabled    : isAllowed
                            );
                            print('callLog 999: ${callLog.name} || ${callLog.isUploaded}');
                            // await HiveUtil.addCallLog(callLog);
                            hiveCallAddList.add(callLog);
                          }
                           List<HiveCaallHistoryModel> allowedCallLogs = hiveCallAddList
                                  .where((log) => log.isEnabled == true)
                                  .toList();

                              // Debug
                              log('allowedCallLogs (for upload): ${allowedCallLogs.length}');

                              // Proceed with upload only for allowed items
                              if (allowedCallLogs.isNotEmpty) {
                                await uploadMissingLogsToServer(allowedCallLogs);   
                              }
                              if(hiveCallAddList.isNotEmpty){
                           await HiveUtil.addCallLogs(hiveCallAddList);
                              }

                //             if (object1.data == true) {
                //   log('~~ OUTGOING CALL success ~~~');
                //   log('success');
                // } else {
                //   log('~~ OUTGOING CALL failure ~~~');
                //   log('failure');
                // }



              }

          }
        uploadCall = true;
        break;
      default:
    }
  }
}


 Future<void> uploadMissingLogsToServer(List<HiveCaallHistoryModel> callLogData) async {
 log("uploadMissingLogsToServer function called");

     List<Map<String, dynamic>> missingLogs = callLogData.map((log) => {
          "name": log.name,
          "phone_number": log.phoneNumber,
          "callTypes": log.callType 
                  .toString()
                  .substring(log.callType.toString().indexOf('.') + 1),
          // "time": DateTime.parse(log.timeStamp).toString(),
          "time": DateTime.fromMillisecondsSinceEpoch(int.parse(log.timeStamp)).toString(), // log.timestamp,
          // "time": log.timeStamp.toString(), // log.timestamp,
          "duration": log.duration,
          "simName": log.simSlot ?? "NIL",
          "timeStamp": log.timeStamp,
        }).toList();

        log("⚠️ Found ${missingLogs.length} missing logs.");

         if (missingLogs.isNotEmpty) {

       log('~~ OUTGOING CALL missingLogs : $missingLogs ~~~');
                log('~~ OUTGOING CALL length : ${missingLogs.length} ~~~');

       Map<String, dynamic> body = {
                  "token": await Common.getSharedPref("token"),
                  'log': missingLogs,
                };
                log('~~ OUTGOING CALL BODY : $body ~~~');



      CallLogUploadModel object1 =
                    await HttpService.callLogUpload(body);
                log('~~ OUTGOING CALL missingLogs object : ${object1.data} ~~~');
      // await HiveUtil.saveCallLog(missingLogs.last);
      if (object1.data == true) {
                  log('~~ OUTGOING CALL success ~~~');
                  log('success');
                } else {
                  log('~~ OUTGOING CALL failure ~~~');
                  log('failure');
                }
    }
 }

void onDeviceReboot() {
  log('Device has rebooted!');
}

Future<void> handleCallState(PhoneState event) async {
  switch (event.status) {
    case PhoneStateStatus.CALL_INCOMING:
      log('Incoming call from ${event.number}');
      break;
    case PhoneStateStatus.CALL_STARTED:
      log('Call started with ${event.number}');
      break;
    case PhoneStateStatus.CALL_ENDED:
      log('Call ended with ${event.number}');
      break;
    case PhoneStateStatus.NOTHING:
      log('No active call');
      break;
  }
}
