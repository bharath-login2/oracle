import 'package:flutter/material.dart';
import '../../core/common.dart';
import '../../models/resetPasswordModel.dart';
import '../../service/service.dart';
import '../../widgets/size_config.dart';
import 'login.dart';


// ignore: must_be_immutable
class ResetPassword extends StatelessWidget {
  String? mobile;

  ResetPassword(this.mobile, {super.key});

  TextEditingController newPassword = TextEditingController();

  TextEditingController confirmPassword = TextEditingController();

  String? firebaseToken;

  final bool _loading = false;

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
                  margin: const EdgeInsets.only(top: 100),
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
                  child: SingleChildScrollView(
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
                                border:
                                    Border.all(color: Colors.white, width: 0),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      offset: Offset(1, 1)),
                                ],
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.email_outlined),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: TextFormField(
                                      maxLines: 1,
                                      obscureText: true,
                                      controller: newPassword,
                                      decoration: const InputDecoration(
                                        hintText: "New password",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Container(
                            width: double.infinity,
                            height: 60,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 0),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      offset: Offset(1, 1)),
                                ],
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.password_outlined),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: TextFormField(
                                      maxLines: 1,
                                      obscureText: true,
                                      controller: confirmPassword,
                                      decoration: const InputDecoration(
                                        hintText: "Confirm Password",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (newPassword.text.isEmpty) {
                              Common.toastMessaage(
                                  'New Password cannot be empty', Colors.red);
                            } else if (confirmPassword.text.isEmpty) {
                              Common.toastMessaage(
                                  'Confirm Password cannot be empty',
                                  Colors.red);
                            } else if (newPassword.text !=
                                confirmPassword.text) {
                              Common.toastMessaage(
                                  'Password Does Not Match', Colors.red);
                            } else {
                              ResetPasswordModel object =
                                  await HttpService.resetPassword(
                                      mobile, newPassword.text);

                              if (object.status == true) {
                                if (context.mounted) {
                                  Common.showProgressDialog(
                                      context, "Loading..");
                                }
                                if (context.mounted) {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) => const Login()),
                                      (Route<dynamic> route) => false);
                                }
                                Common.toastMessaage(
                                    'Password Change successfully',
                                    Colors.green);
                              } else {
                                Common.toastMessaage(
                                    'Password Not Changed', Colors.red);
                              }
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
                                      'Reset',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
