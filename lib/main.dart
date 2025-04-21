import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:call_e_log/call_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login2/firebase_options.dart';
import 'package:login2/hive/call_logs/HiveCaallHistoryModel.dart';
import 'package:login2/hive/call_logs/call_logs_hive_functions.dart';
import 'package:login2/screens/myApp.dart';
import 'package:login2/screens/overlay/overlay.dart';
import 'package:login2/service/backgroundService.dart';
import 'package:phone_state/phone_state.dart';
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
//! n1
 class PhoneStateNotifier extends StateNotifier<PhoneState> {
  StreamSubscription<PhoneState>? _subscription;

  PhoneStateNotifier() : super(PhoneState.nothing()) {
    _listenToStream();
  }



  void _listenToStream() {
    _subscription = PhoneState.stream.listen((event) {
      state = event; 
      log("Updated status: ${state.status}");
    });

  }



  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

}



final phoneStateProvider =

    StateNotifierProvider<PhoneStateNotifier, PhoneState>(

  (ref) => PhoneStateNotifier(),

);


//!
PhoneState status1 = PhoneState.nothing();
String number ="";

void setStream1() {
  PhoneState.stream.listen((event) {
    status1 = event;
    if(status1.number != null){
      number = status1.number.toString();
    }
    });
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  // setStream1();
   final container = ProviderContainer();
  final phoneNumber= container.read(phoneStateProvider); 
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TrueCallerOverlay(
          number: phoneNumber.number.toString(),
        ),
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
   final service = FlutterBackgroundService();
  
  bool isRunning = await service.isRunning();
  
  if (isRunning) {
    service.invoke('stopService');
  }

  await initService();
  service.invoke('setAsForeground');
  }

  // await Hive.initFlutter();
  // Hive.registerAdapter(HiveCaallHistoryModelAdapter());
  // await Hive.openBox<HiveCaallHistoryModel>('callHistoryBox');
  try {
     await HiveUtil.init();
  await HiveUtil.safeOpenBox<HiveCaallHistoryModel>(HiveUtil.CALL_HISTORY_BOX);

  } catch (e) {
    log('error on initializing hive: $e');
  }
   // Hive.registerAdapter(HiveCaallHistoryModelAdapter());
  // await Hive.openBox<HiveCaallHistoryModel>('callHistoryBox');
  
  // await Firebase.initializeApp();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  if (Platform.isAndroid) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'setAsBackgroundService') {
             final service = FlutterBackgroundService();
  
              bool isRunning = await service.isRunning();
              
              if (isRunning) {
                service.invoke('stopService');
              }

              await initService();
              service.invoke('setAsBackground');
        log("============== called : setAsBackgroundService  ===========================");
      }
    });
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  }
}
