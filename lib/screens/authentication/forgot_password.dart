import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

import '../../core/common.dart';
import '../../models/sendOtpModel.dart';
import '../../models/verifyPhoneModel.dart';
import '../../service/service.dart';
import 'otp_screen.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool result = true;
  bool isLoading = false;
  String selectedCode = '+91';
  final formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumber = TextEditingController();

  sendOtp() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult is List<ConnectivityResult>) {
        if (connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi)) {
    // if (connectivityResult == ConnectivityResult.mobile ||
    //     connectivityResult == ConnectivityResult.wifi) {
      VerifyPhoneModel verify = await HttpService.verifyPhone(phoneNumber.text);
      if (verify.data == true) {
        int min = 1000;
        int max = 9999;
        var randomizer = Random();
        var rNum = min + randomizer.nextInt(max - min);
        SendOtpModel otp = await HttpService.sendOtp(phoneNumber.text, rNum,"default");

        if (otp.status == true) {
          if (mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OtpScreen(rNum.toString(), phoneNumber.text)));
          }
          Common.toastMessaage(otp.message, Colors.green);
        } else {
          Common.toastMessaage(otp.message, Colors.red);
        }
      } else {
        Common.toastMessaage('Phone Number Not Registered', Colors.red);
      }
      setState(() {
        result = true;
      });
    }} else {
      setState(() {
        result = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return result == true
        ? Scaffold(
            body: Center(
            child: Form(
              key: formKey,
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
                  const Text("Enter your phone number",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                      controller: phoneNumber,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Phone Number";
                        }
                        final phoneRegExp = RegExp(r'^\+?[1-9]\d{1,14}$');
                        if (!phoneRegExp.hasMatch(value)) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter Phone number',
                        contentPadding: const EdgeInsets.all(10),
                        border: const OutlineInputBorder(),
                        prefixIcon: GestureDetector(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode: true,
                              onSelect: (Country country) {
                                setState(() {
                                  selectedCode = '+${country.phoneCode}';
                                });
                              },
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            alignment: Alignment.center,
                            // decoration: BoxDecoration(
                            //     border: Border.all(),
                            //     borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              selectedCode,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: () async {
                      if (formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        sendOtp();
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
                            : const Text("Send Otp",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))
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
                      if (formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        sendOtp();
                      }
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
}
