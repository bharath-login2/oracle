import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:login2/screens/authentication/resetOtpPage.dart';
import '../../core/common.dart';
import '../../models/sendOtpModel.dart';
import '../../models/verifyPhoneModel.dart';
import '../../service/service.dart';
import '../../widgets/size_config.dart';

class ForgotPasswordNumber extends StatefulWidget {
  const ForgotPasswordNumber({super.key});

  @override
  State<ForgotPasswordNumber> createState() => _ForgotPasswordNumberState();
}

class _ForgotPasswordNumberState extends State<ForgotPasswordNumber> {
  TextEditingController phoneNumber = TextEditingController();
  final bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                // Colors.purple,
                Colors.lightBlueAccent.shade100,
                Colors.orange,
              ])),
          child: Column(
            children: [
              Container(
                  margin: const EdgeInsets.only(top: 200),
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: Image.asset(
                      'assets/main/logo.png',
                      width: 200,
                    ),
                  )),
              Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  margin: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Container(
                        // color: Colors.red,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 22, bottom: 20),

                        child: const Text(
                          "Reset Password",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 1,
                              fontFamily: "Lobster"),
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          height: 60,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 0),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    offset: Offset(1, 1)),
                              ],
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.phone_android),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: TextFormField(
                                    maxLines: 1,
                                    controller: phoneNumber,
                                    decoration: const InputDecoration(
                                      hintText: "Phone Number",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final connectivityResult =
                              await (Connectivity().checkConnectivity());
                          if (connectivityResult == ConnectivityResult.mobile ||
                              connectivityResult == ConnectivityResult.wifi) {
                            if (phoneNumber.text.isEmpty) {
                              Common.toastMessaage(
                                  'Phone Number cannot be empty', Colors.red);
                            } else {
                              VerifyPhoneModel verify =
                                  await HttpService.verifyPhone(
                                      phoneNumber.text);
                              if (verify.data == true) {
                                int min =
                                    1000; //min and max values act as your 6 digit range
                                int max = 9999;
                                var randomizer = Random();
                                var rNum = min + randomizer.nextInt(max - min);
                                SendOtpModel otp = await HttpService.sendOtp(
                                    phoneNumber.text, rNum);

                                if (otp.status == true) {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ResetOtpPage(
                                              rNum.toString(),
                                              phoneNumber.text)),
                                    );
                                  }

                                  Common.toastMessaage(
                                      otp.message, Colors.green);
                                } else {
                                  Common.toastMessaage(otp.message, Colors.red);
                                }
                              } else {
                                Common.toastMessaage(
                                    'Phone Number Not Registered', Colors.red);
                              }
                            }
                          } else {
                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'No Network Found..Try Again Later..'),
                                  backgroundColor: Colors.redAccent,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(10),
                                ),
                              );
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.black,
                            elevation: 15,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15))),
                        child: Ink(
                          decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [Colors.black, Colors.black]),
                              borderRadius: BorderRadius.circular(15)),
                          child: Container(
                            width: 200,
                            height: 50,
                            alignment: Alignment.center,
                            child: _loading == true
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Send OTP',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
