import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:login2/screens/splashScreen.dart';
import 'package:login2/screens/authentication/deep_link_handler.dart';
import '../key.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize deep link listening globally
    log('[DEEPLINK] MyApp: Starting global listener');
    DeepLinkHandler().startListening((link) {
      log('[DEEPLINK] MyApp: Received link from stream: $link');
      DeepLinkHandler().handleAppLink(link);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: NoomiKeys.navKey,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}
