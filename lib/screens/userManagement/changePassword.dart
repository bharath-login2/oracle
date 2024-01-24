import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/common.dart';
import '../../models/userManagement/changePasswordModel.dart';
import '../../screens/userManagement/viewUsers.dart';
import '../../service/service.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ChangePassword extends StatefulWidget {
  String token;
  String staffId;

  ChangePassword(this.token, this.staffId, {super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(MediaQuery.of(context).size.height * 0.08),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF2a86c9), Color(0xFF406dbe)]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, top: 10.0, bottom: 10.0, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 25,
                        width: 25,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            shape: BoxShape.circle),
                        child: const Icon(
                          Icons.arrow_back_ios_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 25,
                    ),
                    const Text(
                      'Change Password',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TextFormField(
                obscureText: true,
                controller: newPassword,
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(
                        left: 10, top: 10, bottom: 10),
                    labelText: 'New Password',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(
                        Icons.lock,
                        color: Colors.grey),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.grey),
                    ),
                    labelStyle: TextStyle(
                        color: Colors.grey)),
              )


            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: TextFormField(
                  obscureText: true,
                  controller: confirmPassword,
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.only(
                          left: 10, top: 10, bottom: 10),
                      labelText: 'Confirm Password',
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.grey),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.grey),
                      ),
                      labelStyle: TextStyle(
                          color: Colors.grey)),
                )


            ),

            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async {
                final connectivityResult =
                    await (Connectivity().checkConnectivity());
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  if (newPassword.text.isEmpty) {
                    Common.toastMessaage('Enter New Password', Colors.red);
                  } else if (newPassword.text != confirmPassword.text) {
                    Common.toastMessaage('Password does not match', Colors.red);
                  } else {
                    if(mounted) {
                      Common.showProgressDialog(context, "Loading..");
                    }
                    ChangePasswordModel changePassword =
                        await HttpService.changePassword(
                            widget.token, confirmPassword.text, widget.staffId);
                    if (changePassword.data == true) {
                      Common.toastMessaage(
                          changePassword.message, Colors.green);
                      if(mounted) {
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewUsers(widget.token)),
                      );
                      }
                    } else {
                      Common.toastMessaage(
                          changePassword.message, Colors.green);
                      if(mounted) {
                        Navigator.pop(context, true);
                      }
                    }
                  }
                } else {
                  setState(() {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('No Network Found..Try Again Later..'),
                        backgroundColor: Colors.redAccent,
                        elevation: 10,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.all(10),
                      ),
                    );
                  });
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('Submit',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
