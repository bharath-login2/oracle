import '../../models/pushNotificationModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class FirebaseServices {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final initializationSettings = const  InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'));
  Future<String?> get token => FirebaseMessaging.instance.getToken();
  void init(BuildContext context) {
    _initNotification(context);
  }
  void _initNotification(BuildContext context) {
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        // onSelectNotification: (String? payload) async {
        //   if (payload != null) {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (context) => Login()),
        //     );
        //   }
        // }
        );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final fbNotification = PushNotificationModel.fromJson(
          Map<String, dynamic>.from(message.data));
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'Login2', 'Login2',
          importance: Importance.max,
          priority: Priority.high,
          ticker: fbNotification.message,
        //sound: const RawResourceAndroidNotificationSound('abc'),
      );
      var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          fbNotification.notificationId ?? 0,
          fbNotification.title,
          fbNotification.message,
          platformChannelSpecifics,
          payload: fbNotification.toString());
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      print('aaa');

    });
    FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('cc');

  }

}
