import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:call_e_log/call_log.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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
//  class PhoneStateNotifier extends StateNotifier<PhoneState> {
//   StreamSubscription<PhoneState>? _subscription;

//   PhoneStateNotifier() : super(PhoneState.nothing()) {
//     _listenToStream();
//   }

//   void _listenToStream() {
//     _subscription = PhoneState.stream.listen((event) {
//       state = event;
//       log("Updated status: ${state.status}");
//     });

//   }

//   @override
//   void dispose() {
//     _subscription?.cancel();
//     super.dispose();
//   }

// }

class PhoneStateNotifier extends StateNotifier<PhoneState> {
  StreamSubscription<PhoneState>? _subscription;
  bool _isFirstEmission = true;

  PhoneStateNotifier() : super(PhoneState.nothing()) {
    _listenToStream();
  }

  void _listenToStream() {
    if (Platform.isAndroid) {
      _subscription = PhoneState.stream.listen((event) {
        // Skip the first emission which is just the initial state
        if (_isFirstEmission) {
          _isFirstEmission = false;
          log("Skipping initial phone state emission");
          return;
        }

        state = event;
        log("Updated status: ${state.status}");
        // if (state.status == PhoneStateStatus.RINGING ||
        //     state.status == PhoneStateStatus.OFF_HOOK) {
        //   _showOverlay(state.number?.toString() ?? "");
        // }
      });
    } else {
      log("PhoneState listener skipped on non-Android platform");
    }
  }

  void _showOverlay(String number) {
    log("Should show overlay for number: $number");
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
String number = "";

void setStream1() {
  PhoneState.stream.listen((event) {
    status1 = event;
    if (status1.number != null) {
      number = status1.number.toString();
    }
  });
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  // setStream1();
  final container = ProviderContainer();
  final phoneNumber = container.read(phoneStateProvider);
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
  print("STARTING MAIN()");
  runZonedGuarded(() async {
    print("INSIDE runZonedGuarded");
    WidgetsFlutterBinding.ensureInitialized();
    print("WidgetsFlutterBinding initialized");
    
    try {
      if (Platform.isAndroid) {
        print("Initializing FlutterDownloader...");
        await FlutterDownloader.initialize(
            debug: true, // Set to false in production
            ignoreSsl: true // If your server uses SSL
        );
        print("FlutterDownloader initialized successfully");
      } else {
        print("Skipping FlutterDownloader initialization on ${Platform.operatingSystem} for debugging");
        // Initialization can also be done without await if it's causing issues, but guard is safer for now
      }
    } catch (e) {
      print("Error initializing FlutterDownloader: $e");
    }

    if (Platform.isAndroid) {
      print("Platform is Android, setting up background service...");
      try {
        final service = FlutterBackgroundService();
        bool isRunning = await service.isRunning();
        if (!isRunning) {
          await initService();
          service.invoke('setAsForeground');
        }
        print("Background service setup done");
      } catch (e) {
        print("Error starting background service: $e");
      }
    } else {
      print("Platform is ${Platform.operatingSystem}, skipping background service setup");
    }

    try {
      print("Initializing Hive...");
      await HiveUtil.init();
      await HiveUtil.safeOpenBox<HiveCaallHistoryModel>(
          HiveUtil.CALL_HISTORY_BOX);
      print("Hive initialized successfully");
    } catch (e) {
      print('error on initializing hive: $e');
    }

    try {
      print("Initializing Firebase...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase initialized successfully");
    } catch (e) {
      print("Error initializing Firebase: $e");
    }

    print("Executing runApp(const MyApp())");
    runApp(const MyApp());
    print("runApp called");

    if (Platform.isAndroid) {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'setAsBackgroundService') {
          final service = FlutterBackgroundService();
          bool isRunning = await service.isRunning();
          if (!isRunning) {
            await initService();
          }
          service.invoke('setAsBackground');
          log("============== called : setAsBackgroundService  ===========================");
        }
      });
      Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    }
  }, (error, stack) {
    print("CRITICAL: Uncaught error in main zone: $error");
    print(stack);
    log("Uncaught error in main zone: $error", stackTrace: stack);
  });
}
