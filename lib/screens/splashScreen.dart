import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/common.dart';
import '../../models/loginCheckModel.dart';
import '../../models/updateModel.dart';
import '../../screens/authentication/login.dart';
import '../../screens/forceUpdate.dart';
import '../../screens/leadManagement/dashboard.dart';
import '../../service/service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final splashDelay = 2;
  bool? result = true;
  String? firebaseToken;
  UpdateModel? updatedata;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    handleAsync();
    getData();
  }

  handleAsync() async {
    firebaseToken = await FirebaseMessaging.instance.getToken();
  }

  getData() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      result = true;
    } else {
      result = false;
    }

    updatedata = await HttpService.forceUpdate();
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    final appVersion = _packageInfo.version;
    int versionCompare =
        appVersion.compareTo(updatedata!.data!.minVersion.toString());
    if (versionCompare < 0) {
      _checkVersion();
    } else {
      _loadWidget();
    }
  }

  void _checkVersion() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const ForceUpdate()),
        (Route<dynamic> route) => false);
  }

  _loadWidget() async {
    var duration = Duration(seconds: splashDelay);
    return Timer(duration, routeTOHomePage);
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Stack(
          children: [
            Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 1,
                child: Center(
                  child: Image.asset(
                    'assets/main/logo.png',
                    width: 200,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.red,
                      backgroundColor: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 10,),
                    Text(
                      _packageInfo.version=='Unknown'?'Connecting...':'Version ${_packageInfo.version}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        )
        : Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/noNetwork.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Text(
                    'No Network Found !',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    onTap: () {
                      getData();
                    },
                    child: SizedBox(
                      width: 120,
                      height: 35,
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Try Again',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }

  routeTOHomePage() async {
    String? token = await Common.getSharedPref("token");
    if (token != null) {
      LoginCheckModel loginCheck =
          await HttpService.loginCheck(token, firebaseToken);
      if (loginCheck.data == true) {
        if (mounted) {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Dashboard(token)));
        }
      } else {
        Common.toastMessaage('Token Expired', Colors.red);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false);
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      }
    }
  }
}
