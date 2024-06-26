// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:login2/screens/leadManagement/leadDetails.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import 'package:login2/screens/pushNotificationChannel.dart';
import 'package:login2/screens/splashScreen.dart';
// import '../core/common.dart';
import '../key.dart';
// import 'leadManagement/leadDetails.dart';
// import 'officialWhatsapp/chatScreen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // bool sts = true;
  // String? token;
  // bool? editLead;
  // bool? deleteLead;
  // bool? cloudCall;
  // String? navigation;
  // String? detailId;
  // bool notification = false;
  // final firebaseServices = FirebaseServices();
  @override
  void initState() {
    super.initState();
    // firebaseServices.init(context);
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //   notification = true;
    //   setState(() {
    //     sts = false;
    //     detailId = message.data['detail_id'];
    //     navigation = message.data['navigation'];
    //     if (message.data['edit_lead'] == 'true') {
    //       editLead = true;
    //     } else {
    //       editLead = false;
    //     }
    //     if (message.data['delete_lead'] == 'true') {
    //       deleteLead = true;
    //     } else {
    //       deleteLead = false;
    //     }
    //     if (message.data['cloud_call'] == 'true') {
    //       cloudCall = true;
    //     } else {
    //       cloudCall = false;
    //     }
    //   });
    // });

    //   if (navigation == 'whatsapp') {
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => ChatScreen(
    //             groupId: detailId.toString(),
    //           ),
    //         ));
    //   } else {
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => LeadDetails(
    //             token!,
    //             editLead!,
    //             deleteLead!,
    //             cloudCall!,
    //             detailId!,
    //             pageName: 'notification',
    //           ),
    //         ));
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NoomiKeys.navKey,
      home: const SplashScreen(),
      // home: navigation == 'whatsapp'
      //     ? ChatScreen(
      //         groupId: detailId.toString(),
      //       )
      //     : sts == true
      //         ? notification == false
      //             ? const SplashScreen()
      //             : null
      //         : LeadDetails(
      //             token!,
      //             editLead!,
      //             deleteLead!,
      //             cloudCall!,
      //             detailId!,
      //             pageName: 'notification',
      //           ),
    );
    
  }
}
