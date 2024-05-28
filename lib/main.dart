import 'dart:developer';
import 'dart:io';

import 'package:call_log/call_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:login2/screens/myApp.dart';
import 'package:login2/service/backgroundService.dart';
import 'package:workmanager/workmanager.dart';
MethodChannel _channel = const MethodChannel('onreBootInitFunctionChannel');
void callbackDispatcher() {
  Workmanager().executeTask((dynamic task, dynamic inputData) async {
    print('Background Services are Working!');
    try {
      final Iterable<CallLogEntry> cLog = await CallLog.get();
      print('Queried call log entries');
      for (CallLogEntry entry in cLog) {
        print('-------------------------------------');
        print('F. NUMBER  : ${entry.formattedNumber}');
        print('C.M. NUMBER: ${entry.cachedMatchedNumber}');
        print('NUMBER     : ${entry.number}');
        print('NAME       : ${entry.name}');
        print('TYPE       : ${entry.callType}');
        print(
            'DATE       : ${DateTime.fromMillisecondsSinceEpoch(entry.timestamp!)}');
        print('DURATION   : ${entry.duration}');
        print('ACCOUNT ID : ${entry.phoneAccountId}');
        print('ACCOUNT ID : ${entry.phoneAccountId}');
        print('SIM NAME   : ${entry.simDisplayName}');
        print('-------------------------------------');
      }
      return true;
    } on PlatformException catch (e, s) {
      print(e);
      print(s);
      return true;
    }
  });
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid)
  {
    await initService();
    FlutterBackgroundService().invoke('setAsBackground');
  }
  await Firebase.initializeApp();
  runApp( const MyApp());
  if(Platform.isAndroid)
  {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'setAsBackgroundService') {
        initService();
        FlutterBackgroundService().invoke('setAsBackground');
        log("============== called : setAsBackgroundService  ===========================");
      }
    });
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }
}
