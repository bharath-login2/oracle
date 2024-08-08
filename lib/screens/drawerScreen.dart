// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:login2/main.dart';
import 'package:login2/screens/leadManagement/webview.dart';
import 'package:login2/service/backgroundService.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:workmanager/workmanager.dart';
import '../../core/common.dart';
import '../../models/commonsettingsModel.dart';
import '../../screens/authentication/login.dart';
import '../../screens/changePassword.dart';
import '../../screens/homePage.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/updateModel.dart';

class DraweScreen extends StatefulWidget {
  String token;

  DraweScreen(this.token, {super.key});

  @override
  _DraweScreenState createState() => _DraweScreenState();
}

class _DraweScreenState extends State<DraweScreen> {
  bool? result = true;
  bool? result1 = true;
  CommonSettingsModel? commmon;
  String name = '';
  String role = '';
  bool isVisible = true;
  final List<Color> _textColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];
  int _currentColorIndex = 0;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );
  UpdateModel? updatedata;
  final MethodChannel _channel =
      const MethodChannel('onreBootInitFunctionChannel');

  @override
  void initState() {
    super.initState();
    getData();
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _currentColorIndex = (_currentColorIndex + 1) % _textColors.length;
    });
  }

  getData() async {
    name = await Common.getSharedPref("name");
    role = await Common.getSharedPref("role");

    setState(() {
      result = result1;
    });
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    commmon = await HttpService.commonSettings();
    if (commmon != null) {
      updatedata = await HttpService.forceUpdate();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
        ),
        child: SizedBox(
          width: 250,
          child: Drawer(
              child: commmon != null
                  ? Column(
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                // Colors.purple,
                                Color(0xFF406dbe),
                                Colors.white,
                                Color(0xFF406dbe),
                              ])),
                          child: DrawerHeader(
                              child: Center(
                            child: Image.asset('assets/main/logo.png',
                                height: 130, fit: BoxFit.contain),
                          )),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              ListTile(
                                leading: SizedBox(
                                    width: 25,
                                    child: Center(
                                      child: Image.asset(
                                          'assets/icons/home.png',
                                          height: 100,
                                          fit: BoxFit.contain),
                                    )),
                                title: const Text('Home'),
                                onTap: () => {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HomePage(widget.token)),
                                  ),
                                },
                              ),
                              // ListTile(
                              //   leading: SizedBox(
                              //       width: 25,
                              //       child: Center(
                              //         child: Image.asset('assets/main/user.png',
                              //             height: 120, fit: BoxFit.contain),
                              //       )),
                              //   title: const Text('Profile'),
                              //   onTap: () => {
                              //
                              //   },
                              // ),
                              ListTile(
                                leading: SizedBox(
                                    width: 25,
                                    child: Center(
                                      child: Image.asset(
                                          'assets/main/padlock.png',
                                          height: 100,
                                          fit: BoxFit.contain),
                                    )),
                                title: const Text('Change Password'),
                                onTap: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UserChangePassword(widget.token)),
                                  ),
                                },
                              ),
                              ListTile(
                                leading: SizedBox(
                                    width: 25,
                                    child: Center(
                                      child: Image.asset(
                                          'assets/main/insurance.png',
                                          height: 100,
                                          fit: BoxFit.contain),
                                    )),
                                title: const Text('Privacy T&C'),
                                onTap: () async => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const WebViewPage(
                                            'Privacy T&C',
                                            'https://myaccount.login2.in/privacy_policy.html')),
                                  ),
                                },
                              ),
                              ListTile(
                                leading: SizedBox(
                                    width: 25,
                                    child: Center(
                                      child: Image.asset(
                                          'assets/icons/notification.png',
                                          height: 100,
                                          fit: BoxFit.contain),
                                    )),
                                title: const Text('Notification Settings'),
                                onTap: () {
                                  AppSettings.openAppSettings(
                                      type: AppSettingsType.notification);
                                },
                              ),
                              // ListTile(
                              //   leading: SizedBox(
                              //       width: 25,
                              //       child: Center(
                              //         child: Image.asset(
                              //             'assets/icons/facebook.png',
                              //             height: 100,
                              //             fit: BoxFit.contain),
                              //       )),
                              //   title: const Text('Facebook Settings'),
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (context) =>
                              //               FacebookSettings(widget.token)),
                              //     );
                              //   },
                              // ),
                              ListTile(
                                leading: SizedBox(
                                    width: 25,
                                    child: Center(
                                      child: Image.asset(
                                          'assets/icons/logout.png',
                                          height: 100,
                                          fit: BoxFit.contain),
                                    )),
                                title: const Text('Logout'),
                                onTap: () => logout(context),
                              ),
                            ],
                          ),
                        ),
                        Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Column(
                              children: [
                                updatedata != null
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        child:
                                            updatedata!.data!.currentVersion ==
                                                    _packageInfo.version
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'New Version Available',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: isVisible
                                                              ? _textColors[
                                                                  _currentColorIndex]
                                                              : Colors
                                                                  .transparent, // Text color when visible
                                                        ),
                                                      ),
                                                      InkWell(
                                                          onTap: () {
                                                            _launchURL(Platform
                                                                    .isIOS
                                                                ? 'https://apps.apple.com/us/app/login2/id6450980527'
                                                                : 'https://play.google.com/store/apps/details?id=com.login2');
                                                          },
                                                          child: const Icon(
                                                            Icons
                                                                .download_for_offline,
                                                            size: 30,
                                                          )),
                                                    ],
                                                  )
                                                : const SizedBox())
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 25, bottom: 30, top: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () async {
                                          final whatsappLink =
                                              "https://wa.me/${commmon!.data!.customerCareWhatsapp}";
                                          await launch(whatsappLink);
                                        },
                                        child: Image.asset(
                                          'assets/icons/whatsapp.png',
                                          fit: BoxFit.contain,
                                          width: 25,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          String url =
                                              'tel:+${commmon!.data!.customerCareCall}';
                                          await launch(url);
                                        },
                                        child: Image.asset(
                                            'assets/icons/telephone.png',
                                            fit: BoxFit.contain,
                                            width: 25),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final whatsappLink = commmon!
                                              .data!.supportUrl
                                              .toString();
                                          await launch(whatsappLink);
                                        },
                                        child: Image.asset(
                                            'assets/icons/web.png',
                                            fit: BoxFit.contain,
                                            width: 25),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )
                  : Center(
                      child: Lottie.asset('assets/main/loading.json',
                          fit: BoxFit.fill),
                    )),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    launchUrl(Uri.parse(url));
  }
}

const MethodChannel _channel = MethodChannel('onreBootInitFunctionChannel');

void logout(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: const Text('Are you sure to Logout?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No')),
            TextButton(
                onPressed: () {
                  Common.saveSharedPref("Logout", "success");
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Login()),
                      (Route<dynamic> route) => false);
                  if (Platform.isAndroid) {
                    _channel.setMethodCallHandler((call) async {
                      if (call.method == 'setAsBackgroundService') {
                        initService();
                        FlutterBackgroundService().invoke('setAsBackground');
                      }
                    });
                    Workmanager()
                        .initialize(callbackDispatcher, isInDebugMode: true);
                  }
                },
                child: const Text('Yes')),
          ],
        );
      });
}
