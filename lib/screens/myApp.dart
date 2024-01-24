import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:login2/screens/splashScreen.dart';

import '../core/common.dart';
import '../key.dart';
import 'leadManagement/leadDetails.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool sts=true;
  String? token;
  bool? editLead;
  bool? deleteLead;
  bool? cloudCall;
  String? navigation;
  String? detailId;
  @override
  void initState() {

    super.initState();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      token = await Common.getSharedPref("token");
      setState(() {
        sts=false;
        detailId=message.data['detail_id'];
        if(message.data['edit_lead']=='true')
        {
          editLead=true;
        }
        else{
          editLead=false;
        }
        if(message.data['delete_lead']=='true')
        {
          deleteLead=true;
        }
        else{
          deleteLead=false;
        }
        if(message.data['cloud_call']=='true')
        {
          cloudCall=true;
        }
        else{
          cloudCall=false;
        }
      });


    });

  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NoomiKeys.navKey,
      home: sts==true?const SplashScreen():LeadDetails(token!,editLead!,deleteLead!,cloudCall!,detailId!,pageName: 'notification'),
    );
  }
}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the background message here (if needed)
  print("onMessageOpenedApp: $message");

}
