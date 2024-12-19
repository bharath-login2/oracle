// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:login2/screens/authentication/login.dart';
import 'package:login2/screens/authentication/reset_password.dart';
import '../../core/common.dart';
import '../../models/sendOtpModel.dart';
import '../../service/service.dart';
import '../../widgets/size_config.dart';

class OtpScreen extends StatefulWidget {
  String? rno;
  String? mobileNo;

  OtpScreen(this.rno, this.mobileNo, {super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _fieldOne = TextEditingController();
  final TextEditingController _fieldTwo = TextEditingController();
  final TextEditingController _fieldThree = TextEditingController();
  final TextEditingController _fieldFour = TextEditingController();
  String? _otp;
  final bool isLoading = false;
  int secondsRemaining = 30;
  bool isResendButtonEnabled = false;
  Timer? _timer;
  String otpType = "WhatsApp";
  String genOtp = "";

  @override
  void initState() {
    super.initState();
    genOtp = widget.rno!;
    startTimer();
  }

  void startTimer() {
    setState(() {
      secondsRemaining = 30;
      isResendButtonEnabled = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          isResendButtonEnabled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void resendOTP() async {
    if (isResendButtonEnabled) {
      int min = 1000;
      int max = 9999;
      var randomizer = Random();
      var rNum = min + randomizer.nextInt(max - min);
      genOtp = rNum.toString();
      SendOtpModel otp = await HttpService.sendOtp(
          widget.mobileNo, rNum, otpType == "WhatsApp" ? "default" : "sms");
      if (otp.status == true) {
        Common.toastMessaage(otp.message, Colors.green);
      } else {
        Common.toastMessaage(otp.message, Colors.red);
      }
      startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (Route<dynamic> route) => false);
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 170),
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Image.asset(
                        'assets/main/logo.png',
                        width: 200,
                      ),
                    )),
                const Text(
                  "Enter OTP",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "OTP sent to your $otpType",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OtpInput(_fieldOne, true),
                      OtpInput(_fieldTwo, false),
                      OtpInput(_fieldThree, false),
                      OtpInput(_fieldFour, false)
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    setState(() {
                      _otp = _fieldOne.text +
                          _fieldTwo.text +
                          _fieldThree.text +
                          _fieldFour.text;
                    });
                    if (_otp == genOtp) {
                      Common.showProgressDialog(context, "Loading..");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ResetPassword(widget.mobileNo)),
                      );
                    } else {
                      Common.toastMessaage('Otp Not Match', Colors.red);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black),
                    child: Center(
                      child: isLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Text("Submit",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  isResendButtonEnabled
                      ? 'You can resend the OTP now.'
                      : 'Resend OTP in $secondsRemaining seconds',
                  style: const TextStyle(fontSize: 12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        otpType = "Phone";
                        setState(() {});
                        resendOTP();
                      },
                      child: Text(
                        otpType == "Phone" ? 'Resend OTP' : 'Send via SMS',
                        style: TextStyle(
                          color:
                              isResendButtonEnabled ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        otpType = "WhatsApp";
                        setState(() {});
                        resendOTP();
                      },
                      child: Text(
                        otpType == "WhatsApp"
                            ? 'Resend OTP'
                            : "Send via WhatsApp",
                        style: TextStyle(
                          color: isResendButtonEnabled
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 50,
      child: TextField(
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        controller: controller,
        maxLength: 1,
        cursorColor: Theme.of(context).primaryColor,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            counterText: '',
            hintStyle: TextStyle(color: Colors.black, fontSize: 20.0)),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
